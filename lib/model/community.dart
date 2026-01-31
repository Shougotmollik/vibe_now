import 'package:vibe_now/model/event.dart';

enum CommunityAccessType { public, private }

enum CommunityStatus { interested, going, requested }

class Community {
  String name;
  String description;
  String location;
  String distance;
  String dateTime;
  String attending;
  String totalAttending;
  String image;
  List<String> avatars;
  int extraCount;
  bool isMyCommunity;
  bool isJoined;
  bool isInterested;
  CommunityStatus? userStatus;
  CommunityAccessType accessType;

  Community({
    required this.name,
    required this.description,
    required this.location,
    required this.distance,
    required this.dateTime,
    required this.attending,
    required this.totalAttending,
    required this.image,
    required this.avatars,
    required this.extraCount,
    this.isMyCommunity = false,
    this.isJoined = false,
    this.isInterested = false,
    this.userStatus,
    required this.accessType,
  });

  Community copyWith({
    String? name,
    String? description,
    String? location,
    String? distance,
    String? dateTime,
    String? attending,
    String? totalAttending,
    String? image,
    List<String>? avatars,
    int? extraCount,
    bool? isMyCommunity,
    bool? isJoined,
    bool? isInterested,
    CommunityStatus? userStatus,
  }) {
    return Community(
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      distance: distance ?? this.distance,
      dateTime: dateTime ?? this.dateTime,
      attending: attending ?? this.attending,
      totalAttending: totalAttending ?? this.totalAttending,
      image: image ?? this.image,
      avatars: avatars ?? this.avatars,
      extraCount: extraCount ?? this.extraCount,
      isMyCommunity: isMyCommunity ?? this.isMyCommunity,
      isJoined: isJoined ?? this.isJoined,
      isInterested: isInterested ?? this.isInterested,
      userStatus: userStatus ?? this.userStatus,
      accessType: accessType,
    );
  }
}
