import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;
  final bool autoPlay;
  final bool looping;
  final bool showControls;

  const VideoPlayerWidget({
    Key? key,
    required this.videoPath,
    this.autoPlay = false,
    this.looping = false,
    this.showControls = true,
  }) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  double _currentPosition = 0.0;
  double _totalDuration = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.file(File(widget.videoPath));

    await _controller.initialize();

    if (widget.autoPlay) {
      await _controller.play();
      _isPlaying = true;
    }

    _controller.setLooping(widget.looping);

    _controller.addListener(_videoListener);

    if (mounted) {
      setState(() {
        _isInitialized = true;
        _totalDuration = _controller.value.duration.inMilliseconds.toDouble();
      });
    }
  }

  void _videoListener() {
    if (mounted && _controller.value.isInitialized) {
      setState(() {
        _currentPosition = _controller.value.position.inMilliseconds.toDouble();
        _isPlaying = _controller.value.isPlaying;
      });
    }
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const AspectRatio(
        aspectRatio: 9 / 16,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_controller),
              if (widget.showControls && !_isPlaying)
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (widget.showControls)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(_formatDuration(Duration(milliseconds: _currentPosition.toInt()))),
                    Expanded(
                      child: Slider(
                        value: _currentPosition,
                        min: 0.0,
                        max: _totalDuration,
                        onChanged: (value) {
                          setState(() {
                            _currentPosition = value;
                          });
                          _controller.seekTo(Duration(milliseconds: value.toInt()));
                        },
                      ),
                    ),
                    Text(_formatDuration(Duration(milliseconds: _totalDuration.toInt()))),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10),
                      onPressed: () {
                        final newPosition = _currentPosition - 10000;
                        _controller.seekTo(Duration(
                          milliseconds: newPosition > 0 ? newPosition.toInt() : 0,
                        ));
                      },
                    ),
                    IconButton(
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      iconSize: 40,
                      onPressed: _togglePlayPause,
                    ),
                    IconButton(
                      icon: const Icon(Icons.forward_10),
                      onPressed: () {
                        final newPosition = _currentPosition + 10000;
                        _controller.seekTo(Duration(
                          milliseconds: newPosition < _totalDuration ? newPosition.toInt() : _totalDuration.toInt(),
                        ));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
