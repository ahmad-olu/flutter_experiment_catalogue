// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i9;
import 'package:experiment_catalogue/applications/01_todo/page/todo_page.dart'
    as _i7;
import 'package:experiment_catalogue/applications/02_weather/page/weather_page.dart'
    as _i8;
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
import 'package:experiment_catalogue/applications/home.dart' as _i3;
import 'package:flutter/material.dart' as _i10;

/// generated route for
/// [_i1.BmiCalc03Page]
class BmiCalc03Route extends _i9.PageRouteInfo<void> {
  const BmiCalc03Route({List<_i9.PageRouteInfo>? children})
    : super(BmiCalc03Route.name, initialChildren: children);

  static const String name = 'BmiCalc03Route';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i1.BmiCalc03Page();
    },
  );
}

/// generated route for
/// [_i2.Chat06Page]
class Chat06Route extends _i9.PageRouteInfo<void> {
  const Chat06Route({List<_i9.PageRouteInfo>? children})
    : super(Chat06Route.name, initialChildren: children);

  static const String name = 'Chat06Route';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i2.Chat06Page();
    },
  );
}

/// generated route for
/// [_i3.HomePage]
class HomeRoute extends _i9.PageRouteInfo<void> {
  const HomeRoute({List<_i9.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i3.HomePage();
    },
  );
}

/// generated route for
/// [_i4.Messages06Page]
class Messages06Route extends _i9.PageRouteInfo<Messages06RouteArgs> {
  Messages06Route({
    required String username,
    required String threadId,
    _i10.Key? key,
    List<_i9.PageRouteInfo>? children,
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

  static _i9.PageInfo page = _i9.PageInfo(
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

  final _i10.Key? key;

  @override
  String toString() {
    return 'Messages06RouteArgs{username: $username, threadId: $threadId, key: $key}';
  }
}

/// generated route for
/// [_i5.Quiz04Page]
class Quiz04Route extends _i9.PageRouteInfo<void> {
  const Quiz04Route({List<_i9.PageRouteInfo>? children})
    : super(Quiz04Route.name, initialChildren: children);

  static const String name = 'Quiz04Route';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i5.Quiz04Page();
    },
  );
}

/// generated route for
/// [_i6.SocketTest05Page]
class SocketTest05Route extends _i9.PageRouteInfo<void> {
  const SocketTest05Route({List<_i9.PageRouteInfo>? children})
    : super(SocketTest05Route.name, initialChildren: children);

  static const String name = 'SocketTest05Route';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i6.SocketTest05Page();
    },
  );
}

/// generated route for
/// [_i7.Todo01Page]
class Todo01Route extends _i9.PageRouteInfo<void> {
  const Todo01Route({List<_i9.PageRouteInfo>? children})
    : super(Todo01Route.name, initialChildren: children);

  static const String name = 'Todo01Route';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i7.Todo01Page();
    },
  );
}

/// generated route for
/// [_i8.Weather02Page]
class Weather02Route extends _i9.PageRouteInfo<void> {
  const Weather02Route({List<_i9.PageRouteInfo>? children})
    : super(Weather02Route.name, initialChildren: children);

  static const String name = 'Weather02Route';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i8.Weather02Page();
    },
  );
}
