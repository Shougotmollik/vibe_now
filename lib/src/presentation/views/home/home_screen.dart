import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vibe_now/gen/assets.gen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _MapHomeScreenState();
}

class _MapHomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late GoogleMapController _mapController;
  late AnimationController _pulseController;

  final LatLng _currentLocation = const LatLng(23.8103, 90.4125);

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),

          Positioned(
            top: 40.h,
            left: 16.w,
            right: 16.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Assets.icons.notification.svg(
                      width: 24.w,
                      height: 24.h,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Assets.icons.filter.svg(width: 20.w, height: 20.h),
                  ),
                ),
              ],
            ),
          ),

          _buildUserPulse(),

          _buildMarkers(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: _currentLocation, zoom: 14),
      myLocationEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: (controller) => _mapController = controller,
    );
  }

  Widget _buildUserPulse() {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final size = 120 + (_pulseController.value * 80);

          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withValues(alpha: 0.15),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCenterUser() {
    return const CircleAvatar(
      radius: 28,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=12'),
      ),
    );
  }

  Widget _buildMarkers() {
    return Positioned.fill(
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildCenterUser(),
          _marker(offset: const Offset(-80, -60), img: 1),
          _marker(offset: const Offset(90, -20), img: 2),
          _marker(offset: const Offset(-60, 80), img: 3),
          _marker(offset: const Offset(70, 90), img: 4),
        ],
      ),
    );
  }

  Widget _marker({required Offset offset, required int img}) {
    return Transform.translate(
      offset: offset,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.purple,
        child: CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=$img'),
        ),
      ),
    );
  }
}
