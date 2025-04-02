import 'dart:async';

import 'package:flutter/material.dart';

/// Controller to manage teleprompter actions
class TeleprompterController {
  final StreamController<TeleprompterCommand> _commandController = StreamController<TeleprompterCommand>.broadcast();

  Stream<TeleprompterCommand> get commandStream => _commandController.stream;

  /// Current state of the teleprompter
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  /// Current speed of the teleprompter
  double _speed = 0.5;
  double get speed => _speed;

  /// Starts the teleprompter scrolling
  void play() {
    _isPlaying = true;
    _commandController.add(const TeleprompterCommand.play());
  }

  /// Pauses the teleprompter scrolling
  void pause() {
    _isPlaying = false;
    _commandController.add(const TeleprompterCommand.pause());
  }

  /// Resets the teleprompter to the beginning
  void reset() {
    _commandController.add(const TeleprompterCommand.reset());
  }

  /// Sets the teleprompter speed (0.1 to 2.0 range recommended)
  void setSpeed(double speed) {
    _speed = speed;
    _commandController.add(TeleprompterCommand.setSpeed(speed));
  }

  /// Toggle play/pause state
  void togglePlayPause() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  /// Clean up resources
  void dispose() {
    _commandController.close();
  }
}

/// Command types for the teleprompter
enum TeleprompterCommandType { play, pause, reset, setSpeed }

/// Commands that can be sent to the teleprompter
class TeleprompterCommand {
  final TeleprompterCommandType type;
  final double? speed;

  const TeleprompterCommand._(this.type, [this.speed]);

  const TeleprompterCommand.play() : this._(TeleprompterCommandType.play);
  const TeleprompterCommand.pause() : this._(TeleprompterCommandType.pause);
  const TeleprompterCommand.reset() : this._(TeleprompterCommandType.reset);
  const TeleprompterCommand.setSpeed(double speed) : this._(TeleprompterCommandType.setSpeed, speed);
}

/// A widget that displays scrolling text like a teleprompter
class TeleprompterWidget extends StatefulWidget {
  /// The text to display in the teleprompter
  final String text;

  /// Controller to manage teleprompter actions
  final TeleprompterController controller;

  /// Initial scroll speed (0.1 to 2.0 recommended)
  final double initialSpeed;

  /// Style for the text
  final TextStyle? textStyle;

  /// Background color of the teleprompter
  final Color? backgroundColor;

  /// Padding around the text
  final EdgeInsetsGeometry? padding;

  /// Border radius of the teleprompter container
  final BorderRadius? borderRadius;

  /// Mirror text (flip horizontally) for reflective teleprompters
  final bool mirrorText;

  const TeleprompterWidget({
    Key? key,
    required this.text,
    required this.controller,
    this.initialSpeed = 0.5,
    this.textStyle,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
    this.mirrorText = false,
  }) : super(key: key);

  @override
  State<TeleprompterWidget> createState() => _TeleprompterWidgetState();
}

class _TeleprompterWidgetState extends State<TeleprompterWidget> with TickerProviderStateMixin {
  /// Controller for scrolling the text
  late ScrollController _scrollController;

  /// The timer that controls the scrolling animation
  Timer? _scrollTimer;

  /// Current speed (pixels per second)
  late double _speed;

  /// Flag to track if teleprompter is playing
  bool _isPlaying = false;

  /// Subscription to controller commands
  StreamSubscription? _commandSubscription;

  /// Last known scroll position
  double _lastScrollPosition = 0;

  /// Base scroll speed in pixels per second at speed 1.0
  final double _baseScrollSpeed = 30.0;

  @override
  void initState() {
    super.initState();
    _speed = widget.initialSpeed;
    _scrollController = ScrollController();

    // Listen to controller commands
    _commandSubscription = widget.controller.commandStream.listen(_handleCommand);

    // Wait for the widget to be laid out before setting up scrolling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Make sure we're still mounted
      if (!mounted) return;

      // Initialize the teleprompter state
      if (widget.controller.isPlaying) {
        _play();
      }
    });
  }

  @override
  void didUpdateWidget(TeleprompterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the text changed, we need to reset
    if (widget.text != oldWidget.text) {
      _reset();
    }

    // If the controller changed, update our subscription
    if (widget.controller != oldWidget.controller) {
      _commandSubscription?.cancel();
      _commandSubscription = widget.controller.commandStream.listen(_handleCommand);
    }
  }

  /// Handle commands from the controller
  void _handleCommand(TeleprompterCommand command) {
    switch (command.type) {
      case TeleprompterCommandType.play:
        _play();
        break;
      case TeleprompterCommandType.pause:
        _pause();
        break;
      case TeleprompterCommandType.reset:
        _reset();
        break;
      case TeleprompterCommandType.setSpeed:
        _setSpeed(command.speed!);
        break;
    }
  }

  /// Start scrolling the text
  void _play() {
    if (!mounted || !_scrollController.hasClients) return;

    // Cancel any existing timer
    _scrollTimer?.cancel();

    setState(() {
      _isPlaying = true;
    });

    // Check if we're at the end
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
      _reset();
    }

    // Save the current position
    _lastScrollPosition = _scrollController.position.pixels;

    // Create a timer that fires frequently for smooth scrolling
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted || !_scrollController.hasClients) {
        timer.cancel();
        return;
      }

      // Calculate how far to scroll based on speed
      final double delta = _baseScrollSpeed * _speed * 0.016; // 16ms = 0.016s
      final double newPosition = _lastScrollPosition + delta;
      _lastScrollPosition = newPosition;

      // Scroll to the new position
      if (newPosition <= _scrollController.position.maxScrollExtent) {
        _scrollController.jumpTo(newPosition);
      } else {
        // We've reached the end, stop scrolling
        _pause();
      }
    });
  }

  /// Stop scrolling the text
  void _pause() {
    if (!mounted) return;

    _scrollTimer?.cancel();
    _scrollTimer = null;

    setState(() {
      _isPlaying = false;
    });
  }

  /// Reset the teleprompter to the beginning
  void _reset() {
    if (!mounted) return;

    final bool wasPlaying = _isPlaying;

    // Stop any current scrolling
    _pause();

    // Jump to the beginning
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
      _lastScrollPosition = 0;
    }

    // Resume playing if it was playing before
    if (wasPlaying) {
      _play();
    }
  }

  /// Change the scroll speed
  void _setSpeed(double speed) {
    if (!mounted) return;

    // Update the speed
    setState(() {
      _speed = speed;
    });

    // If we're playing, restart with the new speed
    if (_isPlaying) {
      _pause();
      _play();
    }
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _commandSubscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine text style to use
    final TextStyle effectiveTextStyle = widget.textStyle ??
        const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
          height: 1.5, // Add line spacing for better readability
        );

    // Build the teleprompter widget
    Widget textWidget = SingleChildScrollView(
      controller: _scrollController,
      physics: const NeverScrollableScrollPhysics(), // Prevent manual scrolling
      child: Padding(
        padding: widget.padding ?? const EdgeInsets.all(16),
        child: Text(
          widget.text,
          style: effectiveTextStyle,
          textAlign: TextAlign.center,
        ),
      ),
    );

    // Apply mirroring if needed
    if (widget.mirrorText) {
      textWidget = Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(3.14159), // Pi radians = 180 degrees
        child: textWidget,
      );
    }

    // The container that holds everything
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.black.withOpacity(0.7),
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
      ),
      child: textWidget,
    );
  }
}

/// A widget that provides a complete teleprompter interface with controls
class TeleprompterWithControls extends StatefulWidget {
  /// The text to display in the teleprompter
  final String text;

  /// Initial scroll speed (0.1 to 2.0 recommended)
  final double initialSpeed;

  /// Style for the text
  final TextStyle? textStyle;

  /// Background color of the teleprompter
  final Color? backgroundColor;

  /// Border radius of the teleprompter container
  final BorderRadius? borderRadius;

  /// Called when the teleprompter starts playing
  final VoidCallback? onPlay;

  /// Called when the teleprompter is paused
  final VoidCallback? onPause;

  final TeleprompterController controller;

  /// Called when the speed changes
  final ValueChanged<double>? onSpeedChanged;

  const TeleprompterWithControls({
    Key? key,
    required this.text,
    required this.controller,
    this.initialSpeed = 0.5,
    this.textStyle,
    this.backgroundColor,
    this.borderRadius,
    this.onPlay,
    this.onPause,
    this.onSpeedChanged,
  }) : super(key: key);

  @override
  State<TeleprompterWithControls> createState() => _TeleprompterWithControlsState();
}

class _TeleprompterWithControlsState extends State<TeleprompterWithControls> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // The teleprompter
        Expanded(
          child: TeleprompterWidget(
            text: widget.text,
            controller: widget.controller,
            initialSpeed: widget.initialSpeed,
            textStyle: widget.textStyle,
            backgroundColor: widget.backgroundColor,
            borderRadius: widget.borderRadius,
          ),
        ),

        // Controls
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Reset button
                IconButton(
                  icon: const Icon(Icons.replay),
                  onPressed: () {
                    widget.controller.reset();
                  },
                ),

                // Play/Pause button
                StreamBuilder<TeleprompterCommand>(
                  stream: widget.controller.commandStream,
                  initialData: const TeleprompterCommand.pause(),
                  builder: (context, snapshot) {
                    return IconButton(
                      icon: Icon(widget.controller.isPlaying ? Icons.pause : Icons.play_arrow),
                      onPressed: () {
                        widget.controller.togglePlayPause();
                        if (widget.controller.isPlaying) {
                          widget.onPlay?.call();
                        } else {
                          widget.onPause?.call();
                        }
                      },
                    );
                  },
                ),

                // Speed slider
                Expanded(
                  child: Slider(
                    value: widget.controller.speed,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    label: (widget.controller.speed * 10).round().toString(),
                    onChanged: (value) {
                      setState(() {});
                      widget.controller.setSpeed(value);
                      widget.onSpeedChanged?.call(value);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
