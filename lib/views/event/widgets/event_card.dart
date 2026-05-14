import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/controller/event_controller.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/event.dart';
import 'package:vibe_now/services/local_storage.dart';
import 'package:vibe_now/views/event/event_details_screen.dart';
import 'package:vibe_now/views/event/event_request_screen.dart';

class EventCard extends StatefulWidget {
  const EventCard({super.key, required this.event, this.isLoading = false});

  @override
  State<EventCard> createState() => _EventCardState();

  final Event event;
  final bool isLoading;
}

class _EventCardState extends State<EventCard> {
  static const String hourglass = "assets/icons/hourglass-end.svg";
  static const String wishlist = "assets/icons/wishlist-star.svg";
  static const String wishlistFilled = "assets/icons/wishlist-star-fill.svg";
  static const String private = "assets/icons/private.svg";
  static const String public = "assets/icons/public.svg";

  final EventController _eventController = Get.find<EventController>();
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

  // Toggle interest
  Future<void> _toggleInterest() async {
    if (widget.event.id == null) return;

    // Immediately update UI (optimistic update) - no loading spinner
    widget.event.isInterested = !(widget.event.isInterested ?? false);
    setState(() {});

    // Make API call in background
    await _eventController.eventInterest(id: widget.event.id!);
  }

  // Join event (public event)
  Future<void> _joinEvent() async {
    if (_isLoadingJoin || widget.event.id == null) return;

    setState(() => _isLoadingJoin = true);

    final success = await _eventController.eventJoin(id: widget.event.id!);

    if (success) {
      widget.event.isJoined = true;
    }

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
                child:
                    widget.event.coverImage != null &&
                        widget.event.coverImage!.isNotEmpty
                    ? Image.network(
                        AppCredentials.fixurl(widget.event.coverImage),
                        height: 200.h,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholderImage(),
                      )
                    : _buildPlaceholderImage(),
              ),

              // Interest Button - Original Position
              GestureDetector(
                onTap: _toggleInterest,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withAlpha(200),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: SvgPicture.asset(
                      widget.event.isInterested != null &&
                              widget.event.isInterested == true
                          ? wishlistFilled
                          : wishlist,
                      height: 18.h,
                      width: 18.w,
                      colorFilter: const ColorFilter.mode(
                        AppColors.background,
                        BlendMode.srcIn,
                      ),
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
                        colorFilter: const ColorFilter.mode(
                          AppColors.background,
                          BlendMode.srcIn,
                        ),
                      ),
                      Text(
                        widget.event.accessLevel == "public"
                            ? "Public"
                            : (widget.event.accessLevel == "private"
                                  ? "Private"
                                  : "Public"),
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
                '${widget.event.eventTime ?? ''}, ${widget.event.eventDate ?? ''}',
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
                "${widget.event.interestedCount ?? 0} Interested • ${widget.event.joinedCount ?? 0} Going",
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
                '${widget.event.joinedCount ?? 0}/${widget.event.maxAttendees ?? 0} attending',
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
              : ((widget.event.isJoined != null &&
                        widget.event.isJoined == true) ||
                    isMyEvent)
              ? _buildViewDetailsButton()
              : _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 200.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: Icon(Icons.image, size: 50.sp, color: Colors.grey.shade500),
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
    final isJoined = widget.event.isJoined == true;
    final isRequested = widget.event.isRequested == true;
    final hasActionCompleted = isJoined || isRequested;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: hasActionCompleted
                ? null
                : () async {
                    final bool isPrivateEvent = !isPublic;

                    // Immediately update UI (optimistic update)
                    if (isPublic) {
                      widget.event.isJoined = true;
                    } else {
                      widget.event.isRequested = true;
                    }
                    setState(() {});

                    // For private events, navigate immediately while API runs in background
                    if (isPrivateEvent && context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EventRequestScreen(event: widget.event),
                        ),
                      );
                    }

                    // Make API call in background
                    if (widget.event.id != null) {
                      await _eventController.eventJoin(id: widget.event.id!);
                    }
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                gradient: hasActionCompleted
                    ? AppColors.primaryGradient.withOpacity(0.5)
                    : AppColors.primaryGradient,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 8.w,
                children: [
                  isPublic
                      ? const SizedBox()
                      : (isRequested
                            ? SvgPicture.asset(
                                hourglass,
                                height: 16.h,
                                width: 16.w,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.background,
                                  BlendMode.srcIn,
                                ),
                              )
                            : const SizedBox()),
                  Text(
                    isPublic
                        ? (isJoined ? "Joined" : "Join")
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
      ],
    );
  }
}
