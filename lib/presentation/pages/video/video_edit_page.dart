import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:selfie_video_app/presentation/widgets/common/error_dialog.dart';
import 'package:video_editor_2/video_editor.dart';

class VideoEditPage extends StatefulWidget {
  final String videoPath;
  final Function(String, String) onVideoSaved;

  const VideoEditPage({
    Key? key,
    required this.videoPath,
    required this.onVideoSaved,
  }) : super(key: key);

  @override
  State<VideoEditPage> createState() => _VideoEditPageState();
}

class _VideoEditPageState extends State<VideoEditPage> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final _exportText = ValueNotifier<String>('');
  late VideoEditorController _controller;

  @override
  void initState() {
    super.initState();
    _initializeVideoEditor();
  }

  Future<void> _initializeVideoEditor() async {
    _controller = VideoEditorController.file(
      XFile(widget.videoPath),
      minDuration: const Duration(seconds: 1),
      maxDuration: const Duration(minutes: 10),
    );

    await _controller.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _exportText.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _exportVideo() async {
    _exportingProgress.value = 0;
    _isExporting.value = true;
    _exportText.value = 'Exporting video...';

    try {
      _isExporting.value = false;
      if (!mounted) return;
      String thumbPath = "";
     if (_controller.selectedCoverVal?.thumbData != null) {
        Uint8List thumbData = _controller.selectedCoverVal!.thumbData!;

        // Get temporary directory
        Directory tempDir = await getTemporaryDirectory();
        String filePath = '${tempDir.path}/thumb_image.png';

        // Write bytes to file
        File thumbFile = File(filePath);
        await thumbFile.writeAsBytes(thumbData);

        thumbPath = thumbFile.path;
      }
      widget.onVideoSaved(_controller.file.path, thumbPath);
    } catch (e) {
      _isExporting.value = false;
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(
          title: 'Export Error',
          message: 'Failed to export video: $e',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Video'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _exportVideo,
          ),
        ],
      ),
      body: _controller.initialized
          ? SafeArea(
            child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: DefaultTabController(
                          length: 2,
                          child: Column(
                            children: [
                              Expanded(
                                child: TabBarView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CropGridViewer.preview(
                                          controller: _controller,
                                        ),
                                        AnimatedBuilder(
                                          animation: _controller.video,
                                          builder: (_, __) => Opacity(
                                            opacity: !_controller.isPlaying ? 0 : 1,
                                            child: GestureDetector(
                                              onTap: _controller.video.play,
                                              child: Container(
                                                width: 40,
                                                height: 40,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(Icons.play_arrow),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    CoverViewer(controller: _controller),
                                  ],
                                ),
                              ),
                              Container(
                                height: 200,
                                margin: const EdgeInsets.only(top: 10),
                                child: Column(
                                  children: [
                                    const TabBar(
                                      tabs: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Icon(Icons.content_cut),
                                            ),
                                            Text('Trim')
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(5),
                                              child: Icon(Icons.video_label),
                                            ),
                                            Text('Cover')
                                          ],
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: TabBarView(
                                        physics: const NeverScrollableScrollPhysics(),
                                        children: [
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: TrimSlider(
                                                  controller: _controller,
                                                  height: 60,
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(5),
                                                    child: TextButton(
                                                      onPressed: () => _controller.rotate90Degrees(RotateDirection.left),
                                                      child: const Text('Rotate Left'),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.all(5),
                                                    child: TextButton(
                                                      onPressed: () => _controller.rotate90Degrees(RotateDirection.right),
                                                      child: const Text('Rotate Right'),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: CoverSelection(
                                                  controller: _controller,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  ValueListenableBuilder(
                    valueListenable: _isExporting,
                    builder: (_, bool export, __) => export
                        ? AlertDialog(
                            title: ValueListenableBuilder(
                              valueListenable: _exportText,
                              builder: (_, String text, __) => Text(text),
                            ),
                            content: ValueListenableBuilder(
                              valueListenable: _exportingProgress,
                              builder: (_, double value, __) => LinearProgressIndicator(value: value),
                            ),
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
          )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
