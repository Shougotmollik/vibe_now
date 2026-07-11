import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/controller/chat_controller.dart';
import 'package:vibe_now/controller/profile_controller.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';
import 'package:vibe_now/model/chat.dart';
import 'package:vibe_now/views/chat/chat_screen.dart';

class ChatListItem extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;

  const ChatListItem({super.key, required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Determine background color based on type
    final backgroundColor = chat.type == ChatType.community
        ? Theme.of(context).colorScheme.surfaceVariant
        : Theme.of(context).colorScheme.surface;

    return InkWell(
      onTap: onTap,
      onLongPress: () => _buildMoreOption(
        context,
        chat: chat,
        onDelete: () => Navigator.pop(context),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        color: backgroundColor,
        child: Row(
          children: [
            _buildAvatar(context), // Extracted Logic
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
  Widget _buildAvatar(BuildContext context) {
    if (chat.type == ChatType.community || chat.type == ChatType.event) {
      return CommunityAvatar(avatars: chat.avatars);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: CachedNetworkImage(
        imageUrl: AppCredentials.fixurl(chat.avatars.first),
        width: 50.w,
        height: 50.w,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: 50.w,
          height: 50.w,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        errorWidget: (_, __, ___) => Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
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
  required Chat chat,
  required VoidCallback onDelete,
}) {
  final loc = AppLocalizations.of(context);
  final isPrivate = chat.type == ChatType.private;
  final isBlocked = chat.canMessage == false;

  // For private chats that are blocked, show unblock option.
  // For private chats not blocked, show block option.
  // For event/community chats, no block/unblock option.

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mute
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  onDelete();
                },
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
                        loc.translate('mute'),
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

              // Delete Chat
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  onDelete();
                },
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
                      ),
                      Text(
                        loc.translate('deleteChat'),
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

              // Block / Unblock — only for private chats
              if (isPrivate) ...[                Divider(height: 1.h),

                InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                    if (isBlocked) {
                      _showUnblockDialog(context, chat);
                    } else {
                      context.pushNamed(
                        RouteNames.blockScreen,
                        extra: {
                          'userId': chat.otherMember?.id,
                          'userName':
                              chat.otherMember?.fullName ?? chat.name,
                        },
                      );
                    }
                  },
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
                          isBlocked
                              ? loc.translate('unblock')
                              : loc.translate('blockUser'),
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
            ],
          ),
        ),
      );
    },
  );
}

void _showUnblockDialog(BuildContext context, Chat chat) {
  final loc = AppLocalizations.of(context);
  final displayName = chat.otherMember?.fullName ??
      chat.name ??
      loc.translate('defaultUserName');
  final targetUserId = chat.otherMember?.id;

  if (targetUserId == null || targetUserId.isEmpty) return;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                loc.translate('areYouSureUnblock')
                    .replaceFirst('{userName}', displayName),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: CustomElevatedButton(
                      onTap: () => Navigator.pop(dialogContext),
                      buttonText: loc.translate('cancel'),
                      btnColor: Theme.of(context).colorScheme.surfaceVariant,
                      textColor: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomElevatedButton(
                      onTap: () async {
                        Navigator.pop(dialogContext);
                        final success = await Get.find<ProfileController>()
                            .unblockUser(
                          targetUserId: targetUserId,
                          blockRecordId: 0,
                        );
                        if (!context.mounted) return;
                        AppSnackbar.show(
                          message: success
                              ? loc.translate('unblockSuccess')
                              : loc.translate('unblockFailed'),
                          type: success ? SnackType.info : SnackType.error,
                        );
                        if (success && context.mounted) {
                          // Refresh the private chat list
                          Get.find<ChatController>().getChatList(
                            type: 'private',
                            refresh: true,
                          );
                        }
                      },
                      buttonText: loc.translate('unblock'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}