import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:chewie/chewie.dart'
    show Chewie, ChewieController, ChewieProgressColors;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart'
    show
        VideoFormat,
        VideoPlayerController,
        VideoProgressColors,
        VideoProgressIndicator;

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

    //? not needed: i thought the video player was not redirecting
    // final redirectedUrl = await _getFinalRedirectUrl(initialUrl);
    // if (redirectedUrl == null) {
    //   log("Error: Couldn't fetch video URL.");
    //   return;
    // }
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(initialUrl),
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
        //allowFullScreen: true,
        //allowMuting: true,
        //showControls: false, // Hide default controls
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.white,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.white38,
        ),

        // customControls: CustomControls(
        //   _videoPlayerController,
        // ),
      );
    });
  }

  //? not needed: i thought the video player was not redirecting
  // Future<String?> _getFinalRedirectUrl(String url) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse(url),
  //       headers: {
  //         'Connection': 'close',
  //       },
  //     );
  //     if (response.statusCode == 302 || response.statusCode == 301) {
  //       return response.headers['location'];
  //     }
  //     return url;
  //   } catch (e) {
  //     log('Error fetching redirect: $e');
  //     return null;
  //   }
  // }

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
          ? GestureDetector(
              onTap: () {
                log('Tapped parent');
              },
              child: Chewie(
                controller: _chewieController!,
              ),
            )
          : const CircularProgressIndicator(),
    );
  }
}

class CustomControls extends HookWidget {
  const CustomControls(this.controller, {super.key});
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final isPlaying = useState(controller.value.isPlaying);
    final showControls = useState(true);

    useEffect(
      () {
        void listener() {
          isPlaying.value = controller.value.isPlaying;
        }

        controller.addListener(listener);
        return () => controller.removeListener(listener);
      },
      [controller],
    );

    void togglePlayPause() {
      isPlaying.value ? controller.pause() : controller.play();
    }

    void toggleControls() {
      log('Tapped toggle');
      showControls.value = !showControls.value;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: toggleControls,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          if (showControls.value)
            Positioned.fill(
              child: Center(
                child: IconButton(
                  icon: Icon(
                    isPlaying.value
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 64,
                    color: Colors.white,
                  ),
                  onPressed: togglePlayPause,
                ),
              ),
            ),
          if (showControls.value)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black54, Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      isPlaying.value ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: togglePlayPause,
                  ),
                  Expanded(
                    child: VideoProgressIndicator(
                      controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Colors.red,
                        bufferedColor: Colors.white38,
                        backgroundColor: Colors.grey,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.fullscreen, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
