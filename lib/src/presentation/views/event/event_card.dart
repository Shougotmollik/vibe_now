import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/event.dart';
import 'package:vibe_now/src/presentation/views/event/widgets/event_animated_dialog.dart';
import 'package:vibe_now/src/presentation/views/notification/widgets/animated_dialog_content.dart';

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
      case EventStatus.interested:
        return 'Interested';
      case EventStatus.going:
        return 'Going';
      case EventStatus.requested:
        return 'Interested';
    }
  }

  // bool get isButtonActive {
  //   return currentStatus == EventStatus.interested;
  // }

  // void _handleButtonTap() {
  //   if (currentStatus != EventStatus.requested) {
  //     setState(() {
  //       currentStatus = EventStatus.requested;
  //     });
  //     AppSnackbar.show(
  //       message: "Your request to join this event has been sent",
  //       type: SnackType.success,
  //     );
  //   }
  // }

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
                        onTap: () {
                          setState(() {
                            if (currentStatus == EventStatus.requested) {
                              currentStatus = EventStatus.interested;
                              showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) {
                                  return Center(
                                    child: Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          20.r,
                                        ),
                                      ),
                                      elevation: 0,
                                      backgroundColor: Colors.transparent,
                                      child: EventAnimatedDialog(
                                        content:
                                            'Revoke your request to join the event',
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else {
                              currentStatus = EventStatus.requested;
                              showDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) {
                                  return Center(
                                    child: Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          20.r,
                                        ),
                                      ),
                                      elevation: 0,
                                      backgroundColor: Colors.transparent,
                                      child: EventAnimatedDialog(
                                        content:
                                            'Send a request to the event creator to joint the event',
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey.shade300),
                            gradient: EventStatus.interested != currentStatus
                                ? null
                                : AppColors.primaryGradientRotated,
                            color: EventStatus.interested != currentStatus
                                ? Color(0xffC4A8FF)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              buttonText,
                              style: TextStyle(
                                color: EventStatus.interested != currentStatus
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
                    widget.event.isMyEvent
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
