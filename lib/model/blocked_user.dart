import 'package:vibe_now/core/constant/credential.dart';

class BlockedUser {
  final int id;
  final BlockedUserProfile blockedUser;
  final String reason;
  final String createdAt;

  BlockedUser({
    required this.id,
    required this.blockedUser,
    required this.reason,
    required this.createdAt,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      id: json['id'] ?? 0,
      blockedUser: BlockedUserProfile.fromJson(json['blocked_user'] ?? {}),
      reason: json['reason'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class BlockedUserProfile {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatar;

  BlockedUserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
  });

  String get fullAvatarUrl => AppCredentials.fixurl(avatar);

  factory BlockedUserProfile.fromJson(Map<String, dynamic> json) {
    return BlockedUserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      avatar: json['avatar'],
    );
  }
}
