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

  // get notification
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

  //read notification by id
  Future<void> readNotificationById({required List<int> ids}) async {
    try {
      for (final id in ids) {
        loadingTabs[_tabForNotificationId(id)] = true;
      }
      final response = await CustomHttp.post(
        endpoint: ApiConstant.markNotificationAsRead,
        need_auth: true,
        body: {'notification_ids': ids},
      );
      if (response.ok) {
        _updateReadState(ids, true);
        _decrementUnreadCounts(ids);
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      for (final id in ids) {
        loadingTabs[_tabForNotificationId(id)] = false;
      }
    }
  }

  // notification action (approve | reject)
  Future<bool> notificationAction({
    required int notificationId,
    required String action,
  }) async {
    try {
      loadingTabs[_tabForNotificationId(notificationId)] = true;
      final response = await CustomHttp.post(
        endpoint: '${ApiConstant.notificationActionPath}/$notificationId/action',
        need_auth: true,
        body: {'action': action},
      );
      if (response.ok) {
        _updateActionStatus(notificationId, action);
        _updateReadState([notificationId], true);
        _decrementUnreadCounts([notificationId]);
        return true;
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      loadingTabs[_tabForNotificationId(notificationId)] = false;
    }
    return false;
  }

  String _tabForNotificationId(int id) {
    if (vibes.any((n) => n.id == id)) return 'vibes';
    if (events.any((n) => n.id == id)) return 'events';
    if (communities.any((n) => n.id == id)) return 'communities';
    return 'vibes';
  }

  void _updateReadState(List<int> ids, bool isRead) {
    final idSet = ids.toSet();
    void updateList(RxList<NotificationModel> list) {
      final index = list.indexWhere((n) => idSet.contains(n.id));
      if (index == -1) return;
      list[index] = list[index].copyWith(isRead: isRead);
    }

    updateList(vibes);
    updateList(events);
    updateList(communities);
  }

  void _decrementUnreadCounts(List<int> ids) {
    final idSet = ids.toSet();
    final newCounts = UnreadCounts(
      vibes: _countInTab(vibes, idSet, unreadCounts.value.vibes),
      events: _countInTab(events, idSet, unreadCounts.value.events),
      communities: _countInTab(communities, idSet, unreadCounts.value.communities),
    );
    unreadCounts.value = newCounts;
  }

  int _countInTab(
    RxList<NotificationModel> list,
    Set<int> idsMarkedRead,
    int currentCount,
  ) {
    final matches = list.where((n) => idsMarkedRead.contains(n.id)).length;
    return (currentCount - matches).clamp(0, 1 << 30);
  }

  void _updateActionStatus(int notificationId, String action) {
    RxList<NotificationModel>? list;
    if (vibes.any((n) => n.id == notificationId)) {
      list = vibes;
    } else if (events.any((n) => n.id == notificationId)) {
      list = events;
    } else if (communities.any((n) => n.id == notificationId)) {
      list = communities;
    }
    if (list == null) return;
    final index = list.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;
    list[index] = list[index].copyWith(actionStatus: action);
  }
}
