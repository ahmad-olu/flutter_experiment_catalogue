// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i3;
import 'package:experiment_catalogue/applications/01_todo/page/todo_page.dart'
    as _i2;
import 'package:experiment_catalogue/applications/home.dart' as _i1;

/// generated route for
/// [_i1.HomePage]
class HomeRoute extends _i3.PageRouteInfo<void> {
  const HomeRoute({List<_i3.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      return const _i1.HomePage();
    },
  );
}

/// generated route for
/// [_i2.Todo01Page]
class Todo01Route extends _i3.PageRouteInfo<void> {
  const Todo01Route({List<_i3.PageRouteInfo>? children})
    : super(Todo01Route.name, initialChildren: children);

  static const String name = 'Todo01Route';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      return const _i2.Todo01Page();
    },
  );
}
