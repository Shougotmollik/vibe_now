import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vibe_now/controller/notification_controller.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/model/community_member.dart';

class CommunityAwaitingDetailsScreen extends StatefulWidget {
  final int communityId;

  const CommunityAwaitingDetailsScreen({super.key, required this.communityId});

  @override
  State<CommunityAwaitingDetailsScreen> createState() =>
      _CommunityAwaitingDetailsScreenState();
}

class _CommunityAwaitingDetailsScreenState
    extends State<CommunityAwaitingDetailsScreen> {
  final NotificationController _controller = Get.find<NotificationController>();
  CommunityMember? _member;
  String? _error;
  String? _mapStyle;

  @override
  void initState() {
    super.initState();
    _fetchRequestStatus();
    rootBundle.loadString('assets/map_theme/dark_map.json').then((string) {
      if (mounted) setState(() => _mapStyle = string);
    });
  }

  Future<void> _fetchRequestStatus() async {
    setState(() => _error = null);
    final member = await _controller.fetchCommunityRequestStatus(
      communityId: widget.communityId,
    );
    if (!mounted) return;
    if (member != null) {
      setState(() => _member = member);
    } else {
      setState(() => _error = _controller.communityRequestError.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Obx(() {
          if (_controller.isCommunityRequestLoading.value && _member == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_error != null) return _buildErrorView();
          if (_member != null) return _buildContent();
          return const Center(child: CircularProgressIndicator());
        }),
      ),
    );
  }

  Widget _buildErrorView() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.icons.stashQuestion.svg(
              width: 64.w,
              height: 64.h,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 16.h),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: _fetchRequestStatus,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Text(
                  AppLocalizations.of(context).translate('retry'),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final member = _member!;
    final user = member.user;
    final theme = Theme.of(context);

    final hasLocation =
        member.communityLatitude != null && member.communityLongitude != null;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(theme),
          SizedBox(height: 4.h),
          _buildProfileCard(theme, member, user),
          SizedBox(height: 12.h),
          _buildCommunityCard(theme, member),
          if (member.scheduledAt != null) ...[
            SizedBox(height: 12.h),
            _buildScheduledCard(theme, member),
          ],
          SizedBox(height: 12.h),
          _buildRequestedCard(theme, member),
          SizedBox(height: 12.h),
          _buildLocationCard(theme, member, hasLocation),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 16.w,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            AppLocalizations.of(context).translate('awaiting'),
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(
    ThemeData theme,
    CommunityMember member,
    MemberUser user,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.08),
              AppColors.primaryVariant.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.12),
            width: 1.w,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 88.w,
              height: 88.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.all(2.5.w),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface,
                ),
                padding: EdgeInsets.all(2.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(44.r),
                  child: user.avatar.isNotEmpty
                      ? Image.network(
                          AppCredentials.fixurl(user.avatar),
                          width: 88.w,
                          height: 88.w,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _defaultAvatar(),
                        )
                      : _defaultAvatar(),
                ),
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              user.fullName,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              user.email,
              style: TextStyle(
                fontSize: 13.sp,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBadge(
                  label: member.status.toUpperCase(),
                  gradient: AppColors.primaryGradient,
                ),
                SizedBox(width: 8.w),
                _buildBadge(
                  label: member.scheduleStatus.toUpperCase(),
                  gradient: const LinearGradient(
                    colors: [Color(0xff99e2f1), Color(0xffaaccff)],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityCard(ThemeData theme, CommunityMember member) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Assets.icons.communityColor.svg(
                width: 20.w,
                height: 20.h,
                colorFilter: ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).translate('community'),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    member.communityTitle ?? 'Unknown Community',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if ((member.communityDescription ?? '').isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Text(
                      member.communityDescription!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledCard(ThemeData theme, CommunityMember member) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Assets.icons.calender3.svg(
                width: 20.w,
                height: 20.h,
                colorFilter: ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).translate('scheduledMeetup'),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    member.scheduledAt!,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestedCard(ThemeData theme, CommunityMember member) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Assets.icons.timeCircle.svg(
                width: 20.w,
                height: 20.h,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).translate('requested'),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    member.requestedAt != null
                        ? timeago.format(
                            DateTime.parse(member.requestedAt!),
                          )
                        : '',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(
    ThemeData theme,
    CommunityMember member,
    bool hasLocation,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Assets.icons.location.svg(
                      width: 20.w,
                      height: 20.h,
                      colorFilter: ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).translate('location'),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if ((member.communityAddress ?? '').isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Text(
                              member.communityAddress!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (hasLocation)
              SizedBox(
                height: 200.h,
                child: GoogleMap(
                  style: Theme.of(context).brightness == Brightness.dark
                      ? _mapStyle
                      : null,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      member.communityLatitude!,
                      member.communityLongitude!,
                    ),
                    zoom: 14.0,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('community'),
                      position: LatLng(
                        member.communityLatitude!,
                        member.communityLongitude!,
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueViolet,
                      ),
                      infoWindow: InfoWindow(
                        title: member.communityTitle ?? 'Community',
                        snippet: member.communityAddress,
                      ),
                    ),
                  },
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  compassEnabled: false,
                  mapType: MapType.normal,
                ),
              ),
            if (!hasLocation)
              Container(
                height: 120.h,
                color: theme.colorScheme.surfaceContainerHighest,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Assets.icons.locationIc.svg(
                        width: 32.w,
                        height: 32.h,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        AppLocalizations.of(context).translate('locationNotAvailable'),
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _defaultAvatar() {
    final theme = Theme.of(context);
    return Container(
      width: 88.w,
      height: 88.w,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: 44.w,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildBadge({required String label, required Gradient gradient}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
