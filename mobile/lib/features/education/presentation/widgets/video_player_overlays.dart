part of 'video_player_widget.dart';

class _VideoPlaybackOverlay extends StatelessWidget {
  final vp.VideoPlayerController controller;
  final bool showControls;
  final VoidCallback onTogglePlayPause;
  final ValueChanged<double> onSeekTo;
  final String Function(Duration) formatDuration;
  final VoidCallback onToggleFullScreen;

  const _VideoPlaybackOverlay({
    required this.controller,
    required this.showControls,
    required this.onTogglePlayPause,
    required this.onSeekTo,
    required this.formatDuration,
    required this.onToggleFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
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
      opacity: showControls ? 1 : 0,
      child: IgnorePointer(
        ignoring: !showControls,
        child: Container(
          color: Colors.black.withValues(alpha: 0.25),
          child: Stack(
            children: [
              Center(
                child: IconButton(
                  onPressed: onTogglePlayPause,
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
                      formatDuration(value.position),
                      style: TextStyle(color: Colors.white, fontSize: 11.sp),
                    ),
                    Expanded(
                      child: Slider(
                        min: 0,
                        max: 1,
                        value: progress,
                        onChanged: onSeekTo,
                        activeColor: Theme.of(context).primaryColor,
                        inactiveColor: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                    Text(
                      formatDuration(value.duration),
                      style: TextStyle(color: Colors.white, fontSize: 11.sp),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                      onPressed: onToggleFullScreen,
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
}

class _VideoFallbackView extends StatelessWidget {
  final double aspectRatio;
  final String message;
  final VoidCallback onRetry;

  const _VideoFallbackView({
    required this.aspectRatio,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
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
                  onPressed: onRetry,
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
}
