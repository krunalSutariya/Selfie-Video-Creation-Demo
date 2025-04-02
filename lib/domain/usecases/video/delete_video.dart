import 'package:dartz/dartz.dart';
import 'package:selfie_video_app/core/errors/app_exceptions.dart';
import 'package:selfie_video_app/domain/repositories/video_repository.dart';

class DeleteVideo {
  final VideoRepository repository;

  DeleteVideo(this.repository);

  Future<Either<AppException, void>> call(String videoId) async {
    return await repository.deleteVideo(videoId);
  }
}

