import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/controller/community_controller.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/core/constant/qrcontext_enum.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/community.dart';
import 'package:vibe_now/model/event.dart';
import 'package:vibe_now/services/local_storage.dart';
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
  final CommunityController _communityController =
      Get.find<CommunityController>();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
      if (widget.community.id != null) {
        _communityController.getCommunityDetails(id: widget.community.id!);
      }
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

  bool get isMyCommunity =>
      widget.community.createdBy?.id != null &&
      _currentUserId != null &&
      widget.community.createdBy!.id == _currentUserId;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_communityController.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final community =
          _communityController.communityDetails.value ?? widget.community;

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
                    community.coverImage != null
                        ? AppCredentials.fixurl(community.coverImage)
                        : 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800',
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
                        color: Theme.of(context).colorScheme.surface,
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
                                  community.title ?? '',
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
                                    extra: community,
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(6.w),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
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

                              Expanded(
                                child: Text(
                                  community.address ?? '',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
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
                                community.formattedDateTime,
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
                                  imageUrls:
                                      community.participants
                                          ?.take(5)
                                          .map((p) => p.avatar)
                                          .whereType<String>()
                                          .toList() ??
                                      [],
                                  extraCount: (community.joinedCount ?? 0) > 5
                                      ? (community.joinedCount ?? 0) - 5
                                      : 0,
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
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

                              // If creator: show QR code button
                              if (isMyCommunity &&
                                  (community.qrCodeImage != null ||
                                      community.qrCodeValue != null))
                                GestureDetector(
                                  onTap: () {
                                    context.pushNamed(
                                      RouteNames.qrVerificationScreen,
                                      extra: {
                                        'qrContext': QRContext.community,
                                        'showQRCodeOnly': true,
                                        'qrCodeUrl': community.qrCodeImage,
                                        'qrCodeValue': community.qrCodeValue,
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
                              if (isMyCommunity &&
                                  (community.qrCodeImage != null ||
                                      community.qrCodeValue != null))
                                SizedBox(width: 12.w),

                              // If not creator: show PopupMenuButton
                              if (!isMyCommunity)
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                  ),

                                  child: PopupMenuButton(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
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
                            community.description ?? '',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                          // Community Rules
                          if ((community.rules ?? '').isNotEmpty) ...[
                            SizedBox(height: 20.h),
                            Text(
                              'Community Rules',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              community.rules!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                          ],
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
                    if (isMyCommunity)
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditCommunityScreen(community: community),
                            ),
                          );
                          if (community.id != null) {
                            _communityController.getCommunityDetails(
                              id: community.id!,
                            );
                            _communityController.getCommunities(tab: 'all');
                          }
                        },
                        child: CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surface,
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
    });
  }
}
