import 'package:flutter/material.dart';
import 'package:selfie_video_app/domain/entities/video.dart';
import 'package:selfie_video_app/presentation/pages/auth/login_page.dart';
import 'package:selfie_video_app/presentation/pages/auth/register_page.dart';
import 'package:selfie_video_app/presentation/pages/dashboard/dashboard_page.dart';
import 'package:selfie_video_app/presentation/pages/splash_page.dart';
import 'package:selfie_video_app/presentation/pages/video/video_capture_page.dart';
import 'package:selfie_video_app/presentation/pages/video/video_detail_page.dart';
import 'package:selfie_video_app/presentation/pages/video/video_edit_page.dart';
import 'package:selfie_video_app/presentation/pages/video/video_share_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String videoCapture = '/video/capture';
  static const String videoEdit = '/video/edit';
  static const String videoDetail = '/video/detail';
  static const String videoShare = '/video/share';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      case videoCapture:
        return MaterialPageRoute(builder: (_) => const VideoCapturePageWrapper());
      case videoEdit:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => VideoEditPage(
            videoPath: args['videoPath'],
            onVideoSaved: args['onVideoSaved'],
          ),
        );
      case videoDetail:
        final video = settings.arguments as Video;
        return MaterialPageRoute(
          builder: (_) => VideoDetailPage(video: video),
        );
      case videoShare:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => VideoSharePage(
            videoPath: args['videoPath'],
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

class VideoCapturePageWrapper extends StatelessWidget {
  const VideoCapturePageWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const VideoCapturePageProvider();
  }
}
