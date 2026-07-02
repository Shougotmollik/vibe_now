class ApiConstant {
  static const String signup = "/auth/sign-up";
  static const String verifyEmail = "/auth/verify-email";
  static const String resentOtp = "/auth/resend-verification-code";
  static const String signIn = "/auth/sign-in";
  static const String refreshToken = "/auth/refresh";
  static const String forgetPassword = "/auth/forgot-password";
  static const String forgetOtpVerification = "/auth/verify-reset-code";
  static const String resetPassword = "/auth/reset-password";
  static const String changePassword = "/auth/change-password";

  static const String onboarding = "/onboarding/complete";
  static const String onboardingImage = "/onboarding/upload-photos";
  static const String onboardingLocation = "/onboarding/location-setup";
  static const String currentLocation = "/onboarding/current-location";

  static const String createEvent = "/events/create";
  static const String event = "/events";

  static const String createCommunity = "/communities/create";
  static const String community = "/communities";
  static String communitiesAwaitings({required int communityId}) =>
      "/communities/$communityId/request-status";

  static const String waves = "/vibes/wave-list";
  static String waveOperation({required int waveId}) =>
      "/vibes/wave/$waveId/moderate";

  static const String vibe = "/vibes";
  static String wave({required int vibeId}) => "/vibes/$vibeId/send-wave";

  static const String notification = "/notifications";
  static const String markNotificationAsRead = "/notifications/mark-as-read";
  static const String notificationActionPath = "/notifications";

  static const String profile = "/auth/me";
  static const String updateProfileImage = "/onboarding/upload-profile-photo";

  static const String chat = "/chats";

  // WebSocket
  static const String chatSocket = "/ws/chat/";
  static const String chatListSocket = "/ws/chat/list/";
}
