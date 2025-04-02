import 'package:flutter/material.dart';
import 'package:selfie_video_app/app.dart';
import 'package:selfie_video_app/core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await di.init();
  
  runApp(const App());
}

