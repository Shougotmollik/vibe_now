import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart'; // Ensure lottie is in pubspec.yaml
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/event/event_check_out_screen.dart';

class EventCheckinScreen extends StatefulWidget {
  const EventCheckinScreen({super.key});

  @override
  State<EventCheckinScreen> createState() => _EventCheckinScreenState();
}

class _EventCheckinScreenState extends State<EventCheckinScreen> {
  static const LatLng _eventLocation = LatLng(
    50.93747315706174,
    6.953134027839385,
  );

  @override
  Widget build(BuildContext context) {
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
                  child: const CustomAppBar(title: "Event Zone", canBack: true),
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
                          color: const Color(0xFFE0AAFF).withValues(alpha: 0.5),
                          width: 4.w,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          GoogleMap(
                            initialCameraPosition: const CameraPosition(
                              target: _eventLocation,
                              zoom: 18.0,
                            ),
                            zoomControlsEnabled: false,
                            myLocationButtonEnabled: false,
                            compassEnabled: false,
                            mapType: MapType.normal,
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
                          Assets.icons.checkinpin.svg(
                            width: 65.w,
                            height: 65.h,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 50.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 4.w,
                  children: [
                    Text(
                      "Welcome to Event Zone",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w400,
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
                Text(
                  "You are Inside the event",
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 20),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  "Only Vibes from this event are visible",
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 20),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 4.w,
                  children: [
                    Text(
                      "Enjoy the moment!",
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 20),
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    // Fixed: Removed underscore in hex color
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
                    text: "Leave Event Zone",
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
