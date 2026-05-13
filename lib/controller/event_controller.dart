import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_now/core/constant/api_constant.dart';
import 'package:vibe_now/model/category.dart';
import 'package:vibe_now/model/event.dart';
import 'package:vibe_now/model/event_participants.dart';
import 'package:vibe_now/services/custom_http.dart';

class EventController extends GetxController {
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
  final RxList<Event> eventList = <Event>[].obs;
  final Rx<Event?> eventDetails = Rx<Event?>(null);

  // create Event
  Future<bool> createEvent({
    required File coverImage,
    required String title,
    required String categories,
    required String accessLevel,
    required String address,
    required String latitude,
    required String longitude,
    required String eventDate,
    required String eventTime,
    required String maxAttendees,
  }) async {
    try {
      isLoading(true);

      final response = await CustomHttp.multipart(
        need_auth: true,
        endpoint: ApiConstant.createEvent,
        fieldName: 'cover_image',
        filePath: coverImage.path,
        method: 'POST',
        fields: {
          'title': title,
          'categories': categories,
          'access_level': accessLevel,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'event_date': eventDate,
          'event_time': eventTime,
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

  // get Events
  Future<void> getEvents({
    String tab = 'all',
    String search = '',
    int page = 1,
    int pageSize = 10,
  }) async {
    isLoading(true);

    final response = await CustomHttp.get(
      need_auth: true,
      endpoint: ApiConstant.event,
      queries: {
        'tab': tab,
        'search': search,
        'page': page.toString(),
        'page_size': pageSize.toString(),
      },
    );

    if (response.ok) {
      final jsonData = response.data['data']['results'];

      eventList.assignAll(
        List<Event>.from(jsonData.map((e) => Event.fromJson(e))),
      );
    } else {
      debugPrint('Error fetching events: ${response.error}');
    }

    isLoading(false);
  }

  // get event details
  Future<void> getEventDetails({required int id}) async {
    isLoading(true);

    final response = await CustomHttp.get(endpoint: "${ApiConstant.event}/$id");

    if (response.ok) {
      final jsonData = response.data['data'];
      eventDetails.value = Event.fromJson(jsonData);
    } else {
      debugPrint("Error fetching event details ${response.error}");
    }
    isLoading(false);
  }

  // update event
  Future<bool> updateEvent({
    required int id,
    File? coverImage,
    required String title,
    required String categories,
    required String accessLevel,
    required String address,
    required String latitude,
    required String longitude,
    required String eventDate,
    required String eventTime,
    required String maxAttendees,
  }) async {
    try {
      isLoading(true);

      // Check if user selected a new image
      final bool hasNewImage = coverImage != null && coverImage.path.isNotEmpty;

      final response = await CustomHttp.multipart(
        need_auth: true,
        endpoint: "${ApiConstant.event}/$id/update",
        fieldName: hasNewImage ? 'cover_image' : '',
        filePath: hasNewImage ? coverImage.path : null,
        method: 'PATCH',
        fields: {
          'title': title,
          'categories': categories,
          'access_level': accessLevel,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'event_date': eventDate,
          'event_time': eventTime,
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

  // join event
  Future<bool> eventJoin({required int id}) async {
    try {
      isLoading(true);
      final response = await CustomHttp.post(
        need_auth: true,
        endpoint: "${ApiConstant.event}/$id/join",
      );
      if (response.ok) {
        return true;
      } else {
        debugPrint("Error joining event: ${response.error}");
        return false;
      }
    } catch (e) {
      debugPrint("Exception while joining event: $e");
      return false;
    } finally {
      isLoading(false);
    }
  }

  // interest event
  Future<bool> eventInterest({required int id}) async {
    try {
      isLoading(true);
      final response = await CustomHttp.post(
        endpoint: "${ApiConstant.event}/$id/interest",
      );
      if (response.ok) {
        return true;
      } else {
        debugPrint("Error interest event ${response.error}");
        return false;
      }
    } catch (e) {
      debugPrint("Exception while interesting event$e");
      return false;
    } finally {
      isLoading(false);
    }
  }

  // leave from event
  Future<bool> eventLeave({required int id}) async {
    try {
      isLoading(true);
      final response = await CustomHttp.post(
        endpoint: "${ApiConstant.event}/$id/leave",
      );
      if (response.ok) {
        return true;
      } else {
        debugPrint("Error leaving event${response.error}");
        return false;
      }
    } catch (e) {
      debugPrint("Exception while leaving event $e");
      return false;
    } finally {
      isLoading(true);
    }
  }

  // Get event participant
  var isLoadingParticipants = false.obs;
  final RxList<ParticipantData> joinedParticipants = <ParticipantData>[].obs;
  final RxList<ParticipantData> requestedParticipants = <ParticipantData>[].obs;
  EventCreator? eventCreator;

  Future<void> getEventParticipants({required int eventId, String? tab}) async {
    try {
      isLoadingParticipants(true);

      Map<String, String>? queries;
      if (tab != null) {
        queries = {'tab': tab};
      }

      // Single API call - with or without tab parameter
      final response = await CustomHttp.get(
        need_auth: true,
        endpoint: "${ApiConstant.event}/$eventId/manage-requests",
        queries: queries,
      );

      if (response.ok) {
        final data = response.data['data'];
        eventCreator = data['event_creator'] != null
            ? EventCreator.fromJson(data['event_creator'])
            : null;

        final participants = (data['participants'] as List?)
                ?.map((p) => ParticipantData.fromJson(p))
                .toList() ??
            [];

        // If tab is specified, filter accordingly, otherwise get all
        if (tab != null) {
          if (tab == 'joined') {
            joinedParticipants.assignAll(participants);
          } else if (tab == 'requested') {
            requestedParticipants.assignAll(participants);
          }
        } else {
          // No tab - split participants by status
          joinedParticipants.assignAll(
            participants.where((p) => p.status == 'joined').toList(),
          );
          requestedParticipants.assignAll(
            participants.where((p) => p.status == 'requested').toList(),
          );
        }
      }
    } catch (e) {
      debugPrint("Error while fetching event participant $e ");
    } finally {
      isLoadingParticipants(false);
    }
  }
}
