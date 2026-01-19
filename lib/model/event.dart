enum EventStatus { interested, going,requested }

class Event {
  String name;
  String description;
  String date;
  String time;
  String location;
  String image;
  String attending;
  String totalAttending;
  bool isJoined;
  bool isMyEvent;
  EventStatus? userStatus;

  Event({
    required this.name,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.image,
    required this.attending,
    required this.totalAttending,
    this.isJoined = false,
    this.isMyEvent = false,
    this.userStatus,
  });

  Event copyWith({
    String? name,
    String? description,
    String? date,
    String? time,
    String? location,
    String? image,
    String? attending,
    String? totalAttending,
    bool? isJoined,
    bool? isMyEvent,
    EventStatus? userStatus,
  }) {
    return Event(
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      image: image ?? this.image,
      attending: attending ?? this.attending,
      totalAttending: totalAttending ?? this.totalAttending,
      isJoined: isJoined ?? this.isJoined,
      isMyEvent: isMyEvent ?? this.isMyEvent,
      userStatus: userStatus ?? this.userStatus,
    );
  }
}
