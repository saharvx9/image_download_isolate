import 'package:download_image_isolate/imagenetwork/concurrency_image_netowrk.dart';
import 'package:download_image_isolate/imagenetwork/core/image_downloader.dart';
import 'package:download_image_isolate/local_images.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _images = <String>[];
  var _useIsolates = true;

  void _clear() {
    ImageDownloader.instance.clear();
    setState(() {
      _images.clear();
    });
  }

  void _changeDownloadType() {
    _useIsolates = !_useIsolates;
    ImageDownloader.instance.enableIsolates(_useIsolates);
    setState(() {});
  }

  void _fill() {
    _images.clear();
    setState(() {
      _images.addAll(images);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Isolates test"),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: _fill,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.black),
                  child: const Text("Fill")),
              ElevatedButton(onPressed: _changeDownloadType, child: Text("Isolate : $_useIsolates")),
              ElevatedButton(
                  onPressed: _clear,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.black),
                  child: const Text("Clear")),
            ],
          ),
          Expanded(
            child: ListView.builder(
                itemCount: _images.length,
                itemBuilder: (_, index) => ListTile(
                      leading: ConcurrencyImageNetwork(url: _images[index]),
                      title: Text("Link num : ${index + 1}"),
                      subtitle: Text(_images[index]),
                    )),
          ),
        ],
      ),
    );
  }
}
