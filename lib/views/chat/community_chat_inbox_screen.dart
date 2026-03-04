import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/views/chat/chat_screen.dart';

enum MessageType { text, image, audio }

class ChatMessage {
  final String? text;
  final String? mediaUrl;
  final String senderAvatar;
  final String senderName;
  final bool isMe;
  final MessageType type;
  final DateTime time;

  ChatMessage({
    this.text,
    this.mediaUrl,
    required this.senderAvatar,
    required this.senderName,
    required this.isMe,
    required this.type,
    required this.time,
  });
}

class CommunityChatInboxScreen extends StatefulWidget {
  const CommunityChatInboxScreen({super.key});

  @override
  State<CommunityChatInboxScreen> createState() =>
      _CommunityChatInboxScreenState();
}

class _CommunityChatInboxScreenState extends State<CommunityChatInboxScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Initial Mock Data based on your screenshots
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Hey how are you',
      senderAvatar: 'https://randomuser.me/api/portraits/men/1.jpg',
      senderName: 'Jony',
      isMe: false,
      type: MessageType.text,
      time: DateTime.now(),
    ),
    ChatMessage(
      text: 'I\'m fine!',
      senderAvatar: '',
      senderName: 'Me',
      isMe: true,
      type: MessageType.text,
      time: DateTime.now(),
    ),
    ChatMessage(
      mediaUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
      senderAvatar: 'https://randomuser.me/api/portraits/women/2.jpg',
      senderName: 'Sarah',
      isMe: false,
      type: MessageType.image,
      time: DateTime.now(),
    ),
    ChatMessage(
      mediaUrl: 'audio_file_url',
      senderAvatar: '',
      senderName: 'Me',
      isMe: true,
      type: MessageType.audio,
      time: DateTime.now(),
    ),
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add(
        ChatMessage(
          text: _messageController.text,
          senderAvatar: '',
          senderName: 'Me',
          isMe: true,
          type: MessageType.text,
          time: DateTime.now(),
        ),
      );
    });
    _messageController.clear();
    // Auto-scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              itemCount: _messages.length,
              itemBuilder: (context, index) =>
                  ChatBubble(message: _messages[index]),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: GestureDetector(
        child: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onTap: () => context.pop(),
      ),
      title: GestureDetector(
        onTap: () {
          context.pushNamed(RouteNames.communityMemberScreen);
        },
        child: Row(
          children: [
            const CommunityAvatar(
              avatars: [
                'https://randomuser.me/api/portraits/men/32.jpg',
                'https://randomuser.me/api/portraits/women/44.jpg',
              ],
              size: 40,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Coffee Meetup at Central Park',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          offset: const Offset(0, 50),
          color: AppColors.backgroundVariant,
          itemBuilder: (_) => [
            PopupMenuItem<String>(
              value: 'block',
              child: Row(
                spacing: 8.w,
                children: [
                  Assets.icons.block.svg(width: 20.w, height: 20.h),
                  const Text('Block'),
                ],
              ),
              onTap: () {
                Future.delayed(
                  Duration.zero,
                  () => context.pushNamed(RouteNames.blockScreen),
                );
              },
            ),
            PopupMenuItem<String>(
              value: 'report',
              child: Row(
                spacing: 8.w,
                children: [
                  Assets.icons.report.svg(width: 20.w, height: 20.h),
                  const Text('Report'),
                ],
              ),
              onTap: () {
                Future.delayed(
                  Duration.zero,
                  () => context.pushNamed(RouteNames.reportScreen),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 30.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Assets.icons.trash.svg(height: 26.sp, width: 26.sp),
          SizedBox(width: 12.w),
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
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Type a message",
                        hintStyle: TextStyle(color: AppColors.primaryText),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: _sendMessage,
            child: Assets.icons.send.svg(height: 26.sp, width: 26.sp),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: message.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) ...[
            CircleAvatar(
              radius: 18.r,
              backgroundImage: NetworkImage(message.senderAvatar),
            ),
            SizedBox(width: 8.w),
          ],
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Flexible(
      child: Column(
        crossAxisAlignment: message.isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: message.type == MessageType.image
                ? EdgeInsets.all(4.w)
                : EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: message.isMe ? null : const Color(0xffF2F4F7),
              gradient: message.isMe ? AppColors.primaryGradient : null,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(message.isMe ? 20 : 0),
                bottomRight: Radius.circular(message.isMe ? 0 : 20),
              ),
            ),
            child: _buildTypeSpecificUI(),
          ),
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 4.w, right: 4.w),
            child: Text(
              "${message.time.hour}:${message.time.minute}",
              style: TextStyle(fontSize: 10.sp, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSpecificUI() {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.text ?? "",
          style: TextStyle(
            color: message.isMe ? Colors.white : const Color(0xff303030),
            fontSize: 14.sp,
          ),
        );
      case MessageType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            message.mediaUrl!,
            width: 200.w,
            fit: BoxFit.cover,
          ),
        );
      case MessageType.audio:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pause_circle_filled, color: Colors.white),
            SizedBox(width: 8.w),
            Text(
              '|||||||||||||||||||||||',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
    }
  }
}
