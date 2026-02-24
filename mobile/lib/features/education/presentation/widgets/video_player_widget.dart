/// Video Player Widget for Educational Content
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart' as vp;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final double? aspectRatio;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    this.aspectRatio = 16 / 9,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  YoutubePlayerController? _youtubeController;
  vp.VideoPlayerController? _videoController;
  bool _isYouTube = false;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  Timer? _controlsHideTimer;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    unawaited(_initializePlayer());
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      unawaited(_initializePlayer());
    }
  }

  Future<void> _initializePlayer() async {
    await _disposeControllers();

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      _showControls = true;
    });

    // Check if it's a YouTube URL
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);

    if (videoId != null) {
      final controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          loop: false,
        ),
      );

      if (!mounted) {
        controller.dispose();
        return;
      }

      setState(() {
        _isYouTube = true;
        _youtubeController = controller;
        _isLoading = false;
      });
      return;
    }

    final uri = Uri.tryParse(widget.videoUrl);
    if (uri == null) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = 'رابط الفيديو غير صالح';
        _isLoading = false;
      });
      return;
    }

    try {
      final controller = vp.VideoPlayerController.networkUrl(uri);
      await controller.initialize();
      await controller.setLooping(false);

      controller.addListener(_onVideoUpdate);

      if (!mounted) {
        controller.removeListener(_onVideoUpdate);
        await controller.dispose();
        return;
      }

      setState(() {
        _isYouTube = false;
        _videoController = controller;
        _isLoading = false;
      });
      _restartControlsTimer();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = 'تعذر تشغيل الفيديو';
        _isLoading = false;
      });
    }
  }

  void _onVideoUpdate() {
    if (!mounted || _videoController == null) return;

    final controller = _videoController!;
    final value = controller.value;
    if (!value.isInitialized) return;

    final isCompleted =
        value.duration.inMilliseconds > 0 && value.position >= value.duration;
    if (isCompleted && !value.isPlaying) {
      _controlsHideTimer?.cancel();
      if (!_showControls) {
        setState(() => _showControls = true);
      }
      return;
    }

    // Update progress UI
    setState(() {});
  }

  Future<void> _togglePlayPause() async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      await controller.pause();
      _controlsHideTimer?.cancel();
      if (mounted) {
        setState(() => _showControls = true);
      }
    } else {
      await controller.play();
      _restartControlsTimer();
    }
  }

  void _toggleControlsVisibility() {
    if (_videoController == null) return;

    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _restartControlsTimer();
    } else {
      _controlsHideTimer?.cancel();
    }
  }

  void _restartControlsTimer() {
    _controlsHideTimer?.cancel();
    final controller = _videoController;
    if (controller == null || !controller.value.isPlaying) return;

    _controlsHideTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _showControls = false);
    });
  }

  Future<void> _seekTo(double progress) async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;

    final duration = controller.value.duration;
    final position = Duration(
      milliseconds: (duration.inMilliseconds * progress).round(),
    );
    await controller.seekTo(position);
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildPlaybackOverlay() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final value = controller.value;
    final progress = value.duration.inMilliseconds == 0
        ? 0.0
        : (value.position.inMilliseconds / value.duration.inMilliseconds).clamp(
            0.0,
            1.0,
          );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _showControls ? 1 : 0,
      child: IgnorePointer(
        ignoring: !_showControls,
        child: Container(
          color: Colors.black.withValues(alpha: 0.25),
          child: Stack(
            children: [
              Center(
                child: IconButton(
                  onPressed: _togglePlayPause,
                  iconSize: 56.sp,
                  color: Colors.white,
                  icon: Icon(
                    value.isPlaying ? Icons.pause_circle : Icons.play_circle,
                  ),
                ),
              ),
              Positioned(
                left: 12.w,
                right: 12.w,
                bottom: 10.h,
                child: Row(
                  children: [
                    Text(
                      _formatDuration(value.position),
                      style: TextStyle(color: Colors.white, fontSize: 11.sp),
                    ),
                    Expanded(
                      child: Slider(
                        min: 0,
                        max: 1,
                        value: progress,
                        onChanged: _seekTo,
                        activeColor: Theme.of(context).primaryColor,
                        inactiveColor: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                    Text(
                      _formatDuration(value.duration),
                      style: TextStyle(color: Colors.white, fontSize: 11.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackView(String message) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio!,
      child: Container(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_outline,
                  size: 60.sp,
                  color: Colors.white,
                ),
                SizedBox(height: 12.h),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 13.sp),
                ),
                SizedBox(height: 10.h),
                TextButton.icon(
                  onPressed: () => unawaited(_initializePlayer()),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    'إعادة المحاولة',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _disposeControllers() async {
    _controlsHideTimer?.cancel();
    _controlsHideTimer = null;

    _youtubeController?.dispose();
    _youtubeController = null;

    final controller = _videoController;
    if (controller != null) {
      controller.removeListener(_onVideoUpdate);
      await controller.dispose();
      _videoController = null;
    }
  }

  @override
  void dispose() {
    unawaited(_disposeControllers());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return AspectRatio(
        aspectRatio: widget.aspectRatio!,
        child: const ColoredBox(
          color: Colors.black,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    if (_hasError) {
      return _buildFallbackView(_errorMessage ?? 'تعذر تشغيل الفيديو');
    }

    if (_isYouTube && _youtubeController != null) {
      return YoutubePlayer(
        controller: _youtubeController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Theme.of(context).primaryColor,
        progressColors: ProgressBarColors(
          playedColor: Theme.of(context).primaryColor,
          handleColor: Theme.of(context).primaryColor,
        ),
        onReady: () {
          // Player is ready
        },
        bottomActions: [
          CurrentPosition(),
          ProgressBar(isExpanded: true),
          RemainingDuration(),
          const PlaybackSpeedButton(),
          FullScreenButton(),
        ],
      );
    }

    final controller = _videoController;
    if (controller != null && controller.value.isInitialized) {
      final aspectRatio = controller.value.aspectRatio > 0
          ? controller.value.aspectRatio
          : widget.aspectRatio!;

      return AspectRatio(
        aspectRatio: aspectRatio,
        child: GestureDetector(
          onTap: _toggleControlsVisibility,
          child: Stack(
            fit: StackFit.expand,
            children: [vp.VideoPlayer(controller), _buildPlaybackOverlay()],
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: widget.aspectRatio!,
      child: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_outline, size: 64.sp, color: Colors.white),
              SizedBox(height: 16.h),
              Text(
                'تعذر تشغيل الفيديو',
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
