import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/controller/event_controller.dart';
import 'package:vibe_now/core/constant/qrcontext_enum.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/event.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/common/custom_search_bar.dart';
import 'package:vibe_now/views/event/widgets/event_card.dart';
import 'package:vibe_now/views/event/widgets/event_filter.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final List<String> tabs = ['All', 'Joined', 'Organized', 'Interested'];
  final selectedTab = 'All'.obs;
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  final EventController eventController = Get.find<EventController>();

  @override
  void initState() {
    super.initState();
    eventController.getEvents(tab: 'all');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: RefreshIndicator(
            onRefresh: () => eventController.getEvents(
              tab: selectedTab.value.toLowerCase(),
            ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Obx(() {
                return Column(
                  children: [
                    _buildAppBar(context),
                    SizedBox(height: 12.h),

                    // Search bar with filter
                    CustomSearchBar(
                      controller: searchController,
                      onFilterTap: () => showDialog(
                        context: context,
                        builder: (context) => const EventFilterDialog(),
                      ),
                      hintText: 'Search for events',
                      onChanged: (query) {
                        _debounce?.cancel();
                        _debounce = Timer(const Duration(milliseconds: 500), () {
                          eventController.getEvents(
                            tab: selectedTab.value.toLowerCase(),
                            search: query,
                          );
                        });
                      },
                    ),

                    SizedBox(height: 12.h),

                    // Category tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: tabs.map((tab) {
                          final isSelected = selectedTab.value == tab;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () async {
                                selectedTab.value = tab;
                                await eventController.getEvents(
                                  tab: tab.toLowerCase(),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 8.w,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? AppColors.primaryGradientRotated
                                      : null,
                                  color: isSelected
                                      ? null
                                      : Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  tab,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Theme.of(context).colorScheme.onSurface,
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
                    Obx(() {
                      final isLoading = eventController.isLoading.value;
                      final events = eventController.eventList;

                      if (isLoading) {
                        return Column(
                          children: List.generate(
                            3,
                            (index) => Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: EventCard(
                                event: Event(
                                  accessLevel: '',
                                  coverImage: '',
                                  isInterested: false,
                                  title: "",
                                  address: "",
                                  eventTime: "",
                                  eventDate: "",
                                  interestedCount: 0,
                                ),
                                isLoading: true,
                              ),
                            ),
                          ),
                        );
                      }

                      if (events.isEmpty) {
                        return _buildEmptyState(context, selectedTab.value);
                      }

                      return Column(
                        children: events
                            .map(
                              (e) => Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: EventCard(event: e),
                              ),
                            )
                            .toList(),
                      );
                    }),

                    SizedBox(height: 24),
                  ],
                );
              }),
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
        const Spacer(),
        GestureDetector(
          onTap: () => context.pushNamed(
            RouteNames.qrVerificationScreen,
            extra: {'qrContext': QRContext.event, 'showScanOnly': true},
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Assets.icons.scan.svg(
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
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

  Widget _buildEmptyState(BuildContext context, String tab) {
    String message;
    String subMessage;

    switch (tab) {
      case 'Joined':
        message = 'No events joined yet';
        subMessage = 'Browse & join events';
        break;
      case 'Organized':
        message = 'No events organized yet';
        subMessage = 'Create your first event';
        break;
      case 'Interested':
        message = 'No interested events yet';
        subMessage = 'Browse & mark your interest';
        break;
      default:
        message = 'No events available';
        subMessage = 'Check back later or create a new event';
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Assets.icons.calender2.svg(
              width: 80.w,
              height: 80.h,
              colorFilter: ColorFilter.mode(
                AppColors.secondaryText,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              style: AppTypography.textTheme.headlineMedium?.copyWith(
                fontSize: 20.sp,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              subMessage,
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}