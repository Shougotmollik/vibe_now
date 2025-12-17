import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/src/presentation/views/auth/intro_screen.dart';
import 'package:vibe_now/src/presentation/views/auth/sign_in_screen.dart';
import 'package:vibe_now/src/presentation/views/auth/splash_screen.dart';
import 'package:vibe_now/src/presentation/views/auth/steps/step_name_screen.dart';
import 'package:vibe_now/src/presentation/views/community/community_details_screen.dart';
import 'package:vibe_now/src/presentation/views/community/community_screen.dart';
import 'package:vibe_now/src/presentation/views/community/create_community_screen.dart';
import 'package:vibe_now/src/presentation/views/community/member_screen.dart';
import 'package:vibe_now/src/presentation/views/event/create_event_screen.dart';
import 'package:vibe_now/src/presentation/views/event/event_screen.dart';
import 'package:vibe_now/src/presentation/views/main_nav_bar_screen.dart';
import 'package:vibe_now/src/presentation/views/qr_verification/qr_verification_screen.dart';
import 'package:vibe_now/src/presentation/views/subscription/subscription_screen.dart';

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

    GoRoute(
      path: '/signin',
      name: RouteNames.signInScreen,
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/signup-onboarding',
      name: RouteNames.signUpOnBoardingScreen,
      builder: (context, state) => const StepNameScreen(),
    ),

    GoRoute(
      path: '/member-screen',
      name: RouteNames.memberScreen,
      builder: (context, state) => const MemberScreen(),
    ),

    GoRoute(
      path: "/main-nav-bar",
      name: RouteNames.mainNavBar,
      builder: (context, state) => const MainNavBarScreen(),
    ),

    GoRoute(
      path: "/community-screen",
      name: RouteNames.communityScreen,
      builder: (context, state) => const CommunityScreen(),
    ),

    GoRoute(
      path: '/create-community-screen',
      name: RouteNames.createCommunityScreen,
      builder: (context, state) => const CreateCommunityScreen(),
    ),
    GoRoute(
      path: '/community-details-screen',
      name: RouteNames.communityDetailsScreen,
      builder: (context, state) => const CommunityDetailsScreen(),
    ),

    GoRoute(
      path: '/event-screen',
      name: RouteNames.eventScreen,
      builder: (context, state) => const EventScreen(),
    ),

    GoRoute(
      path: '/create-event-screen',
      name: RouteNames.createEventScreen,
      builder: (context, state) => const CreateEventScreen(),
    ),

    GoRoute(
      path: '/qr-verification-screen',
      name: RouteNames.qrVerificationScreen,
      builder: (context, state) => const QRVerificationScreen(),
    ),
    GoRoute(
      path: '/subscription-screen',
      name: RouteNames.subscriptionScreen,
      builder: (context, state) => const SubscriptionScreen(),
    ),
  ],
);
