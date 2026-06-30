import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:vibe_now/core/constant/api_constant.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/model/vibe_model.dart';
import 'package:vibe_now/services/custom_http.dart';

class VibeController extends GetxController {
  var isLoading = false.obs;
  var isVibesLoading = false.obs;
  var isMoreLoading = false.obs;

  var ownVibe = Rxn<Vibe>();
  var othersVibe = <Vibe>[].obs;

  int currentPage = 1;
  int totalPages = 1;

  @override
  void onInit() {
    super.onInit();
    getVibes();
  }

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
      if (response.ok) {
        await getVibes();
        return true;
      } else {
        AppSnackbar.show(message: response.error ?? "Something went wrong");
        return false;
      }
    } catch (e) {
      debugPrint("Error while create vibe $e");
      return false;
    } finally {
      isLoading(false);
    }
  }

  // Get Vibes
  Future<void> getVibes({int page = 1}) async {
    try {
      if (page == 1) {
        isVibesLoading(true);
        othersVibe.clear();
      } else {
        isMoreLoading(true);
      }

      final response = await CustomHttp.get(
        endpoint: ApiConstant.vibe,
        queries: {'page': page},
      );

      if (response.ok) {
        final vibeModel = VibeModel.fromJson(response.data);
        if (vibeModel.data != null) {
          if (page == 1) {
            ownVibe.value = vibeModel.data?.ownVibe;
          }
          if (vibeModel.data?.othersVibe != null) {
            othersVibe.addAll(vibeModel.data!.othersVibe!);
          }
          currentPage = vibeModel.data?.page ?? 1;
          totalPages = vibeModel.data?.totalPages ?? 1;
        }
      }
    } catch (e) {
      debugPrint("Error while getting vibes: $e");
    } finally {
      isVibesLoading(false);
      isMoreLoading(false);
    }
  }

  void loadMore() {
    if (currentPage < totalPages && !isMoreLoading.value) {
      getVibes(page: currentPage + 1);
    }
  }

  // End vibe
  Future<bool> endVibe(int vibeId) async {
    try {
      isLoading(true);
      final response = await CustomHttp.post(
        endpoint: "${ApiConstant.vibe}/$vibeId/end",
      );
      if (response.ok) {
        ownVibe.value = null;
        await getVibes();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error while ending vibe $e");
      return false;
    } finally {
      isLoading(false);
    }
  }

  // send wave
  Future<bool> sendWave({required int vibeId}) async {
    try {
      isLoading(true);
      final response = await CustomHttp.post(
        endpoint: ApiConstant.wave(vibeId: vibeId),
      );
      if (response.ok) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Error while sending wave $e");
      return false;
    } finally {
      isLoading(false);
    }
  }
}
