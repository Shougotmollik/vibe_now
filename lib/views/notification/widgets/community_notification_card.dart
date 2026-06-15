import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/notification.dart';

class CommunityNotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final LinearGradient? unreadGradient;
  final VoidCallback? onTap;
  const CommunityNotificationCard({
    super.key,
    required this.acceptOnTap,
    required this.rejectOnTap,
    required this.notification,
    this.unreadGradient,
    this.onTap,
  });
  final VoidCallback acceptOnTap;
  final VoidCallback rejectOnTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          gradient: !notification.isRead ? unreadGradient : null,
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          spacing: 8.w,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50.r),
              child: notification.actor.avatar != null
                  ? Image.network(
                      AppCredentials.fixurl(notification.actor.avatar!),
                      width: 50.w,
                      height: 50.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _defaultAvatar(context),
                    )
                  : _defaultAvatar(context),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(
                    width: 180.w,
                    child: Row(
                      children: [
                        Assets.icons.timeCircle.svg(
                          width: 16.w,
                          height: 16.h,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          timeago.format(
                            DateTime.parse(notification.createdAt),
                          ),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            notification.invitation
                ? SizedBox(
                    child: Row(
                      spacing: 8.w,
                      children: [
                        GestureDetector(
                          onTap: acceptOnTap,
                          child: Assets.icons.accept.svg(
                            width: 20.w,
                            height: 20.h,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        GestureDetector(
                          onTap: rejectOnTap,
                          child: Assets.icons.decline.svg(
                            width: 22.w,
                            height: 22.h,
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _defaultAvatar(BuildContext context) {
    return Container(
      width: 50.w,
      height: 50.w,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(50.r),
      ),
      child: Icon(
        Icons.person,
        size: 24.w,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
