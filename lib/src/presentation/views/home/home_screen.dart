import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/community.dart';
import 'package:vibe_now/model/event.dart';
import 'package:vibe_now/src/presentation/views/community/widgets/community_card.dart';
import 'package:vibe_now/src/presentation/views/event/event_card.dart';
import 'package:vibe_now/src/presentation/views/home/widgets/cloud_container.dart';
import 'package:vibe_now/src/presentation/views/home/widgets/community_location_pin.dart';
import 'package:vibe_now/src/presentation/views/home/widgets/event_location_pin.dart';
import 'package:vibe_now/src/presentation/views/home/widgets/filter_dialog.dart';
import 'package:vibe_now/src/presentation/views/home/widgets/user_location_pin.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

class NearbyUser {
  final String id;
  final String name;
  final String imageUrl;
  final String bio;
  final String interest;
  final double distanceKm;
  final double lat;
  final double lng;
  bool? isWaved;

  NearbyUser({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.bio,
    required this.interest,
    required this.distanceKm,
    required this.lat,
    required this.lng,
    this.isWaved,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _MapHomeScreenState();
}

class _MapHomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _mapController = Completer<GoogleMapController>();
  late AnimationController _pulseController;

  final Set<Marker> _markers = {};

  final LatLng _currentLocation = const LatLng(
    50.93747315706174,
    6.953134027839385,
  );

  String? mapTheme;
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
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    DefaultAssetBundle.of(context).loadString(Assets.mapTheme.pinkTheme).then((
      themeValue,
    ) {
      mapTheme = themeValue;
    });

    _loadMarkers();
    Future.delayed(const Duration(seconds: 2), () {
      _loadMarkers();
    });
  }

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
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openEventPopUp() {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: EventCard(
              event: Event(
                name: 'Club House',
                location: '123 Main St, New York, NY 10001',
                date: '21 Nov',
                time: '8PM - 11PM',
                description: '10 Interested • 16 Going',
                image:
                    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800',
                attending: '5',
                totalAttending: '10',
                isJoined: false,
                isMyEvent: false,
                accessType: EventAccessType.private,
              ),
            ),
          ),
        );
      },
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
          showUserProfileDialog(context, nearbyUsers[0], hasVibe: true);
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
            ).toBitmapDescriptor(
              logicalSize: const Size(300, 300),
              imageSize: const Size(300, 300),
            ),
        onTap: () {
          showUserProfileDialog(context, nearbyUsers[1]);
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
          showUserProfileDialog(context, nearbyUsers[3], hasVibe: true);
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
            ).toBitmapDescriptor(
              logicalSize: const Size(300, 300),
              imageSize: const Size(300, 300),
            ),
        onTap: () {
          showUserProfileDialog(context, nearbyUsers[4]);
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
                          // Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: user.isWaved == true
                                ? Color(0xffC4A8FF)
                                : null,
                            gradient: user.isWaved == true
                                ? null
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

  LatLng _offsetToLatLng(LatLng center, double dx, double dy) {
    // Rough conversion: 1 degree ≈ 111km
    // At zoom 14, adjust these values based on your needs
    const double metersPerPixel = 10.0; // Adjust this value
    final double latOffset = (dy * metersPerPixel) / 111000;
    final double lngOffset =
        (dx * metersPerPixel) / (111000 * 0.9); // Adjust for latitude

    return LatLng(center.latitude + latOffset, center.longitude + lngOffset);
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
              spacing: 8.w,
              children: [
                GestureDetector(
                  onTap: () => context.pushNamed(RouteNames.notificationScreen),
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Assets.icons.notification.svg(
                        width: 20.w,
                        height: 20.h,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Container(
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: TextField(
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          border: InputBorder.none,
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
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
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Assets.icons.filter.svg(width: 16.w, height: 16.h),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // _buildUserPulse(),

          // _buildMarkers(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: _currentLocation, zoom: 14),
      myLocationEnabled: false,
      zoomControlsEnabled: false,
      markers: _markers,
      onMapCreated: (controller) {
        controller.setMapStyle(mapTheme);
        _mapController.complete(controller);
      },
    );
  }

  // Widget _buildUserPulse() {
  //   return Center(
  //     child: AnimatedBuilder(
  //       animation: _pulseController,
  //       builder: (context, child) {
  //         final size = 120 + (_pulseController.value * 80);

  //         return Container(
  //           width: size,
  //           height: size,
  //           decoration: BoxDecoration(
  //             shape: BoxShape.circle,
  //             color: Colors.blue.withValues(alpha: 0.15),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }
}

class CustomMarker extends StatefulWidget {
  const CustomMarker({super.key});

  @override
  State<CustomMarker> createState() => _CustomMarkerState();
}

class _CustomMarkerState extends State<CustomMarker>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
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
    );
  }
}
