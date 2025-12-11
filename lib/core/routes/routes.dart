import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/src/presentation/views/auth/intro_screen.dart';
import 'package:vibe_now/src/presentation/views/auth/splash_screen.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: RouteNames.splashScreen,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/intro',
      name: RouteNames.introScreen,
      builder: (context, state) => const IntroScreen(),
    ),
  ],
);
