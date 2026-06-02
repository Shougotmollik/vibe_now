import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_now/core/constant/api_constant.dart';
import 'package:vibe_now/model/meetup.dart';
import 'package:vibe_now/services/custom_http.dart';

class MeetupController extends GetxController {
  var isLoading = false.obs;
  final RxList<Meetup> meetupList = <Meetup>[].obs;

  final RxString createdMeetupId = ''.obs;

  // create meetupplan
  Future<String?> createMeetupPlan({
    required String communityId,
    required File coverImage,
    required String title,
    required String description,
    required String address,
    required String latitude,
    required String longitude,
    required String meetUpDate,
    required String meetUpTime,
    required String maxMembers,
  }) async {
    try {
      isLoading(true);
      final response = await CustomHttp.multipart(
        endpoint: "${ApiConstant.community}/$communityId/meetups/create",
        fieldName: 'cover_image',
        method: 'POST',
        fields: {
          'title': title,
          'description': description,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'meetup_date': meetUpDate,
          'meetup_time': meetUpTime,
          'max_attendees': maxMembers,
        },
        filePath: coverImage.path,
      );

      if (response.ok) {
        final meetupId = response.data['data']['id'].toString();
        createdMeetupId.value = meetupId;
        return meetupId;
      }
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    } finally {
      isLoading(false);
    }
  }

  // get meetup plans
  Future<void> getMeetups({required int communityId}) async {
    try {
      isLoading(true);
      final response = await CustomHttp.get(
        endpoint: "${ApiConstant.community}/$communityId/meetups",
      );

      if (response.ok) {
        final results = response.data['data']['results'] as List;
        meetupList.value = results.map((e) => Meetup.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading(false);
    }
  }

  // join meetup
  Future<bool> joinMeetup({required String meetupId}) async {
    try {
      isLoading(true);
      final response = await CustomHttp.post(
        endpoint: "/meetups/$meetupId/join",
      );

      return response.ok;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    } finally {
      isLoading(false);
    }
  }

  final Rx<Meetup?> meetupDetails = Rx<Meetup?>(null);

  // meetup details
  Future<Meetup?> getMeetupDetails({required String meetupId}) async {
    try {
      isLoading(true);
      final response = await CustomHttp.get(endpoint: "/meetups/$meetupId");

      if (response.ok) {
        final data = response.data['data'] as Map<String, dynamic>;
        final meetup = Meetup.fromJson(data);
        meetupDetails.value = meetup;
        return meetup;
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      isLoading(false);
    }
    return null;
  }

  final RxList<MeetupParticipant> meetupMembers = <MeetupParticipant>[].obs;
  final isMeetupMembersLoading = false.obs;

  // meetup members
  Future<void> getMeetupMembers({
    required String meetupId,
    required String tab,
    int page = 1,
    int pageSize = 10,
    bool showLoading = true,
  }) async {
    if (showLoading) isMeetupMembersLoading(true);
    final response = await CustomHttp.get(
      endpoint: "/meetups/$meetupId/members",
      queries: {
        'tab': tab,
        'page': page.toString(),
        'page_size': pageSize.toString(),
      },
    );
    if (response.ok) {
      final data = response.data['data'];
      final List results = data is List ? data : data['results'] ?? [];
      meetupMembers.assignAll(
        results.map((e) => MeetupParticipant.fromJson(e)),
      );
    }
    if (showLoading) isMeetupMembersLoading(false);
  }

  // invite member to meetup plan
  Future<bool> inviteMemberToMeetupPlan({
    required String meetupId,
    required List<String> memberIds,
  }) async {
    try {
      isLoading(true);
      final response = await CustomHttp.post(
        endpoint: "/meetups/$meetupId/invite",
        body: {'user_ids': memberIds},
      );
      return response.ok;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    } finally {
      isLoading(false);
    }
  }
}
