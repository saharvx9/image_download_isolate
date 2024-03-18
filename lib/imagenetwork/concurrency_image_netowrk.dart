import 'package:download_image_isolate/imagenetwork/core/image_network_bloc.dart';
import 'package:download_image_isolate/imagenetwork/core/image_state.dart';
import 'package:flutter/material.dart';

class ConcurrencyImageNetwork extends StatefulWidget {
  final String url;
  final double size;

  const ConcurrencyImageNetwork({super.key, required this.url, this.size = 20.0});

  @override
  State<ConcurrencyImageNetwork> createState() => _ConcurrencyImageNetworkState();
}

class _ConcurrencyImageNetworkState extends State<ConcurrencyImageNetwork> {
  final _bloc = ImageNetworkBloc();

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Size.fromRadius(widget.size),
      child: StreamBuilder<ImageState>(
          stream: _bloc.downLoadImage(widget.url),
          initialData: Loading(widget.url, 0),
          builder: (context, snapshot) {
            final state = snapshot.data!;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: ClipOval(child: SizedBox.fromSize(size: Size.fromRadius(widget.size), child: child)),
              ),
              child: switch (state) {
                Result(image: final image) => Image.memory(
                    image,
                    fit: BoxFit.cover,
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
          }),
    );
  }
}
