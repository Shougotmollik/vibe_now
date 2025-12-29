import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/src/presentation/views/qr_verification/qr_verification_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();

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
                      context.pushNamed(RouteNames.qrVerificationScreen),
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
            // Chat List
            Expanded(
              child: ListView(
                children: [
                  ChatListItem(
                    name: 'Jony Gomes',
                    message: 'Hi! How are you? 😊',
                    time: '9:41',
                    avatar: 'https://randomuser.me/api/portraits/men/1.jpg',
                    unreadCount: 0,
                    onTap: () {
                      context.pushNamed(
                        RouteNames.chatInboxScreen,
                        extra: {
                          'name': 'Jony Gomes',
                          'avatar':
                              'https://randomuser.me/api/portraits/men/1.jpg',
                        },
                      );
                    },
                  ),
                  ChatListItem(
                    name: 'carol smith',
                    message: 'Hi! How are you? 😊',
                    time: '9:41',
                    avatar: 'https://randomuser.me/api/portraits/women/2.jpg',
                    unreadCount: 2,
                    onTap: () {
                      context.pushNamed(
                        RouteNames.chatInboxScreen,
                        extra: {
                          'name': 'carol smith',
                          'avatar':
                              'https://randomuser.me/api/portraits/women/2.jpg',
                        },
                      );
                    },
                  ),
                  ChatListItem(
                    name: 'lauren gomes',
                    message: 'Hi! How are you? 😊',
                    time: '9:41',
                    avatar: 'https://randomuser.me/api/portraits/women/8.jpg',
                    unreadCount: 0,
                    onTap: () {
                      context.pushNamed(
                        RouteNames.chatInboxScreen,
                        extra: {
                          'name': 'lauren gomes',
                          'avatar':
                              'https://randomuser.me/api/portraits/women/8.jpg',
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatListItem extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final String avatar;
  final int unreadCount;
  final VoidCallback onTap;

  const ChatListItem({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    required this.avatar,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                avatar,
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
                    name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff303030),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
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
                  time,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                ),
                if (unreadCount > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      unreadCount.toString(),
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
