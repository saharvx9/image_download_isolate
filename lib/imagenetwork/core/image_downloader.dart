import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:download_image_isolate/imagenetwork/core/image_state.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ImageDownloader {
  ImageDownloader._();

  static final instance = ImageDownloader._();
  static const _isolateName = "ImageDownloader";
  var _useIsolates = true;
  Completer? _completerInitIsolate;
  final _updatePort = ReceivePort();
  final _imagesMap = <String, ImageState>{};
  final _imagesStream = StreamController<Map<String, ImageState>>.broadcast();

  Future<void> _init() async {
    if (_completerInitIsolate?.isCompleted == true) return;
    if (_completerInitIsolate == null) {
      _completerInitIsolate = Completer();
    } else {
      await _completerInitIsolate!.future;
      return;
    }
    print("INIT");
    // Start the download manager isolate
    final receivePort = ReceivePort();
    await Isolate.spawn(_downloadImageIsolate, receivePort.sendPort);

    // Create a new port for receiving progress updates and completion data
    _updatePort.listen((state) {
      if (state is ImageState) {
        _updateState(state);
      }
    });
    final result = await receivePort.first;
    if (result == true) {
      _completerInitIsolate!.complete();
    }
  }

  void enableIsolates(bool enable) {
    _useIsolates = enable;
  }

  void clear() {
    _imagesMap.clear();
  }

  void _updateState(ImageState state) {
    _imagesMap[state.url] = state;
    _imagesStream.add(_imagesMap);
  }

  Stream<ImageState> downLoadImage(String url) async* {
    if (_useIsolates) {
      await _init();

      // Use the IsolateNameServer to find the download manager's port
      final managerPort = IsolateNameServer.lookupPortByName(_isolateName);
      if (managerPort != null) {
        // Send a new download task
        managerPort.send({'url': url, 'port': _updatePort.sendPort});
        // You can send more tasks to the same manager at any time
      } else {
        print('$_isolateName not found.');
        throw ArgumentError("$_isolateName not found.");
      }
    } else {
      _downloadImageRegular(url);
    }
    yield* _imagesStream.stream.map((event) => event[url] ?? Loading(url, 0));
  }

  void _downloadImageRegular(String url) async {
    final httpClient = http.Client();
    final request = http.Request('GET', Uri.parse(url));
    final response = await httpClient.send(request);
    List<int> bytes = [];
    response.stream.listen((List<int> chunk) {
        // Update progress
        bytes.addAll(chunk);
        final progress = bytes.length / response.contentLength!;
        _updateState(Loading(url, progress));
      },
      onError: (e, s) {
        _updateState(Error(url, "$e"));
      },
      onDone: () {
        _updateState(Result(url, Uint8List.fromList(bytes)));
      },
      cancelOnError: true,
    );
  }

  static void _downloadImageIsolate(SendPort sendPort) {
    // Create a receive port to listen for download tasks
    final taskPort = ReceivePort();

    // Register this port with the IsolateNameServer so it can be found by the main isolate
    IsolateNameServer.registerPortWithName(taskPort.sendPort, _isolateName);
    // Notify send port for finish register port with nam
    sendPort.send(true);

    // Listen for incoming download tasks
    taskPort.listen((message) async {
      if (message is Map) {
        final url = message['url'] as String;
        final replyTo = message['port'] as SendPort;

        // Start the download
        final httpClient = http.Client();
        final request = http.Request('GET', Uri.parse(url));
        final response = await httpClient.send(request);

        List<int> bytes = [];
        response.stream.listen(
          (List<int> chunk) {
            // Update progress
            bytes.addAll(chunk);
            final progress = bytes.length / response.contentLength!;
            replyTo.send(Loading(url, progress));
          },
          onError: (e, s) {
            replyTo.send(e);
          },
          onDone: () {
            // Send the completed data
            replyTo.send(Result(url, Uint8List.fromList(bytes)));
          },
          cancelOnError: true,
        );
      }
    });
  }
}
