import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/notification.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/notification/widgets/animated_dialog_content.dart';
import 'package:vibe_now/views/notification/widgets/community_notification_card.dart';
import 'package:vibe_now/views/notification/widgets/event_notification_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

final List<NotificationModel> waves = [
  NotificationModel(title: 'Jenny Smith sent you a wave', distance: '160'),
  NotificationModel(title: 'Metin sent you a wave', distance: '90'),
  NotificationModel(title: 'Alex sent you a wave', distance: '20'),
];

final List<NotificationModel> events = [
  NotificationModel(
    title: 'Jenny smith is interested in your event',
    distance: '160',
  ),
  NotificationModel(
    title: 'Engin Accepted your event join request',
    distance: '90',
  ),
  NotificationModel(title: 'Metin joined in your event', distance: '20'),
];

final List<NotificationModel> communities = [
  NotificationModel(
    title: 'Jenny smith is interested in your community',
    distance: '160',
  ),
  NotificationModel(
    title: 'Engin Accepted your community join request',
    distance: '90',
  ),
  NotificationModel(
    title: 'Metin invited you join to community meetup',
    distance: '20',
    invitation: true,
  ),
];

class _NotificationScreenState extends State<NotificationScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Waves', 'Events', 'Community'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const CustomAppBar(title: "Notification"),
              SizedBox(height: 16.h),
              _buildTabBar(),
              SizedBox(height: 16.h),
              Expanded(child: _buildTabContent()),
            ],
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
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = index),
              child: Container(
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
                            ? (index == 0 ? Colors.white : Colors.black87)
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
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
    return SingleChildScrollView(
      child: Container(
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
                waves.length,
                (index) => _buildWaveCard(context, waves[index]),
              ),
              context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsSection() {
    return SingleChildScrollView(
      child: Container(
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
                events.length,
                (index) => EventNotificationCard(notification: events[index]),
              ),
              context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunitySection() {
    return SingleChildScrollView(
      child: Container(
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
                communities.length,
                (index) => _buildCommunityCard(context, index),
              ),
              context,
            ),
          ],
        ),
      ),
    );
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

  Widget _buildWaveCard(BuildContext context, NotificationModel notification) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Row(
        spacing: 8.w,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50.r),
            child: Image.asset(
              "assets/images/profile_picture.jpg",
              width: 50.w,
              height: 50.w,
              fit: BoxFit.cover,
            ),
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
                      '6 hours ago',
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
    );
  }

  Widget _buildCommunityCard(BuildContext context, int index) {
    final notification = communities[index];
    return CommunityNotificationCard(
      notification: notification,
      acceptOnTap: () {
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
                  content:
                      'You have accepted ${notification.title.split(' ').take(2).join(' ')} invitation.',
                  accept: true,
                ),
              ),
            );
          },
        );
      },
      rejectOnTap: () {
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
                child: const AnimatedDialogContent(
                  content: 'You have rejected the invitation.',
                  accept: false,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
