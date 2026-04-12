part of 'video_player_widget.dart';

class _FullScreenVideoPage extends StatefulWidget {
  final vp.VideoPlayerController controller;

  const _FullScreenVideoPage({required this.controller});

  @override
  State<_FullScreenVideoPage> createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<_FullScreenVideoPage> {
  bool _showControls = true;
  Timer? _controlsHideTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    widget.controller.addListener(_onVideoUpdate);
    _restartControlsTimer();
  }

  void _onVideoUpdate() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controlsHideTimer?.cancel();
    widget.controller.removeListener(_onVideoUpdate);
    super.dispose();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _restartControlsTimer();
    } else {
      _controlsHideTimer?.cancel();
    }
  }

  void _restartControlsTimer() {
    _controlsHideTimer?.cancel();
    if (!widget.controller.value.isPlaying) return;
    _controlsHideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _togglePlayPause() {
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
      _controlsHideTimer?.cancel();
      setState(() => _showControls = true);
    } else {
      widget.controller.play();
      _restartControlsTimer();
    }
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.value;
    final progress = value.duration.inMilliseconds == 0
        ? 0.0
        : (value.position.inMilliseconds / value.duration.inMilliseconds).clamp(
            0.0,
            1.0,
          );

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: value.aspectRatio,
                child: vp.VideoPlayer(widget.controller),
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _showControls ? 1 : 0,
              child: IgnorePointer(
                ignoring: !_showControls,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.4),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 16.h,
                        left: 16.w,
                        child: IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 28.sp,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Center(
                        child: IconButton(
                          onPressed: _togglePlayPause,
                          iconSize: 64.sp,
                          color: Colors.white,
                          icon: Icon(
                            value.isPlaying
                                ? Icons.pause_circle
                                : Icons.play_circle,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 24.w,
                        right: 24.w,
                        bottom: 20.h,
                        child: Row(
                          children: [
                            Text(
                              _formatDuration(value.position),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                              ),
                            ),
                            Expanded(
                              child: Slider(
                                min: 0,
                                max: 1,
                                value: progress,
                                onChanged: (p) {
                                  final position = Duration(
                                    milliseconds:
                                        (value.duration.inMilliseconds * p)
                                            .round(),
                                  );
                                  widget.controller.seekTo(position);
                                },
                                activeColor: Theme.of(context).primaryColor,
                                inactiveColor: Colors.white.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                            ),
                            Text(
                              _formatDuration(value.duration),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(
                                Icons.fullscreen_exit,
                                color: Colors.white,
                                size: 28.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
