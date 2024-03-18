import 'package:download_image_isolate/imagenetwork/core/image_downloader.dart';
import 'package:download_image_isolate/imagenetwork/core/image_state.dart';

class ImageNetworkBloc {
  final _downloader = ImageDownloader.instance;

  Stream<ImageState> downLoadImage(String url){
    return _downloader.downLoadImage(url);
  }
}