import 'package:vibe_now/model/incoming_wave.dart';

class Actor {
  final String id;
  final String fullName;
  final String? avatar;

  Actor({
    required this.id,
    required this.fullName,
    this.avatar,
  });

  factory Actor.fromJson(Map<String, dynamic> json) {
    return Actor(
      id: json['id'] ?? '',
      fullName: json['full_name'] ?? '',
      avatar: json['avatar'],
    );
  }
}

class Location {
  final double? latitude;
  final double? longitude;
  final String? address;

  Location({this.latitude, this.longitude, this.address});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'],
    );
  }
}

class RelatedObject {
  final String type;
  final int id;
  final String? title;
  final Location? location;
  final double? distanceKm;

  // Wave-specific fields (for wave-type related objects)
  final int? waveId;
  final String? waveType;
  final String? waveStatus;
  final String? waveCreatedAt;
  final Map<String, dynamic>? waveSenderRaw;
  final Map<String, dynamic>? waveReceiverRaw;
  final int? distanceInMeters;
  final String? distanceText;
  final Map<String, dynamic>? waveMeetupRaw;
  final Map<String, dynamic>? waveVibeRaw;
  final String? qrCodeValue;
  final String? qrCodeImage;

  RelatedObject({
    required this.type,
    required this.id,
    this.title,
    this.location,
    this.distanceKm,
    this.waveId,
    this.waveType,
    this.waveStatus,
    this.waveCreatedAt,
    this.waveSenderRaw,
    this.waveReceiverRaw,
    this.distanceInMeters,
    this.distanceText,
    this.waveMeetupRaw,
    this.waveVibeRaw,
    this.qrCodeValue,
    this.qrCodeImage,
  });

  factory RelatedObject.fromJson(Map<String, dynamic> json) {
    // For wave-type related objects, the wave_id is used instead of id
    final waveId = json['wave_id'] as int?;
    final objId = json['id'] ?? 0;

    return RelatedObject(
      type: json['type'] ?? '',
      id: waveId ?? objId,
      title: json['title'],
      location: json['location'] != null
          ? Location.fromJson(json['location'])
          : null,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      waveId: waveId,
      waveType: json['wave_type'],
      waveStatus: json['status'],
      waveCreatedAt: json['created_at'],
      waveSenderRaw: json['sender'] as Map<String, dynamic>?,
      waveReceiverRaw: json['receiver'] as Map<String, dynamic>?,
      distanceInMeters: (json['distance_in_meters'] as num?)?.toInt(),
      distanceText: json['distance_text'],
      waveMeetupRaw: json['meetup'] as Map<String, dynamic>?,
      waveVibeRaw: json['vibe'] as Map<String, dynamic>?,
      qrCodeValue: json['qr_code_value'],
      qrCodeImage: json['qr_code_image'],
    );
  }

  /// Converts this RelatedObject to an IncomingWave (for wave-type notifications)
  IncomingWave toIncomingWave() {
    return IncomingWave(
      waveId: waveId ?? id,
      waveType: waveType ?? '',
      status: waveStatus ?? '',
      createdAt: waveCreatedAt ?? '',
      sender: waveSenderRaw != null
          ? WaveSender.fromJson(waveSenderRaw!)
          : WaveSender(
              id: '', email: '', fullName: 'Unknown', avatar: ''),
      receiver: waveReceiverRaw != null
          ? WaveSender.fromJson(waveReceiverRaw!)
          : null,
      distanceInMeters: distanceInMeters,
      distanceText: distanceText,
      meetup: waveMeetupRaw != null
          ? WaveMeetup.fromJson(waveMeetupRaw!)
          : null,
      vibe: waveVibeRaw != null
          ? WaveVibe.fromJson(waveVibeRaw!)
          : null,
      qrCodeValue: qrCodeValue,
      qrCodeImage: qrCodeImage,
    );
  }
}

class UnreadCounts {
  final int vibes;
  final int events;
  final int communities;

  UnreadCounts({
    this.vibes = 0,
    this.events = 0,
    this.communities = 0,
  });

  factory UnreadCounts.fromJson(Map<String, dynamic> json) {
    return UnreadCounts(
      vibes: json['vibes'] ?? 0,
      events: json['events'] ?? 0,
      communities: json['communities'] ?? 0,
    );
  }
}

class NotificationStats {
  final int unreadTotal;
  final int totalNotifications;

  NotificationStats({
    this.unreadTotal = 0,
    this.totalNotifications = 0,
  });

  factory NotificationStats.fromJson(Map<String, dynamic> json) {
    return NotificationStats(
      unreadTotal: json['unread_total'] ?? 0,
      totalNotifications: json['total_notifications'] ?? 0,
    );
  }
}

class NotificationModel {
  final int id;
  final String notificationType;
  final Actor actor;
  final String title;
  final String message;
  final bool isRead;
  final String createdAt;
  final String? readAt;
  final RelatedObject? relatedObject;
  final String? actionStatus;
  final String distance;
  final bool invitation;

  NotificationModel({
    required this.id,
    required this.notificationType,
    required this.actor,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.relatedObject,
    this.actionStatus,
    this.distance = '',
    this.invitation = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final relatedObject = json['related_object'] != null
        ? RelatedObject.fromJson(json['related_object'])
        : null;

    final distanceKm = relatedObject?.distanceKm;
    final distanceStr = distanceKm != null
        ? distanceKm.toStringAsFixed(distanceKm == distanceKm.roundToDouble() ? 0 : 2)
        : '--';

    final actionStatus = json['action_status'];
    final notifType = json['notification_type'] ?? '';
    final isInvitation = actionStatus == 'pending' && (notifType.contains('request') || notifType.contains('invitation'));

    return NotificationModel(
      id: json['id'] ?? 0,
      notificationType: notifType,
      actor: json['actor'] != null
          ? Actor.fromJson(json['actor'])
          : Actor(id: '', fullName: 'Unknown'),
      title: json['message'] ?? '',
      message: json['message'] ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] ?? '',
      readAt: json['read_at'],
      relatedObject: relatedObject,
      actionStatus: actionStatus,
      distance: distanceStr,
      invitation: isInvitation,
    );
  }

  NotificationModel copyWith({
    bool? isRead,
    String? actionStatus,
  }) {
    final newActionStatus = actionStatus ?? this.actionStatus;
    final newInvitation =
        newActionStatus == 'pending' && (notificationType.contains('request') || notificationType.contains('invitation'));
    return NotificationModel(
      id: id,
      notificationType: notificationType,
      actor: actor,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      readAt: readAt,
      relatedObject: relatedObject,
      actionStatus: newActionStatus,
      distance: distance,
      invitation: newInvitation,
    );
  }
}
