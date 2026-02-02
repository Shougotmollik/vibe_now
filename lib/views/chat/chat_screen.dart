import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/constant/qrcontext_enum.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/views/qr_verification/qr_verification_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Chat> _chatList = [
    Chat(
      avatar: 'https://randomuser.me/api/portraits/women/10.jpg',
      name: 'Sammy Smith',
      message: 'Send You a Wave',
      time: '10:30 AM',
      unreadCount: 0,
      wave: true,
    ),
    Chat(
      avatar: 'https://randomuser.me/api/portraits/women/11.jpg',
      name: 'Jane Doe',
      message: 'Hello, how are you?',
      time: '10:30 AM',
      unreadCount: 1,
      wave: false,
    ),
    Chat(
      avatar: 'https://randomuser.me/api/portraits/women/12.jpg',
      name: 'kyaliace baker',
      message: 'what are you doing? bro',
      time: '11:30 AM',
      unreadCount: 2,
      wave: false,
    ),
    Chat(
      avatar: 'https://randomuser.me/api/portraits/women/13.jpg',
      name: 'stephanie smith',
      message: 'Are you there?',
      time: '11:30 AM',
      unreadCount: 4,
      wave: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 18),
                Text(
                  'Chats',
                  style: TextStyle(
                    color: Color(0xff303030),
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () =>
                      context.pushNamed(RouteNames.qrVerificationScreen,
                          extra: QRContext.chats),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                    ),
                    child: Assets.icons.scan.svg(
                      width: 24.w,
                      height: 24.h,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search a person',
                  hintStyle: TextStyle(
                    color: Color(0xff9d9d9d),
                    fontSize: 14.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xff9d9d9d),
                    size: 20.sp,
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Color(0xff9d9d9d)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Color(0xff9d9d9d)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Color(0xff9d9d9d)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            Expanded(
              child: Column(
                children: _chatList
                    .map(
                      (e) => ChatListItem(
                        chat: e,
                        onTap: () {
                          e.wave == true
                              ? context.pushNamed(
                                  RouteNames.waveScreen,
                                  extra: e,
                                )
                              : context.pushNamed(
                                  RouteNames.chatInboxScreen,
                                  extra: e,
                                );
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Chat {
  final String name;
  final String message;
  final String time;
  final String avatar;
  final int? unreadCount;
  final bool wave;

  Chat({
    required this.name,
    required this.message,
    required this.time,
    required this.avatar,
    this.unreadCount,
    required this.wave,
  });
}

class ChatListItem extends StatelessWidget {
  final VoidCallback onTap;

  final Chat chat;

  const ChatListItem({super.key, required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: chat.wave ? AppColors.backgroundVariant : Colors.white,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                chat.avatar,
                width: 50.w,
                height: 50.w,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff303030),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.message,
                    style: TextStyle(fontSize: 14.sp, color: Color(0xff585858)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Time and unread badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.time,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                ),
                if (chat.unreadCount! > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      chat.unreadCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
