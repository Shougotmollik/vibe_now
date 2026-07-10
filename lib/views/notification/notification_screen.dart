import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/controller/notification_controller.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/model/community.dart';
import 'package:vibe_now/model/notification.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/community/meetup_details_screen.dart';
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
  final List<String> _tabKeys = ['vibes', 'events', 'communities'];

  String _tabLabel(AppLocalizations loc, int index) {
    switch (index) {
      case 0: return loc.translate('waves');
      case 1: return loc.translate('events');
      case 2: return loc.translate('community');
      default: return '';
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.getNotifications(_tabKeys[0]);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
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
                  CustomAppBar(title: loc.translate('notifications')),
                  SizedBox(height: 16.h),
                  Obx(() => _buildTabBar(loc)),
                  SizedBox(height: 16.h),
                  _buildTabContent(loc),
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

  Widget _buildTabBar(AppLocalizations loc) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabKeys.length, (index) {
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
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
                    decoration: BoxDecoration(
                      gradient: isSelected ? _tabGradients[index] : null,
                      color: isSelected
                          ? null
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? null
                          : Border.all(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                              width: 1,
                            ),
                    ),
                    child: Row(
                      spacing: 6.w,
                      children: [
                        isSelected ? _tabIcons[index] : const SizedBox.shrink(),
                        Text(
                          _tabLabel(loc, index),
                          style: TextStyle(
                            color: isSelected ? Colors.black87 : Theme.of(context).colorScheme.onSurface,
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
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Text(
                          count.toString(),
                          style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w600),
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

  Widget _buildTabContent(AppLocalizations loc) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildNotificationsList(_controller.vibes, loc, 0);
      case 1:
        return _buildNotificationsList(_controller.events, loc, 1);
      case 2:
        return _buildNotificationsList(_controller.communities, loc, 2);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNotificationsList(RxList<NotificationModel> items, AppLocalizations loc, int tabIndex) {
    return Obx(() {
      if (_controller.isLoading(_tabKeys[tabIndex]) && items.isEmpty) {
        return const NotificationShimmer();
      }
      if (items.isEmpty) {
        return SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: Center(
            child: Text(
              loc.translate('noItemsFound'),
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        );
      }
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: List.generate(items.length, (index) => _buildNotificationCard(items[index], tabIndex)),
        ),
      );
    });
  }

  Widget _buildNotificationCard(NotificationModel notification, int tabIndex) {
    return GestureDetector(
      onTap: () {
        if (!notification.isRead) {
          _controller.readNotificationById(ids: [notification.id]);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          gradient: !notification.isRead ? LinearGradient(
            colors: _tabGradients[tabIndex].colors.map((c) => c.withValues(alpha: 0.08)).toList(),
            stops: _tabGradients[tabIndex].stops,
            begin: _tabGradients[tabIndex].begin,
            end: _tabGradients[tabIndex].end,
          ) : null,
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
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Assets.icons.timeCircle.svg(
                        width: 16.w, height: 16.h,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        timeago.format(DateTime.parse(notification.createdAt)),
                        style: TextStyle(fontSize: 12.sp, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8)),
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
      width: 50.w, height: 50.w,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(50.r),
      ),
      child: Icon(Icons.person, size: 24.w, color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}
