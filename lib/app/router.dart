import 'package:auto_route/auto_route.dart';
import 'package:experiment_catalogue/app/router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: HomeRoute.page, initial: true),
        AutoRoute(page: Todo01Route.page),
        AutoRoute(page: Weather02Route.page),
        AutoRoute(page: BmiCalc03Route.page),
        AutoRoute(page: Quiz04Route.page),
        AutoRoute(page: Chat06Route.page),
        AutoRoute(page: SocketTest05Route.page),
        AutoRoute(page: Messages06Route.page),
      ];
  @override
  List<AutoRouteGuard> get guards => [
        // optionally add root guards here
      ];
}
