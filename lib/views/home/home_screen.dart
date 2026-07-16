import 'dart:async';
import 'dart:convert';
import 'dart:ffi' hide Size;
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide Size;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:recase/recase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibe_now/controller/home_controller.dart';
import 'package:vibe_now/controller/notification_controller.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/services/local_storage.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/community.dart';
import 'package:vibe_now/model/event.dart';
import 'package:vibe_now/model/map_item.dart';
import 'package:vibe_now/model/nearby_user.dart';
import 'package:vibe_now/utils.dart' as utils;
import 'package:vibe_now/views/community/widgets/community_card.dart';
import 'package:vibe_now/views/vibe/my_vibe_screen.dart';
import 'package:vibe_now/views/vibe/user_vibe_screen.dart';
import 'package:vibe_now/views/event/widgets/event_card.dart';
import 'package:vibe_now/views/home/widgets/community_location_pin.dart';
import 'package:vibe_now/views/home/widgets/event_location_pin.dart';
import 'package:vibe_now/views/home/widgets/grouped_location_pin.dart';
import 'package:vibe_now/views/home/widgets/filter_dialog.dart';
import 'package:vibe_now/views/home/widgets/map_search_screen.dart';
import 'package:vibe_now/views/home/widgets/user_location_pin.dart';
import 'package:vibe_now/views/home/widgets/wave_animated_dialog.dart';
import 'package:widget_to_marker/widget_to_marker.dart';
import 'package:vibe_now/model/google_map_location.dart';

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

class HomeScreen extends StatefulWidget {
  final LatLng? initialPosition;
  final bool withScaffold;
  final String apiKey;
  final bool canSelectLocation;
  final void Function(GoogleMapLocation)? onLocationSelect;

  const HomeScreen({
    super.key,
    required this.apiKey,
    this.initialPosition,
    this.withScaffold = true,
    this.onLocationSelect,
    this.canSelectLocation = true,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final HomeController homeController = Get.put(HomeController());
  final NotificationController notifController = Get.put(
    NotificationController(),
  );

  static const LatLng _defaultLocation = LatLng(
    50.93747315706174,
    6.953134027839385,
  );

  final Set<Marker> _markers = {};
  late CameraPosition _initialPosition;
  String? _darkMapStyle;

  bool _gettingMyLocation = false;
  Set<Marker> markers = {};
  bool _handlingTap = false;
  Map<String, dynamic>? _selectedPlaceDetails;
  LatLng? _selectedPosition;
  bool _markersBuilt = false;
  bool _isBuildingMarkers = false;
  late final Worker _mapItemsWorker;

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

    if (widget.initialPosition != null) {
      _initialPosition = CameraPosition(
        target: widget.initialPosition!,
        zoom: 14,
      );
      _handleTap(widget.initialPosition!);
    } else {
      // Start with default — stored location will snap instantly after first frame
      _initialPosition = CameraPosition(target: _defaultLocation, zoom: 14);
    }

    // Rebuild markers reactively when map items arrive from WebSocket
    _mapItemsWorker = ever(homeController.mapItems, (_) {
      if (mounted) {
        setState(() => _markersBuilt = false);
      }
    });

    // After first frame: snap to stored location instantly → then get GPS & animate
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final GoogleMapController controller = await _controller.future;

      // Step 1: Snap to stored location (instant — no visible jump from default)
      final storedLat = await LocalStorage.last_latitude.get();
      final storedLng = await LocalStorage.last_longitude.get();
      if (storedLat != null && storedLng != null && mounted) {
        controller.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(storedLat, storedLng), zoom: 14),
          ),
        );
      }

      // Step 2: Get fresh GPS location → animate there → save replaces stored
      final position = await homeController.loadMapData();
      if (position != null && mounted) {
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 14,
            ),
          ),
          duration: const Duration(milliseconds: 1200),
        );
      }
      // If position is null → GPS failed, stay at stored (or default if no stored)
    });

    // Silently refresh notifications (all unread counts come with 'vibes' tab)
    notifController.getNotifications('vibes', forceRefresh: true);
  }

  @override
  void dispose() {
    _mapItemsWorker.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied.');
      return;
    }

    setState(() {
      _gettingMyLocation = true;
    });

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: AndroidSettings(accuracy: LocationAccuracy.high),
    );

    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: LatLng(position.latitude, position.longitude),
          zoom: 15,
        ),
      ),
      duration: const Duration(milliseconds: 1000),
    );

    markers.clear();
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

    final placeId = await getPlaceIdFromLatLng(
      position.latitude,
      position.longitude,
    );
    if (placeId == null) {
      setState(() => _gettingMyLocation = false);
      return;
    }

    final details = await getPlaceDetails(placeId);
    if (details != null && mounted) {
      setState(() {
        _selectedPlaceDetails = details;
      });
    }
    setState(() => _gettingMyLocation = false);
  }

  void _handleTap(LatLng tappedPoint) async {
    if (!mounted || _handlingTap) return;
    _handlingTap = true;
    setState(() {
      markers.clear();
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

    final placeId = await getPlaceIdFromLatLng(
      tappedPoint.latitude,
      tappedPoint.longitude,
    );
    if (placeId == null) {
      _handlingTap = false;
      return;
    }

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
    }
    return null;
  }

  Future<String?> getPlaceIdFromLatLng(double lat, double lng) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${widget.apiKey}',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        return data['results'][0]['place_id'];
      }
    }
    return null;
  }

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
                offset: const Offset(0, 3),
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
            Obx(() {
              final unread = notifController.stats.value.unreadTotal;
              return GestureDetector(
                onTap: () => context.pushNamed(RouteNames.notificationScreen),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).shadowColor.withOpacity(0.1),
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
                    if (unread > 0)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unread.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),

            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) {
                      return MapSearchScreen(
                        apiKey: widget.apiKey,
                        onSearchSelect: _handleSearchSelect,
                      );
                    },
                  ),
                );
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
                      AppLocalizations.of(context).translate('searchDot'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
      duration: const Duration(milliseconds: 800),
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

  // ─── Dynamic Markers from WebSocket Data ──────────────────────

  Future<void> _buildDynamicMarkers() async {
    if (_markersBuilt) return;
    final items = homeController.mapItems.toList();
    if (items.isEmpty) {
      if (mounted) setState(() => _isBuildingMarkers = false);
      return;
    }

    try {
      // Pre-cache images via CachedNetworkImageProvider so the
      // CachedNetworkImage widgets in the pins reuse the same cache.
      try {
        await Future.wait(
          items.map((item) {
            final urls = <String>[];
            if (item.type == MapItemType.vibe) {
              if ((item.coverImageUrl).isNotEmpty) {
                urls.add(item.coverImageUrl);
              }
              if ((item.createdBy?.avatarUrl ?? '').isNotEmpty) {
                urls.add(AppCredentials.fixurl(item.createdBy!.avatarUrl));
              }
            } else if (item.type == MapItemType.availableUser) {
              if ((item.displayAvatarUrl).isNotEmpty) {
                urls.add(item.displayAvatarUrl);
              }
            } else {
              if ((item.coverImageUrl).isNotEmpty) {
                urls.add(item.coverImageUrl);
              }
            }
            if (urls.isEmpty) return Future.value(null);
            return Future.wait(
              urls.map(
                (url) => precacheImage(CachedNetworkImageProvider(url), context),
              ),
            );
          }),
        );
      } catch (_) {
        // Pre-cache errors are non-fatal, continue to build markers
      }

      debugPrint('🔍 _buildDynamicMarkers: processing ${items.length} items: ${items.map((i) => '${i.type.name}:${i.title ?? i.userFullName ?? "?"}@(${i.latitude?.toStringAsFixed(4)},${i.longitude?.toStringAsFixed(4)})').toList()}');

      // Group items by position so overlapping items render a single pin
      final Map<String, List<MapItem>> positionGroups = {};
      for (final item in items) {
        if (item.latitude == null || item.longitude == null) continue;
        final key = '${item.latitude!.toStringAsFixed(6)}_${item.longitude!.toStringAsFixed(6)}';
        positionGroups.putIfAbsent(key, () => []);
        positionGroups[key]!.add(item);
      }
      debugPrint('🔍 _buildDynamicMarkers: grouped into ${positionGroups.length} positions: ${positionGroups.entries.map((e) => '${e.key}=${e.value.length}').toList()}');

      // Build markers in parallel
      final markerFutures = <Future<Marker?>>[];

      for (final entry in positionGroups.entries) {
        final groupItems = entry.value;
        final firstItem = groupItems.first;
        final position = LatLng(firstItem.latitude!, firstItem.longitude!);
        final key = entry.key;

        if (groupItems.length == 1) {
          // Single item at this position — normal marker
          final item = groupItems.first;
          final markerId = MarkerId('map_${item.type.name}_${item.markerId}');
          markerFutures.add(
            _buildMarkerBitmap(item)
                .then((icon) {
                  if (icon == null) return null;
                  return Marker(
                    markerId: markerId,
                    position: position,
                    icon: icon,
                    onTap: () => _onMarkerTap(item),
                  );
                })
                .catchError((e) {
                  debugPrint('Error creating marker for $markerId: $e');
                  return null;
                }),
          );
        } else {
          // Multiple items at the same position — grouped marker
          final markerId = MarkerId('map_grouped_$key');
          final itemsCopy = List<MapItem>.from(groupItems);
          final count = groupItems.length;

          // Build keyframe bitmaps at different scales for a pop-in animation
          final scales = [0.4, 0.65, 0.9, 1.0];
          markerFutures.add(
            (() async {
              // Build all scaled bitmaps in parallel
              final bitmaps = await Future.wait(
                scales.map((s) => _buildGroupedMarkerBitmap(count, scale: s)),
              );

              final firstIcon = bitmaps.isNotEmpty ? bitmaps.first : null;
              if (firstIcon == null) return null;

              final marker = Marker(
                markerId: markerId,
                position: position,
                icon: firstIcon,
                onTap: () => _showGroupedItemsDialog(itemsCopy),
              );

              // Animate through remaining keyframes with delays
              _animateMarkerPopIn(
                markerId: markerId,
                position: position,
                bitmaps: bitmaps,
                onTap: () => _showGroupedItemsDialog(itemsCopy),
              );

              return marker;
            })(),
          );
        }
      }

      final results = await Future.wait(markerFutures);
      final builtCount = results.whereType<Marker>().length;
      debugPrint('🔍 _buildDynamicMarkers: built $builtCount markers out of ${markerFutures.length} attempts');

      if (mounted) {
        setState(() {
          _markers.clear();
          _markers.addAll(results.whereType<Marker>());
          _markersBuilt = true;
          _isBuildingMarkers = false;
        });
      }
    } catch (e) {
      debugPrint('Error building markers: $e');
      if (mounted) {
        setState(() {
          _isBuildingMarkers = false;
        });
      }
    }
  }

  Future<BitmapDescriptor?> _buildGroupedMarkerBitmap(int count, {double scale = 1.0}) async {
    try {
      final baseSize = 300.0 * scale;
      return GroupedLocationPin(count: count).toBitmapDescriptor(
        logicalSize: Size(baseSize, baseSize),
        imageSize: Size(baseSize, baseSize),
      );
    } catch (e) {
      debugPrint('Error rendering grouped pin bitmap: $e');
      return null;
    }
  }

  /// Animates a grouped marker through progressive bitmap scales for a pop-in effect.
  void _animateMarkerPopIn({
    required MarkerId markerId,
    required LatLng position,
    required List<BitmapDescriptor?> bitmaps,
    required VoidCallback onTap,
  }) {
    if (bitmaps.length < 2) return;

    Future.delayed(const Duration(milliseconds: 60), () {
      if (!mounted) return;
      _updateMarkerBitmap(markerId, position, bitmaps, 1, onTap);
    });
  }

  /// Recursively replaces a marker's icon with the next keyframe bitmap.
  void _updateMarkerBitmap(
    MarkerId markerId,
    LatLng position,
    List<BitmapDescriptor?> bitmaps,
    int index,
    VoidCallback onTap,
  ) {
    if (index >= bitmaps.length || !mounted) return;

    final icon = bitmaps[index];
    if (icon == null) {
      // Skip null bitmap, try next
      _updateMarkerBitmap(markerId, position, bitmaps, index + 1, onTap);
      return;
    }

    final delay = index == bitmaps.length - 1
        ? const Duration(milliseconds: 80)  // linger on final frame
        : const Duration(milliseconds: 50);

    setState(() {
      _markers.removeWhere((m) => m.markerId == markerId);
      _markers.add(Marker(
        markerId: markerId,
        position: position,
        icon: icon,
        onTap: onTap,
      ));
    });

    if (index < bitmaps.length - 1) {
      Future.delayed(delay, () {
        if (mounted) {
          _updateMarkerBitmap(markerId, position, bitmaps, index + 1, onTap);
        }
      });
    }
  }

  Future<BitmapDescriptor?> _buildMarkerBitmap(MapItem item) async {
    try {
      switch (item.type) {
        case MapItemType.vibe:
          final hasVibe = item.status == 'live';
          return UserLocationPin(
            imagePath: item.createdBy?.avatarUrl ?? '',
            hasVibe: hasVibe,
          ).toBitmapDescriptor(
            logicalSize: const Size(300, 300),
            imageSize: const Size(300, 300),
          );
        case MapItemType.event:
          return EventLocationPin(
            imageUrl: item.coverImageUrl,
          ).toBitmapDescriptor(
            logicalSize: const Size(300, 300),
            imageSize: const Size(300, 300),
          );
        case MapItemType.community:
          return CommunityLocationPin(
            imageUrl: item.coverImageUrl,
          ).toBitmapDescriptor(
            logicalSize: const Size(300, 300),
            imageSize: const Size(300, 300),
          );
        case MapItemType.availableUser:
          return UserLocationPin(
            imagePath: item.userAvatar != null
                ? AppCredentials.fixurl(item.userAvatar)
                : '',
            hasVibe: false,
          ).toBitmapDescriptor(
            logicalSize: const Size(300, 300),
            imageSize: const Size(300, 300),
          );
      }
    } catch (e) {
      debugPrint('Error rendering pin bitmap for ${item.type}: $e');
      return null;
    }
  }

  void _onMarkerTap(MapItem item) {
    switch (item.type) {
      case MapItemType.vibe:
        _showVibeDialog(item);
        break;
      case MapItemType.event:
        _showEventPopup(item);
        break;
      case MapItemType.community:
        _showCommunityPopup(item);
        break;
      case MapItemType.availableUser:
        _showAvailableUserDialog(item);
        break;
    }
  }

  void _showVibeDialog(MapItem item) {
    final creator = item.createdBy;
    final vibeTitle = item.title ?? 'Vibe';
    final endsAt = item.raw['ends_at'] as String? ?? '';
    final vibeCoverUrl = item.coverImageUrl;
    final nearbyUser = NearbyUser(
      id: creator?.id ?? '',
      name: creator?.fullName ?? vibeTitle,
      imageUrl: creator?.avatarUrl ?? '',
      bio: '$vibeTitle • ${item.duration ?? ""}',
      interest: vibeTitle,
      distanceKm: item.distance ?? 0.0,
      lat: item.latitude ?? 0,
      lng: item.longitude ?? 0,
    );

    final hasVibe = item.status == 'live';

    if (hasVibe) {
      showUserVibeDialog(
        context: context,
        user: nearbyUser,
        hasVibe: true,
        vibeTitle: vibeTitle,
        endsAt: endsAt,
        vibeCoverUrl: vibeCoverUrl,
      );
    } else {
      showUserProfileDialog(context, nearbyUser, hasVibe: false);
    }
  }

  void _showEventPopup(MapItem item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: EventCard(
              event: Event(
                id: item.id,
                title: item.title ?? '',
                coverImage: item.coverImageUrl,
                address: item.address ?? '',
                eventStartingDate: item.eventStartingDate,
                eventStartingTime: item.eventStartingTime,
                eventEndingDate: item.eventEndingDate,
                eventEndingTime: item.eventEndingTime,
                maxAttendees: item.maxAttendees,
                joinedCount: item.joinedCount ?? 0,
                interestedCount: item.interestedCount ?? 0,
                isJoined: item.isJoined ?? false,
                isInterested: item.isInterested ?? false,
                accessLevel: item.accessLevel ?? 'public',
                chatId: item.chatId,
                participants:
                    (item.raw['participants'] as List?)
                        ?.map((p) => Participant.fromJson(p))
                        .toList() ??
                    [],
                createdBy: item.createdBy != null
                    ? CreatedBy(
                        id: item.createdBy!.id,
                        email: item.createdBy!.email,
                        fullName: item.createdBy!.fullName,
                        avatar: item.createdBy!.avatar,
                      )
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCommunityPopup(MapItem item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: CommunityCard(
              community: Community(
                id: item.id,
                title: item.title ?? '',
                description: item.description ?? '',
                coverImage: item.coverImageUrl,
                address: item.address ?? '',
                communityDate: item.communityDate,
                communityTime: item.communityTime,
                maxAttendees: item.maxAttendees,
                joinedCount: item.joinedCount ?? 0,
                interestedCount: item.interestedCount ?? 0,
                isJoined: item.isJoined ?? false,
                isInterested: item.isInterested ?? false,
                isRequested: item.isRequested ?? false,
                accessLevel: item.accessLevel ?? 'public',
                chatId: item.chatId,
                participants:
                    (item.raw['participants'] as List?)
                        ?.map((p) => CommunityParticipant.fromJson(p))
                        .toList() ??
                    [],
                createdBy: item.createdBy != null
                    ? CommunityCreatedBy(
                        id: item.createdBy!.id,
                        email: item.createdBy!.email,
                        fullName: item.createdBy!.fullName,
                        avatar: item.createdBy!.avatar,
                      )
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAvailableUserDialog(MapItem item) {
    final isLocked = item.isLocked ?? true;

    if (isLocked) {
      context.pushNamed(
        RouteNames.lockedProfileScreen,
        extra: {
          'userName': item.userFullName ?? item.title,
          'avatarUrl': item.userAvatar,
          'distanceKm': item.distance,
        },
      );
    } else {
      context.pushNamed(
        RouteNames.profileScreen,
        extra: item.userId,
      );
    }
  }

  /// Builds a contextual subtitle summarizing what types are grouped at this location.
  /// e.g. "2 Communities & 1 User" or "3 Vibes"
  String _buildTypeSummary(Map<String, int> typeCounts) {
    final typeLabels = {
      'vibe': 'Vibe',
      'event': 'Event',
      'community': 'Community',
      'availableUser': 'User',
    };
    final pluralLabels = {
      'vibe': 'Vibes',
      'event': 'Events',
      'community': 'Communities',
      'availableUser': 'Users',
    };

    final parts = <String>[];
    final entries = typeCounts.entries.toList();

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final count = entry.value;
      final label = count == 1
          ? (typeLabels[entry.key] ?? entry.key)
          : (pluralLabels[entry.key] ?? '${entry.key}s');
      parts.add('$count $label');
    }

    if (parts.length == 1) return parts.first;
    if (parts.length == 2) return '${parts[0]} & ${parts[1]}';

    // Join all but the last with commas, then add "& last"
    return '${parts.sublist(0, parts.length - 1).join(", ")} & ${parts.last}';
  }

  void _showGroupedItemsDialog(List<MapItem> items) {
    // Count types for the header chips
    final typeCounts = <String, int>{};
    for (final item in items) {
      final key = item.type.name;
      typeCounts[key] = (typeCounts[key] ?? 0) + 1;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (_, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: child,
              ),
            );
          },
          child: DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.7,
            expand: false,
            builder: (_, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- Header area ---
                    Padding(
                      padding: EdgeInsets.only(top: 10.h),
                      child: Container(
                        width: 36.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    // Title + close
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nearby',
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w800,
                                    color: Theme.of(context).colorScheme.onSurface,
                                    height: 1.1,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                Text(
                                  _buildTypeSummary(typeCounts),
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Close button
                          GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: Container(
                              width: 34.w,
                              height: 34.w,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 20.w,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12.h),
                    // Divider line
                    Container(
                      height: 1,
                      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),

                    // Items list
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.only(top: 4.h, bottom: 16.h),
                        itemCount: items.length,
                        itemBuilder: (_, index) => _buildGroupedItemTile(items[index], ctx),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Returns a SweepGradient ring using the same gradient colors as the chat screen tab gradients.
  /// vibe → waves tab [#8663F6, #C470F5, #57C2FF], event → event tab [#fbadd8, #deb5fe],
  /// community → community tab [#99e2f1, #aaccff], user → private tab [#f5a0d6, #d494f7]
  SweepGradient _typeRingGradient(MapItemType type) {
    switch (type) {
      case MapItemType.vibe:
        return SweepGradient(
          colors: [
            const Color(0xFF8663F6),
            const Color(0xFFC470F5),
            const Color(0xFF57C2FF),
            const Color(0xFF8663F6),
          ],
        );
      case MapItemType.event:
        return SweepGradient(
          colors: [
            const Color(0xfffbadd8),
            const Color(0xffdeb5fe),
            const Color(0xfffbadd8),
          ],
        );
      case MapItemType.community:
        return SweepGradient(
          colors: [
            const Color(0xff99e2f1),
            const Color(0xffaaccff),
            const Color(0xff99e2f1),
          ],
        );
      case MapItemType.availableUser:
        return SweepGradient(
          colors: [
            const Color(0xfff5a0d6),
            const Color(0xffd494f7),
            const Color(0xfff5a0d6),
          ],
        );
    }
  }

  Widget _buildGroupedItemTile(MapItem item, BuildContext dialogContext) {
    Color accentColor;
    String label;
    IconData typeIcon;
    String? imageUrl;

    switch (item.type) {
      case MapItemType.vibe:
        accentColor = const Color(0xFF8663F6);
        label = 'Vibe';
        typeIcon = Icons.waving_hand_rounded;
        imageUrl = item.createdBy?.avatarUrl;
        break;
      case MapItemType.event:
        accentColor = const Color(0xFFFF6B6B);
        label = 'Event';
        typeIcon = Icons.event_rounded;
        imageUrl = item.coverImageUrl;
        break;
      case MapItemType.community:
        accentColor = const Color(0xFF4ECDC4);
        label = 'Community';
        typeIcon = Icons.groups_rounded;
        imageUrl = item.coverImageUrl;
        break;
      case MapItemType.availableUser:
        accentColor = const Color(0xffd494f7);
        label = 'User';
        typeIcon = Icons.person_rounded;
        imageUrl = item.userAvatar != null
            ? AppCredentials.fixurl(item.userAvatar)
            : null;
        break;
    }

    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    final displayName = item.title ?? item.userFullName ?? '';
    final dist = item.distance ?? 0.0;
    final distText = dist < 1
        ? '${(dist * 1000).toStringAsFixed(0)} m'
        : '${dist.toStringAsFixed(1)} km';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(dialogContext);
          _onMarkerTap(item);
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Row(
            children: [
              // Avatar with type-specific gradient ring
              Container(
                width: 54.w,
                height: 54.w,
                padding: EdgeInsets.all(2.5.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _typeRingGradient(item.type),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  padding: EdgeInsets.all(1.5.w),
                  child: ClipOval(
                    child: hasImage
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: 54.w,
                            height: 54.w,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _tileAvatarFallback(accentColor, typeIcon),
                            errorWidget: (_, __, ___) => _tileAvatarFallback(accentColor, typeIcon),
                          )
                        : _tileAvatarFallback(accentColor, typeIcon),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              // Name + metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        // Solid type badge
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(typeIcon, size: 11.w, color: accentColor),
                              SizedBox(width: 3.w),
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: accentColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10.w),
                        // Distance
                        Icon(
                          Icons.near_me_rounded,
                          size: 12.w,
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                        SizedBox(width: 3.w),
                        Text(
                          distText,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Solid arrow circle
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.w,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tileAvatarFallback(Color accentColor, IconData icon) {
    return Container(
      color: accentColor.withValues(alpha: 0.1),
      child: Icon(icon, color: accentColor, size: 24.w),
    );
  }



  // ─── Existing Dialogs ─────────────────────────────────────────

  void showUserVibeDialog({
    required BuildContext context,
    required NearbyUser user,
    required bool hasVibe,
    String vibeTitle = 'Vibe',
    String endsAt = '',
    String vibeCoverUrl = '',
  }) {
    final remaining = _formatRemainingTime(endsAt);
    final displayImage = (vibeCoverUrl.isNotEmpty)
        ? vibeCoverUrl
        : user.imageUrl;

    showDialog(
      context: context,
      animationStyle: AnimationStyle(curve: Curves.easeInOut),
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: displayImage,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 56,
                      height: 56,
                      color: Colors.grey[200],
                    ),
                    errorWidget: (_, __, ___) => CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(user.imageUrl),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.titleCase,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vibeTitle,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    if (remaining.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Expires in $remaining',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
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
      builder: (_) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
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
                Stack(
                  children: [
                    GestureDetector(
                      onTap: hasVibe
                          ? () => _openFullImage(user.imageUrl, context)
                          : () {
                              if (user.isWaved == true) {
                                context.pushNamed(
                                  RouteNames.profileScreen,
                                  extra: user.id,
                                );
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
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundImage: NetworkImage(user.imageUrl),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // --- Mood badge removed per user request ---
                // SizedBox(height: 12.h),
                // Container(
                //   padding: EdgeInsets.symmetric(
                //     vertical: 12.w,
                //     horizontal: 18.w,
                //   ),
                //   decoration: BoxDecoration(
                //     color: Colors.grey.shade200,
                //     borderRadius: BorderRadius.circular(24.r),
                //   ),
                //   child: Text(
                //     AppLocalizations.of(context).translate('sundayCoffeeVibes'),
                //     textAlign: TextAlign.center,
                //     style: const TextStyle(fontSize: 13, color: Colors.black),
                //   ),
                // ),
                const SizedBox(height: 12),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
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
                      "• ${user.distanceKm} ${AppLocalizations.of(context).translate('km')} ${AppLocalizations.of(context).translate('away')}",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                              content: '${AppLocalizations.of(context).translate('waveSent')} ${user.name}',
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
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
                                  user.isWaved == true
                                      ? AppLocalizations.of(
                                          context,
                                        ).translate('waved')
                                      : AppLocalizations.of(
                                          context,
                                        ).translate('wave'),
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

  /// Calculate remaining time from an ISO ends_at string.
  /// Returns "2h", "1h 30m", "45m", or "Expired".
  String _formatRemainingTime(String? endsAt) {
    if (endsAt == null || endsAt.isEmpty) return '';
    try {
      // Normalize space separator to ISO 8601 'T' separator
      final normalized = endsAt.contains(' ')
          ? endsAt.replaceFirst(' ', 'T')
          : endsAt;
      final end = DateTime.parse(normalized);
      final now = DateTime.now().toUtc();
      final diff = end.difference(now);

      if (diff.isNegative)
        return AppLocalizations.of(context).translate('expired');

      final hours = diff.inHours;
      final minutes = diff.inMinutes.remainder(60);

      if (hours > 0 && minutes > 0) {
        return '${hours}h ${minutes}m';
      } else if (hours > 0) {
        return '${hours}h';
      } else if (minutes > 0) {
        return '${minutes}m';
      } else {
        return AppLocalizations.of(context).translate('lessThan1m');
      }
    } catch (e) {
      return '';
    }
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

  // ─── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    String? currentMapStyle = isDarkMode ? _darkMapStyle : null;

    // Build markers from WS data whenever mapItems changes
    if (!_markersBuilt &&
        !_isBuildingMarkers &&
        homeController.mapItems.isNotEmpty) {
      _isBuildingMarkers = true;
      _buildDynamicMarkers();
    }

    Widget buildWidget = SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          GoogleMap(
            style: currentMapStyle,
            onTap: _handleTap,
            markers: {..._markers, ...markers},
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
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            spacing: 5.w,
            children: [
              Assets.icons.creationStar.svg(width: 18.w, height: 18.h),
              Text(
                AppLocalizations.of(context).translate('allVibes'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
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
}
