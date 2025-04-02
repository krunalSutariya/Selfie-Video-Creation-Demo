import 'package:dartz/dartz.dart';
import 'package:selfie_video_app/core/errors/app_exceptions.dart';
import 'package:selfie_video_app/domain/entities/video.dart';
import 'package:selfie_video_app/domain/repositories/video_repository.dart';

class CreateVideo {
  final VideoRepository repository;

  CreateVideo(this.repository);

  Future<Either<AppException, Video>> call({
    required String videoPath,
    required String title,
    required String description,
    required String teleprompterText,
    String? thumbnailPath,
  }) async {
    return await repository.createVideo(
      videoPath: videoPath,
      title: title,
      description: description,
      teleprompterText: teleprompterText,
      thumbnailPath: thumbnailPath,
    );
  }
}

