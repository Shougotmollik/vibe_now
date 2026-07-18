import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_now/core/constant/api_constant.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/blocked_user.dart';
import 'package:vibe_now/model/category.dart';
import 'package:vibe_now/model/interest_model.dart';
import 'package:vibe_now/model/profile_model.dart';
import 'package:vibe_now/services/custom_http.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  final Rxn<UserAccount> account = Rxn<UserAccount>();

  // ---- Flat interest picker (used in edit mode) ----

  final RxList<FlatInterest> flatInterests = <FlatInterest>[].obs;
  final RxSet<String> selectedInterestNames = <String>{}.obs;
  final RxBool isFlatInterestsLoading = false.obs;
  final RxString interestSearchQuery = ''.obs;

  /// Fetch the full flat list from GET /interests and populate
  /// [selectedInterestNames] from the current profile.
  Future<void> fetchFlatInterests() async {
    try {
      isFlatInterestsLoading.value = true;
      final response = await CustomHttp.get(
        endpoint: ApiConstant.interest,
        need_auth: true,
      );
      if (response.ok) {
        final data = response.data['data'] as List<dynamic>? ?? [];
        flatInterests.value = data
            .map((e) => FlatInterest.fromJson(e as Map<String, dynamic>))
            .toList();

        // Seed selected set from current profile interests
        final currentInterests = account.value?.profile.interests ?? [];
        selectedInterestNames.assignAll(currentInterests.toSet());
      }
    } catch (e) {
      debugPrint('ProfileController.fetchFlatInterests error: $e');
    } finally {
      isFlatInterestsLoading.value = false;
    }
  }

  /// Maximum number of interests a user can select.
  static const int maxInterestSelection = 10;

  /// Deselect all interests.
  void clearAllInterests() {
    selectedInterestNames.clear();
  }

  /// Toggle a single interest name on/off.
  /// If already at max capacity and trying to add, shows a snackbar.
  void toggleInterestSelection(String name) {
    if (selectedInterestNames.contains(name)) {
      selectedInterestNames.remove(name);
    } else if (selectedInterestNames.length >= maxInterestSelection) {
      final loc = Get.context != null
          ? AppLocalizations.of(Get.context!)
          : null;
      final msg = loc != null
          ? loc
                .translate('maxInterestSelection')
                .replaceFirst('{count}', maxInterestSelection.toString())
          : 'You can select a maximum of $maxInterestSelection interests';
      AppSnackbar.show(message: msg, type: SnackType.info);
    } else {
      selectedInterestNames.add(name);
    }
  }

  /// Save all profile fields via the PATCH endpoint.
  Future<bool> updateFullProfile({
    required String fullName,
    required String bio,
    required String dateOfBirth,
    required String gender,
    double? latitude,
    double? longitude,
    String? locationName,
    required List<String> lookingFor,
  }) async {
    try {
      isLoading.value = true;

      final body = {
        'full_name': fullName,
        'bio': bio,
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'latitude': latitude,
        'longitude': longitude,
        'location_name': locationName,
        'what_are_you_looking_for': lookingFor,
        'interests': selectedInterestNames.toList(),
      };

      final response = await CustomHttp.patch(
        endpoint: ApiConstant.profileUpdate,
        need_auth: true,
        body: body,
      );

      if (response.ok) {
        await fetchProfile();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('ProfileController.updateFullProfile error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Clears profile data on logout so stale data is never shown.
  void clearProfile() {
    account.value = null;
  }

  // fetch profile data
  Future<void> fetchProfile({String? targetUserId}) async {
    try {
      isLoading.value = true;
      final Map<String, dynamic>? queries = targetUserId != null
          ? {'target_user_id': targetUserId}
          : null;
      final response = await CustomHttp.get(
        endpoint: ApiConstant.profile,
        need_auth: true,
        queries: queries,
      );
      if (response.ok) {
        final data = response.data['data'];
        if (data != null) {
          account.value = UserAccount.fromJson(data);
        }
      }
    } catch (e) {
      debugPrint('ProfileController.fetchProfile error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      isLoading.value = true;
      final response = await CustomHttp.post(
        endpoint: ApiConstant.changePassword,
        need_auth: true,
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );
      if (response.ok) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('ProfileController.changePassword error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // update profile image (primary photo)
  Future<bool> updateProfileImage(File image) async {
    try {
      isLoading(true);
      final response = await CustomHttp.multipart(
        endpoint: ApiConstant.updateProfileImage,
        fieldName: "image",
        method: "POST",
        filePath: image.path,
        need_auth: true,
      );
      if (response.ok) {
        await fetchProfile();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('ProfileController.updateProfileImage error: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  // block  user
  Future<bool> blockUser({
    required String userId,
    required String reason,
  }) async {
    try {
      isLoading.value = true;
      final response = await CustomHttp.post(
        endpoint: ApiConstant.blockUser,
        need_auth: true,
        body: {"target_user_id": userId, "reason": reason},
      );
      if (response.ok) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('ProfileController.blockUser error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // blocked user
  final RxList<BlockedUser> blockedUsers = <BlockedUser>[].obs;
  final blockedUsersLoading = false.obs;
  final unblockingUserId = Rxn<int>();

  Future<void> fetchBlockedUsers({int page = 1, int pageSize = 10}) async {
    try {
      blockedUsersLoading.value = true;
      final response = await CustomHttp.get(
        endpoint: ApiConstant.blockUserList,
        need_auth: true,
        queries: {'page': page.toString(), 'page_size': pageSize.toString()},
      );
      if (response.ok) {
        final data = response.data['data'];
        if (data != null) {
          final results = data['results'] as List? ?? [];
          blockedUsers.value = results
              .map((e) => BlockedUser.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('ProfileController.fetchBlockedUsers error: $e');
    } finally {
      blockedUsersLoading.value = false;
    }
  }

  // Report a user
  Future<bool> reportUser({
    required String reportedUserId,
    required String reason,
    required String details,
  }) async {
    try {
      isLoading.value = true;
      final response = await CustomHttp.post(
        endpoint: ApiConstant.reportUser,
        body: {
          'reported_user_id': reportedUserId,
          'reason': reason,
          'details': details,
        },
        show_floating_error: false,
      );
      return response.ok;
    } catch (e) {
      debugPrint('ProfileController.reportUser error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Unblock a user by their block record ID.
  Future<bool> unblockUser({
    required String targetUserId,
    required int blockRecordId,
  }) async {
    try {
      unblockingUserId.value = blockRecordId;
      final response = await CustomHttp.post(
        endpoint: ApiConstant.unblockUser,
        need_auth: true,
        show_floating_error: false,
        body: {"target_user_id": targetUserId},
      );
      if (response.ok) {
        blockedUsers.removeWhere((u) => u.id == blockRecordId);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('ProfileController.unblockUser error: $e');
      return false;
    } finally {
      unblockingUserId.value = null;
    }
  }
}
