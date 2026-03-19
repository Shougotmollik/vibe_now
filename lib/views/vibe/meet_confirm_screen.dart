import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/views/common/cancel_button.dart';
// Assuming your design system imports
// import 'package:vibe_now/design_system/design_system.dart';

class MeetupConfirmationScreen extends StatefulWidget {
  const MeetupConfirmationScreen({super.key});

  @override
  State<MeetupConfirmationScreen> createState() =>
      _MeetupConfirmationScreenState();
}

class _MeetupConfirmationScreenState extends State<MeetupConfirmationScreen> {
  // Mock positions for the two users
  static const LatLng _posA = LatLng(50.937, 6.953);
  static const LatLng _posB = LatLng(50.938, 6.958);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Define Meetup",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 10.h),
                  CircleAvatar(
                    radius: 40.r,
                    backgroundImage: const NetworkImage(
                      'https://i.pravatar.cc/300?img=10',
                    ),
                  ),
                  SizedBox(height: 16.h),

                  Text(
                    "Meetup Confirmed!",
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "See you at Central Park Cafe",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  SizedBox(height: 30.h),

                  Container(
                    height: 200.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(50.9375, 6.9555),
                        zoom: 14.5,
                      ),
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      markers: {
                        const Marker(
                          markerId: MarkerId('posA'),
                          position: _posA,
                        ),
                        const Marker(
                          markerId: MarkerId('posB'),
                          position: _posB,
                        ),
                      },
                      polylines: {
                        Polyline(
                          polylineId: const PolylineId("route"),
                          points: [_posA, _posB],
                          color: AppColors.primary,
                          width: 4,
                          geodesic: true,
                        ),
                      },
                    ),
                  ),

                  SizedBox(height: 25.h),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradientRotated.withOpacity(
                        0.08,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          Assets.icons.calendarColor,
                          "250m - 3 Min Walk",
                        ),
                        SizedBox(height: 12.h),
                        _buildInfoRow(
                          Assets.icons.colorClock,
                          "Arrive within: 19:45",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 40.h),
            child: Column(
              children: [
                CancelButton(onTap: () {}, btnText: "Cancel Meetup"),
                SizedBox(height: 14.h),
                Text(
                  "Great, see you soon!",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildInfoRow(SvgGenImage icon, String label) {
    return Row(
      children: [
        icon.svg(height: 20.h, width: 20.h),
        SizedBox(width: 12.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 18.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
