/// Video Player Widget for Educational Content
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  bool _isYouTube = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    // Check if it's a YouTube URL
    final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
    
    if (videoId != null) {
      _isYouTube = true;
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          loop: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    // For non-YouTube videos, show a placeholder or use video_player
    return AspectRatio(
      aspectRatio: widget.aspectRatio!,
      child: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_circle_outline,
                size: 64.sp,
                color: Colors.white,
              ),
              SizedBox(height: 16.h),
              Text(
                'Video player not supported for this URL',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
