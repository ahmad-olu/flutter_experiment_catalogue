import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:chewie/chewie.dart' show Chewie, ChewieController;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart'
    show VideoFormat, VideoPlayerController;

@RoutePage()
class VideoStream16Page extends StatelessWidget {
  const VideoStream16Page({super.key, this.videoId});
  final String? videoId;

  @override
  Widget build(BuildContext context) {
    return const VideoStream16View();
  }
}

class VideoStream16View extends StatefulWidget {
  const VideoStream16View({super.key, this.videoId});
  final String? videoId;

  @override
  State<VideoStream16View> createState() => _VideoStream16ViewState();
}

class _VideoStream16ViewState extends State<VideoStream16View> {
  late VideoPlayerController _videoPlayerController;

  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    final initialUrl =
        'http://localhost:3000/video/stream/${widget.videoId ?? '84fb87d6-6897-4121-9389-6a7a33ba9383'}';

    //final videoUrl =
    //    'http://localhost:3000/video/videos/${widget.videoId ?? '84fb87d6-6897-4121-9389-6a7a33ba9383'}.mp4';

    //final videoUrl =
    //    'http://localhost:3000/video/videos/${widget.videoId ?? '84fb87d6-6897-4121-9389-6a7a33ba9383'}/index.m3u8';

    // const videoUrl =
    //     'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

    final redirectedUrl = await _getFinalRedirectUrl(initialUrl);
    if (redirectedUrl == null) {
      log("Error: Couldn't fetch video URL.");
      return;
    }
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(redirectedUrl),
      formatHint: VideoFormat.hls,
    );

    await _videoPlayerController.initialize();

    _videoPlayerController.addListener(() {
      if (_videoPlayerController.value.hasError) {
        debugPrint(
          'Video Error: ${_videoPlayerController.value.errorDescription}',
        );
      }
    });

    setState(() {
      _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          autoPlay: true,
          //startAt: const Duration(seconds: 20)
          
          //  looping: true,
          );
    });
  }

  Future<String?> _getFinalRedirectUrl(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Connection': 'close',
        },
      );
      if (response.statusCode == 302 || response.statusCode == 301) {
        return response.headers['location'];
      }
      return url;
    } catch (e) {
      log('Error fetching redirect: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Player Streamed')),
      body: _chewieController != null
          ? Chewie(
              controller: _chewieController!,
            )
          : const CircularProgressIndicator(),
    );
  }
}
