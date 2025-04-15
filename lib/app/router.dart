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
        AutoRoute(page: SocketTest05Route.page),
        AutoRoute(page: Chat06Route.page),
        AutoRoute(page: Messages06Route.page),
        AutoRoute(page: Note07RouteOne.page),
        AutoRoute(page: Note07RouteTwo.page),
        AutoRoute(page: Note07RouteThree.page),
        AutoRoute(page: Note08RouteOne.page),
        AutoRoute(page: Note08RouteTwo.page),
        AutoRoute(page: Note08RouteThree.page),
        AutoRoute(page: UploadVideo16Route.page),
        AutoRoute(page: VideoStream16Route.page),
        AutoRoute(page: WebRtc20Route.page),
        AutoRoute(page: WebRtc20bRoute.page),
      ];
  @override
  List<AutoRouteGuard> get guards => [
        // optionally add root guards here
      ];
}
