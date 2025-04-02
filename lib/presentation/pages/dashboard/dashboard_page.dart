import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selfie_video_app/config/app_routes.dart';
import 'package:selfie_video_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:selfie_video_app/presentation/bloc/video/video_bloc.dart';
import 'package:selfie_video_app/presentation/widgets/common/app_button.dart';
import 'package:selfie_video_app/presentation/widgets/common/confirmation_dialog.dart';
import 'package:selfie_video_app/presentation/widgets/common/error_dialog.dart';
import 'package:selfie_video_app/presentation/widgets/video/video_item.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  void _loadVideos() {
    context.read<VideoBloc>().add(LoadVideosEvent());
  }

  void _deleteVideo(String videoId) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Delete Video',
        message: 'Are you sure you want to delete this video? This action cannot be undone.',
        confirmText: 'Delete',
        cancelText: 'Cancel',
        isDangerous: true,
        onConfirm: () {
          Navigator.of(context).pop();
          context.read<VideoBloc>().add(DeleteVideoEvent(videoId: videoId));
        },
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Logout',
        message: 'Are you sure you want to logout?',
        confirmText: 'Logout',
        cancelText: 'Cancel',
        onConfirm: () {
          Navigator.of(context).pop();
          context.read<AuthBloc>().add(LogoutEvent());
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox.shrink(),
        title: const Text('My Videos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: BlocConsumer<VideoBloc, VideoState>(
        listener: (context, state) {
          if (state is VideoError) {
            showDialog(
              context: context,
              builder: (context) => ErrorDialog(
                title: 'Error',
                message: state.message,
              ),
            );
          } else if (state is VideoDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Video deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is VideoLoading && state.videos.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final videos = state.videos;

          if (videos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.videocam_off,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No videos yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create your first selfie video',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Create New Video',
                    icon: Icons.add,
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.videoCapture);
                    },
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadVideos();
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 9 / 16,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return VideoItem(
                  video: video,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.videoDetail,
                      arguments: video,
                    );
                  },
                  onDelete: () => _deleteVideo(video.id),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.videoCapture);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
