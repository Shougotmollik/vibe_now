import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart' hide Marker;
import 'package:vibe_now/controller/event_controller.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/event/event_check_out_screen.dart';

class EventCheckinScreen extends StatefulWidget {
  const EventCheckinScreen({super.key, required this.qrCode});

  final String qrCode;

  @override
  State<EventCheckinScreen> createState() => _EventCheckinScreenState();
}

class _EventCheckinScreenState extends State<EventCheckinScreen> {
  final EventController eventController = Get.find<EventController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      eventController.qrcodeEventJoin(qrCode: widget.qrCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loc = AppLocalizations.of(context);
      final event = eventController.qrEventDetails.value;

      if (event == null) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                SizedBox(height: 16.h),
                Text(
                  loc.translate('loadingEvent'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      final lat = event.latitude ?? 0.0;
      final lng = event.longitude ?? 0.0;
      final eventLocation = LatLng(lat, lng);
      final hasLocation = lat != 0.0 && lng != 0.0;

      return Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 20.h,
                    ),
                    child: CustomAppBar(
                      title: loc.translate('eventZone'),
                      canBack: true,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: InnerShadowBox(
                      borderRadius: BorderRadius.circular(24.r),
                      shadowColor: const Color(
                        0xFFC06CFF,
                      ).withValues(alpha: 0.50),
                      blurRadius: 40,
                      child: Container(
                        height: 350.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.r),
                          border: Border.all(
                            color: const Color(
                              0xFFE0AAFF,
                            ).withValues(alpha: 0.5),
                            width: 4.w,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            hasLocation
                                ? GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: eventLocation,
                                      zoom: 18.0,
                                    ),
                                    markers: {
                                      Marker(
                                        markerId: const MarkerId('event'),
                                        position: eventLocation,
                                        infoWindow: InfoWindow(
                                          title: event.title ?? loc.translate('eventOption'),
                                          snippet: event.address,
                                        ),
                                      ),
                                    },
                                    zoomControlsEnabled: false,
                                    myLocationButtonEnabled: false,
                                    compassEnabled: false,
                                    mapType: MapType.normal,
                                  )
                                : Container(
                                    color: Colors.grey.shade200,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.location_off,
                                            size: 48.sp,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(height: 8.h),
                                          Text(
                                            loc.translate('locationNotAvailable'),
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      const Color(
                                        0xFFC06CFF,
                                      ).withValues(alpha: 0.2),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            IgnorePointer(
                              child: Container(
                                width: 180.w,
                                height: 180.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(
                                    0xFFC06CFF,
                                  ).withValues(alpha: 0.2),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    width: 1.5.w,
                                  ),
                                ),
                              ),
                            ),
                            if (hasLocation)
                              Assets.icons.checkinpin.svg(
                                width: 65.w,
                                height: 65.h,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 28.h),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 4.w,
                      children: [
                        Expanded(
                          child: Text(
                            event.title ?? loc.translate('eventZone'),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Image.asset(
                          "assets/icons/checkcongrass.png",
                          width: 25.w,
                          height: 25.w,
                          fit: BoxFit.cover,
                        ),
                      ],
                    ),
                  ),

                  if (event.address != null && event.address!.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: Text(
                        event.address!,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],

                  // if (hasLocation) ...[
                  //   SizedBox(height: 4.h),
                  //   Text(
                  //     "Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}",
                  //     style: TextStyle(
                  //       color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                  //       fontSize: 11.sp,
                  //       fontWeight: FontWeight.w400,
                  //     ),
                  //   ),
                  // ],
                  SizedBox(height: 16.h),
                  Text(
                    loc.translate('youAreInsideEvent'),
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  // Text(
                  //   "Only Vibes from this event are visible",
                  //   style: TextStyle(
                  //     color: Theme.of(
                  //       context,
                  //     ).colorScheme.onSurface.withValues(alpha: 0.4),
                  //     fontSize: 14.sp,
                  //     fontWeight: FontWeight.w400,
                  //   ),
                  // ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 4.w,
                    children: [
                      Text(
                        loc.translate('enjoyTheMoment'),
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Icon(
                        Icons.favorite,
                        color: const Color(0xFFC470F5),
                        size: 20.sp,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: PrimaryButton.text(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const EventCheckOutScreen(),
                          ),
                        );
                      },
                      text: loc.translate('leaveEventZone'),
                      gradient: AppColors.primaryGradientRotated,
                    ),
                  ),
                ],
              ),
            ),
            IgnorePointer(
              child: Lottie.asset(
                'assets/lottie/Confetti.json',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.cover,
                repeat: false,
              ),
            ),
          ],
        ),
      );
    });
  }
}

// --- Supporting Widgets ---

class InnerShadowBox extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final Color shadowColor;
  final double blurRadius;

  const InnerShadowBox({
    super.key,
    required this.child,
    required this.borderRadius,
    required this.shadowColor,
    required this.blurRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        children: [
          child,
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _InnerShadowPainter(
                  borderRadius: borderRadius,
                  shadowColor: shadowColor,
                  blurRadius: blurRadius,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InnerShadowPainter extends CustomPainter {
  final BorderRadius borderRadius;
  final Color shadowColor;
  final double blurRadius;

  _InnerShadowPainter({
    required this.borderRadius,
    required this.shadowColor,
    required this.blurRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect);

    canvas.saveLayer(rect, Paint());

    final fillPaint = Paint()..color = shadowColor;
    canvas.drawRRect(rrect, fillPaint);

    final cutPaint = Paint()
      ..color = Colors.black
      ..blendMode = BlendMode.dstOut
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius / 3);

    final innerRRect = borderRadius.toRRect(rect.deflate(blurRadius / 4));
    canvas.drawRRect(innerRRect, cutPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_InnerShadowPainter oldDelegate) =>
      oldDelegate.shadowColor != shadowColor ||
      oldDelegate.blurRadius != blurRadius ||
      oldDelegate.borderRadius != borderRadius;
}
