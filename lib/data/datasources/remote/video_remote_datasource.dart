import 'dart:math';
import 'package:selfie_video_app/core/errors/app_exceptions.dart';

abstract class VideoRemoteDataSource {
  Future<void> deleteVideo(String id);
}

class VideoRemoteDataSourceImpl implements VideoRemoteDataSource {
  final Random _random = Random();

  @override
  Future<void> deleteVideo(String id) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(700)));
    
    // Simulate random errors (5% chance)
    if (_random.nextInt(20) == 0) {
      final errorType = _random.nextInt(3);
      if (errorType == 0) {
        throw ServerException('Video not found', 404);
      } else if (errorType == 1) {
        throw ServerException('Server unavailable. Please try again later.', 503);
      } else {
        throw ServerException('Internal server error. Please try again later.', 500);
      }
    }
    
    // In a real app, this would make an API call to delete the video
    return;
  }
}

