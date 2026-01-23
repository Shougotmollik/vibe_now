import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/constant/qrcontext_enum.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/src/presentation/views/auth/intro_screen.dart';
import 'package:vibe_now/src/presentation/views/auth/sign_in_screen.dart';
import 'package:vibe_now/src/presentation/views/auth/sign_up_screen.dart';
import 'package:vibe_now/src/presentation/views/auth/splash_screen.dart';
import 'package:vibe_now/src/presentation/views/auth/steps/step_name_screen.dart';
import 'package:vibe_now/src/presentation/views/chat/chat_inbox_screen.dart';
import 'package:vibe_now/src/presentation/views/chat/chat_screen.dart';
import 'package:vibe_now/src/presentation/views/chat/report_screen.dart';
import 'package:vibe_now/src/presentation/views/chat/wave_screen.dart';
import 'package:vibe_now/src/presentation/views/community/community_details_screen.dart';
import 'package:vibe_now/src/presentation/views/community/community_screen.dart';
import 'package:vibe_now/src/presentation/views/community/create_community_screen.dart';
import 'package:vibe_now/src/presentation/views/community/member_screen.dart';
import 'package:vibe_now/src/presentation/views/event/create_event_screen.dart';
import 'package:vibe_now/src/presentation/views/event/event_screen.dart';
import 'package:vibe_now/src/presentation/views/main_nav_bar_screen.dart';
import 'package:vibe_now/src/presentation/views/notification/notification_screen.dart';
import 'package:vibe_now/src/presentation/views/profile/like_list_screen.dart';
import 'package:vibe_now/src/presentation/views/profile/locked_profile_screen.dart';
import 'package:vibe_now/src/presentation/views/profile/profile_screen.dart';
import 'package:vibe_now/src/presentation/views/profile/unlocked_profile_screen.dart';
import 'package:vibe_now/src/presentation/views/qr_verification/qr_verification_screen.dart';
import 'package:vibe_now/src/presentation/views/settings/delete_reason_screen.dart';
import 'package:vibe_now/src/presentation/views/settings/settings_screen.dart';
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
      builder: (context, state) => IntroScreen(),
    ),

    GoRoute(
      path: '/signin',
      name: RouteNames.signInScreen,
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: RouteNames.signUpScreen,
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/step-name',
      name: RouteNames.stepNameScreen,
      builder: (context, state) => StepNameScreen(),
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
      builder: (context, state) {
        final qrContext = state.extra as QRContext;
        return QRVerificationScreen(qrContext: qrContext);
      },
    ),
    GoRoute(
      path: '/subscription-screen',
      name: RouteNames.subscriptionScreen,
      builder: (context, state) => const SubscriptionScreen(),
    ),

    GoRoute(
      path: '/notification-screen',
      name: RouteNames.notificationScreen,
      builder: (context, state) => const NotificationScreen(),
    ),
    GoRoute(
      path: '/chat-screen',
      name: RouteNames.chatScreen,
      builder: (context, state) => const ChatScreen(),
    ),
    GoRoute(
      path: '/chat-inbox-screen',
      name: RouteNames.chatInboxScreen,
      builder: (context, state) => const ChatInboxScreen(),
    ),
    GoRoute(
      path: '/report-screen',
      name: RouteNames.reportScreen,
      builder: (context, state) => const ReportScreen(),
    ),
    GoRoute(
      path: '/profile-screen',
      name: RouteNames.profileScreen,
      builder: (context, state) => const ProfileScreen(isMyProfile: false),
    ),
    GoRoute(
      path: '/locked-profile-screen',
      name: RouteNames.lockedProfileScreen,
      builder: (context, state) => const LockedProfileScreen(),
    ),
    GoRoute(
      path: '/like-screen',
      name: RouteNames.likeScreen,
      builder: (context, state) => const LikeListScreen(),
    ),
    GoRoute(
      path: '/setting-screen',
      name: RouteNames.settingsScreen,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/wave-screen',
      name: RouteNames.waveScreen,
      builder: (context, state) => const WaveScreen(),
    ),
    GoRoute(
      path: '/reason-screen',
      name: RouteNames.reasonScreen,
      builder: (context, state) => const DeleteReasonScreen(),
    ),
  ],
);
