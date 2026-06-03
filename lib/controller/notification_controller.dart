import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_now/core/constant/api_constant.dart';
import 'package:vibe_now/model/notification.dart';
import 'package:vibe_now/services/custom_http.dart';

class NotificationController extends GetxController {
  final RxMap<String, bool> loadingTabs = <String, bool>{
    'vibes': false,
    'events': false,
    'communities': false,
  }.obs;
  final RxList<NotificationModel> events = <NotificationModel>[].obs;
  final RxList<NotificationModel> communities = <NotificationModel>[].obs;
  final RxList<NotificationModel> vibes = <NotificationModel>[].obs;

  final RxSet<String> loadedTabs = <String>{}.obs;
  final Rx<UnreadCounts> unreadCounts = UnreadCounts().obs;
  final Rx<NotificationStats> stats = NotificationStats().obs;

  bool isLoading(String tab) => loadingTabs[tab] ?? false;

  Future<void> getNotifications(String tab) async {
    if (loadedTabs.contains(tab)) return;
    try {
      loadingTabs[tab] = true;
      final response = await CustomHttp.get(
        endpoint: ApiConstant.notification,
        need_auth: true,
        queries: {'tab': tab},
      );
      if (response.ok) {
        final data = response.data['data'];
        if (data['unread_counts'] != null) {
          unreadCounts.value = UnreadCounts.fromJson(data['unread_counts']);
        }
        if (data['stats'] != null) {
          stats.value = NotificationStats.fromJson(data['stats']);
        }
        final tabData = data['results']?[tab];
        if (tabData == null) return;
        final items = (tabData['items'] as List)
            .map((e) => NotificationModel.fromJson(e))
            .toList();
        switch (tab) {
          case 'events':
            events.assignAll(items);
          case 'communities':
            communities.assignAll(items);
          case 'vibes':
            vibes.assignAll(items);
        }
        loadedTabs.add(tab);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      loadingTabs[tab] = false;
    }
  }
}
