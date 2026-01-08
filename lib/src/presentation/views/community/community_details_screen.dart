import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/src/presentation/views/common/avatar_stack.dart';

class CommunityDetailsScreen extends StatefulWidget {
  const CommunityDetailsScreen({super.key});

  @override
  State<CommunityDetailsScreen> createState() => _CommunityDetailsScreenState();
}

class _CommunityDetailsScreenState extends State<CommunityDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: 380.h,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800',
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.65),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.65,
            // maxChildSize: 0.9,
            builder: (context, scrollController) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.all(16.w),

                      children: [
                        // Handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: EdgeInsets.only(bottom: 24.h),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        Text(
                          "Neighbors Get Together",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xff303030),
                          ),
                        ),
                        SizedBox(height: 10.h),

                        Row(
                          spacing: 4.w,
                          children: [
                            Assets.icons.location.svg(
                              width: 16.w,
                              height: 16.h,
                              color: Color(0xff707070),
                            ),

                            Text(
                              "300km away",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff707070),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),

                        Row(
                          spacing: 4.w,
                          children: [
                            Assets.icons.timeCircle.svg(
                              width: 16.w,
                              height: 16.h,
                              color: Color(0xff707070),
                            ),

                            Text(
                              "8PM, 21 Nov",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff707070),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
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
                            TextButton(
                              onPressed: () {
                                context.pushNamed(RouteNames.memberScreen);
                              },
                              child: Text(
                                "View all",
                                style: TextStyle(
                                  color: Color(0xff008CFF),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20.h),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),

                                  gradient: AppColors.primaryGradient,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Icon(
                                    //   Icons.favorite,
                                    //   color: Colors.white,
                                    //   size: 20.sp,
                                    // ),
                                    Assets.icons.chattingLight.svg(
                                      width: 24.w,
                                      height: 24.h,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8.w),
                                    // Text(
                                    //   'Interested',
                                    //   style: TextStyle(
                                    //     color: Colors.white,
                                    //     fontSize: 16.sp,
                                    //     fontWeight: FontWeight.w600,
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                color: Colors.grey.shade100,
                              ),
                              child: Icon(
                                Icons.more_vert,
                                color: Colors.black54,
                                size: 20.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),

                        // About Event
                        Text(
                          'About Event',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Lorem ipsum dolor sit amet consectetur. Mattis neque elementum laoreet faucibus morbi venenatis nam nisi. Morbi sit dolor porttitor dictum laoreet nunc dictum. Aliquet erat sit pellentesque proin parturient aliquet.',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Experiences Section
                        Text(
                          'Experiences',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        // Experience Card
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20.r,
                                    backgroundImage: const NetworkImage(
                                      'https://i.pravatar.cc/150?img=5',
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Jenny smith',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.celebration_outlined,
                                            size: 14.sp,
                                            color: Colors.grey.shade600,
                                          ),
                                          SizedBox(width: 4.w),
                                          Text(
                                            '20 Oct',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'Had a wonderful day with you guys 😊',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
