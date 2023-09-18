import 'package:go_router/go_router.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/pages/home/home.dart';
import 'package:hospital_ai_client/pages/users/login.dart';
import 'package:hospital_ai_client/pages/video/fullscreen.dart';

final router = GoRouter(routes: [
  GoRoute(
      path: '/',
      name: 'login',
      builder: ((context, state) => const UserLogin())),
  GoRoute(
      path: '/',
      name: 'home',
      builder: ((context, state) {
        return const HomePage();
      })),
  GoRoute(
      path: '/player/:id',
      name: 'player',
      builder: ((context, state) {
        final id = state.pathParameters['id'];
        if (id == null) {
          return const HomePage();
        } else {
          return FullScreenLive(id: id);
        }
      }))
]);
