import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_now/core/constant/api_constant.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/category.dart';
import 'package:vibe_now/model/interest_model.dart';
import 'package:vibe_now/model/profile_model.dart';
import 'package:vibe_now/services/custom_http.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  final Rxn<UserAccount> account = Rxn<UserAccount>();

  final RxSet<String> expandedParents = <String>{}.obs;

  final RxSet<String> selectedSubcategories = <String>{}.obs;

  final RxList<Interest> interestGroups = <Interest>[
    Interest(
      parent: 'Lifestyle',
      children: [
        SubInterest(name: 'Coffee', icon: Assets.icons.coffee),
        SubInterest(name: 'Brunch', icon: Assets.icons.aiGame),
        SubInterest(name: 'Selfcare', icon: Assets.icons.coffee),
        SubInterest(name: 'Minimalism', icon: Assets.icons.organicFood),
        SubInterest(name: 'Journaling', icon: Assets.icons.book),
      ],
    ),

    Interest(
      parent: 'Entertainment',
      children: [
        SubInterest(name: 'Music', icon: Assets.icons.music),
        SubInterest(name: 'Concerts', icon: Assets.icons.music),
        SubInterest(name: 'Podcasts', icon: Assets.icons.block),
        SubInterest(name: 'Festivals', icon: Assets.icons.aiGame),
        SubInterest(name: 'Karaoke', icon: Assets.icons.acceptIc),
      ],
    ),

    Interest(
      parent: 'Culture',
      children: [
        SubInterest(name: 'Books', icon: Assets.icons.book),
        SubInterest(name: 'Reading', icon: Assets.icons.book),
        SubInterest(name: 'Writing', icon: Assets.icons.dumbbell),
        SubInterest(name: 'Museums', icon: Assets.icons.community),
        SubInterest(name: 'Languages', icon: Assets.icons.location),
      ],
    ),

    Interest(
      parent: 'Games & Tech',
      children: [
        SubInterest(name: 'Gaming', icon: Assets.icons.aiGame),
        SubInterest(name: 'Board Games', icon: Assets.icons.aiGame),
        SubInterest(name: 'Tech', icon: Assets.icons.book),
        SubInterest(name: 'Gadgets', icon: Assets.icons.aiGame),
        SubInterest(name: 'VR', icon: Assets.icons.book),
      ],
    ),
  ].obs;

  void addParentInterest({required String parentName}) {
    // Prevent duplicates
    final exists = interestGroups.any(
      (g) => g.parent.toLowerCase() == parentName.toLowerCase(),
    );

    if (exists) {
      AppSnackbar.show(
        message: 'Interest already exists',
        type: SnackType.info,
      );
      return;
    }

    interestGroups.add(Interest(parent: parentName, children: []));
  }

  void addSubInterest({
    required String parent,
    required SubInterest subInterest,
  }) {
    final index = interestGroups.indexWhere((g) => g.parent == parent);

    if (index == -1) return;

    interestGroups[index].children.add(subInterest);
    interestGroups.refresh();
  }

  void toggleExpand(String parent) {
    expandedParents.contains(parent)
        ? expandedParents.remove(parent)
        : expandedParents.add(parent);
  }

  void toggleParent(Interest group) {
    final allSelected = group.children.every(
      (c) => selectedSubcategories.contains(c),
    );

    if (allSelected) {
      selectedSubcategories.removeAll(group.children);
    } else {
      selectedSubcategories.addAll(group.children as Iterable<String>);
      expandedParents.add(group.parent);
    }
  }

  void toggleSubcategory(String sub, String parent) {
    selectedSubcategories.contains(sub)
        ? selectedSubcategories.remove(sub)
        : selectedSubcategories.add(sub);

    expandedParents.add(parent);
  }

  void clear() {
    expandedParents.clear();
    selectedSubcategories.clear();
  }

  bool isParentSelected(Interest group) {
    return group.children.every((c) => selectedSubcategories.contains(c));
  }

  bool isParentPartiallySelected(Interest group) {
    final selectedCount = group.children
        .where((c) => selectedSubcategories.contains(c))
        .length;

    return selectedCount > 0 && selectedCount < group.children.length;
  }

  // fetch profile data
  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final response = await CustomHttp.get(
        endpoint: ApiConstant.profile,
        need_auth: true,
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
}
