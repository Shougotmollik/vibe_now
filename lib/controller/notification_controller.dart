import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_now/core/constant/api_constant.dart';
import 'package:vibe_now/services/custom_http.dart';

class NotificationController extends GetxController {
  var isLoading = false.obs;

  Future<void> getNotifications({required String tab}) async {
    try {
      isLoading.value = true;
      final response = await CustomHttp.get(
        endpoint: ApiConstant.notification,
        need_auth: true,
        queries: {'tab': tab},
      );
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
