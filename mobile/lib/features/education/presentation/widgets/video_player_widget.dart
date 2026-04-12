/// Video Player Widget for Educational Content
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart' as vp;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

part 'video_player_fullscreen.dart';
part 'video_player_overlays.dart';

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
    } catch (_) {
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

  void _toggleFullScreen() {
    if (_videoController == null) return;

    _controlsHideTimer?.cancel();
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) =>
                _FullScreenVideoPage(controller: _videoController!),
          ),
        )
        .then((_) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.manual,
            overlays: SystemUiOverlay.values,
          );
          if (mounted) {
            setState(() {});
            _restartControlsTimer();
          }
        });
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
      return _VideoFallbackView(
        aspectRatio: widget.aspectRatio!,
        message: _errorMessage ?? 'تعذر تشغيل الفيديو',
        onRetry: () => unawaited(_initializePlayer()),
      );
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
        onReady: () {},
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
            children: [
              vp.VideoPlayer(controller),
              _VideoPlaybackOverlay(
                controller: controller,
                showControls: _showControls,
                onTogglePlayPause: _togglePlayPause,
                onSeekTo: _seekTo,
                formatDuration: _formatDuration,
                onToggleFullScreen: _toggleFullScreen,
              ),
            ],
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
