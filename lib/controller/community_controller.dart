import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_now/core/constant/api_constant.dart';
import 'package:vibe_now/model/category.dart';
import 'package:vibe_now/model/community.dart';
import 'package:vibe_now/services/custom_http.dart';

class CommunityController extends GetxController {
  final RxSet<String> expandedParents = <String>{}.obs;

  final RxSet<String> selectedSubcategories = <String>{}.obs;

  final RxList<CategoryGroup> categoryGroups = [
    CategoryGroup(
      parent: 'Social & Connection',
      children: [
        'Meetups',
        'New Friends',
        'Expats',
        'Language Exchange',
        'Hangouts',
      ],
    ),
    CategoryGroup(
      parent: 'Sports & Movement',
      children: [
        'Running',
        'Gym',
        'Yoga / Pilates',
        'Team Sports',
        'Hiking',
        'Cycling',
      ],
    ),
    CategoryGroup(
      parent: 'Food & Drink',
      children: ['Dinner', 'Lunch', 'Desserts', 'Drinks', 'Snacks'],
    ),
  ].obs;

  void addParentCategory(String name) {
    final exists = categoryGroups.any((e) => e.parent == name);
    if (exists) return;

    categoryGroups.add(CategoryGroup(parent: name, children: []));
  }

  void addSubCategory({required String parent, required String subCategory}) {
    final index = categoryGroups.indexWhere((e) => e.parent == parent);
    if (index == -1) return;

    final children = categoryGroups[index].children;

    if (!children.contains(subCategory)) {
      children.add(subCategory);
      categoryGroups.refresh();
    }
  }

  void toggleExpand(String parent) {
    expandedParents.contains(parent)
        ? expandedParents.remove(parent)
        : expandedParents.add(parent);
  }

  void toggleParent(CategoryGroup group) {
    final allSelected = group.children.every(
      (c) => selectedSubcategories.contains(c),
    );

    if (allSelected) {
      selectedSubcategories.removeAll(group.children);
    } else {
      selectedSubcategories.addAll(group.children);
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

  bool isParentSelected(CategoryGroup group) {
    return group.children.every((c) => selectedSubcategories.contains(c));
  }

  bool isParentPartiallySelected(CategoryGroup group) {
    final selectedCount = group.children
        .where((c) => selectedSubcategories.contains(c))
        .length;

    return selectedCount > 0 && selectedCount < group.children.length;
  }

  // Api functions
  var isLoading = false.obs;
  final RxList<Community> communityList = <Community>[].obs;

  // Get communities
  Future<void> getCommunities({
    String tab = 'all',
    String search = '',
    int page = 1,
    int pageSize = 10,
  }) async {
    isLoading(true);

    final response = await CustomHttp.get(
      need_auth: true,
      endpoint: ApiConstant.community,
      queries: {
        'tab': tab,
        'search': search,
        'page': page.toString(),
        'page_size': pageSize.toString(),
      },
    );

    if (response.ok) {
      final jsonData = response.data['data']['results'];

      communityList.assignAll(
        List<Community>.from(jsonData.map((e) => Community.fromJson(e))),
      );
    } else {
      debugPrint('Error fetching communities: ${response.error}');
    }
    isLoading(false);
  }

  // Create community
  Future<bool> createEvent({
    required File coverImage,
    required String title,
    required String categories,
    required String description,
    required String rules,
    required String address,
    required String latitude,
    required String longitude,
    required String communityDate,
    required String communityTime,
    required String maxAttendees,
  }) async {
    try {
      isLoading(true);

      final response = await CustomHttp.multipart(
        need_auth: true,
        endpoint: ApiConstant.createCommunity,
        fieldName: 'cover_image',
        filePath: coverImage.path,
        method: 'POST',
        fields: {
          'title': title,
          'description': description,
          'rules': rules,
          'categories': categories,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'community_date': communityDate,
          'community_time': communityTime,
          'max_attendees': maxAttendees,
        },
      );

      return response.ok;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    } finally {
      isLoading(false);
    }
  }

  // Join community
  Future<bool> communityJoin({required int id}) async {
    try {
      isLoading(true);
      final response = await CustomHttp.post(
        need_auth: true,
        endpoint: "${ApiConstant.community}/$id/join-request",
      );
      if (response.ok) {
        return true;
      } else {
        debugPrint("Error joining community: ${response.error}");
        return false;
      }
    } catch (e) {
      debugPrint("Exception while joining community: $e");
      return false;
    } finally {
      isLoading(false);
    }
  }

  // Leave community
  Future<bool> communityLeave({required int id}) async {
    try {
      isLoading(true);
      final response = await CustomHttp.post(
        need_auth: true,
        endpoint: "${ApiConstant.community}/$id/leave",
      );
      if (response.ok) {
        return true;
      } else {
        debugPrint("Error leaving community: ${response.error}");
        return false;
      }
    } catch (e) {
      debugPrint("Exception while leaving community: $e");
      return false;
    } finally {
      isLoading(false);
    }
  }

  // Mark community as interested
  Future<bool> communityInterest({required int id}) async {
    try {
      final response = await CustomHttp.post(
        need_auth: true,
        endpoint: "${ApiConstant.community}/$id/interest",
      );
      if (response.ok) {
        return true;
      } else {
        debugPrint("Error marking interest: ${response.error}");
        return false;
      }
    } catch (e) {
      debugPrint("Exception while marking interest: $e");
      return false;
    }
  }

  // Withdraw join request
  Future<bool> communityJoinWithdraw({required int id}) async {
    try {
      isLoading(true);
      final response = await CustomHttp.post(
        need_auth: true,
        endpoint: "${ApiConstant.community}/$id/withdraw-request",
      );
      if (response.ok) {
        return true;
      } else {
        debugPrint("Error withdrawing request: ${response.error}");
        return false;
      }
    } catch (e) {
      debugPrint("Exception while withdrawing request: $e");
      return false;
    } finally {
      isLoading(false);
    }
  }
}
