import 'package:get/get.dart';
import 'package:vibe_now/model/nearby_user.dart';

class HomeController extends GetxController {
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
}
