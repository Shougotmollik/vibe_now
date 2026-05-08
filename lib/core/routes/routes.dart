import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/constant/qrcontext_enum.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/env.dart';
import 'package:vibe_now/model/community.dart';
import 'package:vibe_now/model/event.dart';
import 'package:vibe_now/services/local_storage.dart';
import 'package:vibe_now/views/auth/email_verification_screen.dart';
import 'package:vibe_now/views/auth/intro_screen.dart';
import 'package:vibe_now/views/auth/new_password_screen.dart';
import 'package:vibe_now/views/auth/otp_verification_screen.dart';
import 'package:vibe_now/views/auth/sign_in_screen.dart';
import 'package:vibe_now/views/auth/sign_up_screen.dart';
import 'package:vibe_now/views/auth/signup_otp_verification_screen.dart';
import 'package:vibe_now/views/auth/splash_screen.dart';
import 'package:vibe_now/views/auth/steps/step_name_screen.dart';
import 'package:vibe_now/views/auth/steps/step_upload_image_screen.dart';
import 'package:vibe_now/views/chat/block_screen.dart';
import 'package:vibe_now/views/chat/chat_inbox_screen.dart';
import 'package:vibe_now/views/chat/chat_screen.dart';
import 'package:vibe_now/views/chat/community_chat_inbox_screen.dart';
import 'package:vibe_now/views/chat/report_screen.dart';
import 'package:vibe_now/views/chat/chat_wave_screen.dart';
import 'package:vibe_now/views/community/community_details_screen.dart';
import 'package:vibe_now/views/community/community_screen.dart';
import 'package:vibe_now/views/community/create_community_screen.dart';
import 'package:vibe_now/views/community/community_member_screen.dart';
import 'package:vibe_now/views/event/create_event_screen.dart';
import 'package:vibe_now/views/event/edit_event_screen.dart';
import 'package:vibe_now/views/event/event_details_screen.dart';
import 'package:vibe_now/views/event/event_screen.dart';
import 'package:vibe_now/views/main_nav_bar_screen.dart';
import 'package:vibe_now/views/notification/notification_screen.dart';
import 'package:vibe_now/views/profile/like_list_screen.dart';
import 'package:vibe_now/views/profile/locked_profile_screen.dart';
import 'package:vibe_now/views/profile/profile_screen.dart';
import 'package:vibe_now/views/qr_verification/qr_verification_screen.dart';
import 'package:vibe_now/views/settings/delete_confirm_screen.dart';
import 'package:vibe_now/views/settings/delete_reason_screen.dart';
import 'package:vibe_now/views/settings/settings_screen.dart';
import 'package:vibe_now/views/subscription/subscription_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

late GoRouter appRouter;

void setupRouter(bool hasToken) {
  appRouter = GoRouter(
    initialLocation: hasToken ? '/main-nav-bar' : '/',
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
        path: '/email-verification',
        name: RouteNames.emailVerificationScreen,
        builder: (context, state) => const EmailVerificationScreen(),
      ),

      GoRoute(
        path: "/signup-otp-verification",
        name: RouteNames.signupOtpVerificationScreen,
        builder: (context, state) => const SignupOtpVerificationScreen(),
      ),
      GoRoute(
        path: '/otp-verification',
        name: RouteNames.otpVerificationScreen,
        builder: (context, state) => OtpVerificationScreen(),
      ),
      GoRoute(
        path: '/new-password',
        name: RouteNames.newPasswordScreen,
        builder: (context, state) => const NewPasswordScreen(),
      ),
      GoRoute(
        path: '/step-name',
        name: RouteNames.stepNameScreen,
        builder: (context, state) => StepNameScreen(),
      ),
      GoRoute(
        path: '/step-photo-upload',
        name: RouteNames.stepPhotoUploadScreen,
        builder: (context, state) => const StepUploadImageScreen(),
      ),

      GoRoute(
        path: '/member-screen',
        name: RouteNames.communityMemberScreen,
        builder: (context, state) => const CommunityMembersScreen(),
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
        builder: (context, state) {
          final community = state.extra as Community;
          return CommunityDetailsScreen(community: community);
        },
      ),

      GoRoute(
        path: '/event-screen',
        name: RouteNames.eventScreen,
        builder: (context, state) => const EventScreen(),
      ),

      GoRoute(
        path: '/event-details-screen',
        name: RouteNames.eventDetailsScreen,
        builder: (context, state) =>
            EventDetailsScreen(event: state.extra as Event),
      ),

      GoRoute(
        path: "/edit-event-screen",
        name: RouteNames.editEventScreen,
        builder: (context, state) {
          final event = state.extra as Event;
          return EditEventScreen(event: event);
        },
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
        path: '/community-chat-screen',
        name: RouteNames.communityChatScreen,
        builder: (context, state) => const CommunityChatInboxScreen(),
      ),
      GoRoute(
        path: '/report-screen',
        name: RouteNames.reportScreen,
        builder: (context, state) => const ReportScreen(),
      ),
      GoRoute(
        path: '/block-screen',
        name: RouteNames.blockScreen,
        builder: (context, state) => const BlockScreen(),
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
        builder: (context, state) => const ChatWaveScreen(),
      ),
      GoRoute(
        path: '/reason-screen',
        name: RouteNames.reasonScreen,
        builder: (context, state) => const DeleteReasonScreen(),
      ),

      GoRoute(
        path: '/delete-confirm-screen',
        name: RouteNames.deleteConfirmScreen,
        builder: (context, state) => const DeleteConfirmScreen(),
      ),
    ],
  );
}
