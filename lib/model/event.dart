// enum EventStatus { interested, going, requested }

// enum EventAccessType { public, private }

// class Event {
//   String name;
//   String description;
//   String date;
//   String time;
//   String location;
//   String image;
//   String attending;
//   String totalAttending;
//   bool isJoined;
//   bool isMyEvent;
//   EventStatus? userStatus;
//   EventAccessType accessType;
//   bool isFavorite;

//   Event({
//     required this.name,
//     required this.description,
//     required this.date,
//     required this.time,
//     required this.location,
//     required this.image,
//     required this.attending,
//     required this.totalAttending,
//     this.isJoined = false,
//     this.isMyEvent = false,
//     this.userStatus,
//     required this.accessType,
//     this.isFavorite = false,
//   });

//   Event copyWith({
//     String? name,
//     String? description,
//     String? date,
//     String? time,
//     String? location,
//     String? image,
//     String? attending,
//     String? totalAttending,
//     bool? isJoined,
//     bool? isMyEvent,
//     EventStatus? userStatus,
//     EventAccessType? accessType,
//     bool? isFavorite,
//   }) {
//     return Event(
//       name: name ?? this.name,
//       description: description ?? this.description,
//       date: date ?? this.date,
//       time: time ?? this.time,
//       location: location ?? this.location,
//       image: image ?? this.image,
//       attending: attending ?? this.attending,
//       totalAttending: totalAttending ?? this.totalAttending,
//       isJoined: isJoined ?? this.isJoined,
//       isMyEvent: isMyEvent ?? this.isMyEvent,
//       userStatus: userStatus ?? this.userStatus,
//       accessType: accessType ?? this.accessType,
//       isFavorite: isFavorite ?? this.isFavorite,
//     );
//   }
// }

class Event {
  final int? id;
  final String? coverImage;
  final String? title;
  final List<Category>? categories;
  final String? accessLevel;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? eventDate;
  final String? eventTime;
  final String? eventStartingDate;
  final String? eventStartingTime;
  final String? eventEndingDate;
  final String? eventEndingTime;
  final int? maxAttendees;
  final String? status;
  final String? qrCodeValue;
  final String? qrCodeImage;
  final CreatedBy? createdBy;
  final int? joinedCount;
  final int? interestedCount;
  bool? isJoined;
  bool? isRequested;
  bool? isInterested;
  final String? chatId;
  final String? createdAt;
  final List<Participant>? participants;

  Event({
    this.id,
    this.coverImage,
    this.title,
    this.categories,
    this.accessLevel,
    this.latitude,
    this.longitude,
    this.address,
    this.eventDate,
    this.eventTime,
    this.eventStartingDate,
    this.eventStartingTime,
    this.eventEndingDate,
    this.eventEndingTime,
    this.maxAttendees,
    this.status,
    this.qrCodeValue,
    this.qrCodeImage,
    this.createdBy,
    this.joinedCount,
    this.interestedCount,
    this.isJoined,
    this.isRequested,
    this.isInterested,
    this.chatId,
    this.createdAt,
    this.participants,
  });

  factory Event.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Event();

    return Event(
      id: json['id'],
      coverImage: json['cover_image'],
      title: json['title'],
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => Category.fromJson(e))
          .toList(),
      accessLevel: json['access_level'],
      latitude: (json['latitude'] != null)
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: (json['longitude'] != null)
          ? (json['longitude'] as num).toDouble()
          : null,
      address: json['address'],
      eventDate: json['event_date'],
      eventTime: json['event_time'],
      eventStartingDate: json['event_starting_date'],
      eventStartingTime: json['event_starting_time'],
      eventEndingDate: json['event_ending_date'],
      eventEndingTime: json['event_ending_time'],
      maxAttendees: json['max_attendees'],
      status: json['status'],
      qrCodeValue: json['qr_code_value'],
      qrCodeImage: json['qr_code_image'],
      createdBy: json['created_by'] != null
          ? CreatedBy.fromJson(json['created_by'])
          : null,
      joinedCount: json['joined_count'],
      interestedCount: json['interested_count'],
      isJoined: json['is_joined'],
      isRequested: json['is_requested'],
      isInterested: json['is_interested'],
      chatId: json['chat_id'],
      createdAt: json['created_at'],
      participants: (json['participants'] as List<dynamic>?)
          ?.map((e) => Participant.fromJson(e))
          .toList(),
    );
  }
}

class Category {
  final String? name;
  final List<String>? subcategories;

  Category({this.name, this.subcategories});

  factory Category.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Category();

    return Category(
      name: json['name'],
      subcategories: (json['subcategories'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }
}

class CreatedBy {
  final String? id;
  final String? email;
  final String? fullName;
  final String? avatar;

  CreatedBy({this.id, this.email, this.fullName, this.avatar});

  factory CreatedBy.fromJson(Map<String, dynamic>? json) {
    if (json == null) return CreatedBy();

    return CreatedBy(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      avatar: json['avatar'],
    );
  }
}

class Participant {
  final String? id;
  final String? email;
  final String? fullName;
  final String? avatar;

  Participant({this.id, this.email, this.fullName, this.avatar});

  factory Participant.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Participant();

    return Participant(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      avatar: json['avatar'],
    );
  }
}
