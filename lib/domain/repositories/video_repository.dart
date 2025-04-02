import 'package:dartz/dartz.dart';
import 'package:selfie_video_app/core/errors/app_exceptions.dart';
import 'package:selfie_video_app/domain/entities/video.dart';

abstract class VideoRepository {
  Future<Either<AppException, List<Video>>> getVideos();

  Future<Either<AppException, Video>> createVideo({
    required String videoPath,
    required String title,
    required String description,
    required String teleprompterText,
    String? thumbnailPath,
  });

  Future<Either<AppException, void>> deleteVideo(String videoId);

  Future<Either<AppException, Video>> updateVideo(Video video);
}

