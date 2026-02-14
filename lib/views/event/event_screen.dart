import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/constant/qrcontext_enum.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/event.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/common/custom_search_bar.dart';
import 'package:vibe_now/views/event/event_card.dart';
import 'package:vibe_now/views/event/widgets/event_filter.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final List<String> tabs = ['All', 'Joined', 'Organized', 'Interested'];
  String selectedTab = 'All';

  final List<Event> events = [
    Event(
      name: 'Club House',
      location: '123 Main St, New York, NY 10001',
      date: '21 Nov',
      time: '8PM - 11PM',
      description: '10 Interested • 16 Going',
      image: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800',
      attending: '5',
      totalAttending: '10',
      isJoined: false,
      isMyEvent: false,
      userStatus: EventStatus.interested,
      accessType: EventAccessType.private,
      isFavorite: false,
    ),
    Event(
      name: 'Music Night',
      description: '15 Interested • 20 Going',
      date: '25 Nov',
      time: '9PM - 12AM',
      location: '456 Party Ave, Los Angeles, CA 90001',
      image:
          'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800',
      attending: '8',
      totalAttending: '15',
      isJoined: true,
      isMyEvent: false,
      userStatus: EventStatus.interested,
      accessType: EventAccessType.public,
      isFavorite: false,
    ),
    Event(
      name: 'Beach Party',
      description: '20 Interested • 30 Going',
      date: '28 Nov',
      time: '6PM - 10PM',
      location: '789 Beach Blvd, Miami, FL 33101',
      image:
          'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=800',
      attending: '12',
      totalAttending: '20',
      isJoined: false,
      isMyEvent: true,
      userStatus: EventStatus.going,
      accessType: EventAccessType.public,
      isFavorite: true,
    ),
    Event(
      name: 'Food Festival',
      description: '25 Interested • 40 Going',
      date: '30 Nov',
      time: '5PM - 11PM',
      location: '321 Food St, Chicago, IL 60007',
      image: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800',
      attending: '15',
      totalAttending: '25',
      isJoined: true,
      isMyEvent: true,
      userStatus: EventStatus.going,
      accessType: EventAccessType.private,
      isFavorite: false,
    ),
  ];

  // Filter events based on selected tab
  List<Event> get filteredEvents {
    switch (selectedTab) {
      case 'Joined':
        return events.where((e) => e.userStatus == EventStatus.going).toList();
      case 'Organized':
        return events.where((e) => e.isMyEvent).toList();
      case 'Interested':
        return events
            .where((e) => e.userStatus == EventStatus.interested)
            .toList();
      case 'All':
      default:
        return events;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildAppBar(context),
                SizedBox(height: 12.h),

                // Search bar with filter
                CustomSearchBar(
                  onFilterTap: () => showDialog(
                    context: context,
                    builder: (context) => const EventFilterDialog(),
                  ),
                  hintText: 'Search for events',
                ),

                SizedBox(height: 12.h),

                // Category tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: tabs.map((tab) {
                      final isSelected = selectedTab == tab;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => selectedTab = tab),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 8.w,
                            ),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? AppColors.primaryGradientRotated
                                  : null,
                              color: isSelected ? null : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              tab,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                SizedBox(height: 14.h),

                // Event list based on selected tab
                Column(
                  children: filteredEvents
                      .map(
                        (e) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: EventCard(event: e),
                        ),
                      )
                      .toList(),
                ),

                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Custom AppBar with QR and Add buttons
  Row _buildAppBar(BuildContext context) {
    return Row(
      children: [
        CustomAppBar(title: 'Events'),
        Spacer(),
        GestureDetector(
          onTap: () => context.pushNamed(
            RouteNames.qrVerificationScreen,
            extra: QRContext.event,
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: Assets.icons.scan.svg(),
          ),
        ),
        SizedBox(width: 8),
        GestureDetector(
          onTap: () => context.pushNamed(RouteNames.createEventScreen),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradientRotated,
            ),
            child: Assets.icons.add.svg(),
          ),
        ),
      ],
    );
  }
}
