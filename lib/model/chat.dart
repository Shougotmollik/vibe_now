enum ChatType { event, community, private }

ChatType _parseChatType(String? raw) {
  switch (raw?.toLowerCase()) {
    case 'event':
    case 'events':
      return ChatType.event;
    case 'community':
    case 'communities':
    case 'group':
      return ChatType.community;
    case 'private':
    case 'single':
    case 'direct':
      return ChatType.private;
    default:
      return ChatType.private;
  }
}

class LastMessage {
  final String? id;
  final String? senderId;
  final String? senderName;
  final String? senderAvatar;
  final String? content;
  final DateTime? createdAt;

  LastMessage({
    this.id,
    this.senderId,
    this.senderName,
    this.senderAvatar,
    this.content,
    this.createdAt,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'];
    return LastMessage(
      id: json['id']?.toString(),
      senderId: sender is Map ? sender['id']?.toString() : null,
      senderName: sender is Map ? sender['full_name']?.toString() : null,
      senderAvatar: sender is Map ? sender['avatar']?.toString() : null,
      content: json['content']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class OtherMember {
  final String? id;
  final String? fullName;
  final String? avatar;

  OtherMember({this.id, this.fullName, this.avatar});

  factory OtherMember.fromJson(Map<String, dynamic> json) {
    return OtherMember(
      id: json['id']?.toString(),
      fullName: json['full_name']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }
}

class ChatRef {
  final int? id;
  final String? name;
  final String? coverImage;

  ChatRef({this.id, this.name, this.coverImage});

  factory ChatRef.fromJson(Map<String, dynamic> json) {
    return ChatRef(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? json['title']?.toString(),
      coverImage: json['cover_image']?.toString() ?? json['avatar']?.toString(),
    );
  }
}

class Chat {
  final String id;
  final String name;
  final bool isGroup;
  final ChatType type;
  final LastMessage? lastMessage;
  final int unreadCount;
  final OtherMember? otherMember;
  final DateTime? createdAt;
  final ChatRef? community;
  final ChatRef? meetup;
  final int? eventId;
  final String? eventImage;

  final bool canMessage;
  final String? blockBy;

  // Derived helpers used by existing list item UI
  final String message;
  final String time;
  final DateTime? lastMessageAt;
  final String? avatar;
  final List<String> avatars;

  Chat({
    this.id = '',
    this.name = '',
    this.isGroup = false,
    this.type = ChatType.private,
    this.lastMessage,
    this.unreadCount = 0,
    this.otherMember,
    this.createdAt,
    this.community,
    this.meetup,
    this.eventId,
    this.eventImage,
    this.canMessage = true,
    this.blockBy,
    this.message = '',
    this.time = '',
    this.lastMessageAt,
    this.avatar,
    this.avatars = const [],
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    final type = _parseChatType(json['chat_type']?.toString());
    final lastMessageJson = json['last_message'];
    final lastMessage = lastMessageJson is Map<String, dynamic>
        ? LastMessage.fromJson(lastMessageJson)
        : null;
    final otherMemberJson = json['other_member'];
    final otherMember = otherMemberJson is Map<String, dynamic>
        ? OtherMember.fromJson(otherMemberJson)
        : null;
    final communityJson = json['community'];
    final community = communityJson is Map<String, dynamic>
        ? ChatRef.fromJson(communityJson)
        : null;
    
    // Check if community image exists in main json if not in object
    final communityImage = (communityJson is Map<String, dynamic> && communityJson['image'] != null)
        ? communityJson['image'].toString()
        : (community?.coverImage);

    final meetupJson = json['meetup'];
    final meetup = meetupJson is Map<String, dynamic>
        ? ChatRef.fromJson(meetupJson)
        : null;

    final eventJson = json['event'];
    final eventImage = eventJson is Map<String, dynamic>
        ? eventJson['image']?.toString()
        : json['image']?.toString();
    final eventId = eventJson is Map<String, dynamic>
        ? (eventJson['id'] is int ? eventJson['id'] : int.tryParse(eventJson['id']?.toString() ?? ''))
        : (json['event'] is int ? json['event'] : int.tryParse(json['event']?.toString() ?? ''));

    final canMessage = json['can_message'] as bool? ?? true;
    final blockBy = json['block_by']?.toString();

    final avatars = <String>[];
    
    // For community or event, prioritize their image
    if (communityImage?.isNotEmpty == true) {
      avatars.add(communityImage!);
    } else if (eventImage?.isNotEmpty == true) {
      avatars.add(eventImage!);
    } 
    // Only fall back to member/sender if no group image and it's not a group chat
    else if (otherMember?.avatar?.isNotEmpty == true) {
      avatars.add(otherMember!.avatar!);
    } else if (lastMessage?.senderAvatar?.isNotEmpty == true) {
      avatars.add(lastMessage!.senderAvatar!);
    }

    String? primaryAvatar = avatars.isNotEmpty ? avatars.first : null;

    return Chat(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      isGroup: json['is_group'] == true,
      type: type,
      lastMessage: lastMessage,
      unreadCount: (json['unread_count'] is int)
          ? json['unread_count'] as int
          : int.tryParse(json['unread_count']?.toString() ?? '') ?? 0,
      otherMember: otherMember,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      community: community,
      meetup: meetup,
      eventId: eventId,
      eventImage: eventImage,
      canMessage: canMessage,
      blockBy: blockBy,
      message: lastMessage?.content ?? 'No messages yet',
      time: _formatTime(lastMessage?.createdAt),
      lastMessageAt: lastMessage?.createdAt,
      avatar: primaryAvatar,
      avatars: avatars,
    );
  }

  static String _formatTime(DateTime? t) {
    if (t == null) return '';
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inDays >= 7) {
      return '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
    }
    if (diff.inDays >= 1) {
      return '${diff.inDays}d ago';
    }
    if (diff.inHours >= 1) {
      return '${diff.inHours}h ago';
    }
    if (diff.inMinutes >= 1) {
      return '${diff.inMinutes}m ago';
    }
    return 'now';
  }
}
