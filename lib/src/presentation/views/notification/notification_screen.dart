import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/src/presentation/views/common/custom_app_bar.dart';
import 'package:vibe_now/src/presentation/views/notification/widgets/community_notification_card.dart';
import 'package:vibe_now/src/presentation/views/notification/widgets/event_notification_card.dart';
import 'package:vibe_now/src/presentation/views/notification/widgets/wave_notification_card.dart';
import 'package:vibe_now/model/community_notification.dart';

//filter enum here
enum CommunityFilter { all, request, interest }

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<String> notificationTabs = ['Event', 'Community'];
  int selectedTapIndex = 0;
  CommunityFilter _selectedCommunityFilter = CommunityFilter.all;
  CommunityFilter _selectedEventFilter =
      CommunityFilter.all; // Separate filter for events

  // Community notifications
  final List<NotificationModel> _allCommunityNotifications = [
    NotificationModel(
      id: '1',
      userName: 'Jhon Gomes',
      userImage:
          'https://images.unsplash.com/photo-1525026198548-4baa812f1183?q=80&w=1034&auto=format&fit=crop',
      distance: '300km away',
      type: NotificationType.request,
    ),
    NotificationModel(
      id: '2',
      userName: 'Jenny Smith',
      userImage:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1034&auto=format&fit=crop',
      distance: '300km away',
      type: NotificationType.event,
      eventName: 'City Get Together',
      eventTime: '8PM, 21 Nov',
    ),
    NotificationModel(
      id: '3',
      userName: 'Jhon Gomes',
      userImage:
          'https://images.unsplash.com/photo-1525026198548-4baa812f1183?q=80&w=1034&auto=format&fit=crop',
      distance: '300km away',
      type: NotificationType.request,
    ),
    NotificationModel(
      id: '4',
      userName: 'Jhon Gomes',
      userImage:
          'https://images.unsplash.com/photo-1525026198548-4baa812f1183?q=80&w=1034&auto=format&fit=crop',
      distance: '300km away',
      type: NotificationType.interest,
      interestDescription: 'Is Interested In Rock Concert',
    ),
    NotificationModel(
      id: '5',
      userName: 'Jenny Smith',
      userImage:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1034&auto=format&fit=crop',
      distance: '300km away',
      type: NotificationType.event,
      eventName: 'City Get Together',
      eventTime: '8PM, 21 Nov',
    ),
  ];

  // Event notifications (separate list)
  final List<NotificationModel> _allEventNotifications = [
    NotificationModel(
      id: '1',
      userName: 'Jenny Smith',
      userImage:
          'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?q=80&w=1470&auto=format&fit=crop',
      distance: '300km away',
      type: NotificationType.event,
      eventName: 'Rock Concert',
      eventTime: '8PM, 21 Nov',
    ),
    NotificationModel(
      id: '2',
      userName: 'John Doe',
      userImage:
          'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?q=80&w=1470&auto=format&fit=crop',
      distance: '150km away',
      type: NotificationType.event,
      eventName: 'City Get Together',
      eventTime: '7PM, 22 Nov',
    ),
    NotificationModel(
      id: '3',
      userName: 'Sarah Johnson',
      userImage:
          'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?q=80&w=1470&auto=format&fit=crop',
      distance: '500km away',
      type: NotificationType.interest,
      interestDescription: 'Is Interested In Music Festival',
      eventTime: '9PM, 23 Nov',
    ),
    NotificationModel(
      id: '4',
      userName: 'Mike Wilson',
      userImage:
          'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?q=80&w=1470&auto=format&fit=crop',
      distance: '200km away',
      type: NotificationType.request,
    ),
    NotificationModel(
      id: '5',
      userName: 'Emma Davis',
      userImage:
          'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?q=80&w=1470&auto=format&fit=crop',
      distance: '350km away',
      type: NotificationType.event,
      eventName: 'Stand-up Comedy',
      eventTime: '8PM, 25 Nov',
    ),
  ];

  // Filter community notifications based on selected filter
  List<NotificationModel> get _filteredCommunityNotifications {
    switch (_selectedCommunityFilter) {
      case CommunityFilter.request:
        return _allCommunityNotifications
            .where((n) => n.type == NotificationType.request)
            .toList();
      case CommunityFilter.interest:
        return _allCommunityNotifications
            .where((n) => n.type == NotificationType.interest)
            .toList();
      case CommunityFilter.all:
      default:
        return _allCommunityNotifications;
    }
  }

  // Filter Event notifications based on selected filter
  List<NotificationModel> get _filteredEventNotifications {
    switch (_selectedEventFilter) {
      case CommunityFilter.request:
        return _allEventNotifications
            .where((n) => n.type == NotificationType.request)
            .toList();
      case CommunityFilter.interest:
        return _allEventNotifications
            .where((n) => n.type == NotificationType.interest)
            .toList();
      case CommunityFilter.all:
      default:
        return _allEventNotifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: const CustomAppBar(title: "Notification"),
            ),
            SizedBox(height: 12.h),
            _buildTapBarSection(),
            SizedBox(height: 16.h),

            // Show filter for Event tab
            if (selectedTapIndex == 0) ...[
              _buildEventFilterSection(),
              SizedBox(height: 12.h),
            ],

            // Show filter for Community tab
            if (selectedTapIndex == 1) ...[
              _buildCommunityFilterSection(),
              SizedBox(height: 12.h),
            ],

            Expanded(child: _buildNotificationsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    if (selectedTapIndex == 1) {
      // Community tab with filtering
      return ListView.builder(
        itemCount: _filteredCommunityNotifications.length,
        itemBuilder: (context, index) {
          return CommunityNotificationCard(
            notification: _filteredCommunityNotifications[index],
          );
        },
      );
    } else {
      // Event tab with filtering
      return ListView.builder(
        itemCount: _filteredEventNotifications.length,
        itemBuilder: (context, index) {
          return EventNotificationCard(
            notification: _filteredEventNotifications[index],
          );
        },
      );
    }
  }

  Widget _buildEventFilterSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          _buildEventFilterChip('All', CommunityFilter.all),
          SizedBox(width: 12.w),
          _buildEventFilterChip('Request', CommunityFilter.request),
          SizedBox(width: 12.w),
          _buildEventFilterChip('Interest', CommunityFilter.interest),
        ],
      ),
    );
  }

  Widget _buildCommunityFilterSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          _buildCommunityFilterChip('All', CommunityFilter.all),
          SizedBox(width: 12.w),
          _buildCommunityFilterChip('Request', CommunityFilter.request),
          SizedBox(width: 12.w),
          _buildCommunityFilterChip('Interest', CommunityFilter.interest),
        ],
      ),
    );
  }

  // Filter chip for Event tab
  Widget _buildEventFilterChip(String label, CommunityFilter filter) {
    final isSelected = _selectedEventFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEventFilter = filter;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff303030) : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xff303030)
                : const Color(0xffE0E0E0),
            width: 1.w,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xff707070),
          ),
        ),
      ),
    );
  }

  // Filter chip for Community tab
  Widget _buildCommunityFilterChip(String label, CommunityFilter filter) {
    final isSelected = _selectedCommunityFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCommunityFilter = filter;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff303030) : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? const Color(0xff303030)
                : const Color(0xffE0E0E0),
            width: 1.w,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xff707070),
          ),
        ),
      ),
    );
  }

  Widget _buildTapBarSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 8.w,
        children: List.generate(notificationTabs.length, (index) {
          bool isTapSelected = selectedTapIndex == index;
          return GestureDetector(
            onTap: () => setState(() {
              selectedTapIndex = index;

              // Reset filters when switching tabs
              if (index == 1) {
                _selectedEventFilter = CommunityFilter.all;
              } else if (index == 2) {
                _selectedCommunityFilter = CommunityFilter.all;
              }
            }),
            child: Container(
              height: 32.h,
              width: 110.w,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                gradient: isTapSelected
                    ? AppColors.primaryGradientRotated
                    : const LinearGradient(
                        colors: [Colors.white, Colors.white],
                      ),
                border: Border.all(
                  color: isTapSelected
                      ? Colors.transparent
                      : const Color(0xffEAEAEA),
                ),
              ),
              child: Text(
                notificationTabs[index],
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                  color: isTapSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
