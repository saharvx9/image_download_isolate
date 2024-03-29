import 'package:flutter/material.dart';

class InfiniteAnimationWidget extends StatefulWidget {
  const InfiniteAnimationWidget({super.key});

  @override
  State<InfiniteAnimationWidget> createState() => _InfiniteAnimationWidgetState();
}

class _InfiniteAnimationWidgetState extends State<InfiniteAnimationWidget> with TickerProviderStateMixin {
  late final _animationController = AnimationController(duration: const Duration(seconds: 3), vsync: this)
    ..repeat(reverse: true);
  late final _borderAnimation = BorderRadiusTween(begin: BorderRadius.circular(100.0), end: BorderRadius.circular(0.0))
      .animate(_animationController);
  late final _logoTransition = Tween<Offset>(
    begin: const Offset(0.7, 0.0),
    end: const Offset(-0.7, 0.0),
  ).animate(_animationController);

  late final _scaleAnimationSequence = TweenSequence(
    <TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.2, end: 1.0),
        weight: 50.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 0.2),
        weight: 50.0,
      ),
    ],
  ).animate(_animationController);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _borderAnimation,
        builder: (context, child) {
          return Container(
            alignment: Alignment.bottomCenter,
            width: 350,
            height: 150,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                colors: [
                  Colors.blueAccent,
                  Colors.redAccent,
                ],
              ),
              borderRadius: _borderAnimation.value,
            ),
            child: SlideTransition(
              position: _logoTransition,
              child: ScaleTransition(
                scale: _scaleAnimationSequence,
                child: const FlutterLogo(
                  size: 200,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
