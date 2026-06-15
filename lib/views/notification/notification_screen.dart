import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/controller/notification_controller.dart';
import 'package:vibe_now/model/notification.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/notification/widgets/animated_dialog_content.dart';
import 'package:vibe_now/views/notification/widgets/community_notification_card.dart';
import 'package:vibe_now/views/notification/widgets/event_notification_card.dart';
import 'package:vibe_now/views/notification/widgets/notification_shimmer.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationController _controller = Get.find<NotificationController>();
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Waves', 'Events', 'Community'];
  final List<String> _tabKeys = ['vibes', 'events', 'communities'];

  @override
  void initState() {
    super.initState();
    _controller.getNotifications(_tabKeys[0]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: RefreshIndicator(
            onRefresh: () async {
              await _controller.getNotifications(
                _tabKeys[_selectedTabIndex],
                forceRefresh: true,
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const CustomAppBar(title: "Notification"),
                  SizedBox(height: 16.h),
                  Obx(() => _buildTabBar()),
                  SizedBox(height: 16.h),
                  _buildTabContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<LinearGradient> get _tabGradients => [
    const LinearGradient(
      colors: [Color(0xFF8663F6), Color(0xFFC470F5), Color(0xFF57C2FF)],
      stops: [0.16, 0.54, 0.92],
    ),
    const LinearGradient(colors: [Color(0xfffbadd8), Color(0xffdeb5fe)]),
    const LinearGradient(colors: [Color(0xff99e2f1), Color(0xffaaccff)]),
  ];

  List<Widget> get _tabIcons => [
    Assets.icons.handWave.svg(
      width: 18.w,
      height: 18.h,
      colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
    ),
    Assets.icons.calendarColor.svg(
      width: 18.w,
      height: 18.h,
      colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
    ),
    Assets.icons.communityColor.svg(
      width: 18.w,
      height: 18.h,
      colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
    ),
  ];

  Widget _buildTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          final count = switch (index) {
            0 => _controller.unreadCounts.value.vibes,
            1 => _controller.unreadCounts.value.events,
            _ => _controller.unreadCounts.value.communities,
          };
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedTabIndex = index);
                _controller.getNotifications(_tabKeys[index]);
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.w,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected ? _tabGradients[index] : null,
                      color: isSelected
                          ? null
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? null
                          : Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.15),
                              width: 1,
                            ),
                    ),
                    child: Row(
                      spacing: 6.w,
                      children: [
                        isSelected ? _tabIcons[index] : const SizedBox.shrink(),
                        Text(
                          _tabs[index],
                          style: TextStyle(
                            color: isSelected
                                ? (index == 0 ? Colors.black87 : Colors.black87)
                                : Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (count > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildWavesSection();
      case 1:
        return _buildEventsSection();
      case 2:
        return _buildCommunitySection();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWavesSection() {
    return Obx(() {
      if (_controller.isLoading('vibes') && _controller.vibes.isEmpty) {
        return const NotificationShimmer();
      }
      final items = _controller.vibes;
      if (items.isEmpty) {
        final mq = MediaQuery.of(context);
        final contentHeight =
            mq.size.height -
            mq.padding.top -
            mq.padding.bottom -
            56.h -
            16.h -
            40.h -
            16.h;
        return SizedBox(
          height: contentHeight > 0 ? contentHeight : 0,
          child: Center(
            child: Text(
              'No waves received yet',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ..._withDividers(
              List.generate(
                items.length,
                (index) => _buildWaveCard(context, items[index]),
              ),
              context,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEventsSection() {
    return Obx(() {
      if (_controller.isLoading('events') && _controller.events.isEmpty) {
        return const NotificationShimmer();
      }
      final items = _controller.events;
      if (items.isEmpty) {
        final mq = MediaQuery.of(context);
        final contentHeight =
            mq.size.height -
            mq.padding.top -
            mq.padding.bottom -
            56.h -
            16.h -
            40.h -
            16.h;
        return SizedBox(
          height: contentHeight > 0 ? contentHeight : 0,
          child: Center(
            child: Text(
              'No event updates yet',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ..._withDividers(
              List.generate(
                items.length,
                (index) => EventNotificationCard(
                  notification: items[index],
                  unreadGradient: _unreadGradient(1),
                  onTap: () {
                    final n = items[index];
                    if (!n.isRead) {
                      _controller.readNotificationById(ids: [n.id]);
                    }
                  },
                ),
              ),
              context,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCommunitySection() {
    return Obx(() {
      if (_controller.isLoading('communities') &&
          _controller.communities.isEmpty) {
        return const NotificationShimmer();
      }
      final items = _controller.communities;
      if (items.isEmpty) {
        final mq = MediaQuery.of(context);
        final contentHeight =
            mq.size.height -
            mq.padding.top -
            mq.padding.bottom -
            56.h -
            16.h -
            40.h -
            16.h;
        return SizedBox(
          height: contentHeight > 0 ? contentHeight : 0,
          child: Center(
            child: Text(
              'No community updates yet',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            ..._withDividers(
              List.generate(
                items.length,
                (index) => _buildCommunityCard(context, index),
              ),
              context,
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _withDividers(List<Widget> items, BuildContext context) {
    if (items.isEmpty) return items;
    return List.generate(items.length * 2 - 1, (i) {
      if (i.isOdd) {
        return Divider(
          height: 1,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        );
      }
      return items[i ~/ 2];
    });
  }

  LinearGradient _unreadGradient(int tabIndex) {
    final g = _tabGradients[tabIndex];
    return LinearGradient(
      colors: g.colors.map((c) => c.withValues(alpha: 0.08)).toList(),
      stops: g.stops,
      begin: g.begin,
      end: g.end,
    );
  }

  Widget _buildWaveCard(BuildContext context, NotificationModel notification) {
    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          _controller.readNotificationById(ids: [notification.id]);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          gradient: !notification.isRead ? _unreadGradient(0) : null,
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
                      errorBuilder: (_, __, ___) => _defaultAvatar(),
                    )
                  : _defaultAvatar(),
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
                  SizedBox(height: 4.h),
                  Row(
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
                        timeago.format(DateTime.parse(notification.createdAt)),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultAvatar() {
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

  Widget _buildCommunityCard(BuildContext context, int index) {
    final notification = _controller.communities[index];
    return CommunityNotificationCard(
      notification: notification,
      unreadGradient: _unreadGradient(2),
      acceptOnTap: () => _handleInvitationAction(
        context: context,
        notification: notification,
        action: 'approve',
        successMessage: 'You have accepted the invitation.',
        accept: true,
      ),
      rejectOnTap: () => _handleInvitationAction(
        context: context,
        notification: notification,
        action: 'reject',
        successMessage: 'You have rejected the invitation.',
        accept: false,
      ),
    );
  }

  Future<void> _handleInvitationAction({
    required BuildContext context,
    required NotificationModel notification,
    required String action,
    required String successMessage,
    required bool accept,
  }) async {
    final ok = await _controller.notificationAction(
      notificationId: notification.id,
      action: action,
    );
    if (!ok || !context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Center(
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: AnimatedDialogContent(
              content: successMessage,
              accept: accept,
            ),
          ),
        );
      },
    );
  }
}
