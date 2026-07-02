import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:vibe_now/core/constant/api_constant.dart';
import 'package:vibe_now/model/map_item.dart';
import 'package:vibe_now/model/nearby_user.dart';
import 'package:vibe_now/services/custom_http.dart';
import 'package:vibe_now/services/local_storage.dart';
import 'package:vibe_now/services/map_socket_service.dart';

class HomeController extends GetxController {
  final MapSocketService _mapSocket = MapSocketService.instance;

  // Current user location
  final Rxn<double> currentLatitude = Rxn<double>();
  final Rxn<double> currentLongitude = Rxn<double>();

  // Map items from WebSocket
  final RxList<MapItem> mapItems = <MapItem>[].obs;
  final RxBool isMapLoading = false.obs;

  // Hardcoded nearby users (for existing wave/profile dialogs)
  final List<NearbyUser> nearbyUsers = [
    NearbyUser(
      id: 'u1',
      name: 'Jhon Gomes',
      imageUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      bio: 'Coffee lover ☕ | Weekend explorer | Always down for deep talks',
      interest: 'Coffee & Music',
      distanceKm: 0.3,
      lat: 23.780887,
      lng: 90.279237,
      isWaved: false,
    ),
    NearbyUser(
      id: 'u2',
      name: 'Ariana Lewis',
      imageUrl:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
      bio: 'Yoga, sunsets, and good energy 🌿',
      interest: 'Wellness',
      distanceKm: 0.7,
      lat: 23.781912,
      lng: 90.280541,
      isWaved: true,
    ),
    NearbyUser(
      id: 'u3',
      name: 'Jhon Gomes',
      imageUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
      bio: 'Coffee lover ☕ | Weekend explorer | Always down for deep talks',
      interest: 'Coffee & Music',
      distanceKm: 0.3,
      lat: 23.780887,
      lng: 90.279237,
      isWaved: false,
    ),
    NearbyUser(
      id: 'u4',
      name: 'Daniel Cruz',
      imageUrl:
          'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=400',
      bio: 'Tech by day, guitarist by night 🎸',
      interest: 'Music & Tech',
      distanceKm: 1.2,
      lat: 23.779421,
      lng: 90.277843,
      isWaved: true,
    ),
    NearbyUser(
      id: 'u5',
      name: 'Maya Chen',
      imageUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400',
      bio: 'Photography addict 📸 | Capturing small moments',
      interest: 'Photography',
      distanceKm: 1.8,
      lat: 23.782334,
      lng: 90.281992,
      isWaved: false,
    ),
    NearbyUser(
      id: 'u5',
      name: 'Maya Chen',
      imageUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400',
      bio: 'Photography addict 📸 | Capturing small moments',
      interest: 'Photography',
      distanceKm: 1.8,
      lat: 23.782334,
      lng: 90.281992,
      isWaved: false,
    ),
    NearbyUser(
      id: 'u5',
      name: 'Maya Chen',
      imageUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400',
      bio: 'Photography addict 📸 | Capturing small moments',
      interest: 'Photography',
      distanceKm: 1.8,
      lat: 23.782334,
      lng: 90.281992,
      isWaved: false,
    ),
    NearbyUser(
      id: 'u5',
      name: 'Maya Chen',
      imageUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400',
      bio: 'Photography addict 📸 | Capturing small moments',
      interest: 'Photography',
      distanceKm: 1.8,
      lat: 23.782334,
      lng: 90.281992,
      isWaved: false,
    ),
  ];

  @override
  void onClose() {
    _mapSocket.disconnect();
    super.onClose();
  }

  Future<Position?> loadMapData({
    String type = 'all',
    String search = '',
    int radius = 50,
  }) async {
    isMapLoading(true);

    // Get user location
    final Position? position = await _determinePosition();
    if (position != null) {
      currentLatitude.value = position.latitude;
      currentLongitude.value = position.longitude;
      // Save to local storage for next launch
      await LocalStorage.last_latitude.set(position.latitude);
      await LocalStorage.last_longitude.set(position.longitude);
    }

    // Fallback if no location: use stored, then hardcoded default
    double lat =
        currentLatitude.value ??
        (await LocalStorage.last_latitude.get()) ??
        23.8103;
    double lng =
        currentLongitude.value ??
        (await LocalStorage.last_longitude.get()) ??
        90.4125;

    // Set up WS callback
    _mapSocket.onItemsReceived = (response) {
      mapItems.assignAll(response.results);
      isMapLoading(false);
    };
    _mapSocket.onError = (error) {
      debugPrint('Map WS error: $error');
      isMapLoading(false);
    };

    // Connect and send
    final connected = await _mapSocket.connect();
    if (connected) {
      // Small delay to ensure connection is established
      await Future.delayed(const Duration(milliseconds: 300));
      _mapSocket.sendLocation(
        latitude: lat,
        longitude: lng,
        type: type,
        search: search,
        radius: radius,
      );
    } else {
      isMapLoading(false);
    }

    // Notify backend of current location (fire & forget in background)
    _notifyCurrentLocation(lat, lng);

    return position;
  }

  Future<Position?> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  /// Refresh map data with current location
  Future<void> refreshMapData() async {
    await loadMapData();
  }

  /// Notify backend of current location (fire & forget in background)
  Future<void> _notifyCurrentLocation(double lat, double lng) async {
    try {
      // Default location name from coordinates
      String locationName =
          "${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}";

      // Try to reverse-geocode for a proper location name
      try {
        final placemarks = await placemarkFromCoordinates(lat, lng)
            .timeout(const Duration(seconds: 5));
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final city =
              p.locality ??
              p.subAdministrativeArea ??
              p.administrativeArea ??
              "";
          final country = p.country ?? "";
          if (city.isNotEmpty && country.isNotEmpty) {
            locationName = "$city, $country";
          } else if (city.isNotEmpty) {
            locationName = city;
          } else if (country.isNotEmpty) {
            locationName = country;
          }
        }
      } catch (e) {
        debugPrint('Geocoding for location notify failed: $e');
        // Fall back to coordinates as location name
      }

      await sendCurrentLocation(
        latitude: lat,
        longitude: lng,
        locationName: locationName,
      );
    } catch (e) {
      debugPrint('Error notifying current location: $e');
    }
  }

  // current location notify
  Future<bool> sendCurrentLocation({
    required double latitude,
    required double longitude,
    required String locationName,
  }) async {
    try {
      final response = await CustomHttp.post(
        endpoint: ApiConstant.currentLocation,
        body: {
          "current_latitude": latitude,
          "current_longitude": longitude,
          "current_location_name": locationName,
        },
      );
      return response.ok;
    } catch (e) {
      debugPrint('Error sending current location: $e');
      return false;
    }
  }
}
