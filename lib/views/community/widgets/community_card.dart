import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/community.dart';
import 'package:vibe_now/views/community/community_details_screen.dart';
import 'package:vibe_now/views/common/avatar_stack.dart';
import 'package:vibe_now/views/community/widgets/community_animated_dialog.dart';

class CommunityCard extends StatefulWidget {
  const CommunityCard({super.key, required this.community});

  @override
  State<CommunityCard> createState() => _CommunityCardState();

  final Community community;
}

class _CommunityCardState extends State<CommunityCard> {
  late CommunityStatus? currentStatus;

  bool get isPublic =>
      widget.community.accessType == CommunityAccessType.public;

  bool get isPrivate =>
      widget.community.accessType == CommunityAccessType.private;

  bool get isGoing => currentStatus == CommunityStatus.going;
  bool get isRequested => currentStatus == CommunityStatus.requested;
  bool get isActive => isGoing || isRequested;

  static const String hourglass = "assets/icons/hourglass-end.svg";
  static const String wishlist = "assets/icons/wishlist-star.svg";

  String get buttonText {
    if (shouldShowViewDetails) return 'View Details';

    if (isPublic) {
      return isGoing ? 'Going' : 'Join';
    }

    // Private
    return isRequested ? 'Requested' : 'Request';
  }

  @override
  void initState() {
    super.initState();
    currentStatus = widget.community.userStatus;
  }

  // Check if should show "View Details" button
  // bool get shouldShowViewDetails {
  //   return widget.community.isMyCommunity ||
  //       widget.community.isJoined ||
  //       widget.community.isInterested;
  // }
  bool get shouldShowViewDetails {
    // My own community → always view details
    if (widget.community.isMyCommunity) return true;

    // Public: joined
    if (isPublic && currentStatus == CommunityStatus.going) {
      return true;
    }

    // Private: only after approved (going)
    if (isPrivate && currentStatus == CommunityStatus.going) {
      return true;
    }

    return false;
  }

  // String get buttonText {
  //   // If it's my community, joined, or interested - show "View Details"
  //   if (shouldShowViewDetails) {
  //     return 'View Details';
  //   }

  //   // Otherwise show status-based text
  //   if (currentStatus == null) return 'Request';
  //   switch (currentStatus!) {
  //     case CommunityStatus.requested:
  //       return 'Interested';
  //     case CommunityStatus.interested:
  //       return 'Interested';
  //     case CommunityStatus.going:
  //       return 'Going';
  //   }
  // }

  // bool get isButtonActive {
  //   return currentStatus == CommunityStatus.requested;
  // }

  // void _handleButtonTap() {
  //   // If should show view details, navigate to details screen
  //   if (shouldShowViewDetails) {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => CommunityDetailsScreen()),
  //     );
  //     return;
  //   }

  //   // Otherwise handle request logic
  //   if (currentStatus != CommunityStatus.requested) {
  //     setState(() {
  //       currentStatus = CommunityStatus.requested;
  //     });
  //     AppSnackbar.show(
  //       message: "Your request to join this community has been sent",
  //       type: SnackType.success,
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Color(0xffBDBDBD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  widget.community.image,
                  width: double.infinity,
                  height: 160.h,
                  fit: BoxFit.cover,
                ),
              ),

              isPrivate
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withAlpha(200),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: SvgPicture.asset(
                          isActive ? wishlist : wishlist,
                          height: 18.h,
                          width: 18.w,
                          color: isActive
                              ? AppColors.background
                              : AppColors.background.withAlpha(100),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withAlpha(200),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: SvgPicture.asset(
                          wishlist,
                          height: 18.h,
                          width: 18.w,
                          color: AppColors.background,
                        ),
                      ),
                    ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            widget.community.name,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Color(0xff303030),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            widget.community.description,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Color(0xff707070),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Assets.icons.location.svg(
                width: 16.w,
                height: 16.h,
                color: Color(0xff707070),
              ),
              SizedBox(width: 4.w),
              Text(
                "${widget.community.location} • ${widget.community.distance}",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff707070),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Assets.icons.calendarColor.svg(
                width: 16.w,
                height: 16.h,
                color: Color(0xff707070),
              ),
              SizedBox(width: 4.w),
              Text(
                widget.community.dateTime,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff707070),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Assets.icons.community.svg(
                width: 16.w,
                height: 16.h,
                color: Color(0xff707070),
              ),
              SizedBox(width: 4.w),
              Text(
                "${widget.community.attending}/${widget.community.totalAttending} attending",
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff707070),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          AvatarStack(
            imageUrls: widget.community.avatars,
            extraCount: widget.community.extraCount,
          ),
          SizedBox(height: 12.h),
          // If should show "View Details", show simple button
          if (shouldShowViewDetails)
            GestureDetector(
              onTap: () {
                context.pushNamed(
                  RouteNames.communityDetailsScreen,
                  extra: widget.community,
                );
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  gradient: AppColors.primaryGradient,
                ),
                child: Center(
                  child: Text(
                    'View Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            )
          else
            // Otherwise show request button with dropdown
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // setState(() {
                      //   // currentStatus = CommunityStatus.requested;
                      //   // AppSnackbar.show(
                      //   //   message:
                      //   //       "Send a request to the community creator to joint the community",
                      //   //   type: SnackType.success,
                      //   // );

                      //   if (currentStatus == CommunityStatus.requested) {
                      //     currentStatus = CommunityStatus.interested;
                      //     showDialog(
                      //       context: context,
                      //       barrierDismissible: true,
                      //       builder: (context) {
                      //         return Center(
                      //           child: Dialog(
                      //             shape: RoundedRectangleBorder(
                      //               borderRadius: BorderRadius.circular(20.r),
                      //             ),
                      //             elevation: 0,
                      //             backgroundColor: Colors.transparent,
                      //             child: CommunityAnimatedDialog(
                      //               content:
                      //                   'Revoke your request to join the community?',
                      //             ),
                      //           ),
                      //         );
                      //       },
                      //     );
                      //   } else {
                      //     currentStatus = CommunityStatus.requested;
                      //     showDialog(
                      //       context: context,
                      //       barrierDismissible: true,
                      //       builder: (context) {
                      //         return Center(
                      //           child: Dialog(
                      //             shape: RoundedRectangleBorder(
                      //               borderRadius: BorderRadius.circular(20.r),
                      //             ),
                      //             elevation: 0,
                      //             backgroundColor: Colors.transparent,
                      //             child: CommunityAnimatedDialog(
                      //               content:
                      //                   'Send a request to the community creator to joint the community',
                      //             ),
                      //           ),
                      //         );
                      //       },
                      //     );
                      //   }
                      // });

                      // Public Community flow
                      if (isPrivate && isRequested) return;

                      if (isPublic && !isGoing) {
                        setState(() {
                          currentStatus = CommunityStatus.going;
                        });
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            backgroundColor: Colors.transparent,
                            child: CommunityAnimatedDialog(
                              content:
                                  'You have joined the community successfully.',
                            ),
                          ),
                        );
                        return;
                      }

                      // Private Community flow
                      if (isPrivate && !isRequested) {
                        setState(() {
                          currentStatus = CommunityStatus.requested;
                        });
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            backgroundColor: Colors.transparent,
                            child: CommunityAnimatedDialog(
                              content:
                                  'Send a request to the community creator to join the community',
                            ),
                          ),
                        );
                        return;
                      }
                    },

                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade300),
                        gradient: CommunityStatus.interested != currentStatus
                            ? null
                            : AppColors.primaryGradient,
                        color: CommunityStatus.interested != currentStatus
                            ? Color(0xffC4A8FF)
                            : null,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 8.w,
                          children: [
                            isPrivate
                                ? SvgPicture.asset(
                                    isActive ? hourglass : "",
                                    height: isActive ? 18.h : 0,
                                    width: isActive ? 18.w : 0,
                                    color: AppColors.background,
                                  )
                                : SizedBox(),
                            // : SvgPicture.asset(
                            //     wishlist,
                            //     height: 18.h,
                            //     width: 18.w,
                            //     color: AppColors.background,
                            //   ),
                            Text(
                              buttonText,
                              style: TextStyle(
                                color:
                                    CommunityStatus.interested != currentStatus
                                    ? Colors.white
                                    : Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                // widget.community.isMyCommunity
                //     ? SizedBox.shrink()
                //     : _buildPopUpMenuSection(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPopUpMenuSection() {
    return Container(
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
                  currentStatus = CommunityStatus.interested;
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
                  currentStatus = CommunityStatus.going;
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
    );
  }
}
