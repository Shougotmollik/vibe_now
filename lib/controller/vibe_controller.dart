import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:vibe_now/core/constant/api_constant.dart';
import 'package:vibe_now/services/custom_http.dart';

class VibeController extends GetxController {
  var isLoading = false.obs;

  // Create vibe
  Future<bool> createVibe({
    required File coverImage,
    required String title,
    required String duration,
  }) async {
    try {
      isLoading(true);

      final response = await CustomHttp.multipart(
        endpoint: "${ApiConstant.vibe}/create",
        fieldName: "cover_image",
        filePath: coverImage.path,
        method: "POST",
        fields: {'title': title, 'duration': duration},
      );
      return response.ok;
    } catch (e) {
      debugPrint("Error while create vibe $e");
      return false;
    } finally {
      isLoading(false);
    }
  }
}
