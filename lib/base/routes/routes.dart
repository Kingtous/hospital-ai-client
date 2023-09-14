import 'package:go_router/go_router.dart';
import 'package:hospital_ai_client/pages/home/home.dart';

final router = GoRouter(routes: [
  GoRoute(
      path: '/',
      builder: ((context, state) {
        return const HomePage();
      }))
]);
