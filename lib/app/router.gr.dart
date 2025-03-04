// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i12;
import 'package:experiment_catalogue/applications/01_todo/page/todo_page.dart'
    as _i7;
import 'package:experiment_catalogue/applications/02_weather/page/weather_page.dart'
    as _i10;
import 'package:experiment_catalogue/applications/03_bmi_calc/page/bmi_calc_page.dart'
    as _i1;
import 'package:experiment_catalogue/applications/04_quiz/page/quiz.dart'
    as _i5;
import 'package:experiment_catalogue/applications/05_socket_io_test/page/socket_page.dart'
    as _i6;
import 'package:experiment_catalogue/applications/06_chat_app/page/chat_page.dart'
    as _i2;
import 'package:experiment_catalogue/applications/06_chat_app/page/message_page.dart'
    as _i4;
import 'package:experiment_catalogue/applications/16_video_streaming/page/upload_vid16.dart'
    as _i8;
import 'package:experiment_catalogue/applications/16_video_streaming/page/video_stream16.dart'
    as _i9;
import 'package:experiment_catalogue/applications/20_web_rtc/page/webrtc_page.dart'
    as _i11;
import 'package:experiment_catalogue/applications/home.dart' as _i3;
import 'package:flutter/material.dart' as _i13;

/// generated route for
/// [_i1.BmiCalc03Page]
class BmiCalc03Route extends _i12.PageRouteInfo<void> {
  const BmiCalc03Route({List<_i12.PageRouteInfo>? children})
    : super(BmiCalc03Route.name, initialChildren: children);

  static const String name = 'BmiCalc03Route';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i1.BmiCalc03Page();
    },
  );
}

/// generated route for
/// [_i2.Chat06Page]
class Chat06Route extends _i12.PageRouteInfo<void> {
  const Chat06Route({List<_i12.PageRouteInfo>? children})
    : super(Chat06Route.name, initialChildren: children);

  static const String name = 'Chat06Route';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i2.Chat06Page();
    },
  );
}

/// generated route for
/// [_i3.HomePage]
class HomeRoute extends _i12.PageRouteInfo<void> {
  const HomeRoute({List<_i12.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i3.HomePage();
    },
  );
}

/// generated route for
/// [_i4.Messages06Page]
class Messages06Route extends _i12.PageRouteInfo<Messages06RouteArgs> {
  Messages06Route({
    required String username,
    required String threadId,
    _i13.Key? key,
    List<_i12.PageRouteInfo>? children,
  }) : super(
         Messages06Route.name,
         args: Messages06RouteArgs(
           username: username,
           threadId: threadId,
           key: key,
         ),
         initialChildren: children,
       );

  static const String name = 'Messages06Route';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<Messages06RouteArgs>();
      return _i4.Messages06Page(
        username: args.username,
        threadId: args.threadId,
        key: args.key,
      );
    },
  );
}

class Messages06RouteArgs {
  const Messages06RouteArgs({
    required this.username,
    required this.threadId,
    this.key,
  });

  final String username;

  final String threadId;

  final _i13.Key? key;

  @override
  String toString() {
    return 'Messages06RouteArgs{username: $username, threadId: $threadId, key: $key}';
  }
}

/// generated route for
/// [_i5.Quiz04Page]
class Quiz04Route extends _i12.PageRouteInfo<void> {
  const Quiz04Route({List<_i12.PageRouteInfo>? children})
    : super(Quiz04Route.name, initialChildren: children);

  static const String name = 'Quiz04Route';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i5.Quiz04Page();
    },
  );
}

/// generated route for
/// [_i6.SocketTest05Page]
class SocketTest05Route extends _i12.PageRouteInfo<void> {
  const SocketTest05Route({List<_i12.PageRouteInfo>? children})
    : super(SocketTest05Route.name, initialChildren: children);

  static const String name = 'SocketTest05Route';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i6.SocketTest05Page();
    },
  );
}

/// generated route for
/// [_i7.Todo01Page]
class Todo01Route extends _i12.PageRouteInfo<void> {
  const Todo01Route({List<_i12.PageRouteInfo>? children})
    : super(Todo01Route.name, initialChildren: children);

  static const String name = 'Todo01Route';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i7.Todo01Page();
    },
  );
}

/// generated route for
/// [_i8.UploadVideo16Page]
class UploadVideo16Route extends _i12.PageRouteInfo<void> {
  const UploadVideo16Route({List<_i12.PageRouteInfo>? children})
    : super(UploadVideo16Route.name, initialChildren: children);

  static const String name = 'UploadVideo16Route';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i8.UploadVideo16Page();
    },
  );
}

/// generated route for
/// [_i9.VideoStream16Page]
class VideoStream16Route extends _i12.PageRouteInfo<VideoStream16RouteArgs> {
  VideoStream16Route({
    _i13.Key? key,
    String? videoId,
    List<_i12.PageRouteInfo>? children,
  }) : super(
         VideoStream16Route.name,
         args: VideoStream16RouteArgs(key: key, videoId: videoId),
         initialChildren: children,
       );

  static const String name = 'VideoStream16Route';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VideoStream16RouteArgs>(
        orElse: () => const VideoStream16RouteArgs(),
      );
      return _i9.VideoStream16Page(key: args.key, videoId: args.videoId);
    },
  );
}

class VideoStream16RouteArgs {
  const VideoStream16RouteArgs({this.key, this.videoId});

  final _i13.Key? key;

  final String? videoId;

  @override
  String toString() {
    return 'VideoStream16RouteArgs{key: $key, videoId: $videoId}';
  }
}

/// generated route for
/// [_i10.Weather02Page]
class Weather02Route extends _i12.PageRouteInfo<void> {
  const Weather02Route({List<_i12.PageRouteInfo>? children})
    : super(Weather02Route.name, initialChildren: children);

  static const String name = 'Weather02Route';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i10.Weather02Page();
    },
  );
}

/// generated route for
/// [_i11.WebRtc20Page]
class WebRtc20Route extends _i12.PageRouteInfo<void> {
  const WebRtc20Route({List<_i12.PageRouteInfo>? children})
    : super(WebRtc20Route.name, initialChildren: children);

  static const String name = 'WebRtc20Route';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i11.WebRtc20Page();
    },
  );
}

/// generated route for
/// [_i11.WebRtc20bPage]
class WebRtc20bRoute extends _i12.PageRouteInfo<void> {
  const WebRtc20bRoute({List<_i12.PageRouteInfo>? children})
    : super(WebRtc20bRoute.name, initialChildren: children);

  static const String name = 'WebRtc20bRoute';

  static _i12.PageInfo page = _i12.PageInfo(
    name,
    builder: (data) {
      return const _i11.WebRtc20bPage();
    },
  );
}
