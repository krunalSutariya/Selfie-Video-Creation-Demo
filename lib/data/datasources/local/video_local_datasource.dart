import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:selfie_video_app/core/errors/app_exceptions.dart';
import 'package:selfie_video_app/core/utils/video_utils.dart';
import 'package:selfie_video_app/data/models/video_model.dart';

abstract class VideoLocalDataSource {
  Future<List<VideoModel>> getVideos();
  Future<VideoModel?> getVideoById(String id);
  Future<VideoModel> saveVideo(VideoModel video, File videoFile);
  Future<void> deleteVideo(String id);
  Future<VideoModel> updateVideo(VideoModel video);
  Future<String> saveThumbnail(File thumbnailFile);
}

class VideoLocalDataSourceImpl implements VideoLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String videosKey = 'CACHED_VIDEOS';

  VideoLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<VideoModel>> getVideos() async {
    try {
      final jsonString = sharedPreferences.getString(videosKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.map((json) => VideoModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw CacheException('Failed to get cached videos: $e');
    }
  }

  @override
  Future<VideoModel?> getVideoById(String id) async {
    try {
      final videos = await getVideos();
      return videos.firstWhere((video) => video.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<VideoModel> saveVideo(VideoModel video, File videoFile) async {
    try {
      // Save video file to permanent storage
      final fileName = VideoUtils.generateUniqueFileName(
        VideoUtils.getFileExtension(videoFile.path),
      );
      final destinationPath = await VideoUtils.getPermanentFilePath(fileName);
      final savedFile = await VideoUtils.copyFileToStorage(videoFile, destinationPath);
      
      // Create updated video model with new path
      final updatedVideo = VideoModel(
        id: video.id,
        title: video.title,
        description: video.description,
        path: savedFile.path,
        teleprompterText: video.teleprompterText,
        createdAt: video.createdAt,
        thumbnailPath: video.thumbnailPath,
      );
      
      // Save to shared preferences
      final videos = await getVideos();
      videos.add(updatedVideo);
      await _saveVideos(videos);
      
      return updatedVideo;
    } catch (e) {
      throw CacheException('Failed to save video: $e');
    }
  }

  @override
  Future<void> deleteVideo(String id) async {
    try {
      final videos = await getVideos();
      if (videos.isNotEmpty) {
        
     
      final videoToDelete = videos.firstWhere((video) => video.id == id);
      
      // Delete video file
      await VideoUtils.deleteFile(videoToDelete.path);
      
      // Delete thumbnail if exists
      if (videoToDelete.thumbnailPath.isNotEmpty) {
        await VideoUtils.deleteFile(videoToDelete.thumbnailPath);
      }
      
      // Remove from list and save
      videos.removeWhere((video) => video.id == id);
      await _saveVideos(videos);
      }
    } catch (e) {
      throw CacheException('Failed to delete video: $e');
    }
  }

  @override
  Future<VideoModel> updateVideo(VideoModel video) async {
    try {
      final videos = await getVideos();
      final index = videos.indexWhere((v) => v.id == video.id);
      
      if (index != -1) {
        videos[index] = video;
        await _saveVideos(videos);
        return video;
      } else {
        throw CacheException('Video not found');
      }
    } catch (e) {
      throw CacheException('Failed to update video: $e');
    }
  }

  @override
  Future<String> saveThumbnail(File thumbnailFile) async {
    try {
      final fileName = VideoUtils.generateUniqueFileName('.jpg');
      final destinationPath = await VideoUtils.getThumbnailPath(fileName);
      final savedFile = await VideoUtils.copyFileToStorage(thumbnailFile, destinationPath);
      return savedFile.path;
    } catch (e) {
      throw CacheException('Failed to save thumbnail: $e');
    }
  }

  Future<void> _saveVideos(List<VideoModel> videos) async {
    final jsonString = json.encode(
      videos.map((video) => video.toJson()).toList(),
    );
    await sharedPreferences.setString(videosKey, jsonString);
  }
}

