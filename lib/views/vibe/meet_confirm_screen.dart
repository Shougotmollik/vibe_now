import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/core/constant/qrcontext_enum.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/model/incoming_wave.dart';
import 'package:vibe_now/views/common/cancel_button.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';
import 'package:vibe_now/views/qr_verification/qr_verification_screen.dart';

class MeetupConfirmationScreen extends StatefulWidget {
  final IncomingWave wave;
  final String? locationType;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? scheduledAt;

  const MeetupConfirmationScreen({
    super.key,
    required this.wave,
    this.locationType,
    this.latitude,
    this.longitude,
    this.address,
    this.scheduledAt,
  });

  @override
  State<MeetupConfirmationScreen> createState() =>
      _MeetupConfirmationScreenState();
}

class _MeetupConfirmationScreenState extends State<MeetupConfirmationScreen> {
  String? _darkMapStyle;

  // Get positions from the wave data
  LatLng get _senderPos {
    final loc = widget.wave.sender.currentLocation;
    if (loc?.latitude != null && loc?.longitude != null) {
      return LatLng(loc!.latitude!, loc.longitude!);
    }
    return const LatLng(50.937, 6.953);
  }

  LatLng get _meetupPos {
    if (widget.latitude != null && widget.longitude != null) {
      return LatLng(widget.latitude!, widget.longitude!);
    }
    // Use the midpoint between sender and receiver as fallback
    final loc = widget.wave.receiver?.currentLocation;
    if (loc?.latitude != null && loc?.longitude != null) {
      return LatLng(
        (_senderPos.latitude + loc!.latitude!) / 2,
        (_senderPos.longitude + loc.longitude!) / 2,
      );
    }
    return const LatLng(50.9375, 6.9555);
  }

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/map_theme/dark_map.json').then((string) {
      if (mounted) {
        setState(() {
          _darkMapStyle = string;
        });
      }
    });
  }

  String get _formattedScheduledAt {
    final raw = widget.scheduledAt ?? widget.wave.meetup?.scheduledAt;
    if (raw == null || raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('MMM d, yyyy \u00b7 h:mm a').format(dt);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final sender = widget.wave.sender;
    final meetupAddress = widget.address ?? '';
    final distanceText =
        sender.toMeetupDistanceText ?? widget.wave.distanceText ?? '';
    final scheduledAtText = _formattedScheduledAt;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () {
            // Pop all the way back to the wave list
            Navigator.pop(context);
          },
        ),
        title: Text(
          loc.translate('confirmMeetup'),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(40.r),
              child: sender.avatar.isNotEmpty
                  ? Image.network(
                      AppCredentials.fixurl(sender.avatar),
                      width: 80.w,
                      height: 80.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => CircleAvatar(
                        radius: 40.r,
                        child: Icon(Icons.person, size: 32.w),
                      ),
                    )
                  : CircleAvatar(
                      radius: 40.r,
                      child: Icon(Icons.person, size: 32.w),
                    ),
            ),
            SizedBox(height: 16.h),

            Text(
              loc.translate('confirmMeetup'),
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              meetupAddress.isNotEmpty
                  ? loc
                        .translate('seeYouAt')
                        .replaceFirst('{address}', meetupAddress)
                  : loc.translate('seeYouSoon'),
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

            SizedBox(height: 30.h),

            Container(
              height: 200.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
              ),
              clipBehavior: Clip.antiAlias,
              child: GoogleMap(
                style: Theme.of(context).brightness == Brightness.dark
                    ? _darkMapStyle
                    : null,
                initialCameraPosition: CameraPosition(
                  target: _meetupPos,
                  zoom: 14.5,
                ),
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                markers: {
                  Marker(
                    markerId: const MarkerId('meetup'),
                    position: _meetupPos,
                  ),
                  Marker(
                    markerId: const MarkerId('sender'),
                    position: _senderPos,
                  ),
                },
                polylines: {
                  Polyline(
                    polylineId: const PolylineId("route"),
                    points: [_senderPos, _meetupPos],
                    color: AppColors.primary,
                    width: 4,
                    geodesic: true,
                  ),
                },
                onMapCreated: (controller) {
                  final s = _senderPos;
                  final m = _meetupPos;
                  if (s.latitude != m.latitude || s.longitude != m.longitude) {
                    final bounds = LatLngBounds(
                      southwest: LatLng(
                        s.latitude < m.latitude ? s.latitude : m.latitude,
                        s.longitude < m.longitude ? s.longitude : m.longitude,
                      ),
                      northeast: LatLng(
                        s.latitude > m.latitude ? s.latitude : m.latitude,
                        s.longitude > m.longitude ? s.longitude : m.longitude,
                      ),
                    );
                    controller.animateCamera(
                      CameraUpdate.newLatLngBounds(bounds, 60.w),
                    );
                  }
                },
              ),
            ),

            SizedBox(height: 25.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradientRotated.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                children: [
                  if (distanceText.isNotEmpty)
                    _buildInfoRow(Assets.icons.calendarColor, distanceText),
                  if (meetupAddress.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    _buildInfoRow(Assets.icons.locationColor, meetupAddress),
                  ],
                  if (scheduledAtText.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    _buildInfoRow(
                      Assets.icons.colorClock,
                      '${loc.translate('scheduledAt')} $scheduledAtText',
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Show QR code button — uses the dedicated QR screen
            if (widget.wave.vibe?.qrCodeImage != null ||
                widget.wave.qrCodeImage != null ||
                widget.wave.qrCodeValue != null)
              Padding(
                padding: EdgeInsets.only(bottom: 24.h),
                child: Column(
                  children: [
                    // Hint text above the button
                    Text(
                      loc.translate('showQRToVerify'),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    // Gradient button
                    GestureDetector(
                      onTap: () => _showQRFullScreen(context),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradientRotated,
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.qr_code_2_rounded,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              loc.translate('showQRCode'),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: 30.h),

            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  CustomElevatedButton(
                    onTap: () {
                      // Pop all the way back to the wave list
                      Navigator.pop(context);
                    },
                    buttonText: loc.translate('cancelMeetup'),
                    btnColor: Theme.of(context).colorScheme.surfaceVariant,
                    textColor: Theme.of(context).colorScheme.onSurface,
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    loc.translate('greatSeeYouSoon'),
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  void _showQRFullScreen(BuildContext context) {
    final qrUrl = widget.wave.vibe?.qrCodeImage ?? widget.wave.qrCodeImage;
    final qrValue = widget.wave.qrCodeValue;
    if (qrUrl == null && qrValue == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QRVerificationScreen(
          qrContext: QRContext.chats,
          showQRCodeOnly: true,
          qrCodeUrl: qrUrl,
          qrCodeValue: qrValue,
        ),
      ),
    );
  }

  Widget _buildInfoRow(SvgGenImage icon, String label) {
    return Row(
      children: [
        icon.svg(height: 20.h, width: 20.h),
        SizedBox(width: 12.w),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18.sp,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
