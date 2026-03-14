import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';

class Reaction {
  final String emoji;
  int count;
  bool reactedByMe;

  Reaction({
    required this.emoji,
    required this.count,
    this.reactedByMe = false,
  });
}

class ChatMessage {
  final String id;
  final String text;
  final String sender;
  final DateTime time;
  final List<Reaction> reactions;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.time,
    List<Reaction>? reactions,
  }) : reactions = reactions ?? [];
}

class EventChatScreen extends StatefulWidget {
  const EventChatScreen({super.key});

  @override
  State<EventChatScreen> createState() => _EventChatScreenState();
}

class _EventChatScreenState extends State<EventChatScreen> {
  bool isAdmin = false;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasText = false;

  final List<ChatMessage> messages = [
    ChatMessage(
      id: '1',
      text: 'Hi! how can i help?',
      sender: 'Admin',
      time: DateTime.now().subtract(const Duration(minutes: 30)),
      reactions: [
        Reaction(emoji: '❤️', count: 2),
        Reaction(emoji: '🔥', count: 5),
      ],
    ),
    ChatMessage(
      id: '2',
      text: 'What are you doing',
      sender: 'Admin',
      time: DateTime.now().subtract(const Duration(minutes: 20)),
      reactions: [Reaction(emoji: '😂', count: 3)],
    ),
    ChatMessage(
      id: '3',
      text:
          'Lorem ipsum dolor sit amet consectetur. Rhoncus pretium cursus vestibulum lorem tristique ornare lectus ut erat.',
      sender: 'Admin',
      time: DateTime.now().subtract(const Duration(minutes: 10)),
      reactions: [
        Reaction(emoji: '👏', count: 7),
        Reaction(emoji: '❤️', count: 4),
      ],
    ),
    ChatMessage(
      id: '4',
      text: 'Lorem ipsum dolor sit amet consectetur.',
      sender: 'Admin',
      time: DateTime.now().subtract(const Duration(minutes: 2)),
      reactions: [],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _hasText = _controller.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          sender: 'Admin',
          time: DateTime.now(),
        ),
      );
      _controller.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _deleteLastMessage() {
    if (messages.isEmpty) return;
    setState(() => messages.removeLast());
  }

  void _toggleReaction(ChatMessage message, String emoji) {
    setState(() {
      final existing = message.reactions
          .where((r) => r.emoji == emoji)
          .toList();
      if (existing.isNotEmpty) {
        final r = existing.first;
        if (r.reactedByMe) {
          r.count--;
          r.reactedByMe = false;
          if (r.count <= 0) message.reactions.remove(r);
        } else {
          r.count++;
          r.reactedByMe = true;
        }
      } else {
        message.reactions.add(
          Reaction(emoji: emoji, count: 1, reactedByMe: true),
        );
      }
    });
  }

  void _addNewReaction(ChatMessage message, String emoji) {
    setState(() {
      final existing = message.reactions
          .where((r) => r.emoji == emoji)
          .toList();
      if (existing.isNotEmpty) {
        final r = existing.first;
        if (!r.reactedByMe) {
          r.count++;
          r.reactedByMe = true;
        }
      } else {
        message.reactions.add(
          Reaction(emoji: emoji, count: 1, reactedByMe: true),
        );
      }
    });
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildMessageList()),
            _buildBottomArea(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                  size: 20,
                ),
              ),

              const SizedBox(width: 8),

              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(
                  "https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=800",
                ),
              ),
              const SizedBox(width: 10),

              // Title
              const Expanded(
                child: Text(
                  'Club house',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Admin/User label + toggle
              Text(
                isAdmin ? 'Admin' : 'User',
                style: TextStyle(
                  fontSize: 12,
                  color: isAdmin ? Colors.deepPurple : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(
                value: isAdmin,
                onChanged: (val) => setState(() => isAdmin = val),
                activeColor: Colors.deepPurple,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),

              // More icon
              const Icon(Icons.more_vert, color: Colors.black),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Message List ────────────────────────────────────────────────────────────

  Widget _buildMessageList() {
    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'No messages yet',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length,
      itemBuilder: (context, index) => _buildMessageTile(messages[index]),
    );
  }

  // ─── Message Tile ────────────────────────────────────────────────────────────

  Widget _buildMessageTile(ChatMessage msg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bubble
        Container(
          margin: const EdgeInsets.only(right: 60),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                msg.text,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(msg.time),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),

        // Reactions Row
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 14, left: 2),
          child: _buildReactionRow(msg),
        ),
      ],
    );
  }

  // ─── Reaction Row ────────────────────────────────────────────────────────────

  Widget _buildReactionRow(ChatMessage msg) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ...msg.reactions.map((r) => _reactionChip(r, msg)),
        _addReactionButton(msg),
      ],
    );
  }

  Widget _reactionChip(Reaction reaction, ChatMessage msg) {
    return GestureDetector(
      onTap: () => _toggleReaction(msg, reaction.emoji),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: reaction.reactedByMe
              ? Colors.deepPurple.shade50
              : Colors.white,
          border: Border.all(
            color: reaction.reactedByMe
                ? Colors.deepPurple.shade200
                : Colors.grey.shade200,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(reaction.emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Text(
              '${reaction.count}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: reaction.reactedByMe
                    ? Colors.deepPurple
                    : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addReactionButton(ChatMessage msg) {
    return GestureDetector(
      onTap: () => _showEmojiPicker(msg),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: const Text(
          '+',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ),
    );
  }

  void _showEmojiPicker(ChatMessage msg) {
    const emojis = ['❤️', '🔥', '😂', '👏', '😮', '😢', '🎉', '💯'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Reaction',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: emojis.map((e) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _addNewReaction(msg, e);
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(e, style: const TextStyle(fontSize: 26)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─── Bottom Bar ──────────────────────────────────────────────────────────────

  Widget _buildBottomArea() {
    if (isAdmin) {
      return _buildAdminBar();
    } else {
      return _buildLockedBar();
    }
  }

  Widget _buildAdminBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 30.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {},
            child: Assets.icons.trash.svg(height: 26.sp, width: 26.sp),
          ),

          SizedBox(width: 12.w),

          // Input field
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey),
              ),
              child: Row(
                children: [
                  Icon(Icons.keyboard_voice_outlined, color: AppColors.primary),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        hintStyle: TextStyle(color: AppColors.primaryText),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Send icon
          GestureDetector(
            onTap: _hasText ? _sendMessage : null,
            child: Assets.icons.send.svg(height: 26.sp, width: 26.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            'Only admins can send messages',
            style: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
