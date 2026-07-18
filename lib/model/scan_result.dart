class ScanOtherUser {
  final String id;
  final String email;
  final String fullName;
  final String avatar;

  ScanOtherUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.avatar,
  });

  factory ScanOtherUser.fromJson(Map<String, dynamic> json) {
    return ScanOtherUser(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
    );
  }
}

class ScanResult {
  final String chatId;
  final ScanOtherUser otherUser;

  ScanResult({
    required this.chatId,
    required this.otherUser,
  });

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      chatId: json['chat_id']?.toString() ?? '',
      otherUser: ScanOtherUser.fromJson(
        json['other_user'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
