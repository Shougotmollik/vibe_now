import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:vibe_now/controller/onboarding_controller.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/tokens.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/views/auth/widgets/step_page.dart';
import 'package:vibe_now/views/auth/widgets/step_title.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';
import 'package:vibe_now/views/home/home_screen.dart';

class StepLocationScreen extends StatefulWidget {
  final int step;
  const StepLocationScreen({this.step = 1, super.key});

  @override
  State<StepLocationScreen> createState() => _StepLocationScreenState();
}

class _StepLocationScreenState extends State<StepLocationScreen> {
  final _isLoading = false.obs;
  final OnBoardingController controller = Get.find<OnBoardingController>();
  @override
  Widget build(BuildContext context) {
    return StepPage(
      currentStep: widget.step,
      footer: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1.w,
                ),
              ),
              child: CustomElevatedButton(
                btnColor: Theme.of(context).colorScheme.surface,
                textColor: Theme.of(context).colorScheme.onSurface,
                onTap: () {
                  context.pushNamed(RouteNames.mainNavBar);
                },
                buttonText: 'Not Now',
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Obx(
              () => PrimaryButton.text(
                onPressed: _isLoading.value
                    ? () {}
                    : () => _getCurrentLocation(),
                text: 'Allow',
                isLoading: _isLoading.value,
              ),
            ),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 32.h),

            const StepTitle(title: 'Location access', subtitle: ""),

            SizedBox(height: 68.h),

            // SizedBox(height: 115.h),

            // Assets.icons.locationIc.svg(width: 100.w, height: 100.h),
            Lottie.asset(
              'assets/lottie/Location Pin.json',
              height: 200.w,
              width: 300.w,
              // delegates: LottieDelegates(
              //   values: [
              //     // All fills
              //     ValueDelegate.color(
              //       ['**', 'Fill *'],
              //       value: Theme.of(context).colorScheme.,
              //     ),
              //     ValueDelegate.color(
              //       ['**', 'Stroke *'],
              //       value: Theme.of(context).colorScheme.primary,
              //     ),
              //   ],
              // ),
            ),

            // SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                'Used to connect you with what’s nearby.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Only while using the app.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    if (_isLoading.value) return;
    _isLoading.value = true;

    try {
      // 1. Service & Permission Checks
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Location services are disabled.';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Permissions denied.';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'Permissions permanently denied.';
      }

      // 2. Get Position
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
      } catch (e) {
        position = await Geolocator.getLastKnownPosition();
        if (position == null) throw 'Could not determine coordinates.';
      }

      // 3. Safe Geocoding
      String locationName = "Unknown Location";
      try {
        // Check if geocoding service is present (Android only)
        // This prevents the "Null check operator" crash inside the package
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 5));

        if (placemarks.isNotEmpty) {
          final p = placemarks.first;

          // Build address parts without using ANY "!" operators
          final city =
              p.locality ??
              p.subAdministrativeArea ??
              p.administrativeArea ??
              "";
          final country = p.country ?? "";

          if (city.isNotEmpty && country.isNotEmpty) {
            locationName = "$city, $country";
          } else {
            locationName = city.isNotEmpty
                ? city
                : (country.isNotEmpty ? country : "Unknown");
          }
        }
      } catch (e) {
        print("⚠️ Geocoding failed: $e");
        print("Lat: ${position.latitude}, Long: ${position.longitude}");
        // Last resort: formatted coordinates as the name
        locationName =
            "${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}";
      }

      // 4. API Request
      print(">>> Location Name: $locationName");
      final bool success = await controller.onboardingLocationSubmit(
        latitude: position.latitude,
        longitude: position.longitude,
        locationName: locationName,
      );

      if (success && mounted) {
        context.pushReplacementNamed(RouteNames.mainNavBar);
      }
    } catch (e) {
      AppSnackbar.show(message: e.toString(), type: SnackType.error);
    } finally {
      _isLoading.value = false;
    }
  }
}
