import 'package:go_router/go_router.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/pages/home/home.dart';
import 'package:hospital_ai_client/pages/users/landing.dart';
import 'package:hospital_ai_client/pages/users/login.dart';
import 'package:hospital_ai_client/pages/video/fullscreen.dart';

final router = GoRouter(initialLocation: '/', routes: [
  GoRoute(
      path: '/',
      name: 'load',
      builder: ((context, state) => const LandingPage())),
  GoRoute(
      path: '/login',
      name: 'login',
      builder: ((context, state) => const UserLogin())),
  GoRoute(
      path: '/home',
      name: 'home',
      builder: ((context, state) {
        return const HomePage();
      })),
  GoRoute(
      path: '/player/:name',
      name: 'player',
      builder: ((context, state) {
        final name = state.pathParameters['name'] ?? '';
        final cam = videoModel.getPlayableByName(name);
        if (cam == null) {
          return const HomePage();
        } else {
          return FullScreenLive(
            cam: cam,
          );
        }
      }))
]);
