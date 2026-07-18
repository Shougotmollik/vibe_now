class NotificationSettings {
  final bool pushEnabled;
  final bool eventNotifications;
  final bool communityNotifications;
  final bool meetupNotifications;
  final bool vibeNotifications;
  final bool chatNotifications;

  NotificationSettings({
    this.pushEnabled = false,
    this.eventNotifications = false,
    this.communityNotifications = false,
    this.meetupNotifications = false,
    this.vibeNotifications = false,
    this.chatNotifications = false,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return NotificationSettings();

    return NotificationSettings(
      pushEnabled: json['push_enabled'] ?? false,
      eventNotifications: json['event_notifications'] ?? false,
      communityNotifications: json['community_notifications'] ?? false,
      meetupNotifications: json['meetup_notifications'] ?? false,
      vibeNotifications: json['vibe_notifications'] ?? false,
      chatNotifications: json['chat_notifications'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'push_enabled': pushEnabled,
      'event_notifications': eventNotifications,
      'community_notifications': communityNotifications,
      'meetup_notifications': meetupNotifications,
      'vibe_notifications': vibeNotifications,
      'chat_notifications': chatNotifications,
    };
  }
}
