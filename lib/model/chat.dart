enum ChatType { single, community, wave }

class Chat {
  final String name;
  final String message;
  final String time;
  final List<String> avatars;
  final int unreadCount;
  final ChatType type;

  Chat({
    required this.name,
    required this.message,
    required this.time,
    required this.avatars,
    this.unreadCount = 0,
    required this.type,
  });
}
