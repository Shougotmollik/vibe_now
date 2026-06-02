class Meetup {
  final int id;
  final String? title;
  final String? description;
  final String? coverImage;
  final MeetupCommunity? community;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? meetupDate;
  final String? meetupTime;
  final int? maxAttendees;
  final String? status;
  final MeetupCreatedBy? createdBy;
  final int? joinedCount;
  final int? interestedCount;
  bool? isJoined;
  bool? isInterested;
  bool? isInvited;
  final String? chatId;
  final String? createdAt;
  final List<MeetupParticipant>? participants;

  Meetup({
    required this.id,
    this.title,
    this.description,
    this.coverImage,
    this.community,
    this.latitude,
    this.longitude,
    this.address,
    this.meetupDate,
    this.meetupTime,
    this.maxAttendees,
    this.status,
    this.createdBy,
    this.joinedCount,
    this.interestedCount,
    this.isJoined,
    this.isInterested,
    this.isInvited,
    this.chatId,
    this.createdAt,
    this.participants,
  });

  factory Meetup.fromJson(Map<String, dynamic> json) {
    return Meetup(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      coverImage: json['cover_image'],
      community: json['community'] != null
          ? MeetupCommunity.fromJson(json['community'])
          : null,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'],
      meetupDate: json['meetup_date'],
      meetupTime: json['meetup_time'],
      maxAttendees: json['max_attendees'],
      status: json['status'],
      createdBy: json['created_by'] != null
          ? MeetupCreatedBy.fromJson(json['created_by'])
          : null,
      joinedCount: json['joined_count'],
      interestedCount: json['interested_count'],
      isJoined: json['is_joined'],
      isInterested: json['is_interested'],
      isInvited: json['is_invited'],
      chatId: json['chat_id'],
      createdAt: json['created_at'],
      participants: (json['participants'] as List<dynamic>?)
          ?.map((e) => MeetupParticipant.fromJson(e))
          .toList(),
    );
  }
}

class MeetupCommunity {
  final int id;
  final String? title;

  MeetupCommunity({required this.id, this.title});

  factory MeetupCommunity.fromJson(Map<String, dynamic> json) {
    return MeetupCommunity(
      id: json['id'],
      title: json['title'],
    );
  }
}

class MeetupCreatedBy {
  final String? id;
  final String? email;
  final String? fullName;
  final String? avatar;

  MeetupCreatedBy({this.id, this.email, this.fullName, this.avatar});

  factory MeetupCreatedBy.fromJson(Map<String, dynamic> json) {
    return MeetupCreatedBy(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      avatar: json['avatar'],
    );
  }
}

class MeetupParticipant {
  final String? id;
  final String? email;
  final String? fullName;
  final String? avatar;
  final String? status;
  final int? participantId;
  final String? joinedAt;
  final String? invitedAt;

  MeetupParticipant({
    this.id,
    this.email,
    this.fullName,
    this.avatar,
    this.status,
    this.participantId,
    this.joinedAt,
    this.invitedAt,
  });

  factory MeetupParticipant.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return MeetupParticipant(
      id: user?['id'] ?? json['id'],
      email: user?['email'] ?? json['email'],
      fullName: user?['full_name'] ?? json['full_name'],
      avatar: user?['avatar'] ?? json['avatar'],
      status: json['status'],
      participantId: json['participant_id'],
      joinedAt: json['joined_at'],
      invitedAt: json['invited_at'],
    );
  }
}
