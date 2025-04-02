import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:selfie_video_app/config/app_routes.dart';
import 'package:selfie_video_app/domain/entities/video.dart';
import 'package:selfie_video_app/presentation/widgets/common/error_dialog.dart';
import 'package:selfie_video_app/presentation/widgets/teleprompter/teleprompter_widget.dart';
import 'package:uuid/uuid.dart';

import '../../bloc/video/video_bloc.dart';

class VideoCapturePageProvider extends StatefulWidget {
  const VideoCapturePageProvider({Key? key}) : super(key: key);

  @override
  State<VideoCapturePageProvider> createState() => _VideoCapturePageProviderState();
}

class _VideoCapturePageProviderState extends State<VideoCapturePageProvider> {
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _initCameras();
  }

  Future<void> _initCameras() async {
    try {
      final cameras = await availableCameras();
      setState(() {
        _cameras = cameras;
      });
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            title: 'Camera Error',
            message: 'Failed to initialize camera: $e',
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameras == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_cameras!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Record Video'),
        ),
        body: const Center(
          child: Text('No cameras found on this device'),
        ),
      );
    }

    return VideoCapturePage(cameras: _cameras!);
  }
}

class VideoCapturePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const VideoCapturePage({
    Key? key,
    required this.cameras,
  }) : super(key: key);

  @override
  State<VideoCapturePage> createState() => _VideoCapturePageState();
}

class _VideoCapturePageState extends State<VideoCapturePage> with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isFrontCamera = true;
  bool _isRecording = false;
  bool _isInitialized = false;
  bool _isTeleprompterVisible = false;
  String _teleprompterText = '';
  final TextEditingController _textController = TextEditingController();
  double _teleprompterSpeed = 0.5; // Default speed
  final TeleprompterController _teleprompterController = TeleprompterController();
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _textController.text = '''Lorem Ipsum
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla facilisi. Fusce varius, purus eget tincidunt cursus, nisi odio laoreet neque, in vestibulum sapien justo nec risus. Curabitur id ligula vel enim suscipit pellentesque. Donec ut lacus nec erat scelerisque facilisis.

Suspendisse potenti. Vivamus euismod, nunc et tempus volutpat, risus justo fermentum tortor, at gravida lacus metus a ligula. Phasellus consectetur, velit a varius blandit, neque lorem cursus tortor, nec vehicula lacus sapien nec sapien. Aenean gravida feugiat mauris, nec faucibus turpis hendrerit vel.''';
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _textController.dispose();
    _teleprompterController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final frontCamera = widget.cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => widget.cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to initialize camera: $e');
    }
  }

  void _showErrorDialog(String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(
          title: 'Camera Error',
          message: message,
        ),
      );
    }
  }

  Future<void> _toggleCamera() async {
    if (widget.cameras.length < 2) return;

    final lensDirection = _cameraController!.description.lensDirection;
    CameraDescription newCamera;

    if (lensDirection == CameraLensDirection.front) {
      newCamera = widget.cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
    } else {
      newCamera = widget.cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
    }

    await _cameraController!.dispose();

    _cameraController = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isFrontCamera = newCamera.lensDirection == CameraLensDirection.front;
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to switch camera: $e');
    }
  }

  Future<void> _toggleRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_isRecording) {
      try {
        final XFile? videoFile = await _cameraController?.stopVideoRecording();
        setState(() {
          _isRecording = false;
        });

        if (_isTeleprompterVisible) {
          _teleprompterController.pause();
        }

        if (mounted) {
          Navigator.of(context).pushNamed(
            AppRoutes.videoEdit,
            arguments: {
              'videoPath': videoFile?.path,
              'onVideoSaved': (String editedVideoPath, String thumbnailPath) async {
                context.read<VideoBloc>().add(CreateVideoEvent(
                    thumbnailPath: thumbnailPath,
                    description: "",
                    title: "",
                    teleprompterText: _teleprompterText,
                    videoPath: editedVideoPath));

                Navigator.of(context).pushReplacementNamed(AppRoutes.videoDetail,
                    arguments: Video(
                        id: _uuid.v4(),
                        title: "",
                        description: "",
                        path: editedVideoPath,
                        teleprompterText: _teleprompterText,
                        createdAt: DateTime.now()));
              },
            },
          );
        }
      } catch (e) {
        _showErrorDialog('Failed to stop recording: $e');
      }
    } else {
      try {
        await _cameraController!.startVideoRecording();

        setState(() {
          _isRecording = true;
        });

        if (_isTeleprompterVisible) {
          _teleprompterController.play();
        }
      } catch (e) {
        _showErrorDialog('Failed to start recording: $e');
      }
    }
  }

  void _showTeleprompterDialog() {
    // Create a temporary variable to hold the new speed value
    double tempSpeed = _teleprompterSpeed;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        // Use StatefulBuilder to manage dialog state
        builder: (context, setDialogState) {
          // This is a separate setState function just for the dialog
          return AlertDialog(
            title: const Text('Teleprompter Text'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _textController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Enter your script here...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Speed:'),
                    Expanded(
                      child: Slider(
                        value: tempSpeed, // Use the temporary variable here
                        min: 0.1,
                        max: 1.0,
                        divisions: 9,
                        label: (tempSpeed * 10).round().toString(),
                        onChanged: (value) {
                          // Use the dialog's setState to update the slider in real-time
                          setDialogState(() {
                            tempSpeed = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  // Use the parent widget's setState to update the actual state
                  setState(() {
                    _teleprompterText = _textController.text;
                    _teleprompterSpeed = tempSpeed; // Apply the temporary speed value
                    _teleprompterController.setSpeed(_teleprompterSpeed);
                    _isTeleprompterVisible = _teleprompterText.isNotEmpty;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _cameraController == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Record Video'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Camera preview
          Center(
            child: CameraPreview(_cameraController!),
          ),

          // Teleprompter overlay
          if (_isTeleprompterVisible)
            Positioned(
              left: 0,
              right: 0,
              bottom: 120,
              child: Container(
                constraints: BoxConstraints(
                  minHeight: 10,
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: TeleprompterWithControls(
                  text: _teleprompterText,
                  controller: _teleprompterController,
                  initialSpeed: _teleprompterSpeed,
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: Colors.black.withValues(alpha: .3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

          // Controls overlay
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20),
                color: Colors.black54,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isTeleprompterVisible ? Icons.text_fields : Icons.text_fields_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: _showTeleprompterDialog,
                    ),
                    GestureDetector(
                      onTap: _toggleRecording,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          color: _isRecording ? Colors.red : Colors.transparent,
                        ),
                        child: _isRecording
                            ? const Icon(
                                Icons.stop,
                                color: Colors.white,
                                size: 30,
                              )
                            : const Icon(
                                Icons.fiber_manual_record,
                                color: Colors.red,
                                size: 30,
                              ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.flip_camera_ios,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: _toggleCamera,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Back button
          Positioned(
            top: 30,
            left: 15,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
