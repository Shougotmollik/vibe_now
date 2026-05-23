import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/core/constant/qrcontext_enum.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/event.dart';
import 'package:vibe_now/controller/event_controller.dart';
import 'package:vibe_now/services/local_storage.dart';
import 'package:vibe_now/views/common/avatar_stack.dart';
import 'package:vibe_now/views/event/event_chat_screen.dart';
import 'package:vibe_now/views/event/event_member_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({super.key, required this.eventId});

  final int eventId;

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final EventController _eventController = Get.find<EventController>();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
      _eventController.getEventDetails(id: widget.eventId);
    });
  }

  Future<void> _loadCurrentUserId() async {
    final userId = await LocalStorage.user_id.get();
    if (mounted) {
      setState(() {
        _currentUserId = userId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_eventController.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final event = _eventController.eventDetails.value;
      if (event == null) {
        return Scaffold(body: Center(child: Text('Event not found')));
      }

      return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 400.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      AppCredentials.fixurl(event.coverImage),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 40.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).maybePop(),
                            child: CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surface,
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                        if (event.createdBy?.id == _currentUserId)
                          Align(
                            alignment: Alignment.topLeft,
                            child: GestureDetector(
                              onTap: () {
                                context.pushNamed(
                                  RouteNames.editEventScreen,
                                  extra: event,
                                );
                              },
                              child: CircleAvatar(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.surface,
                                child: Assets.icons.edit.svg(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fit: BoxFit.cover,
                                  height: 24.w,
                                  width: 24.w,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // Event Details Card
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Title
                      Text(
                        event.title ?? "",
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Assets.icons.location.svg(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withAlpha(150),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              event.address ?? "",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withAlpha(150),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      _buildDateTimeRow(event),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Text(
                            "${event.interestedCount} Interested • ${event.joinedCount} Going",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Assets.icons.community.svg(width: 16.w, height: 16.h),
                          SizedBox(width: 4.w),
                          Text(
                            '${event.joinedCount}/${event.maxAttendees} attending',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: AvatarStack(
                              imageUrls:
                                  event.participants
                                      ?.take(5)
                                      .map(
                                        (p) => AppCredentials.fixurl(p.avatar),
                                      )
                                      .toList() ??
                                  [],
                              extraCount: (event.joinedCount ?? 0) > 5
                                  ? (event.joinedCount ?? 0) - 5
                                  : 0,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => EventMemberScreen(
                                    eventId: widget.eventId,
                                  ),
                                ),
                              );
                            },
                            child: Text("View all"),
                          ),
                        ],
                      ),

                      SizedBox(height: 20.h),

                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => EventChatScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradientRotated,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Assets.icons.chatting.svg(
                                  width: 24.w,
                                  height: 24.h,
                                  color: AppColors.surface,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),

                          // QR Code Button
                          if ((event.qrCodeImage != null ||
                                  event.qrCodeValue != null) &&
                              event.createdBy?.id == _currentUserId)
                            GestureDetector(
                              onTap: () {
                                context.pushNamed(
                                  RouteNames.qrVerificationScreen,
                                  extra: {
                                    'qrContext': QRContext.event,
                                    'showQRCodeOnly': true,
                                    'qrCodeUrl': event.qrCodeImage,
                                    'qrCodeValue': event.qrCodeValue,
                                  },
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(30),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Assets.icons.scanner.svg(
                                  width: 24.w,
                                  height: 24.h,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          if ((event.qrCodeImage != null ||
                                  event.qrCodeValue != null) &&
                              event.createdBy?.id == _currentUserId)
                            SizedBox(width: 8.w),

                          if (event.createdBy?.id != _currentUserId)
                            PopupMenuButton<int>(
                              icon: Icon(
                                Icons.more_vert,
                                color: Theme.of(context).colorScheme.onSurface,
                                size: 24.sp,
                              ),

                              offset: Offset(0, 45.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              onSelected: (value) async {
                                if (value == 1) {
                                  // // // Logic for leaving event
                                  // // print("User left the event");
                                  // Navigator.of(context).pop();

                                  final success = await _eventController
                                      .leaveEvent(eventId: event.id ?? 0);

                                  if (success) {
                                    Navigator.of(context).pop();
                                    AppSnackbar.show(
                                      message: "You Leave from ${event.title}",
                                      type: SnackType.info,
                                    );
                                  }
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 1,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.logout_rounded,
                                        color: AppColors.primary,
                                        size: 20.sp,
                                      ),
                                      SizedBox(width: 10.w),
                                      Text(
                                        'Leave Event',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),

                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDateTimeRow(Event event) {
    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return '';
      try {
        final parts = dateStr.split('-');
        if (parts.length != 3) return dateStr;
        final months = [
          '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        final month = int.tryParse(parts[1]) ?? 0;
        return '${int.parse(parts[2])} ${month > 0 && month <= 12 ? months[month] : parts[1]} ${parts[0]}';
      } catch (_) {
        return dateStr;
      }
    }

    final startDate = event.eventStartingDate;
    final startTime = event.eventStartingTime;
    final endDate = event.eventEndingDate;
    final endTime = event.eventEndingTime;

    String dateTimeText = '';

    if (startDate != null) {
      final start = '${formatDate(startDate)}${startTime != null ? "  $startTime" : ""}';
      if (endDate != null) {
        final end = '${formatDate(endDate)}${endTime != null ? "  $endTime" : ""}';
        dateTimeText = '$start  —  $end';
      } else {
        dateTimeText = start;
      }
    } else {
      // Fallback to legacy fields
      dateTimeText = '${event.eventTime ?? ""} ${event.eventDate ?? ""}';
    }

    return Row(
      children: [
        Assets.icons.calender3.svg(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            dateTimeText,
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

