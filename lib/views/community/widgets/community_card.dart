import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vibe_now/controller/community_controller.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/community.dart';
import 'package:vibe_now/services/local_storage.dart';
import 'package:vibe_now/views/common/avatar_stack.dart';

class CommunityCard extends StatefulWidget {
  const CommunityCard({
    super.key,
    required this.community,
    this.isLoading = false,
  });

  @override
  State<CommunityCard> createState() => _CommunityCardState();

  final Community community;
  final bool isLoading;
}

class _CommunityCardState extends State<CommunityCard> {
  static const String hourglass = "assets/icons/hourglass-end.svg";
  static const String wishlist = "assets/icons/wishlist-star.svg";
  static const String wishlistFilled = "assets/icons/wishlist-star-fill.svg";
  static const String private = "assets/icons/private.svg";

  final CommunityController _communityController =
      Get.find<CommunityController>();

  String? _currentUserId;
  bool _isLoadingJoin = false;
  bool _isLoadingInterest = false;
  bool _localIsJoined = false;
  bool _localIsInterested = false;

  @override
  void initState() {
    super.initState();
    _localIsJoined = widget.community.isJoined ?? false;
    _localIsInterested = widget.community.isInterested ?? false;
    _loadCurrentUserId();
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

  bool get isPrivate => widget.community.isPrivate;
  bool get isJoined => _localIsJoined;
  bool get isInterested => _localIsInterested;

  // Handle join request button tap
  Future<void> _handleJoinTap() async {
    if (widget.community.id == null || _isLoadingJoin) return;

    // Optimistic update
    setState(() => _isLoadingJoin = true);

    final success = await _communityController.communityJoin(
      id: widget.community.id!,
    );

    if (mounted) {
      setState(() => _isLoadingJoin = false);

      if (success) {
        setState(() => _localIsJoined = true);
        AppSnackbar.show(
          message: isPrivate
              ? 'Your request has been sent to the community creator'
              : 'You have joined the community successfully',
          type: SnackType.info,
        );
      } else {
        AppSnackbar.show(
          message: 'Failed to join community',
          type: SnackType.error,
        );
      }
    }
  }

  // Handle interest button tap
  Future<void> _handleInterestTap() async {
    if (widget.community.id == null || _isLoadingInterest) return;

    // Optimistic update
    final wasInterested = _localIsInterested;
    setState(() => _isLoadingInterest = true);

    final success = await _communityController.communityInterest(
      id: widget.community.id!,
    );

    if (mounted) {
      setState(() => _isLoadingInterest = false);

      if (success) {
        setState(() => _localIsInterested = !wasInterested);

        AppSnackbar.show(
          message: wasInterested
              ? 'Removed from interested'
              : 'Added to interested',
          type: SnackType.info,
        );
      } else {
        AppSnackbar.show(
          message: 'Failed to update interest',
          type: SnackType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: widget.isLoading ? _buildShimmerContent() : _buildMainContent(),
    );
  }

  Widget _buildShimmerContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image placeholder
          Container(
            height: 160.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          SizedBox(height: 12.h),

          // Title placeholder
          Container(
            height: 16.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 10.h),

          // Description placeholder
          Container(
            height: 14.h,
            width: double.infinity * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 10.h),

          // Location placeholder
          Container(
            height: 12.h,
            width: double.infinity * 0.6,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 10.h),

          // DateTime placeholder
          Container(
            height: 12.h,
            width: double.infinity * 0.4,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 10.h),

          // Attendees placeholder
          Container(
            height: 12.h,
            width: double.infinity * 0.3,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 12.h),

          // Button placeholder
          Container(
            height: 44.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildImageSection(),
        SizedBox(height: 12.h),
        _buildTitle(),
        SizedBox(height: 12.h),
        _buildDescription(),
        SizedBox(height: 12.h),
        _buildLocation(),
        SizedBox(height: 12.h),
        _buildDateTime(),
        SizedBox(height: 12.h),
        _buildAttendees(),
        SizedBox(height: 12.h),
        _buildParticipants(),
        SizedBox(height: 12.h),
        _buildActionButton(),
      ],
    );
  }

  Widget _buildImageSection() {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: widget.community.coverImage != null
              ? Image.network(
                  widget.community.coverImage!.startsWith('http')
                      ? widget.community.coverImage!
                      : '${AppCredentials.domain}${widget.community.coverImage}',
                  width: double.infinity,
                  height: 160.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildImagePlaceholder(),
                )
              : _buildImagePlaceholder(),
        ),

        // Interest/Favorite button
        GestureDetector(
          onTap: _isLoadingInterest ? null : _handleInterestTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isInterested
                    ? AppColors.primary
                    : AppColors.primary.withAlpha(200),
              ),
              padding: const EdgeInsets.all(10),
              child: _isLoadingInterest
                  ? SizedBox(
                      height: 18.h,
                      width: 18.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : SvgPicture.asset(
                      isInterested ? wishlistFilled : wishlist,
                      height: 18.h,
                      width: 18.w,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
            ),
          ),
        ),

        // Private/Public badge
        Positioned(
          top: 10.h,
          left: 12.w,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(200),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 4.w,
              children: [
                SvgPicture.asset(
                  private,
                  height: 14.h,
                  width: 14.w,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                Text(
                  isPrivate ? "Private" : "Public",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 160.h,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.image,
        size: 48.h,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.community.title ?? '',
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.community.description ?? '',
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildLocation() {
    return Row(
      children: [
        Assets.icons.location.svg(
          width: 16.w,
          height: 16.h,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            widget.community.address ?? '',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTime() {
    final dateTime = widget.community.formattedDateTime;
    if (dateTime.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        Assets.icons.calendarColor.svg(
          width: 16.w,
          height: 16.h,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          dateTime,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendees() {
    return Row(
      children: [
        Assets.icons.community.svg(
          width: 16.w,
          height: 16.h,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          "${widget.community.joinedCount ?? 0}/${widget.community.maxAttendees ?? 0} attending",
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildParticipants() {
    final participants = widget.community.participants ?? [];
    if (participants.isEmpty) return const SizedBox.shrink();

    final avatars = participants
        .take(3)
        .map((p) => AppCredentials.fixurl(p.avatar))
        .whereType<String>()
        .toList();

    if (avatars.isEmpty) return const SizedBox.shrink();

    return AvatarStack(
      imageUrls: avatars,
      extraCount: participants.length > 3 ? participants.length - 3 : 0,
    );
  }

  Widget _buildActionButton() {
    // My community - show View Details
    if (isMyCommunity) {
      return PrimaryButton.text(
        radius: 12.r,
        onPressed: () {
          context.pushNamed(
            RouteNames.communityDetailsScreen,
            extra: widget.community,
          );
        },
        text: "View Details",
      );
    }

    // Already joined - show View Details
    if (isJoined) {
      return PrimaryButton.text(
        radius: 12.r,
        onPressed: () {
          context.pushNamed(
            RouteNames.communityDetailsScreen,
            extra: widget.community,
          );
        },
        text: "View Details",
      );
    }

    // Not joined - show Join button
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _isLoadingJoin ? null : _handleJoinTap,
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Theme.of(context).dividerColor),
                gradient: AppColors.primaryGradient,
              ),
              child: Center(
                child: _isLoadingJoin
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 8.w,
                        children: [
                          if (isPrivate)
                            SvgPicture.asset(
                              hourglass,
                              height: 18.h,
                              width: 18.w,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          Text(
                            isPrivate ? "Request" : "Join",
                            style: TextStyle(
                              color: Colors.white,
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
      ],
    );
  }
}
