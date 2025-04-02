part of 'video_bloc.dart';

abstract class VideoEvent extends Equatable {
  const VideoEvent();

  @override
  List<Object?> get props => [];
}

class LoadVideosEvent extends VideoEvent {}

class CreateVideoEvent extends VideoEvent {
  final String videoPath;
  final String title;
  final String description;
  final String teleprompterText;
  final String? thumbnailPath;

  const CreateVideoEvent({
    required this.videoPath,
    required this.title,
    required this.description,
    required this.teleprompterText,
    this.thumbnailPath,
  });

  @override
  List<Object?> get props => [videoPath, title, description, teleprompterText, thumbnailPath];
}

class DeleteVideoEvent extends VideoEvent {
  final String videoId;

  const DeleteVideoEvent({required this.videoId});

  @override
  List<Object?> get props => [videoId];
}

