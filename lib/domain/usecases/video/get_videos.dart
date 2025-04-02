import 'package:dartz/dartz.dart';
import 'package:selfie_video_app/core/errors/app_exceptions.dart';
import 'package:selfie_video_app/domain/entities/video.dart';
import 'package:selfie_video_app/domain/repositories/video_repository.dart';

class GetVideos {
  final VideoRepository repository;

  GetVideos(this.repository);

  Future<Either<AppException, List<Video>>> call() async {
    return await repository.getVideos();
  }
}

