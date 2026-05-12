import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/event.dart';
import 'package:vibe_now/services/local_storage.dart';
import 'package:vibe_now/views/event/event_details_screen.dart';
import 'package:vibe_now/views/event/event_request_screen.dart';

class EventCard extends StatefulWidget {
  const EventCard({super.key, required this.event});

  @override
  State<EventCard> createState() => _EventCardState();

  final Event event;
}

class _EventCardState extends State<EventCard> {
  static const String hourglass = "assets/icons/hourglass-end.svg";
  static const String wishlist = "assets/icons/wishlist-star.svg";
  static const String wishlistFilled = "assets/icons/wishlist-star-fill.svg";
  static const String private = "assets/icons/private.svg";
  static const String public = "assets/icons/public.svg";

  bool _isLoadingInterest = false;
  bool _isLoadingJoin = false;
  bool _isLoadingRequest = false;
  String? _currentUserId;
  bool _isLoadingUserId = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    final userId = await LocalStorage.user_id.get();
    if (mounted) {
      setState(() {
        _currentUserId = userId;
        _isLoadingUserId = false;
      });
    }
  }

  bool get isMyEvent =>
      widget.event.createdBy?.id != null &&
      _currentUserId != null &&
      widget.event.createdBy!.id == _currentUserId;

  // TODO: Implement API call for toggle interest
  Future<void> _toggleInterest() async {
    if (_isLoadingInterest || widget.event.isJoined == true) return;

    setState(() => _isLoadingInterest = true);

    // TODO: Call API to toggle interest
    // final response = await CustomHttp.post(
    //   endpoint: ApiConstant.toggleInterest(widget.event.id!),
    //   need_auth: true,
    // );
    // if (response.ok) {
    //   // Update local state based on API response
    // }

    // Simulating toggle for now
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() => _isLoadingInterest = false);
  }

  // TODO: Implement API call for join event (public)
  Future<void> _joinEvent() async {
    if (_isLoadingJoin) return;

    setState(() => _isLoadingJoin = true);

    // TODO: Call API to join event
    // final response = await CustomHttp.post(
    //   endpoint: ApiConstant.joinEvent(widget.event.id!),
    //   need_auth: true,
    // );
    // if (response.ok) {
    //   // Show success dialog, update local state
    // }

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() => _isLoadingJoin = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.h),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withAlpha(15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  AppCredentials.fixurl(widget.event.coverImage),
                  height: 200.h,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),

              // Interest Button - Original Position
              GestureDetector(
                onTap: _isLoadingInterest || widget.event.isJoined == true
                    ? null
                    : _toggleInterest,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isLoadingInterest || widget.event.isJoined == true
                          ? Colors.grey.shade400
                          : AppColors.primary.withAlpha(200),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: _isLoadingInterest
                        ? SizedBox(
                            height: 18.h,
                            width: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : SvgPicture.asset(
                            widget.event.isInterested != null &&
                                    widget.event.isInterested == true
                                ? wishlistFilled
                                : wishlist,
                            height: 18.h,
                            width: 18.w,
                            color: AppColors.background,
                          ),
                  ),
                ),
              ),

              // Access Level Badge - Original Position
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
                        widget.event.accessLevel == "public" ? public : private,
                        height: 14.h,
                        width: 14.w,
                        color: AppColors.background,
                      ),
                      Text(
                        widget.event.accessLevel == "public"
                            ? "Public"
                            : "Private",
                        style: TextStyle(
                          color: AppColors.background,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            widget.event.title ?? '',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Assets.icons.location.svg(
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onSurface.withAlpha(180),
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  widget.event.address ?? '',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(180),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Assets.icons.calender3.svg(
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onSurface.withAlpha(180),
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                '${widget.event.eventTime}, ${widget.event.eventDate}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Text(
                "${widget.event.interestedCount} Interested • ${widget.event.joinedCount} Going",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Assets.icons.users.svg(
                colorFilter: ColorFilter.mode(
                  Theme.of(context).colorScheme.onSurface.withAlpha(180),
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                '${widget.event.joinedCount}/${widget.event.maxAttendees} attending',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          // Original Button Section with functionality
          // Show "View Details" if: user joined OR user is the event creator
          _isLoadingUserId
              ? _buildLoadingButton()
              : ((widget.event.isJoined != null && widget.event.isJoined == true) || isMyEvent)
                  ? _buildViewDetailsButton()
                  : _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildLoadingButton() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: Center(
        child: SizedBox(
          height: 20.h,
          width: 20.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildViewDetailsButton() {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          RouteNames.eventDetailsScreen,
          extra: widget.event.id,
        );
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          gradient: AppColors.primaryGradientRotated,
        ),
        child: Center(
          child: Text(
            "View Details",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    final isPublic = widget.event.accessLevel == 'public';
    final isRequested = widget.event.isRequested == true;
    final isLoading = isPublic ? _isLoadingJoin : _isLoadingRequest;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: isLoading
                ? null
                : () {
                    if (isPublic) {
                      // Public event - Join
                      _joinEvent();
                    } else {
                      // Private event - Navigate to request screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EventRequestScreen(event: widget.event),
                        ),
                      );
                    }
                  },
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                gradient: isLoading
                    ? null
                    : AppColors.primaryGradient,
                color: isLoading ? Colors.grey.shade400 : null,
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        height: 16.h,
                        width: 16.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 8.w,
                        children: [
                          isPublic
                              ? const SizedBox()
                              : SvgPicture.asset(
                                  isRequested ? hourglass : "",
                                  height: isRequested ? 16.h : 0.h,
                                  width: isRequested ? 16.w : 0.w,
                                  color: AppColors.background,
                                ),
                          Text(
                            isPublic
                                ? "Join"
                                : (isRequested ? "Requested" : "Request"),
                            style: TextStyle(
                              color: Colors.grey.shade100,
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