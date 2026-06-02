import 'package:vibe_now/model/event.dart';

enum CommunityAccessType { public, private }

enum CommunityStatus { interested, going, requested }

class Community {
  final int? id;
  final String? title;
  final String? description;
  final String? rules;
  final List<CommunityCategory>? categories;
  final String? accessLevel;
  final String? coverImage;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? communityDate;
  final String? communityTime;
  final int? maxAttendees;
  final String? status;
  final String? qrCodeValue;
  final String? qrCodeImage;
  final CommunityCreatedBy? createdBy;
  final int? joinedCount;
  final int? interestedCount;
  final bool? isJoined;
  final bool? isInterested;
  final bool? isRequested;
  final String? chatId;
  final List<CommunityParticipant>? participants;
  final String? createdAt;

  Community({
    this.id,
    this.title,
    this.description,
    this.rules,
    this.categories,
    this.accessLevel,
    this.coverImage,
    this.latitude,
    this.longitude,
    this.address,
    this.communityDate,
    this.communityTime,
    this.maxAttendees,
    this.status,
    this.qrCodeValue,
    this.qrCodeImage,
    this.createdBy,
    this.joinedCount,
    this.interestedCount,
    this.isJoined,
    this.isInterested,
    this.isRequested,
    this.chatId,
    this.participants,
    this.createdAt,
  });

  factory Community.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Community();

    return Community(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      rules: json['rules'],
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => CommunityCategory.fromJson(e))
          .toList(),
      accessLevel: json['access_level'],
      coverImage: json['cover_image'],
      latitude: (json['latitude'] != null)
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: (json['longitude'] != null)
          ? (json['longitude'] as num).toDouble()
          : null,
      address: json['address'],
      communityDate: json['community_date'],
      communityTime: json['community_time'],
      maxAttendees: json['max_attendees'],
      status: json['status'],
      qrCodeValue: json['qr_code_value'],
      qrCodeImage: json['qr_code_image'],
      createdBy: json['created_by'] != null
          ? CommunityCreatedBy.fromJson(json['created_by'])
          : null,
      joinedCount: json['joined_count'],
      interestedCount: json['interested_count'],
      isJoined: json['is_joined'],
      isInterested: json['is_interested'],
      isRequested: json['is_requested'],
      chatId: json['chat_id'],
      participants: (json['participants'] as List<dynamic>?)
          ?.map((e) => CommunityParticipant.fromJson(e))
          .toList(),
      createdAt: json['created_at'],
    );
  }

  bool get isPrivate => accessLevel == 'private';
  bool get isPublic => accessLevel == 'public';

  String get formattedDateTime {
    if (communityDate == null && communityTime == null) return '';
    return '${communityDate ?? ''} ${communityTime ?? ''}'.trim();
  }

  String get attendeesCount => '${joinedCount ?? 0}/${maxAttendees ?? 0}';
}

class CommunityCategory {
  final String? name;
  final List<String>? subcategories;

  CommunityCategory({this.name, this.subcategories});

  factory CommunityCategory.fromJson(Map<String, dynamic>? json) {
    if (json == null) return CommunityCategory();

    return CommunityCategory(
      name: json['name'],
      subcategories: (json['subcategories'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }
}

class CommunityCreatedBy {
  final String? id;
  final String? email;
  final String? fullName;
  final String? avatar;

  CommunityCreatedBy({this.id, this.email, this.fullName, this.avatar});

  factory CommunityCreatedBy.fromJson(Map<String, dynamic>? json) {
    if (json == null) return CommunityCreatedBy();

    return CommunityCreatedBy(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      avatar: json['avatar'],
    );
  }
}

class CommunityParticipant {
  final String? id;
  final String? email;
  final String? fullName;
  final String? avatar;
  final String? status;

  CommunityParticipant({
    this.id,
    this.email,
    this.fullName,
    this.avatar,
    this.status,
  });

  factory CommunityParticipant.fromJson(Map<String, dynamic>? json) {
    if (json == null) return CommunityParticipant();

    return CommunityParticipant(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      avatar: json['avatar'],
      status: json['status'],
    );
  }
}