
import 'dart:async';

import 'package:flutter/scheduler.dart';

class FpsData {
  final double fps;
  final double averageFPS;

  FpsData(this.fps, this.averageFPS);
}

class FPSCounter {
  int _frameCount = 0;
  double _totalFPS = 0;
  int _fpsCount = 0;
  Duration _startTime = Duration.zero;
  bool _shouldDoWork = false;
  final fpsState = StreamController<FpsData>.broadcast();

  void init() {
    SchedulerBinding.instance.addPersistentFrameCallback((timeStamp) {
      if (!_shouldDoWork) return;
      if (_startTime == Duration.zero) {
        _startTime = timeStamp;
      }

      _frameCount++;

      final elapsed = timeStamp - _startTime;

      if (elapsed > const Duration(seconds: 1)) {
        double fps = _frameCount / elapsed.inSeconds;
        _totalFPS += fps;
        _fpsCount++;
        double averageFPS = _totalFPS / _fpsCount;
        _startTime = timeStamp;
        _frameCount = 0;
        print('Current FPS: $fps, Average FPS: $averageFPS');
        fpsState.add(FpsData(fps, averageFPS));
      }
    });
  }

  void start() {
    _shouldDoWork = true;
  }

  void stop() {
    _shouldDoWork = false;
    _totalFPS = 0;
    _fpsCount = 0;
    fpsState.add(FpsData(0, 0));
  }
}

