import 'package:flutter/foundation.dart';

sealed class ImageState {
  final String url;

  ImageState(this.url);
}

class Loading extends ImageState {
  final double progress;

  Loading(super.url, this.progress);
}

class Result extends ImageState {
  final Uint8List image;

  Result(super.url, this.image);
}

class Error extends ImageState {
  final String message;

  Error(super.url, this.message);
}
