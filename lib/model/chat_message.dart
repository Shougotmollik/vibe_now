class ChatMessage {
  String? id;
  String? chat;
  Sender? sender;
  String? content;
  String? type;
  String? file;
  String? voice;
  DateTime? createdAt;
  bool? isEdited;
  bool? isDeleted;
  List<dynamic>? reads;
  int? readCount;
  List<Reaction>? reactions;

  ChatMessage({
    this.id,
    this.chat,
    this.sender,
    this.content,
    this.type,
    this.file,
    this.voice,
    this.createdAt,
    this.isEdited,
    this.isDeleted,
    this.reads,
    this.readCount,
    this.reactions,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      chat: json['chat'],
      sender: json['sender'] != null ? Sender.fromJson(json['sender']) : null,
      content: json['content'],
      type: json['type'],
      file: json['file'],
      voice: json['voice'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      isEdited: json['is_edited'],
      isDeleted: json['is_deleted'],
      reads: json['reads'],
      readCount: json['read_count'],
      reactions: (json['reactions'] as List?)
          ?.map((e) => Reaction.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'chat': chat,
    'sender': sender?.toJson(),
    'content': content,
    'type': type,
    'file': file,
    'voice': voice,
    'created_at': createdAt?.toIso8601String(),
    'is_edited': isEdited,
    'is_deleted': isDeleted,
    'reads': reads,
    'read_count': readCount,
    'reactions': reactions?.map((e) => e.toJson()).toList(),
  };
}

class Sender {
  String? id;
  String? email;
  String? fullName;
  String? role;
  String? avatar;

  Sender({this.id, this.email, this.fullName, this.role, this.avatar});

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      role: json['role'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'role': role,
    'avatar': avatar,
  };
}

class Reaction {
  String? emoji;
  String? type;
  int? count;
  List<ReactionUser>? users;

  Reaction({this.emoji, this.type, this.count, this.users});

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      emoji: json['emoji'],
      type: json['type'],
      count: json['count'],
      users: (json['users'] as List?)
          ?.map((e) => ReactionUser.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'emoji': emoji,
    'type': type,
    'count': count,
    'users': users?.map((e) => e.toJson()).toList(),
  };
}

class ReactionUser {
  String? id;
  String? email;
  String? fullName;

  ReactionUser({this.id, this.email, this.fullName});

  factory ReactionUser.fromJson(Map<String, dynamic> json) {
    return ReactionUser(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
  };
}
