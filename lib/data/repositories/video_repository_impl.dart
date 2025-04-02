import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:selfie_video_app/core/errors/app_exceptions.dart';
import 'package:selfie_video_app/data/datasources/local/video_local_datasource.dart';
import 'package:selfie_video_app/data/datasources/remote/video_remote_datasource.dart';
import 'package:selfie_video_app/data/models/video_model.dart';
import 'package:selfie_video_app/domain/entities/video.dart';
import 'package:selfie_video_app/domain/repositories/video_repository.dart';
import 'package:uuid/uuid.dart';

class VideoRepositoryImpl implements VideoRepository {
  final VideoRemoteDataSource remoteDataSource;
  final VideoLocalDataSource localDataSource;
  final Uuid _uuid = const Uuid();

  VideoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<AppException, List<Video>>> getVideos() async {
    try {
      final videos = await localDataSource.getVideos();
      return Right(videos);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(CacheException('Failed to get videos: $e'));
    }
  }

  @override
  Future<Either<AppException, Video>> createVideo({
    required String videoPath,
    required String title,
    required String description,
    required String teleprompterText,
    String? thumbnailPath,
  }) async {
    try {
      // Create video model
      final videoModel = VideoModel(
        id: _uuid.v4(),
        title: title,
        description: description,
        path: videoPath, // Temporary path, will be updated by saveVideo
        teleprompterText: teleprompterText,
        createdAt: DateTime.now(),
        thumbnailPath: thumbnailPath ?? '',
      );

      // Save video file and update model with permanent path
      final savedVideo = await localDataSource.saveVideo(
        videoModel,
        File(videoPath),
      );

      // Save thumbnail if provided
      if (thumbnailPath != null && thumbnailPath.isNotEmpty) {
        final thumbnailFile = File(thumbnailPath);
        final savedThumbnailPath = await localDataSource.saveThumbnail(thumbnailFile);

        // Update video with thumbnail path
        final updatedVideo = VideoModel(
          id: savedVideo.id,
          title: savedVideo.title,
          description: savedVideo.description,
          path: savedVideo.path,
          teleprompterText: savedVideo.teleprompterText,
          createdAt: savedVideo.createdAt,
          thumbnailPath: savedThumbnailPath,
        );

        return Right(await localDataSource.updateVideo(updatedVideo));
      }

      return Right(savedVideo);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(CacheException('Failed to create video: $e'));
    }
  }

  @override
  Future<Either<AppException, void>> deleteVideo(String videoId) async {
    try {
      // Delete from local storage
      await localDataSource.deleteVideo(videoId);

      // Try to delete from remote (this is mock and might fail)
      try {
        await remoteDataSource.deleteVideo(videoId);
      } catch (_) {
        // Ignore remote errors since we've already deleted locally
      }

      return const Right(null);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(CacheException('Failed to delete video: $e'));
    }
  }

  @override
  Future<Either<AppException, Video>> updateVideo(Video video) async {
    try {
      final videoModel = VideoModel.fromEntity(video);
      final updatedVideo = await localDataSource.updateVideo(videoModel);
      return Right(updatedVideo);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(CacheException('Failed to update video: $e'));
    }
  }
}
