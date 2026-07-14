import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vibe_now/controller/wave_controller.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/env.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/model/incoming_wave.dart';
import 'package:vibe_now/views/common/cancel_button.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';
import 'package:vibe_now/views/home/widgets/google_map.dart';
import 'package:vibe_now/views/home/widgets/map_search_screen.dart';
import 'package:vibe_now/views/vibe/meet_confirm_screen.dart';
import 'package:vibe_now/views/vibe/reshedule_meetup_screen.dart';

/// Which location option the user has selected.
enum _LocationOption { none, myLocation, midpoint, custom }

class MeetLocationSuggestionScreen extends StatefulWidget {
  final IncomingWave wave;

  const MeetLocationSuggestionScreen({super.key, required this.wave});

  @override
  State<MeetLocationSuggestionScreen> createState() =>
      _MeetLocationSuggestionScreenState();
}

class _MeetLocationSuggestionScreenState
    extends State<MeetLocationSuggestionScreen> {
  final WaveController _waveController = Get.find<WaveController>();
  bool _isProcessing = false;

  // Selected location state
  _LocationOption _selectedOption = _LocationOption.none;
  GoogleMapLocation? _selectedMapLocation;

  // Get positions from the wave data
  LatLng get _senderPos {
    final loc = widget.wave.sender.currentLocation;
    if (loc?.latitude != null && loc?.longitude != null) {
      return LatLng(loc!.latitude!, loc.longitude!);
    }
    return const LatLng(50.937, 6.953); // fallback
  }

  LatLng get _receiverPos {
    final loc = widget.wave.receiver?.currentLocation;
    if (loc?.latitude != null && loc?.longitude != null) {
      return LatLng(loc!.latitude!, loc.longitude!);
    }
    return const LatLng(50.938, 6.958); // fallback
  }

  /// Compute the midpoint between sender and receiver
  LatLng get _midpoint => LatLng(
        (_senderPos.latitude + _receiverPos.latitude) / 2,
        (_senderPos.longitude + _receiverPos.longitude) / 2,
      );

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

  /// Opens the GoogleMapScreen for picking a custom location.
  Future<void> _openMapPicker({required _LocationOption option}) async {
    if (option == _LocationOption.myLocation) {
      // Use sender's location directly — no map needed
      setState(() {
        _selectedOption = option;
        _selectedMapLocation = GoogleMapLocation(
          position: _senderPos,
          name: widget.wave.sender.currentLocation?.locationName ?? '',
          placeId: '',
        );
      });
      return;
    }

    // For midpoint or custom, open the map to pick
    final LatLng startPos =
        option == _LocationOption.midpoint ? _midpoint : _senderPos;

    // Use a completer to get the result back from the map
    GoogleMapLocation? pickedLocation;

    await Navigator.push<GoogleMapLocation>(
      context,
      MaterialPageRoute(
        builder: (context) => GoogleMapScreen(
          apiKey: EnvHandler.google_map_api_key,
          initialPosition: startPos,
          canSelectLocation: true,
          showDemoMarkers: false,
          onLocationSelect: (location) {
            pickedLocation = location;
          },
        ),
      ),
    );

    // pickedLocation is set by onLocationSelect callback before pop
    if (pickedLocation != null && mounted) {
      setState(() {
        _selectedOption = option;
        _selectedMapLocation = pickedLocation;
      });
    }
  }

  Future<void> _handleMeetNow() async {
    if (_isProcessing) return;

    // Determine location details based on selected option
    String locationType;
    double lat;
    double lng;
    String address;

    switch (_selectedOption) {
      case _LocationOption.myLocation:
        locationType = 'creator_location';
        lat = _senderPos.latitude;
        lng = _senderPos.longitude;
        address =
            widget.wave.sender.currentLocation?.locationName ??
                AppLocalizations.of(context).translate('myLocation');
        break;
      case _LocationOption.midpoint:
      case _LocationOption.custom:
        locationType = _selectedOption == _LocationOption.midpoint
            ? 'midpoint'
            : 'custom';
        if (_selectedMapLocation != null) {
          lat = _selectedMapLocation!.position.latitude;
          lng = _selectedMapLocation!.position.longitude;
          address = _selectedMapLocation!.name;
        } else {
          // Fallback to midpoint if no custom location was picked
          locationType = 'midpoint';
          lat = _midpoint.latitude;
          lng = _midpoint.longitude;
          address = AppLocalizations.of(context).translate('midpoint');
        }
        break;
      case _LocationOption.none:
        // Default: use sender's location
        locationType = 'creator_location';
        lat = _senderPos.latitude;
        lng = _senderPos.longitude;
        address =
            widget.wave.sender.currentLocation?.locationName ?? '';
        break;
    }

    setState(() => _isProcessing = true);

    final success = await _waveController.suggestMeetup(
      waveId: widget.wave.waveId,
      meetupType: 'now',
      locationType: locationType,
      latitude: lat.toString(),
      longitude: lng.toString(),
      address: address,
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MeetupConfirmationScreen(
            wave: widget.wave,
            locationType: locationType,
            latitude: lat,
            longitude: lng,
            address: address,
          ),
        ),
        (route) => route.isFirst,
      );
    } else {
      AppSnackbar.show(
        message: AppLocalizations.of(context).translate('failedToSuggestMeetup'),
        type: SnackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final sender = widget.wave.sender;
    final distanceText = widget.wave.distanceText ?? '';

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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(45.r),
                        child: sender.avatar.isNotEmpty
                            ? Image.network(
                                AppCredentials.fixurl(sender.avatar),
                                width: 90.w,
                                height: 90.w,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => CircleAvatar(
                                  radius: 45.r,
                                  child: Icon(Icons.person, size: 36.w),
                                ),
                              )
                            : CircleAvatar(
                                radius: 45.r,
                                child: Icon(Icons.person, size: 36.w),
                              ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        sender.fullName,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (distanceText.isNotEmpty)
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
                              ' $distanceText',
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
                        (_senderPos.latitude + _receiverPos.latitude) / 2,
                        (_senderPos.longitude + _receiverPos.longitude) / 2,
                      ),
                      zoom: 14,
                    ),
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    markers: {
                      Marker(
                        markerId: const MarkerId('sender'),
                        position: _senderPos,
                      ),
                      Marker(
                        markerId: const MarkerId('receiver'),
                        position: _receiverPos,
                      ),
                      if (_selectedMapLocation != null)
                        Marker(
                          markerId: const MarkerId('selected'),
                          position: _selectedMapLocation!.position,
                        ),
                    },
                    polylines: {
                      Polyline(
                        polylineId: const PolylineId("route"),
                        points: [_senderPos, _receiverPos],
                        color: AppColors.primary,
                        width: 4,
                        geodesic: true,
                      ),
                    },
                  ),
                ),

                SizedBox(height: 25.h),

                GestureDetector(
                  onTap: () => _openMapPicker(
                    option: _LocationOption.myLocation,
                  ),
                  child: _buildLocationOption(
                    icon: Assets.icons.home,
                    title: loc.translate('meetAtMyLocation'),
                    subtitle: _selectedOption == _LocationOption.myLocation
                        ? loc.translate('locationSelected')
                        : loc.translate('hereAndNow'),
                    isSelected: _selectedOption == _LocationOption.myLocation,
                  ),
                ),

                SizedBox(height: 15.h),

                GestureDetector(
                  onTap: () => _openMapPicker(
                    option: _LocationOption.midpoint,
                  ),
                  child: _buildLocationOption(
                    icon: Assets.icons.locationColor,
                    title: loc.translate('suggestMidpoint'),
                    subtitle: _selectedOption == _LocationOption.midpoint &&
                            _selectedMapLocation != null
                        ? '✓ ${_selectedMapLocation!.name}'
                        : loc.translate('pickLocationOnMap'),
                    isSelected: _selectedOption == _LocationOption.midpoint ||
                        _selectedOption == _LocationOption.custom,
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
                    onPressed: () => _handleMeetNow(),
                    isEnabled: !_isProcessing,
                    isLoading: _isProcessing,
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
                          builder: (context) =>
                              ResheduleMeetupScreen(wave: widget.wave),
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
    bool isSelected = false,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          width: isSelected ? 2 : 1,
        ),
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
      ),
      child: Row(
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
          Expanded(
            child: Column(
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
                    color: isSelected
                        ? AppColors.primary
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check_circle,
              color: AppColors.primary,
              size: 20.w,
            ),
        ],
      ),
    );
  }
}
