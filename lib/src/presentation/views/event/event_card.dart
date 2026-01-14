import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';

class EventCard extends StatefulWidget {
  const EventCard({super.key, this.isMyEvent = false, this.isJoined = false});

  @override
  State<EventCard> createState() => _EventCardState();

  final bool isMyEvent;
  final bool isJoined;
}

class _EventCardState extends State<EventCard> {
  String btnText = 'Interested';
  String requestBtnText = 'Request';
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
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Club House',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Assets.icons.location.svg(),
              SizedBox(width: 4.w),
              Text(
                '123 Main St, New York, NY 10001',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Assets.icons.calender3.svg(),
              SizedBox(width: 4.w),
              Text(
                '8PM - 11PM, 21 Nov',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Text(
                '10 Interested • 16 Going',
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
                '5/10 attending',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
          SizedBox(height: 12),
          widget.isMyEvent
              ? SizedBox.shrink()
              : Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: widget.isJoined
                            ? () {
                                setState(() {
                                  requestBtnText = 'Waiting';
                                });
                                AppSnackbar.show(
                                  message:
                                      "You request to join this event has been sent",
                                  type: SnackType.success,
                                );
                              }
                            : null,
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey.shade300),
                            gradient: AppColors.primaryGradientRotated,
                          ),
                          child: Center(
                            child: Text(
                              widget.isJoined ? requestBtnText : btnText,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    widget.isJoined
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
                                    setState(() {
                                      btnText = 'Going';
                                    });
                                    // context.pop();
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
