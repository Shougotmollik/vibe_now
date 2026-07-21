import 'package:get/get.dart';
import 'package:vibe_now/core/constant/api_constant.dart';
import 'package:vibe_now/model/notification_settings.dart';
import 'package:vibe_now/services/custom_http.dart';

class SettingsController extends GetxController {
  var isLoading = false.obs;

  bool get pushEnabled => true;

  // Reactive notification settings
  final eventNotifications = false.obs;
  final communityNotifications = false.obs;
  final vibeNotifications = false.obs;
  final chatNotifications = false.obs;

  final locationSharing = true.obs;

  // Fetch notification settings from API
  Future<void> getNotificationStatus() async {
    try {
      isLoading.value = true;
      final response = await CustomHttp.get(
        endpoint: ApiConstant.notificationSettings,
      );

      if (response.ok && response.data != null) {
        final data = response.data;
        final settingsData = data['data'] as Map<String, dynamic>? ?? data;
        final settings = NotificationSettings.fromJson(settingsData);

        eventNotifications.value = settings.eventNotifications;
        communityNotifications.value = settings.communityNotifications;
        vibeNotifications.value = settings.vibeNotifications;
        chatNotifications.value = settings.chatNotifications;
      }
    } catch (e) {
      Get.log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Update notification settings
  Future<void> updateNotificationSetting({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await CustomHttp.patch(
        endpoint: ApiConstant.notificationSettings,
        add_api_prefix: true,
        body: body,
      );

      if (!response.ok) {
        await getNotificationStatus();
      }
    } catch (e) {
      Get.log(e.toString());
      await getNotificationStatus();
    }
  }

  // Convenience toggle methods
  void toggleEventNotifications(bool val) {
    eventNotifications.value = val;
    updateNotificationSetting(body: {'event_notifications': val});
  }

  void toggleCommunityNotifications(bool val) {
    communityNotifications.value = val;
    // Meetup follows community automatically
    updateNotificationSetting(
      body: {'community_notifications': val, 'meetup_notifications': val},
    );
  }

  void toggleVibeNotifications(bool val) {
    vibeNotifications.value = val;
    updateNotificationSetting(body: {'vibe_notifications': val});
  }

  void toggleChatNotifications(bool val) {
    chatNotifications.value = val;
    updateNotificationSetting(body: {'chat_notifications': val});
  }

  void toggleLocationSharing(bool val) {
    locationSharing.value = val;
  }

  // Privacy policy
  final privacyPolicyContent = ''.obs;
  final privacyPolicyUpdatedAt = ''.obs;

  Future<void> getPrivacyPolicy() async {
    try {
      isLoading.value = true;
      final response = await CustomHttp.get(
        endpoint: ApiConstant.privacyPolicy,
      );

      if (response.ok && response.data != null) {
        final data = response.data['data'] as Map<String, dynamic>?;
        if (data != null) {
          privacyPolicyContent.value = data['privacy_policy'] ?? '';
          privacyPolicyUpdatedAt.value = data['updated_at'] ?? '';
        }
      }
    } catch (e) {
      Get.log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // account pause
  Future<bool> accountPause({
    required String reason,
    required String explanation,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      final response = await CustomHttp.post(
        endpoint: ApiConstant.accountPause,
        add_api_prefix: true,
        body: {
          "reason": reason,
          "explanation": explanation,
          "password": password,
        },
      );
      return response.ok;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // account delete
  Future<bool> accountDelete({
    required String reason,
    required String explanation,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      final response = await CustomHttp.post(
        endpoint: ApiConstant.accountDelete,
        add_api_prefix: true,
        body: {
          "reason": reason,
          "explanation": explanation,
          "password": password,
        },
      );
      return response.ok;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
