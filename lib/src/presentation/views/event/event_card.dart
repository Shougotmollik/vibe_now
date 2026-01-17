import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';

enum EventStatus { request, requested, interested, going }

class Event {
  String name;
  String description;
  String date;
  String time;
  String location;
  String image;
  String attending;
  String totalAttending;
  bool isJoined;
  bool isMyEvent;
  EventStatus? userStatus; // Can be null, interested, going, or requested

  Event({
    required this.name,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.image,
    required this.attending,
    required this.totalAttending,
    this.isJoined = false,
    this.isMyEvent = false,
    this.userStatus,
  });

  Event copyWith({
    String? name,
    String? description,
    String? date,
    String? time,
    String? location,
    String? image,
    String? attending,
    String? totalAttending,
    bool? isJoined,
    bool? isMyEvent,
    EventStatus? userStatus,
  }) {
    return Event(
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      image: image ?? this.image,
      attending: attending ?? this.attending,
      totalAttending: totalAttending ?? this.totalAttending,
      isJoined: isJoined ?? this.isJoined,
      isMyEvent: isMyEvent ?? this.isMyEvent,
      userStatus: userStatus ?? this.userStatus,
    );
  }
}

class EventCard extends StatefulWidget {
  const EventCard({super.key, required this.event});

  @override
  State<EventCard> createState() => _EventCardState();

  final Event event;
}

class _EventCardState extends State<EventCard> {
  late EventStatus? currentStatus;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.event.userStatus;
  }

  String get buttonText {
    if (currentStatus == null) return 'Request';
    switch (currentStatus!) {
      case EventStatus.request:
        return 'Request';
      case EventStatus.requested:
        return 'Requested';
      case EventStatus.interested:
        return 'Interested';
      case EventStatus.going:
        return 'Going';
    }
  }

  bool get isButtonActive {
    return currentStatus == EventStatus.requested;
  }

  void _handleButtonTap() {
    if (currentStatus != EventStatus.requested) {
      setState(() {
        currentStatus = EventStatus.requested;
      });
      AppSnackbar.show(
        message: "Your request to join this event has been sent",
        type: SnackType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.h),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 200.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(widget.event.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            widget.event.name,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Assets.icons.location.svg(),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  widget.event.location,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Assets.icons.calender3.svg(),
              SizedBox(width: 4.w),
              Text(
                '${widget.event.time}, ${widget.event.date}',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Text(
                widget.event.description,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Assets.icons.users.svg(),
              SizedBox(width: 4.w),
              Text(
                '${widget.event.attending}/${widget.event.totalAttending} attending',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
          SizedBox(height: 12),
          widget.event.isMyEvent
              ? SizedBox.shrink()
              : Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _handleButtonTap,
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey.shade300),
                            gradient: isButtonActive
                                ? null
                                : AppColors.primaryGradientRotated,
                            color: isButtonActive ? Colors.grey.shade200 : null,
                          ),
                          child: Center(
                            child: Text(
                              buttonText,
                              style: TextStyle(
                                color: isButtonActive
                                    ? Colors.grey.shade600
                                    : Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    isButtonActive
                        ? SizedBox.shrink()
                        : Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              color: Colors.grey.shade200,
                            ),
                            child: PopupMenuButton(
                              color: AppColors.surface,
                              iconColor: Colors.grey.shade600,
                              icon: Assets.icons.down.svg(),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  onTap: () {
                                    Future.delayed(Duration.zero, () {
                                      setState(() {
                                        currentStatus = EventStatus.interested;
                                      });
                                    });
                                  },
                                  child: Text(
                                    "Interested",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                                PopupMenuItem(
                                  onTap: () {
                                    Future.delayed(Duration.zero, () {
                                      setState(() {
                                        currentStatus = EventStatus.going;
                                      });
                                    });
                                  },
                                  child: Text(
                                    "Going",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
        ],
      ),
    );
  }
}