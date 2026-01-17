import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/src/presentation/views/community/community_details_screen.dart';
import 'package:vibe_now/src/presentation/views/common/avatar_stack.dart';

enum CommunityStatus {
  request,
  requested,
  interested,
  going,
}

class Community {
  String name;
  String description;
  String location;
  String distance;
  String dateTime;
  String attending;
  String totalAttending;
  String image;
  List<String> avatars;
  int extraCount;
  bool isMyCommunity;
  bool isJoined;
  bool isInterested;
  CommunityStatus? userStatus;

  Community({
    required this.name,
    required this.description,
    required this.location,
    required this.distance,
    required this.dateTime,
    required this.attending,
    required this.totalAttending,
    required this.image,
    required this.avatars,
    required this.extraCount,
    this.isMyCommunity = false,
    this.isJoined = false,
    this.isInterested = false,
    this.userStatus,
  });

  Community copyWith({
    String? name,
    String? description,
    String? location,
    String? distance,
    String? dateTime,
    String? attending,
    String? totalAttending,
    String? image,
    List<String>? avatars,
    int? extraCount,
    bool? isMyCommunity,
    bool? isJoined,
    bool? isInterested,
    CommunityStatus? userStatus,
  }) {
    return Community(
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      distance: distance ?? this.distance,
      dateTime: dateTime ?? this.dateTime,
      attending: attending ?? this.attending,
      totalAttending: totalAttending ?? this.totalAttending,
      image: image ?? this.image,
      avatars: avatars ?? this.avatars,
      extraCount: extraCount ?? this.extraCount,
      isMyCommunity: isMyCommunity ?? this.isMyCommunity,
      isJoined: isJoined ?? this.isJoined,
      isInterested: isInterested ?? this.isInterested,
      userStatus: userStatus ?? this.userStatus,
    );
  }
}

class CommunityCard extends StatefulWidget {
  const CommunityCard({super.key, required this.community});
  final Community community;

  @override
  State<CommunityCard> createState() => _CommunityCardState();
}

class _CommunityCardState extends State<CommunityCard> {
  late CommunityStatus? currentStatus;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.community.userStatus;
  }

  // Check if should show "View Details" button
  bool get shouldShowViewDetails {
    return widget.community.isMyCommunity || 
           widget.community.isJoined || 
           widget.community.isInterested;
  }

  String get buttonText {
    // If it's my community, joined, or interested - show "View Details"
    if (shouldShowViewDetails) {
      return 'View Details';
    }
    
    // Otherwise show status-based text
    if (currentStatus == null) return 'Request';
    switch (currentStatus!) {
      case CommunityStatus.request:
        return 'Request';
      case CommunityStatus.requested:
        return 'Requested';
      case CommunityStatus.interested:
        return 'Interested';
      case CommunityStatus.going:
        return 'Going';
    }
  }

  bool get isButtonActive {
    return currentStatus == CommunityStatus.requested;
  }

  void _handleButtonTap() {
    // If should show view details, navigate to details screen
    if (shouldShowViewDetails) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CommunityDetailsScreen()),
      );
      return;
    }

    // Otherwise handle request logic
    if (currentStatus != CommunityStatus.requested) {
      setState(() {
        currentStatus = CommunityStatus.requested;
      });
      AppSnackbar.show(
        message: "Your request to join this community has been sent",
        type: SnackType.success,
      );
    }
  }

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
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.network(
              widget.community.image,
              width: double.infinity,
              height: 160.h,
              fit: BoxFit.cover,
            ),
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
              onTap: _handleButtonTap,
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
                    onTap: _handleButtonTap,
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade300),
                        gradient: isButtonActive
                            ? null
                            : AppColors.primaryGradient,
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
                      ),
              ],
            ),
        ],
      ),
    );
  }
}