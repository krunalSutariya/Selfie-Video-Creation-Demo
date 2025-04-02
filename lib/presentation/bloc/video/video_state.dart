part of 'video_bloc.dart';

abstract class VideoState extends Equatable {
  final List<Video> videos;
  
  const VideoState({required this.videos});
  
  @override
  List<Object?> get props => [videos];
}

class VideoInitial extends VideoState {
  const VideoInitial() : super(videos: const []);
}

class VideoLoading extends VideoState {
  const VideoLoading({required super.videos});
}

class VideosLoaded extends VideoState {
  const VideosLoaded({required super.videos});
}

class VideoCreated extends VideoState {
  final Video createdVideo;
  
  const VideoCreated({
    required super.videos,
    required this.createdVideo,
  });
  
  @override
  List<Object?> get props => [videos, createdVideo];
}

class VideoDeleted extends VideoState {
  final String deletedVideoId;
  
  const VideoDeleted({
    required super.videos,
    required this.deletedVideoId,
  });
  
  @override
  List<Object?> get props => [videos, deletedVideoId];
}

class VideoError extends VideoState {
  final String message;
  
  const VideoError({
    required super.videos,
    required this.message,
  });
  
  @override
  List<Object?> get props => [videos, message];
}

