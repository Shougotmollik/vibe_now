import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/chat.dart';
import 'package:vibe_now/views/chat/chat_screen.dart';

class ChatListItem extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;

  const ChatListItem({super.key, required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Determine background color based on type
    final backgroundColor = chat.type == ChatType.wave
        ? Theme.of(context).colorScheme.surfaceVariant
        : Theme.of(context).colorScheme.surface;

    return InkWell(
      onTap: onTap,
      onLongPress: () => _buildMoreOption(
        context,
        onDelete: () => Navigator.pop(context),
        onBlockUser: () => context.pushNamed(RouteNames.blockScreen),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        color: backgroundColor,
        child: Row(
          children: [
            _buildAvatar(), // Extracted Logic
            SizedBox(width: 12.w),
            Expanded(
              child: _buildChatDetails(context: context),
            ), // Extracted Logic
            _buildTrailingInfo(), // Extracted Logic
          ],
        ),
      ),
    );
  }

  /// Logic to decide which avatar style to show
  Widget _buildAvatar() {
    if (chat.type == ChatType.community) {
      return CommunityAvatar(avatars: chat.avatars);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Image.network(
        chat.avatars.first,
        width: 50.w,
        height: 50.w,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildChatDetails({required BuildContext context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          chat.name,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          chat.message,
          style: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTrailingInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          chat.time,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
        ),
        if (chat.unreadCount > 0) ...[
          SizedBox(height: 4.h),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${chat.unreadCount}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

Future<dynamic> _buildMoreOption(
  BuildContext context, {
  required VoidCallback onDelete,
  required VoidCallback onBlockUser,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: onDelete,
                splashColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 4.w,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 20.sp,
                        color: AppColors.primary,
                      ),
                      Text(
                        'Mute',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Divider(height: 1.5.h),
              InkWell(
                onTap: onDelete,
                splashColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 4.w,
                    children: [
                      Assets.icons.trash.svg(
                        width: 20.w,
                        height: 20.h,
                        // color: Colors.red,
                      ),
                      Text(
                        'Delete Chat',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Divider(height: 1.h),

              InkWell(
                onTap: onBlockUser,
                splashColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 4.w,
                    children: [
                      Assets.icons.block.svg(
                        width: 20.w,
                        height: 20.w,
                        color: AppColors.primary,
                      ),
                      Text(
                        'Block User',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
