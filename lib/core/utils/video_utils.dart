import 'dart:io';

import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class VideoUtils {
  static const uuid = Uuid();

  static Future<String> getTemporaryFilePath(String extension) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${tempDir.path}/$timestamp$extension';
  }

  static Future<String> getPermanentFilePath(String fileName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final videoDir = Directory('${appDir.path}/Videos');
    if (!await videoDir.exists()) {
      await videoDir.create(recursive: true);
    }
    return '${videoDir.path}/$fileName';
  }

  static Future<String> getThumbnailPath(String fileName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final thumbnailDir = Directory('${appDir.path}/Thumbnails');
    if (!await thumbnailDir.exists()) {
      await thumbnailDir.create(recursive: true);
    }
    return '${thumbnailDir.path}/$fileName';
  }

  static Future<String> generateThumbnail(String videoPath) async {
    final directory = await getTemporaryDirectory();
    final thumbnailPath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: thumbnailPath,
        maxHeight: 200,
        quality: 75,
      );
      return thumbnail.path;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return '';
    }
  }

  static Future<File> copyFileToStorage(File sourceFile, String destinationPath) async {
    return await sourceFile.copy(destinationPath);
  }

  static String generateUniqueFileName(String extension) {
    return '${uuid.v4()}$extension';
  }

  static String getFileExtension(String path) {
    return path.substring(path.lastIndexOf('.'));
  }

  static Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
