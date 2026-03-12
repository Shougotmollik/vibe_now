import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/event.dart';
import 'package:vibe_now/views/common/avatar_stack.dart';

class EventDetailsScreen extends StatelessWidget {
  const EventDetailsScreen({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 400.h,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(event.image),
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
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
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
                            backgroundColor: Colors.white,
                            child: Assets.icons.edit.svg(
                              color: Colors.black,
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
                      event.name,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Assets.icons.location.svg(),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            event.location,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.subText,
                              fontWeight: FontWeight.w400,
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
                          '${event.time}, ${event.date}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.subText,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Text(
                          event.description,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.subText,
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
                          '${event.attending}/${event.totalAttending} attending',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.subText,
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
                            imageUrls: [
                              "https://i.pravatar.cc/150?img=1",
                              "https://i.pravatar.cc/150?img=2",
                              "https://i.pravatar.cc/150?img=3",
                              "https://i.pravatar.cc/150?img=4",
                              "https://i.pravatar.cc/150?img=5",
                            ],
                            extraCount: 5,
                          ),
                        ),
                        TextButton(onPressed: () {}, child: Text("View all")),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    Row(
                      children: [
                        Expanded(
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
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: Color(0xff_F4F4F4),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Assets.icons.archive.svg(
                            width: 24.w,
                            height: 24.h,
                            color: AppColors.primaryText,
                          ),
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
  }
}
