import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/env.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/views/common/cancel_button.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';
import 'package:vibe_now/views/home/widgets/google_map.dart';
import 'package:vibe_now/views/home/widgets/map_search_screen.dart';
import 'package:vibe_now/views/vibe/meet_confirm_screen.dart';
import 'package:vibe_now/views/vibe/reshedule_meetup_screen.dart';

class MeetLocationSuggestionScreen extends StatefulWidget {
  const MeetLocationSuggestionScreen({super.key});

  @override
  State<MeetLocationSuggestionScreen> createState() =>
      _MeetLocationSuggestionScreenState();
}

class _MeetLocationSuggestionScreenState
    extends State<MeetLocationSuggestionScreen> {
  static const LatLng _userPos = LatLng(50.937, 6.953);
  static const LatLng _friendPos = LatLng(50.938, 6.958);
  String? _darkMapStyle;

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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.translate('confirmMeetup'),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 22.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              children: [
                SizedBox(height: 10.h),
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45.r,
                        backgroundImage: const NetworkImage(
                          'https://i.pravatar.cc/300?img=10',
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        "Jhon Gomes",
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16.sp,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          Text(
                            "300m away",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30.h),
                Container(
                  height: 180.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: GoogleMap(
                    style: Theme.of(context).brightness == Brightness.dark
                        ? _darkMapStyle
                        : null,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        (_userPos.latitude + _friendPos.latitude) / 2,
                        (_userPos.longitude + _friendPos.longitude) / 2,
                      ),
                      zoom: 14,
                    ),
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    markers: {
                      const Marker(markerId: MarkerId('u'), position: _userPos),
                      const Marker(
                        markerId: MarkerId('f'),
                        position: _friendPos,
                      ),
                    },
                    polylines: {
                      Polyline(
                        polylineId: const PolylineId("route"),
                        points: [_userPos, _friendPos],
                        color: AppColors.primary,
                        width: 4,
                        geodesic: true,
                      ),
                    },
                  ),
                ),

                SizedBox(height: 25.h),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GoogleMapScreen(
                          apiKey: EnvHandler.google_map_api_key,
                        ),
                      ),
                    );
                  },
                  child: _buildLocationOption(
                    icon: Assets.icons.home,
                    title: loc.translate('meetAtMyLocation'),
                    subtitle: loc.translate('hereAndNow'),
                  ),
                ),

                SizedBox(height: 15.h),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GoogleMapScreen(
                          apiKey: EnvHandler.google_map_api_key,
                        ),
                      ),
                    );
                  },
                  child: _buildLocationOption(
                    icon: Assets.icons.locationColor,
                    title: loc.translate('suggestMidpoint'),
                    subtitle: loc.translate('pickLocationOnMap'),
                  ),
                ),

                SizedBox(height: 24.h),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 40.h),
            child: Row(
              children: [
                Expanded(
                  child: PrimaryButton.text(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MeetupConfirmationScreen(),
                        ),
                      );
                    },
                    text: loc.translate('meetNow'),
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: CustomElevatedButton(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResheduleMeetupScreen(),
                        ),
                      );
                    },
                    buttonText: loc.translate('later'),
                    btnColor: Theme.of(context).colorScheme.surfaceVariant,
                    textColor: Theme.of(context).colorScheme.onSurface,
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

  Widget _buildLocationOption({
    required SvgGenImage icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: const Color(0xFF9D59FF).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: icon.svg(width: 24.w, height: 24.h),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
