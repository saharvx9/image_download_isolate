import 'package:download_image_isolate/imagenetwork/core/image_network_bloc.dart';
import 'package:download_image_isolate/imagenetwork/core/image_state.dart';
import 'package:flutter/material.dart';

class ConcurrencyImageNetwork extends StatefulWidget {
  final String url;

  const ConcurrencyImageNetwork({super.key, required this.url});

  @override
  State<ConcurrencyImageNetwork> createState() => _ConcurrencyImageNetworkState();
}

class _ConcurrencyImageNetworkState extends State<ConcurrencyImageNetwork> {
  final _bloc = ImageNetworkBloc();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ImageState>(
        stream: _bloc.downLoadImage(widget.url),
        initialData: Loading(widget.url, 0),
        builder: (context, snapshot) {
          final state = snapshot.data!;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.decelerate,
            switchOutCurve: Curves.decelerate,
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: switch (state) {
              Result(image: final image) => SizedBox.expand(
                  child: Image.memory(
                    image,
                    fit: BoxFit.fill,
                  ),
                ),
              Loading(progress: final progress) => Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      color: Colors.blue,
                    ),
                    Text("${(progress * 100).toStringAsFixed(0)}%")
                  ],
                ),
              Error(message: final message) => Text("Failed load image : $message"),
            },
          );
        });
  }
}
