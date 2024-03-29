import 'package:download_image_isolate/utils/fps_counter.dart';
import 'package:download_image_isolate/imagenetwork/concurrency_image_netowrk.dart';
import 'package:download_image_isolate/imagenetwork/core/image_downloader.dart';
import 'package:download_image_isolate/widgets/infinite_animation.dart';
import 'package:download_image_isolate/local_images.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _images = <String>[];
  var _useIsolates = true;
  final _fpsCounter = FPSCounter();

  void _clear() {
    ImageDownloader.instance.clear();
    setState(() {
      _images.clear();
    });
    _fpsCounter.stop();
  }

  void _changeDownloadType() {
    _useIsolates = !_useIsolates;
    ImageDownloader.instance.enableIsolates(_useIsolates);
    setState(() {});
  }

  void _fill() {
    _fpsCounter.start();
    _images.clear();
    setState(() {
      _images.addAll(images);
    });
  }

  @override
  void initState() {
    _fpsCounter.init();
    super.initState();
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: StreamBuilder<FpsData>(
                stream: _fpsCounter.fpsState.stream,
                initialData: FpsData(0, 0),
                builder: (context, snapshot) {
                  final state = snapshot.data!;
                  return Text(
                      "Current FPS: ${state.fps.toStringAsFixed(2)}, Average FPS: ${state.averageFPS.toStringAsFixed(2)}");
                }),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: InfiniteAnimationWidget(),
          ),
          Expanded(
            child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4, crossAxisSpacing: 2, mainAxisSpacing: 2),
                padding: EdgeInsets.zero,
                itemCount: _images.length,
                itemBuilder: (_, index) => ConcurrencyImageNetwork(key: ValueKey(_images[index]), url: _images[index])),
          ),
        ],
      ),
    );
  }
}
