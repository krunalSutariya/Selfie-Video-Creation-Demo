import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selfie_video_app/domain/entities/video.dart';
import 'package:selfie_video_app/domain/usecases/video/create_video.dart';
import 'package:selfie_video_app/domain/usecases/video/delete_video.dart';
import 'package:selfie_video_app/domain/usecases/video/get_videos.dart';

part 'video_event.dart';
part 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final GetVideos getVideos;
  final CreateVideo createVideo;
  final DeleteVideo deleteVideo;

  VideoBloc({
    required this.getVideos,
    required this.createVideo,
    required this.deleteVideo,
  }) : super(const VideoInitial()) {
    on<LoadVideosEvent>(_onLoadVideos);
    on<CreateVideoEvent>(_onCreateVideo);
    on<DeleteVideoEvent>(_onDeleteVideo);
  }

  Future<void> _onLoadVideos(LoadVideosEvent event, Emitter<VideoState> emit) async {
    emit(VideoLoading(videos: state.videos));
    
    final result = await getVideos();
    
    result.fold(
      (failure) => emit(VideoError(videos: state.videos, message: failure.message)),
      (videos) => emit(VideosLoaded(videos: videos)),
    );
  }

  Future<void> _onCreateVideo(CreateVideoEvent event, Emitter<VideoState> emit) async {
    emit(VideoLoading(videos: state.videos));
    
    final result = await createVideo(
      videoPath: event.videoPath,
      title: event.title,
      description: event.description,
      teleprompterText: event.teleprompterText,
      thumbnailPath: event.thumbnailPath,
    );
    
    result.fold(
      (failure) => emit(VideoError(videos: state.videos, message: failure.message)),
      (video) {
        final updatedVideos = List<Video>.from(state.videos)..add(video);
        emit(VideoCreated(videos: updatedVideos, createdVideo: video));
      },
    );
  }

  Future<void> _onDeleteVideo(DeleteVideoEvent event, Emitter<VideoState> emit) async {
    emit(VideoLoading(videos: state.videos));
    
    final result = await deleteVideo(event.videoId);
    
    result.fold(
      (failure) => emit(VideoError(videos: state.videos, message: failure.message)),
      (_) {
        final updatedVideos = List<Video>.from(state.videos)
          ..removeWhere((video) => video.id == event.videoId);
        emit(VideoDeleted(videos: updatedVideos, deletedVideoId: event.videoId));
      },
    );
  }
}

