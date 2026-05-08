import 'dart:io';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vibe_now/core/constant/api_constant.dart';
import 'package:vibe_now/services/custom_http.dart';

class OnBoardingController extends GetxController {
  var isLoading = false.obs;
  static final OnBoardingController _instance =
      OnBoardingController._internal();
  factory OnBoardingController() => _instance;
  OnBoardingController._internal();

  // Fields
  String fullName = "";
  String dob = "";
  String gender = "male";
  List<String> lookingFor = [];
  List<String> interests = [];

  // Helper to format date for backend (DD/MM/YYYY -> YYYY-MM-DD)
  String _formatDate(String date) {
    try {
      DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(date);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  Map<String, dynamic> toOnboarding() {
    return {
      "full_name": fullName,
      "date_of_birth": _formatDate(dob),
      "gender": gender.toLowerCase(),
      "what_are_you_looking_for": lookingFor,
      "interests": interests,
    };
  }

  // onboarding api data submit

  Future<bool> onboardingDataSubmit() async {
    isLoading.value = true;
    final response = await CustomHttp.post(
      endpoint: ApiConstant.onboarding,
      need_auth: true,
      body: toOnboarding(),
    );
    isLoading.value = false;
    if (response.ok) {
      return true;
    } else {
      return false;
    }
  }

  // onboarding image submit
  Future<bool> onboardingImageSubmit(List<File> images) async {
    isLoading.value = true;
    final response = await CustomHttp.multipart(
      endpoint: ApiConstant.onboardingImage,
      fieldName: "images",
      method: "POST",
      filePaths: images.map((e) => e.path).toList(),
      need_auth: true,
    );
    isLoading.value = false;
    if (response.ok) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onboardingLocationSubmit({
    required double latitude,
    required double longitude,
    String? locationName,
  }) async {
    isLoading(true);
    final response = await CustomHttp.post(
      endpoint: ApiConstant.onboardingLocation,
      body: {
        "latitude": latitude,
        "longitude": longitude,
        if (locationName != null) "location_name": locationName,
      },
    );
    isLoading(false);
    if (response.ok) {
      return true;
    } else {
      return false;
    }
  }
}
