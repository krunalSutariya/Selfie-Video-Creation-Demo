import 'package:selfie_video_app/domain/entities/video.dart';

class VideoModel extends Video {
  const VideoModel({
    required super.id,
    required super.title,
    required super.description,
    required super.path,
    required super.teleprompterText,
    required super.createdAt,
    super.thumbnailPath = '',
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      path: json['path'],
      teleprompterText: json['teleprompterText'],
      createdAt: DateTime.parse(json['createdAt']),
      thumbnailPath: json['thumbnailPath'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'path': path,
      'teleprompterText': teleprompterText,
      'createdAt': createdAt.toIso8601String(),
      'thumbnailPath': thumbnailPath,
    };
  }

  factory VideoModel.fromEntity(Video video) {
    return VideoModel(
      id: video.id,
      title: video.title,
      description: video.description,
      path: video.path,
      teleprompterText: video.teleprompterText,
      createdAt: video.createdAt,
      thumbnailPath: video.thumbnailPath,
    );
  }
}

