import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/community.dart';
import 'package:vibe_now/model/event.dart';
import 'package:vibe_now/views/chat/chat_screen.dart';
import 'package:vibe_now/views/common/avatar_stack.dart';
import 'package:vibe_now/views/community/community_manage_member_screen.dart';
import 'package:vibe_now/views/community/community_plan_meetup_screen.dart';
import 'package:vibe_now/views/community/edit_community_screen.dart';
import 'package:vibe_now/views/community/meetup_details_screen.dart';
import 'package:vibe_now/views/community/Community_member_screen.dart';
import 'package:vibe_now/views/community/widgets/meetup_card.dart';
import 'package:vibe_now/views/event/widgets/event_card.dart';

class CommunityDetailsScreen extends StatefulWidget {
  const CommunityDetailsScreen({super.key, required this.community});
  final Community community;

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

                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Neighbors Get Together",
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xff303030),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.pushNamed(
                                  RouteNames.communityChatScreen,
                                  extra: widget.community,
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(6.w),
                                decoration: BoxDecoration(
                                  color: Color(0xff_F0F7FF),
                                  shape: BoxShape.circle,
                                ),
                                child: Assets.icons.chatting.svg(
                                  width: 24.w,
                                  height: 24.h,
                                ),
                              ),
                            ),
                          ],
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CommunityMemberScreen(),
                                  ),
                                );
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
                              child: SizedBox(
                                height: 42.h,
                                child: PrimaryButton.text(
                                  gradient: AppColors.primaryGradientRotated,
                                  radius: 12.r,
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CommunityPlanMeetupScreen(),
                                      ),
                                    );
                                  },
                                  text: "Plan meetup",
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),

                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                color: Colors.grey.shade100,
                              ),

                              child: PopupMenuButton(
                                color: AppColors.surface,
                                iconColor: Colors.grey.shade600,
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    onTap: () {
                                      context.pop();
                                    },
                                    child: Row(
                                      children: [
                                        Assets.icons.leave.svg(
                                          width: 24.w,
                                          height: 24.h,
                                          color: AppColors.primary,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          "Leave",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),

                        // About Event
                        Text(
                          'About Community',
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

                        // Upcoming Events
                        Text(
                          'Planed Meetup',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        GestureDetector(
                          onTap: () {
                            // context.pushNamed(RouteNames.communityMemberScreen);
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) =>
                            //         const MeetupDetailsScreen(),
                            //   ),
                            // );
                          },
                          child: MeetupCard(
                            event: Event(
                              name: '  ',
                              location: '123 Main St, New York, NY 10001',
                              date: '21 Nov',
                              time: '8PM - 11PM',
                              description: '10 Interested • 16 Going',
                              image:
                                  'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800',
                              attending: '5',
                              totalAttending: '10',
                              isJoined: true,
                              isMyEvent: true,
                              accessType: EventAccessType.public,
                            ),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditCommunityScreen(community: widget.community),
                        ),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
