import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vibe_now/controller/auth_controller.dart';
import 'package:vibe_now/controller/chat_controller.dart';
import 'package:vibe_now/controller/community_controller.dart';
import 'package:vibe_now/controller/event_controller.dart';
import 'package:vibe_now/controller/home_controller.dart';
import 'package:vibe_now/controller/meetup_controller.dart';
import 'package:vibe_now/controller/notification_controller.dart';
import 'package:vibe_now/controller/onboarding_controller.dart';
import 'package:vibe_now/controller/profile_controller.dart';
import 'package:vibe_now/controller/vibe_controller.dart';
import 'package:vibe_now/controller/settings_controller.dart';
import 'package:vibe_now/controller/wave_controller.dart';
import 'package:vibe_now/localization/language_controller.dart';
import 'package:vibe_now/model/event.dart';

import 'package:vibe_now/controller/theme_controller.dart';

class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ThemeController(), permanent: true);
    Get.put(LanguageController(), permanent: true);
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<EventController>(() => EventController());
    Get.lazyPut<CommunityController>(() => CommunityController());
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<OnBoardingController>(() => OnBoardingController());
    Get.lazyPut<VibeController>(() => VibeController());
    Get.lazyPut<MeetupController>(() => MeetupController());
    Get.lazyPut<NotificationController>(() => NotificationController());
    Get.lazyPut<ChatController>(() => ChatController());
    Get.lazyPut<WaveController>(() => WaveController());
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
