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
  bool? hasSentWave;
  bool? isLocked;

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
    this.hasSentWave,
    this.isLocked,
  });
}