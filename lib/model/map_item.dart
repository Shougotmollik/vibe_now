import 'package:vibe_now/core/constant/credential.dart';

enum MapItemType { vibe, event, community, availableUser }

MapItemType _parseType(String? raw) {
  switch (raw?.toLowerCase()) {
    case 'vibe':
      return MapItemType.vibe;
    case 'event':
      return MapItemType.event;
    case 'community':
      return MapItemType.community;
    case 'available_user':
      return MapItemType.availableUser;
    default:
      return MapItemType.vibe;
  }
}

class MapItemCreatedBy {
  final String? id;
  final String? email;
  final String? fullName;
  final String? avatar;

  MapItemCreatedBy({this.id, this.email, this.fullName, this.avatar});

  factory MapItemCreatedBy.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MapItemCreatedBy();
    return MapItemCreatedBy(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      avatar: json['avatar'],
    );
  }

  String get avatarUrl => AppCredentials.fixurl(avatar);
}

class MapItem {
  final int id;
  final MapItemType type;
  final String? title;
  final String? coverImage;
  final double? latitude;
  final double? longitude;
  final double? distance;
  final MapItemCreatedBy? createdBy;
  final Map<String, dynamic> raw;

  /// Available-user-specific fields (populated from the 'user' object)
  final String? userId;
  final String? userFullName;
  final String? userAvatar;
  final String? locationName;
  final String? bio;
  final bool? isLocked;

  MapItem({
    required this.id,
    required this.type,
    this.title,
    this.coverImage,
    this.latitude,
    this.longitude,
    this.distance,
    this.createdBy,
    this.raw = const {},
    this.userId,
    this.userFullName,
    this.userAvatar,
    this.locationName,
    this.bio,
    this.isLocked,
  });

  factory MapItem.fromJson(Map<String, dynamic> json) {
    final rawType = json['type']?.toString() ?? 'vibe';
    final type = _parseType(rawType);

    if (type == MapItemType.availableUser) {
      final user = json['user'] as Map<String, dynamic>? ?? {};
      final location =
          json['current_location'] as Map<String, dynamic>? ?? {};
      return MapItem(
        id: 0,
        type: type,
        title: user['full_name'] as String?,
        coverImage: user['avatar'] as String?,
        userId: json['id'] as String?,
        userFullName: user['full_name'] as String?,
        userAvatar: user['avatar'] as String?,
        latitude: (location['latitude'] as num?)?.toDouble(),
        longitude: (location['longitude'] as num?)?.toDouble(),
        locationName: location['location_name'] as String?,
        distance: (json['distance'] as num?)?.toDouble(),
        bio: json['bio'] as String?,
        isLocked: json['is_locked'] as bool?,
        raw: json,
      );
    }

    return MapItem(
      id: json['id'] ?? 0,
      type: type,
      title: json['title'],
      coverImage: json['cover_image'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distance: (json['distance'] as num?)?.toDouble(),
      createdBy: json['created_by'] != null
          ? MapItemCreatedBy.fromJson(json['created_by'])
          : null,
      raw: json,
    );
  }

  String get coverImageUrl => AppCredentials.fixurl(coverImage);

  /// Convenience getters per type
  // Vibe-specific
  String? get status => raw['status'];
  String? get duration => raw['duration'];
  bool? get hasSentWave => raw['has_sent_wave'];

  // Event-specific
  String? get address => raw['address'];
  String? get accessLevel => raw['access_level'];
  String? get eventStartingDate => raw['event_starting_date'];
  String? get eventStartingTime => raw['event_starting_time'];
  String? get eventEndingDate => raw['event_ending_date'];
  String? get eventEndingTime => raw['event_ending_time'];
  int? get maxAttendees => raw['max_attendees'];
  int? get joinedCount => raw['joined_count'];
  int? get interestedCount => raw['interested_count'];
  bool? get isJoined => raw['is_joined'];
  bool? get isRequested => raw['is_requested'];
  bool? get isInterested => raw['is_interested'];
  String? get chatId => raw['chat_id'];

  // Community-specific
  String? get description => raw['description'];
  String? get rules => raw['rules'];
  String? get communityDate => raw['community_date'];
  String? get communityTime => raw['community_time'];

  /// Unique identifier for markers (handles both numeric and string IDs)
  String get markerId => userId ?? id.toString();

  /// Resolved avatar URL (from userAvatar for available_user, or createdBy for others)
  String get displayAvatarUrl =>
      AppCredentials.fixurl(userAvatar ?? createdBy?.avatar);
}

class MapItemsResponse {
  final bool success;
  final String? message;
  final String? type;
  final int total;
  final List<MapItem> results;

  MapItemsResponse({
    required this.success,
    this.message,
    this.type,
    this.total = 0,
    this.results = const [],
  });

  factory MapItemsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final resultsList = (data?['results'] as List<dynamic>?)
            ?.map((e) => MapItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return MapItemsResponse(
      success: json['success'] ?? false,
      message: json['message'],
      type: data?['type'],
      total: data?['total'] ?? 0,
      results: resultsList,
    );
  }
}
