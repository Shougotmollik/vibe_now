import 'dart:async';
import 'dart:convert';
import 'dart:ffi' hide Size;
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide Size;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_now/controller/home_controller.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/community.dart';
import 'package:vibe_now/model/event.dart';
import 'package:vibe_now/model/nearby_user.dart';
import 'package:vibe_now/utils.dart' as utils;
import 'package:vibe_now/views/community/widgets/community_card.dart';
import 'package:vibe_now/views/vibe/my_vibe_screen.dart';
import 'package:vibe_now/views/vibe/user_vibe_screen.dart';
import 'package:vibe_now/views/event/widgets/event_card.dart';
import 'package:vibe_now/views/home/widgets/community_location_pin.dart';
import 'package:vibe_now/views/home/widgets/event_location_pin.dart';
import 'package:vibe_now/views/home/widgets/filter_dialog.dart';
import 'package:vibe_now/views/home/widgets/map_search_screen.dart';
import 'package:vibe_now/views/home/widgets/user_location_pin.dart';
import 'package:vibe_now/views/home/widgets/wave_animated_dialog.dart';
import 'package:widget_to_marker/widget_to_marker.dart';
// import 'package:voice_vive/utils.dart' as utils;
// import 'package:voice_vive/utils/app_colors.dart';

class GoogleMapSearchModel {
  String description;
  String placeId;

  GoogleMapSearchModel({required this.description, required this.placeId});
}

class GoogleMapLocation {
  String name;
  String placeId;
  LatLng position;

  GoogleMapLocation({
    required this.position,
    required this.name,
    required this.placeId,
  });
}

// Removed global hardcoded colors to use Theme.of(context) instead.

class GoogleMapScreen extends StatefulWidget {
  final LatLng? initialPosition;
  final bool withScaffold;
  final String apiKey;
  final bool canSelectLocation;
  final void Function(GoogleMapLocation)? onLocationSelect;

  const GoogleMapScreen({
    super.key,
    required this.apiKey,
    this.initialPosition,
    this.withScaffold = true,
    this.onLocationSelect,
    this.canSelectLocation = true,
  });

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final HomeController homeController = Get.put(HomeController());

  static const LatLng _currentLocation = LatLng(
    50.93747315706174,
    6.953134027839385,
  );
  LatLng _offsetToLatLng(LatLng center, double dx, double dy) {
    // Rough conversion: 1 degree ≈ 111km
    // At zoom 14, adjust these values based on your needs
    const double metersPerPixel = 10.0; // Adjust this value
    final double latOffset = (dy * metersPerPixel) / 111000;
    final double lngOffset =
        (dx * metersPerPixel) / (111000 * 0.9); // Adjust for latitude

    return LatLng(center.latitude + latOffset, center.longitude + lngOffset);
  }

  final Set<Marker> _markers = {};
  late CameraPosition _initialPosition;

  @override
  void initState() {
    super.initState();

    if (widget.initialPosition != null) {
      _initialPosition = CameraPosition(
        target: widget.initialPosition!,
        zoom: 14,
      );

      _handleTap(widget.initialPosition!);
    } else {
      _initialPosition = CameraPosition(target: _currentLocation, zoom: 14);
    }

    _loadMarkers();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   showUserVibeDialog(context: context, user: someNearbyUser, hasVibe: true);
    // });
  }

  bool _gettingMyLocation = false;

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('');
      debugPrint('Location services are disabled.');
      debugPrint('');
      return;
    }

    // Check permission status
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('');
      debugPrint(
        'Location permissions are permanently denied. Please enable them from settings.',
      );
      debugPrint('');
      return;
    }

    setState(() {
      _gettingMyLocation = true;
    });

    // If everything is good, get the current position
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: AndroidSettings(accuracy: LocationAccuracy.high),
    );

    debugPrint('');
    debugPrint(
      'Latitude: ${position.latitude}, Longitude: ${position.longitude}',
    );
    debugPrint('');

    final GoogleMapController controller = await _controller.future;

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        ),
      ),
    );

    markers.clear(); // If you want only one marker at a time
    markers.add(
      Marker(
        markerId: MarkerId(position.hashCode.toString()),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: InfoWindow(
          title: 'Selected Location',
          snippet: '${position.latitude}, ${position.longitude}',
        ),
      ),
    );

    setState(() {
      _selectedPlaceDetails = null;
      _selectedPosition = LatLng(position.latitude, position.longitude);
    });

    //Get the place id
    final placeId = await getPlaceIdFromLatLng(
      position.latitude,
      position.longitude,
    );

    if (placeId == null) return;

    //Get the place details
    final details = await getPlaceDetails(placeId);
    if (details == null) return;

    setState(() {
      _selectedPlaceDetails = details;
    });

    setState(() {
      _gettingMyLocation = false;
    });
  }

  Set<Marker> markers = {};

  bool _handlingTap = false;

  // This method handles the tap event on the map
  void _handleTap(LatLng tappedPoint) async {
    if (!mounted || _handlingTap) return;
    _handlingTap = true;
    setState(() {
      markers.clear(); // If you want only one marker at a time
      markers.add(
        Marker(
          markerId: MarkerId(
            '${tappedPoint.latitude}_${tappedPoint.longitude}',
          ),
          position: tappedPoint,
          infoWindow: InfoWindow(
            title: 'Selected Location',
            snippet: '${tappedPoint.latitude}, ${tappedPoint.longitude}',
          ),
        ),
      );
    });

    if (!mounted) return;
    setState(() {
      _selectedPlaceDetails = null;
      _selectedPosition = LatLng(tappedPoint.latitude, tappedPoint.longitude);
    });

    //Get the place id
    final placeId = await getPlaceIdFromLatLng(
      tappedPoint.latitude,
      tappedPoint.longitude,
    );

    if (placeId == null) {
      _handlingTap = false;
      return;
    }

    //Get the place details
    final details = await getPlaceDetails(placeId);
    _handlingTap = false;
    if (details == null || !mounted) return;

    setState(() {
      _selectedPlaceDetails = details;
    });
  }

  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${widget.apiKey}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        return data['result'];
      } else {
        print('API Error: ${data['status']}');
        return null;
      }
    } else {
      return null;
    }
  }

  Future<String?> getPlaceIdFromLatLng(double lat, double lng) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${widget.apiKey}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        final placeId = data['results'][0]['place_id'];
        return placeId;
      }
    }

    return null;
  }

  String _googleMapPhotoUrl(String photoReference, {int maxWidth = 400}) {
    return 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=$maxWidth&photoreference=$photoReference&key=${widget.apiKey}';
  }

  Map<String, dynamic>? _selectedPlaceDetails;
  LatLng? _selectedPosition;

  String _searchIcon() {
    return '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M18.031 16.6166L22.3137 20.8993L20.8995 22.3135L16.6168 18.0308C15.0769 19.2628 13.124 19.9998 11 19.9998C6.032 19.9998 2 15.9678 2 10.9998C2 6.03176 6.032 1.99976 11 1.99976C15.968 1.99976 20 6.03176 20 10.9998C20 13.1238 19.263 15.0767 18.031 16.6166ZM16.0247 15.8746C17.2475 14.6144 18 12.8954 18 10.9998C18 7.13226 14.8675 3.99976 11 3.99976C7.1325 3.99976 4 7.13226 4 10.9998C4 14.8673 7.1325 17.9998 11 17.9998C12.8956 17.9998 14.6146 17.2473 15.8748 16.0245L16.0247 15.8746Z" fill="white"/></svg>';
  }

  String _gpsIcon() {
    return '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" clip-rule="evenodd" d="M12 1.25C12.4142 1.25 12.75 1.58579 12.75 2V3.28169C16.9842 3.64113 20.3589 7.01581 20.7183 11.25H22C22.4142 11.25 22.75 11.5858 22.75 12C22.75 12.4142 22.4142 12.75 22 12.75H20.7183C20.3589 16.9842 16.9842 20.3589 12.75 20.7183V22C12.75 22.4142 12.4142 22.75 12 22.75C11.5858 22.75 11.25 22.4142 11.25 22V20.7183C7.01581 20.3589 3.64113 16.9842 3.28169 12.75H2C1.58579 12.75 1.25 12.4142 1.25 12C1.25 11.5858 1.58579 11.25 2 11.25H3.28169C3.64113 7.01581 7.01581 3.64113 11.25 3.28169V2C11.25 1.58579 11.5858 1.25 12 1.25ZM12 4.75C7.99594 4.75 4.75 7.99594 4.75 12C4.75 16.0041 7.99594 19.25 12 19.25C16.0041 19.25 19.25 16.0041 19.25 12C19.25 7.99594 16.0041 4.75 12 4.75ZM12 9.75C10.7574 9.75 9.75 10.7574 9.75 12C9.75 13.2426 10.7574 14.25 12 14.25C13.2426 14.25 14.25 13.2426 14.25 12C14.25 10.7574 13.2426 9.75 12 9.75ZM8.25 12C8.25 9.92893 9.92893 8.25 12 8.25C14.0711 8.25 15.75 9.92893 15.75 12C15.75 14.0711 14.0711 15.75 12 15.75C9.92893 15.75 8.25 14.0711 8.25 12Z" fill="#999999"/></svg>';
  }

  Widget _blurBgWrapper({
    required Widget child,
    BorderRadius? borderRadius,
    double? height,
    double? width,
    EdgeInsetsGeometry? padding,
    Color? color,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? EdgeInsets.zero,
          decoration: BoxDecoration(
            color:
                color ?? Theme.of(context).colorScheme.surface.withOpacity(0.1),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              width: 1.w,
            ),
            borderRadius: borderRadius ?? BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.15),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),

          child: child,
        ),
      ),
    );
  }

  Widget _searchWidget() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 48.h, left: 12.w, right: 10.w),
        child: Row(
          spacing: 12.w,
          children: [
            GestureDetector(
              onTap: () => context.pushNamed(RouteNames.notificationScreen),
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Assets.icons.notification.svg(
                  width: 20.w,
                  height: 20.h,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),

            GestureDetector(
              onTap: () {
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (_) {
                //       return MapSearchScreen(
                //         apiKey: widget.apiKey,
                //         onSearchSelect: _handleSearchSelect,
                //       );
                //     },
                //   ),
                // );
              },
              child: Container(
                height: 40.h,
                width: 1.sw - 72.w - 36.w - 24.w,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.string(
                      _searchIcon(),
                      width: 20.w,
                      height: 20.w,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Search ...',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // GestureDetector(
            //   onTap: _getCurrentLocation,
            //   child: _blurBgWrapper(
            //     width: 36.w,
            //     height: 36.w,
            //     child: Center(
            //       child: _gettingMyLocation
            //           ? SizedBox(
            //               width: 20.w,
            //               height: 20.w,
            //               child: const CircularProgressIndicator(
            //                 color: Colors.white,
            //                 strokeWidth: 1,
            //               ),
            //             )
            //           : SvgPicture.string(
            //               _gpsIcon(),
            //               width: 20.w,
            //               height: 20.w,
            //               color: Colors.white,
            //             ),
            //     ),
            //   ),
            // ),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const FilterDialog(),
                );
              },
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Assets.icons.filter.svg(
                  width: 16.w,
                  height: 16.h,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSearchSelect(GoogleMapSearchModel item) async {
    final details = await getPlaceDetails(item.placeId);
    if (details == null) return;

    setState(() {
      _selectedPlaceDetails = details;
    });

    final location = details['geometry']['location'];
    setState(() {
      _selectedPosition = LatLng(location['lat'], location['lng']);
    });

    final SharedPreferences localStorage =
        await SharedPreferences.getInstance();

    List<dynamic> str = jsonDecode(
      localStorage.getString('google-map-location-search-history') ?? '[]',
    );

    List<Map<String, dynamic>> history = List<Map<String, dynamic>>.from(str);

    history.removeWhere((element) => element['placeId'] == item.placeId);
    history.add({'placeId': item.placeId, 'description': item.description});

    localStorage.setString(
      'google-map-location-search-history',
      jsonEncode(history),
    );

    final GoogleMapController controller = await _controller.future;

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(bearing: 0, target: _selectedPosition!, zoom: 15),
      ),
    );

    markers.clear();
    markers.add(
      Marker(
        markerId: MarkerId(item.placeId),
        position: LatLng(location['lat'], location['lng']),
        infoWindow: InfoWindow(
          title: 'Selected Location',
          snippet: '${location['lat']}, ${location['lng']}',
        ),
      ),
    );
  }

  Widget _photoWidget({
    required Map<String, dynamic> photo,
    required void Function() onTap,
  }) {
    final double height = 100.h;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: (height * photo['width']) / photo['height'],
        margin: EdgeInsets.only(right: 8.w),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6.r)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6.r),
          child: CachedNetworkImage(
            imageUrl: _googleMapPhotoUrl(photo['photo_reference']),
            fit: BoxFit.cover,
            placeholder: (context, url) {
              return Container(
                height: height,
                width: (height * photo['width']) / photo['height'],
                decoration: BoxDecoration(
                  color: Color(0xff242424).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _selectedPositionDetailsWidget() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 12.h),
          child: _blurBgWrapper(
            width: double.infinity,
            borderRadius: BorderRadius.circular(16.r),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '${_selectedPlaceDetails!['address_components'].map((e) => e['long_name']).join(', ')}',
                        style: TextStyle(
                          color: AppColors.primaryText.withValues(alpha: 0.8),
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPlaceDetails = null;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Icon(
                          Icons.close,
                          color: AppColors.primaryText.withValues(alpha: 0.8),
                          size: 18.w,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                if (_selectedPlaceDetails != null &&
                    _selectedPlaceDetails!['photos'] != null)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ..._selectedPlaceDetails!['photos'].asMap().entries.map(
                          (entry) {
                            int index = entry.key;
                            final photo = entry.value;
                            return _photoWidget(
                              photo: photo,
                              onTap: () {
                                utils.openImageViewer(
                                  context: context,
                                  index: index,
                                  preLoad: 2,
                                  showNumber: true,
                                  images: [
                                    ..._selectedPlaceDetails!['photos'].map((
                                      item,
                                    ) {
                                      return CachedNetworkImageProvider(
                                        _googleMapPhotoUrl(
                                          item['photo_reference'],
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                );
                              },
                            );
                          },
                        ).toList(),
                      ],
                    ),
                  ),
                SizedBox(height: 24.h),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   spacing: 12.w,
                //   children: [
                //     GestureDetector(
                //       onTap: () {
                //         setState(() {
                //           _selectedPlaceDetails = null;
                //         });
                //       },
                //       child: Container(
                //         padding: EdgeInsets.symmetric(
                //           horizontal: 12.w,
                //           vertical: 8.h,
                //         ),
                //         decoration: BoxDecoration(
                //           color: AppColors.backgroundVariant,
                //           borderRadius: BorderRadius.circular(24.r),
                //         ),
                //         child: Text(
                //           'Cancel',
                //           style: TextStyle(
                //             fontSize: 14.sp,
                //             color: Colors.black.withValues(alpha: 0.8),
                //           ),
                //         ),
                //       ),
                //     ),
                //     if (widget.canSelectLocation)
                //       GestureDetector(
                //         onTap: () {
                //           widget.onLocationSelect?.call(
                //             GoogleMapLocation(
                //               position: _selectedPosition!,
                //               name: _selectedPlaceDetails!['address_components']
                //                   .map((e) => e['long_name'])
                //                   .join(', '),
                //               placeId: _selectedPlaceDetails!['place_id'],
                //             ),
                //           );
                //           print(
                //             "selected location ${_selectedPlaceDetails!['place_id']} location name ===>${_selectedPlaceDetails!['address_components'].map((e) => e['long_name']).join(', ')}",
                //           );

                //           // get back with address
                //           Navigator.of(context).pop();
                //         },
                //         child: Container(
                //           padding: EdgeInsets.symmetric(
                //             horizontal: 12.w,
                //             vertical: 8.h,
                //           ),
                //           decoration: BoxDecoration(
                //             color: AppColors.backgroundVariant,
                //             borderRadius: BorderRadius.circular(24.r),
                //           ),
                //           child: Text(
                //             'Select',
                //             style: TextStyle(
                //               color: AppColors.primary,
                //               fontSize: 14.sp,
                //             ),
                //           ),
                //         ),
                //       ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget buildWidget = SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          GoogleMap(
            // style: jsonEncode(mapStyle),
            onTap: _handleTap,
            markers: _markers,
            compassEnabled: true,
            buildingsEnabled: true,
            mapToolbarEnabled: true,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            initialCameraPosition: _initialPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          _searchWidget(),
          if (_selectedPlaceDetails != null) _selectedPositionDetailsWidget(),
          _buildAllVibeButton(),
        ],
      ),
    );

    if (widget.withScaffold) {
      return Scaffold(body: buildWidget);
    } else {
      return buildWidget;
    }
  }

  Widget _buildAllVibeButton() {
    return Positioned(
      bottom: 120.h,
      right: 20.w,
      child: GestureDetector(
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => UserVibeScreen()));
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            spacing: 5.w,
            children: [
              Assets.icons.creationStar.svg(width: 18.w, height: 18.h),
              Text(
                "All Vibes",
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showUserVibeDialog({
    required BuildContext context,
    required NearbyUser user,
    required bool hasVibe,
  }) {
    showDialog(
      context: context,
      animationStyle: AnimationStyle(curve: Curves.easeInOut),
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyVibeScreen()),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(user.imageUrl),
                ),
                const SizedBox(width: 16),

                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          "Coffee break",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(width: 4),
                        const Text("☕", style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "Expires in 20min",
                      style: TextStyle(fontSize: 14, color: Colors.black38),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showUserProfileDialog(
    BuildContext context,
    NearbyUser user, {
    bool hasVibe = false,
  }) {
    showDialog(
      context: context,
      // isScrollControlled: true,
      // backgroundColor: Colors.transparent,
      builder: (_) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),

                // avatar
                Stack(
                  children: [
                    GestureDetector(
                      onTap: hasVibe
                          ? () => _openFullImage(user.imageUrl, context)
                          : () {
                              if (user.isWaved == true) {
                                context.pushNamed(RouteNames.profileScreen);
                              } else {
                                context.pushNamed(
                                  RouteNames.lockedProfileScreen,
                                );
                              }
                            },
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: hasVibe
                            ? BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: SweepGradient(
                                  colors: [
                                    AppColors.primaryVariant,
                                    Color(0xffC470F5),
                                    Color(0xff8663F6),
                                    Color(0xff57C2FF),
                                    AppColors.primaryVariant,
                                  ],
                                ),
                              )
                            : null,
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundImage: NetworkImage(user.imageUrl),
                          ),
                        ),
                      ),
                    ),
                    // Positioned(
                    //   bottom: 0,
                    //   right: 0,
                    //   child: Container(
                    //     padding: const EdgeInsets.all(6),
                    //     decoration: BoxDecoration(
                    //       shape: BoxShape.circle,
                    //       gradient: AppColors.primaryGradient,
                    //       border: Border.all(color: Colors.white, width: 2),
                    //     ),
                    //     child: Assets.icons.location.svg(height: 14),
                    //   ),
                    // ),
                  ],
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 12.w,
                    horizontal: 18.w,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,

                    borderRadius: BorderRadius.circular(24.r),
                    // border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Text(
                    "sunday coffee vibes - who's in? 🌞",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.black),
                  ),
                ),

                // SizedBox(height: 6.h),
                const SizedBox(height: 12),

                // name
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                // interests row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Assets.icons.coffeeColor.svg(height: 14),
                    const SizedBox(width: 4),
                    Text(
                      user.interest,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "• ${user.distanceKm} km away",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // bio
                !hasVibe
                    ? Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          user.bio,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      )
                    : Container(),

                const SizedBox(height: 16),

                // action buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (user.isWaved == true) return;

                          setState(() {
                            user.isWaved = true;
                          });

                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (context) => WaveAnimatedDialog(
                              content: 'You have wave to ${user.name}',
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            // color: user.isWaved == true
                            //     ? Color(0xffC4A8FF)
                            //     : null,
                            gradient: user.isWaved == true
                                ? AppColors.primaryGradient.withOpacity(0.5)
                                : AppColors.primaryGradientRotated,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 4.w,
                              children: [
                                Text(
                                  user.isWaved == true ? 'Waved' : 'Wave',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Assets.icons.handWave.svg(
                                  width: 14.w,
                                  height: 14.h,
                                  color: AppColors.onPrimary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // const SizedBox(width: 12),
                    // Container(
                    //   padding: const EdgeInsets.all(14),
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(14),
                    //     color: Colors.grey.shade200,
                    //   ),
                    //   child: Assets.icons.chatting.svg(),
                    // ),
                  ],
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openFullImage(String imageUrl, BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (_, __, ___) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Dismissible(
              key: const Key('full_image'),
              direction: DismissDirection.down,
              onDismissed: (_) => Navigator.pop(context),
              child: Center(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _loadMarkers() async {
    _markers.add(
      Marker(
        markerId: MarkerId('0'),
        position: _currentLocation,
        icon:
            await UserLocationPin(
              imagePath: 'https://i.pravatar.cc/150?img=11',
              hasVibe: true,
            ).toBitmapDescriptor(
              logicalSize: const Size(300, 300),
              imageSize: const Size(300, 300),
            ),
        onTap: () {
          showUserVibeDialog(
            context: context,
            user: homeController.nearbyUsers[0],
            hasVibe: true,
          );
        },
      ),
    );
    setState(() {});
    _markers.add(
      Marker(
        markerId: const MarkerId("1"),
        position: _offsetToLatLng(_currentLocation, -60, 80),
        icon:
            await UserLocationPin(
              imagePath: 'https://i.pravatar.cc/150?img=12',
              hasVibe: false,
            ).toBitmapDescriptor(
              logicalSize: const Size(300, 300),
              imageSize: const Size(300, 300),
            ),
        onTap: () {
          // showUserVibeDialog(
          //   context: context,
          //   user: homeController.nearbyUsers[1],
          //   hasVibe: true,
          // );

          showUserProfileDialog(
            context,
            homeController.nearbyUsers[1],
            hasVibe: false,
          );
        },
      ),
    );
    setState(() {});
    _markers.add(
      Marker(
        markerId: const MarkerId("2"),
        position: _offsetToLatLng(_currentLocation, 70, 90),
        icon: await CommunityLocationPin().toBitmapDescriptor(
          logicalSize: const Size(300, 300),
          imageSize: const Size(300, 300),
        ),
        onTap: () {
          // showUserProfileDialog(context, nearbyUsers[2]);
          _openCommunityPopUp();
        },
      ),
    );
    setState(() {});
    _markers.add(
      Marker(
        markerId: const MarkerId("3"),
        position: _offsetToLatLng(_currentLocation, 90, -20),
        icon:
            await UserLocationPin(
              imagePath: 'https://i.pravatar.cc/150?img=13',
              hasVibe: true,
            ).toBitmapDescriptor(
              logicalSize: const Size(300, 300),
              imageSize: const Size(300, 300),
            ),
        onTap: () {
          showUserVibeDialog(
            context: context,
            user: homeController.nearbyUsers[3],
            hasVibe: true,
          );
        },
      ),
    );
    setState(() {});
    _markers.add(
      Marker(
        markerId: const MarkerId("4"),

        position: _offsetToLatLng(_currentLocation, -80, -60),

        icon:
            await UserLocationPin(
              imagePath: 'https://i.pravatar.cc/150?img=14',
              hasVibe: false,
            ).toBitmapDescriptor(
              logicalSize: const Size(300, 300),
              imageSize: const Size(300, 300),
            ),
        onTap: () {
          // showUserVibeDialog(
          //   context: context,
          //   user: homeController.nearbyUsers[4],
          //   hasVibe: true,
          // );

          showUserProfileDialog(
            context,
            homeController.nearbyUsers[4],
            hasVibe: false,
          );
        },
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId("5"),
        position: _offsetToLatLng(_currentLocation, -140, 10),
        icon: await EventLocationPin().toBitmapDescriptor(
          logicalSize: const Size(300, 300),
          imageSize: const Size(300, 300),
        ),
        onTap: () {
          _openEventPopUp();
        },
      ),
    );
    setState(() {});
  }

  // Event
  void _openEventPopUp() {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: EventCard(
              event: Event(
                title: 'Club House',
                address: '123 Main St, New York, NY 10001',
                eventDate: '21 Nov',
                eventTime: '8PM - 11PM',
                coverImage:
                    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800',
                interestedCount: 5,
                maxAttendees: 10,
                isJoined: false,
                isInterested: false,
                accessLevel: 'private',
              ),
            ),
          ),
        );
      },
    );
  }

  // Community
  void _openCommunityPopUp() {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SizedBox(
              child: CommunityCard(
                community: Community(
                  name: "Coffee Meetup at Central Park",
                  description: "Casual coffee and conversation in the park",
                  location: "Central Park Cafe",
                  distance: "0.3 km",
                  dateTime: "Tomorrow at 3:00 PM",
                  attending: "5",
                  totalAttending: "10",
                  image:
                      'https://www.sbdcnet.org/wp-content/uploads/2020/07/chuttersnap-aEnH4hJ_Mrs-unsplash-e1594836312246.jpg',
                  avatars: [
                    "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fHBlb3BsZXxlbnwwfHwwfHx8MA%3D%3D",
                    "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=764&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                    "https://plus.unsplash.com/premium_photo-1673957923985-b814a9dbc03d?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                  ],
                  extraCount: 5,
                  isMyCommunity: true,
                  userStatus: CommunityStatus.going,
                  accessType: CommunityAccessType.public,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
