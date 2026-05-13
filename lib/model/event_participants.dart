class ParticipantData {
  final int? participantId;
  final EventCreator? user;
  final String? status;
  final String? requestedAt;

  ParticipantData({
    this.participantId,
    this.user,
    this.status,
    this.requestedAt,
  });

  factory ParticipantData.fromJson(Map<String, dynamic> json) {
    return ParticipantData(
      participantId: json['participant_id'],
      user: json['user'] != null ? EventCreator.fromJson(json['user']) : null,
      status: json['status'],
      requestedAt: json['requested_at'],
    );
  }
}

class EventCreator {
  final String? id;
  final String? email;
  final String? fullName;
  final String? avatar;

  EventCreator({this.id, this.email, this.fullName, this.avatar});

  factory EventCreator.fromJson(Map<String, dynamic> json) {
    return EventCreator(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      avatar: json['avatar'],
    );
  }
}
