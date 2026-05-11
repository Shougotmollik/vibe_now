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
                      color: Theme.of(
                        context,
                      ).colorScheme.background,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).shadowColor.withValues(alpha: 0.08),
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
                              color: Theme.of(context).dividerColor,
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
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
                                  color: Theme.of(context).colorScheme.surface,
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
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),

                            Text(
                              "300km away",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
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
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),

                            Text(
                              "8PM, 21 Nov",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
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
                                  color: Theme.of(context).colorScheme.primary,
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
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceVariant,
                              ),

                              child: PopupMenuButton(
                                color: Theme.of(context).colorScheme.surface,
                                iconColor: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
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
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          "Leave",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w400,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
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
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Lorem ipsum dolor sit amet consectetur. Mattis neque elementum laoreet faucibus morbi venenatis nam nisi. Morbi sit dolor porttitor dictum laoreet nunc dictum. Aliquet erat sit pellentesque proin parturient aliquet.',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
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
                            color: Theme.of(context).colorScheme.onSurface,
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
                              title: '  ',
                              address: '123 Main St, New York, NY 10001',
                              eventDate: '21 Nov',
                              eventTime: '8PM - 11PM',
                              coverImage:
                                  'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800',
                              interestedCount: 5,
                              maxAttendees: 10,
                              isJoined: true,
                              isInterested: true,
                              accessLevel: 'public',
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
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      child: Assets.icons.edit.svg(
                        color: Theme.of(context).colorScheme.onSurface,
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
