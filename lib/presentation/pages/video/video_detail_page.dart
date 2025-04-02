import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selfie_video_app/config/app_routes.dart';
import 'package:selfie_video_app/domain/entities/video.dart';
import 'package:selfie_video_app/presentation/bloc/video/video_bloc.dart';
import 'package:selfie_video_app/presentation/widgets/common/app_button.dart';
import 'package:selfie_video_app/presentation/widgets/common/confirmation_dialog.dart';
import 'package:selfie_video_app/presentation/widgets/video/video_player_widget.dart';

class VideoDetailPage extends StatelessWidget {
  final Video video;

  const VideoDetailPage({
    Key? key,
    required this.video,
  }) : super(key: key);

  void _deleteVideo(BuildContext context) {
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
          context.read<VideoBloc>().add(DeleteVideoEvent(videoId: video.id));
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _shareVideo(BuildContext context) {
    Navigator.of(context).pushNamed(
      AppRoutes.videoShare,
      arguments: {
        'videoPath': video.path,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(video.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteVideo(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                VideoPlayerWidget(
                  videoPath: video.path,
                  autoPlay: true,
                  looping: true,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      video.title.isEmpty
                          ? const SizedBox.shrink()
                          : Text(
                              video.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      const SizedBox(height: 8),
                      Text(
                        'Created on ${video.createdAt.day}/${video.createdAt.month}/${video.createdAt.year}',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (video.description.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(video.description),
                            const SizedBox(height: 16),
                          ],
                        ),
                      if (video.teleprompterText.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Teleprompter Script',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                video.teleprompterText,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AppButton(
                            text: 'Edit',
                            icon: Icons.edit,
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.videoEdit,
                                arguments: {
                                  'videoPath': video.path,
                                  'onVideoSaved': (String editedVideoPath, String thumbnailPath) {},
                                },
                              );
                            },
                          ),
                          AppButton(
                            text: 'Share',
                            icon: Icons.share,
                            onPressed: () => _shareVideo(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
