import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/core/routes/route_observer.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/controller/notification_controller.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/model/community.dart';
import 'package:vibe_now/model/incoming_wave.dart';
import 'package:vibe_now/model/notification.dart';
import 'package:vibe_now/views/chat/chat_wave_screen.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/community/meetup_details_screen.dart';
import 'package:vibe_now/views/notification/widgets/animated_dialog_content.dart';
import 'package:vibe_now/views/notification/widgets/community_notification_card.dart';
import 'package:vibe_now/views/notification/widgets/event_notification_card.dart';
import 'package:vibe_now/views/notification/widgets/notification_shimmer.dart';
import 'package:vibe_now/views/vibe/meet_confirm_screen.dart';
import 'package:vibe_now/views/vibe/vibe_connect_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with RouteAware {
  final NotificationController _controller = Get.find<NotificationController>();
  int _selectedTabIndex = 0;
  final List<String> _tabKeys = ['vibes', 'events', 'communities'];

  String _tabLabel(AppLocalizations loc, int index) {
    switch (index) {
      case 0:
        return loc.translate('waves');
      case 1:
        return loc.translate('events');
      case 2:
        return loc.translate('community');
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context);
      if (route != null) {
        routeObserver.subscribe(this, route as PageRoute<dynamic>);
      }
    });
    _controller.getNotifications(_tabKeys[0], forceRefresh: true);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Silently refresh the current tab when coming back from a child route
    _controller.getNotifications(
      _tabKeys[_selectedTabIndex],
      forceRefresh: true,
    );
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
                _controller.getNotifications(_tabKeys[index], forceRefresh: true);
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
                          _tabLabel(loc, index),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.black87
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

  Widget _buildNotificationsList(
    RxList<NotificationModel> items,
    AppLocalizations loc,
    int tabIndex,
  ) {
    return Obx(() {
      if (_controller.isLoading(_tabKeys[tabIndex]) && items.isEmpty) {
        return const NotificationShimmer();
      }
      if (items.isEmpty) {
        return _buildEmptyState(loc, tabIndex);
      }
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: List.generate(
            items.length,
            (index) => _buildNotificationCard(items[index], tabIndex),
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState(AppLocalizations loc, int tabIndex) {
    String titleKey;
    String descKey;
    Widget icon;
    Color iconColor;

    switch (tabIndex) {
      case 0: // Vibes / Waves
        titleKey = 'noWaveNotificationsTitle';
        descKey = 'noWaveNotificationsDesc';
        icon = Assets.icons.handWave.svg(
          width: 80.w,
          height: 80.h,
          colorFilter: ColorFilter.mode(
            AppColors.secondaryText,
            BlendMode.srcIn,
          ),
        );
        iconColor = const Color(0xFF8663F6);
        break;
      case 1: // Events
        titleKey = 'noEventNotificationsTitle';
        descKey = 'noEventNotificationsDesc';
        icon = Assets.icons.calender2.svg(
          width: 80.w,
          height: 80.h,
          colorFilter: ColorFilter.mode(
            AppColors.secondaryText,
            BlendMode.srcIn,
          ),
        );
        iconColor = const Color(0xfffbadd8);
        break;
      case 2: // Communities
      default:
        titleKey = 'noCommunityNotificationsTitle';
        descKey = 'noCommunityNotificationsDesc';
        icon = Assets.icons.community.svg(
          width: 80.w,
          height: 80.h,
          colorFilter: ColorFilter.mode(
            AppColors.secondaryText,
            BlendMode.srcIn,
          ),
        );
        iconColor = const Color(0xff99e2f1);
        break;
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height - 280,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120.w,
                height: 120.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withValues(alpha: 0.1),
                ),
                child: Center(child: icon),
              ),
              SizedBox(height: 24.h),
              Text(
                loc.translate(titleKey),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                loc.translate(descKey),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToWaveScreen(NotificationModel notification) {
    final relObj = notification.relatedObject;
    if (relObj == null) return;

    // Build the IncomingWave from related_object data
    final wave = relObj.toIncomingWave();
    final notifType = notification.notificationType;

    switch (notifType) {
      case 'vibe_wave_received':
        context.pushNamed(RouteNames.waveScreen, extra: wave);
        break;
      case 'vibe_wave_accepted':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => VibeConnectScreen(wave: wave)),
        );
        break;
      case 'vibe_meetup_suggested':
        // Extract meetup details from the wave's meetup data
        final meetup = wave.meetup;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MeetupConfirmationScreen(
              wave: wave,
              locationType: meetup?.locationType,
              latitude: meetup?.latitude,
              longitude: meetup?.longitude,
              address: meetup?.address,
              scheduledAt: meetup?.scheduledAt,
            ),
          ),
        );
        break;
    }
  }

  void _navigateToEventScreen(NotificationModel notification) {
    final relObj = notification.relatedObject;
    if (relObj == null) return;

    // Navigate to event details with the event ID from related_object
    context.pushNamed(RouteNames.eventDetailsScreen, extra: relObj.id);
  }

  void _navigateToCommunityScreen(NotificationModel notification) {
    final relObj = notification.relatedObject;
    // Only navigate if the related object is actually a community
    if (relObj == null || relObj.type != 'community') return;

    // Create a minimal Community with the ID — CommunityDetailsScreen
    // fetches full community data from the API in initState
    final community = Community(id: relObj.id);
    context.pushNamed(
      RouteNames.communityDetailsScreen,
      extra: community,
    );
  }

  Widget _buildNotificationCard(NotificationModel notification, int tabIndex) {
    final unreadGradient = !notification.isRead
        ? LinearGradient(
            colors: _tabGradients[tabIndex].colors
                .map((c) => c.withValues(alpha: 0.08))
                .toList(),
            stops: _tabGradients[tabIndex].stops,
            begin: _tabGradients[tabIndex].begin,
            end: _tabGradients[tabIndex].end,
          )
        : null;

    void handleTap() {
      if (!notification.isRead) {
        _controller.readNotificationById(ids: [notification.id]);
      }
      switch (tabIndex) {
        case 0:
          _navigateToWaveScreen(notification);
          break;
        case 1:
          _navigateToEventScreen(notification);
          break;
        case 2:
          _navigateToCommunityScreen(notification);
          break;
      }
    }

    Future<void> handleAccept() async {
      await _controller.notificationAction(
        notificationId: notification.id,
        action: 'approve',
      );
      // For community join requests, navigate to the manage member screen
      // Skip navigation for meetup_invitation — just accept silently
      if (tabIndex == 2 &&
          mounted &&
          notification.notificationType != 'meetup_invitation') {
        final relObj = notification.relatedObject;
        if (relObj != null) {
          context.pushNamed(
            RouteNames.communityManageMemberScreen,
            extra: relObj.id,
          );
        }
      }
    }

    Future<void> handleReject() async {
      await _controller.notificationAction(
        notificationId: notification.id,
        action: 'reject',
      );
    }

    // Use specialized cards for events & communities tabs which have accept/reject buttons
    switch (tabIndex) {
      case 1:
        return EventNotificationCard(
          notification: notification,
          unreadGradient: unreadGradient,
          onTap: handleTap,
          acceptOnTap: handleAccept,
          rejectOnTap: handleReject,
        );
      case 2:
        return CommunityNotificationCard(
          notification: notification,
          unreadGradient: unreadGradient,
          onTap: handleTap,
          acceptOnTap: handleAccept,
          rejectOnTap: handleReject,
        );
      default:
        return GestureDetector(
          onTap: handleTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              gradient: unreadGradient,
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
                            timeago.format(
                              DateTime.parse(notification.createdAt),
                            ),
                            style: TextStyle(
                              fontSize: 12.sp,
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
}
