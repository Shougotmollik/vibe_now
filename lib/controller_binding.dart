import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vibe_now/controller/community_controller.dart';
import 'package:vibe_now/controller/event_controller.dart';
import 'package:vibe_now/controller/home_controller.dart';
import 'package:vibe_now/controller/profile_controller.dart';
import 'package:vibe_now/model/event.dart';

import 'package:vibe_now/controller/theme_controller.dart';

class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ThemeController(), permanent: true);
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<EventController>(() => EventController());
    Get.lazyPut<CommunityController>(() => CommunityController());
  }
}
