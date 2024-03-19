import 'dart:math';

import 'package:flutter/material.dart';

class InfiniteAnimation extends StatefulWidget {
  const InfiniteAnimation({super.key});

  @override
  State<InfiniteAnimation> createState() => _InfiniteAnimationState();
}

class _InfiniteAnimationState extends State<InfiniteAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat();

  late final Animation<double> _rotation = Tween<double>(
    begin: 0,
    end: 2 * pi,
  ).animate(_controller);

  late final Animation<double> _scale = Tween<double>(
    begin: 1,
    end: 2,
  ).animate(_controller);

  late final Animation<Color?> _color = ColorTween(
    begin: Colors.blue,
    end: Colors.red,
  ).animate(_controller);

  late final Animation<double> _opacity = Tween<double>(
    begin: 0.1,
    end: 1,
  ).animate(_controller);

  late final Animation<double> _shadow = Tween<double>(
    begin: 0,
    end: 10,
  ).animate(_controller);

  late final Animation<ShapeBorder?> _shape = ShapeBorderTween(
    begin: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
    end: const CircleBorder(),
  ).animate(_controller);

  late final Animation<double> _width = Tween<double>(
    begin: 50,
    end: 300,
  ).animate(_controller);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotation.value,
          child: Transform.scale(
            scale: _scale.value,
            child: Opacity(
              opacity: _opacity.value,
              child: Container(
                decoration: ShapeDecoration(
                  color: _color.value,
                  shape: _shape.value ?? Border.all(),
                  shadows: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      spreadRadius: _shadow.value,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                width: _width.value,
                height: 30,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}