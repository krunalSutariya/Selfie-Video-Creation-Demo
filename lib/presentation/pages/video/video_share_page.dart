import 'package:flutter/material.dart';
import 'package:selfie_video_app/presentation/widgets/common/app_button.dart';
import 'package:selfie_video_app/presentation/widgets/common/error_dialog.dart';
import 'package:selfie_video_app/presentation/widgets/video/video_player_widget.dart';
import 'package:share_plus/share_plus.dart';

class VideoSharePage extends StatefulWidget {
  final String videoPath;

  const VideoSharePage({
    Key? key,
    required this.videoPath,
  }) : super(key: key);

  @override
  State<VideoSharePage> createState() => _VideoSharePageState();
}

class _VideoSharePageState extends State<VideoSharePage> {
  bool _isSharing = false;

  Future<void> _shareVideo(String platform) async {
    setState(() {
      _isSharing = true;
    });

    try {
      // In a real app, you would use platform-specific sharing SDKs
      // For this demo, we'll use the share_plus package for general sharing

      String message;
      switch (platform) {
        case 'facebook':
          message = 'Check out my new video on Facebook!';
          break;
        case 'instagram':
          message = 'Check out my new video on Instagram!';
          break;
        case 'tiktok':
          message = 'Check out my new video on TikTok!';
          break;
        default:
          message = 'Check out my new video!';
      }

      await Share.shareXFiles(
        [XFile(widget.videoPath)],
        text: message,
      );
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            title: 'Sharing Error',
            message: 'Failed to share video: $e',
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Video'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VideoPlayerWidget(
              videoPath: widget.videoPath,
              autoPlay: false,
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Share to Social Media',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // const SizedBox(height: 24),
                  // _buildSocialMediaButton(
                  //   icon: Icons.facebook,
                  //   color: Colors.blue.shade800,
                  //   label: 'Facebook',
                  //   onPressed: () => _shareVideo('facebook'),
                  // ),
                  // const SizedBox(height: 16),
                  // _buildSocialMediaButton(
                  //   icon: Icons.camera_alt,
                  //   color: Colors.pink,
                  //   label: 'Instagram',
                  //   onPressed: () => _shareVideo('instagram'),
                  // ),
                  // const SizedBox(height: 16),
                  // _buildSocialMediaButton(
                  //   icon: Icons.music_note,
                  //   color: Colors.black,
                  //   label: 'TikTok',
                  //   onPressed: () => _shareVideo('tiktok'),
                  // ),
                  const SizedBox(height: 24),
                  AppButton(
                    text: 'Share to Other Apps',
                    icon: Icons.share,
                    onPressed: _isSharing ? null : () => _shareVideo('other'),
                    width: double.infinity,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onPressed,
  }) {
    return AppButton(
      text: label,
      icon: icon,
      onPressed: _isSharing ? null : onPressed,
      type: AppButtonType.secondary,
      width: double.infinity,
    );
  }
}
