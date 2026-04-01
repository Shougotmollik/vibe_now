class NotificationModel {
  final String title;
  final String distance;
  final bool invitation;

  NotificationModel({
    required this.title,
    required this.distance,
    this.invitation = false,
  });
}
