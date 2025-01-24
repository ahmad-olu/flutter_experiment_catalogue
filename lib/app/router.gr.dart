// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:experiment_catalogue/applications/01_todo/page/todo_page.dart'
    as _i3;
import 'package:experiment_catalogue/applications/02_weather/page/weather_page.dart'
    as _i4;
import 'package:experiment_catalogue/applications/03_bmi_calc/page/bmi_calc_page.dart'
    as _i1;
import 'package:experiment_catalogue/applications/home.dart' as _i2;

/// generated route for
/// [_i1.BmiCalc03Page]
class BmiCalc03Route extends _i5.PageRouteInfo<void> {
  const BmiCalc03Route({List<_i5.PageRouteInfo>? children})
    : super(BmiCalc03Route.name, initialChildren: children);

  static const String name = 'BmiCalc03Route';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i1.BmiCalc03Page();
    },
  );
}

/// generated route for
/// [_i2.HomePage]
class HomeRoute extends _i5.PageRouteInfo<void> {
  const HomeRoute({List<_i5.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i2.HomePage();
    },
  );
}

/// generated route for
/// [_i3.Todo01Page]
class Todo01Route extends _i5.PageRouteInfo<void> {
  const Todo01Route({List<_i5.PageRouteInfo>? children})
    : super(Todo01Route.name, initialChildren: children);

  static const String name = 'Todo01Route';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i3.Todo01Page();
    },
  );
}

/// generated route for
/// [_i4.Weather02Page]
class Weather02Route extends _i5.PageRouteInfo<void> {
  const Weather02Route({List<_i5.PageRouteInfo>? children})
    : super(Weather02Route.name, initialChildren: children);

  static const String name = 'Weather02Route';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i4.Weather02Page();
    },
  );
}
