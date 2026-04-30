import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/constant/qrcontext_enum.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/chat.dart';
import 'package:vibe_now/views/chat/chat_list_item.dart';
import 'package:vibe_now/views/qr_verification/qr_verification_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();

  // ! chat dummy data
  final List<Chat> _chatList = [
    Chat(
      avatars: ['https://randomuser.me/api/portraits/women/12.jpg'],
      name: 'Sammy Smith',
      message: 'Sent you a wave!',
      time: '10:30 AM',
      type: ChatType.wave,
    ),
    Chat(
      name: "smith jane",
      message: "my work is done please check it out",
      time: "11:00 AM",
      avatars: ['https://randomuser.me/api/portraits/women/14.jpg'],
      type: ChatType.single,
    ),
    Chat(
      avatars: [
        'https://randomuser.me/api/portraits/men/32.jpg',
        'https://randomuser.me/api/portraits/women/44.jpg',
      ],
      name: 'Coffee Meetup at Central Park',
      message: 'Join us for a coffee meetup at Central Park',
      time: '11:00 AM',
      type: ChatType.community,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 18),
                Text(
                  'Chats',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () => context.pushNamed(
                    RouteNames.qrVerificationScreen,
                    extra: QRContext.chats,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    child: Assets.icons.scan.svg(
                      width: 24.w,
                      height: 24.h,
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
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
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 20.sp,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
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
                      (item) => ChatListItem(
                        chat: item,
                        onTap: () {
                          switch (item.type) {
                            case ChatType.wave:
                              context.pushNamed(
                                RouteNames.waveScreen,
                                extra: item,
                              );
                            case ChatType.community:
                              context.pushNamed(
                                RouteNames.communityChatScreen,
                                extra: item,
                              );
                            case ChatType.single:
                              context.pushNamed(
                                RouteNames.chatInboxScreen,
                                extra: item,
                              );
                          }
                        },
                      ),
                    )
                    .toList(),
              ),
            ),

            // Expanded(
            //   child: Column(
            //     children: _chatList
            //         .map(
            //           (item) => ChatListItem(
            //             chat: item,
            //             onTap: () {
            //               item.wave == true
            //                   ? context.pushNamed(
            //                       RouteNames.waveScreen,
            //                       extra: item,
            //                     )
            //                   : context.pushNamed(
            //                       RouteNames.chatInboxScreen,
            //                       extra: item,
            //                     );
            //             },
            //           ),
            //         )
            //         .toList(),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

// class Chat {
//   final String name;
//   final String message;
//   final String time;
//   final List<String> avatar;
//   final int? unreadCount;
//   final bool wave;
//   final bool isCommunity;
//   Chat({
//     required this.name,
//     required this.message,
//     required this.time,
//     required this.avatar,
//     this.unreadCount,
//     required this.wave,
//     this.isCommunity = false,
//   });
// }

// class ChatListItem extends StatelessWidget {
//   final VoidCallback onTap;

//   final Chat chat;

//   const ChatListItem({super.key, required this.chat, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       onLongPress: () => _buildMoreOption(
//         context,
//         onDelete: () {
//           AppSnackbar.show(message: 'Chat deleted successfully');
//           Navigator.pop(context);
//         },
//         onBlockUser: () {
//           context.pushNamed(RouteNames.blockScreen);
//           context.pop();
//         },
//       ),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: chat.wave ? AppColors.backgroundVariant : Colors.white,
//         ),
//         child: Row(
//           children: [
//             chat.isCommunity
//                 ? CommunityAvatar(avatars: chat.avatar)
//                 : ClipRRect(
//                     borderRadius: BorderRadius.circular(50),
//                     child: Image.network(
//                       chat.avatar[0],
//                       width: 50.w,
//                       height: 50.w,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//             const SizedBox(width: 12),

//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     chat.name,
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w500,
//                       color: Color(0xff303030),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     chat.message,
//                     style: TextStyle(fontSize: 14.sp, color: Color(0xff585858)),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//             // Time and unread badge
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   chat.time,
//                   style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
//                 ),
//                 if (chat.unreadCount! > 0) ...[
//                   const SizedBox(height: 4),
//                   Container(
//                     padding: const EdgeInsets.all(6),
//                     decoration: BoxDecoration(
//                       gradient: AppColors.primaryGradient,
//                       shape: BoxShape.circle,
//                     ),
//                     child: Text(
//                       chat.unreadCount.toString(),
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class CommunityAvatar extends StatelessWidget {
  final List<String> avatars;
  final double size;

  const CommunityAvatar({super.key, required this.avatars, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.w,
      height: size.w,
      child: Stack(
        children: [
          // Background/First Avatar (slightly offset)
          Positioned(
            top: 0,
            left: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                avatars[0],
                width: (size * 0.8).w,
                height: (size * 0.8).w,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Foreground/Second Avatar (bottom right)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  avatars.length > 1 ? avatars[1] : avatars[0],
                  width: (size * 0.7).w,
                  height: (size * 0.7).w,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
