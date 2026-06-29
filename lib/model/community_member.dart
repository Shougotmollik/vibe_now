class CommunityMember {
  final int memberId;
  final MemberUser user;
  final String status;
  final String scheduleStatus;
  final String? scheduledAt;
  final String? requestedAt;
  final String? communityTitle;
  final String? communityDescription;
  final String? communityAddress;
  final double? communityLatitude;
  final double? communityLongitude;
  final String? qrCodeValue;
  final String? qrCodeImage;

  CommunityMember({
    required this.memberId,
    required this.user,
    required this.status,
    required this.scheduleStatus,
    this.scheduledAt,
    this.requestedAt,
    this.communityTitle,
    this.communityDescription,
    this.communityAddress,
    this.communityLatitude,
    this.communityLongitude,
    this.qrCodeValue,
    this.qrCodeImage,
  });

  factory CommunityMember.fromJson(Map<String, dynamic> json) {
    final location = json['community_location'] as Map<String, dynamic>?;
    return CommunityMember(
      memberId: json['member_id'],
      user: MemberUser.fromJson(json['user']),
      status: json['status'] ?? '',
      scheduleStatus: json['schedule_status'] ?? '',
      scheduledAt: json['scheduled_at'],
      requestedAt: json['requested_at'],
      communityTitle: json['community_title'],
      communityDescription: json['community_description'],
      communityAddress: location?['address'],
      communityLatitude: (location?['latitude'] as num?)?.toDouble(),
      communityLongitude: (location?['longitude'] as num?)?.toDouble(),
      qrCodeValue: json['qr_code_value'],
      qrCodeImage: json['qr_code_image'],
    );
  }
}

class MemberUser {
  final String id;
  final String email;
  final String fullName;
  final String avatar;

  MemberUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.avatar,
  });

  factory MemberUser.fromJson(Map<String, dynamic> json) {
    return MemberUser(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }
}
