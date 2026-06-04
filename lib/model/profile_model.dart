import 'package:vibe_now/core/constant/credential.dart';

class ProfilePhoto {
  final int id;
  final String image;
  final bool isPrimary;
  final String createdAt;

  ProfilePhoto({
    required this.id,
    required this.image,
    required this.isPrimary,
    required this.createdAt,
  });

  String get fullUrl => AppCredentials.fixurl(image);

  factory ProfilePhoto.fromJson(Map<String, dynamic> json) {
    return ProfilePhoto(
      id: json['id'] ?? 0,
      image: json['image'] ?? '',
      isPrimary: json['is_primary'] ?? false,
      createdAt: json['created_at'] ?? '',
    );
  }
}

class TrustedScore {
  final double score;
  final int meetsCount;

  TrustedScore({required this.score, required this.meetsCount});

  factory TrustedScore.fromJson(Map<String, dynamic> json) {
    return TrustedScore(
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      meetsCount: json['meets_count'] ?? 0,
    );
  }
}

class UserProfile {
  final String userId;
  final String email;
  final String fullName;
  final String bio;
  final String? dateOfBirth;
  final String? gender;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final bool onboardingCompleted;
  final ProfilePhoto? primaryPhoto;
  final List<String> whatAreYouLookingFor;
  final List<String> interests;
  final List<ProfilePhoto> photos;
  final TrustedScore? trustedScore;
  final String createdAt;
  final String updatedAt;

  UserProfile({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.bio,
    this.dateOfBirth,
    this.gender,
    this.latitude,
    this.longitude,
    this.locationName,
    required this.onboardingCompleted,
    this.primaryPhoto,
    required this.whatAreYouLookingFor,
    required this.interests,
    required this.photos,
    this.trustedScore,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      bio: json['bio'] ?? '',
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationName: json['location_name'],
      onboardingCompleted: json['onboarding_completed'] ?? false,
      primaryPhoto: json['primary_photo'] != null
          ? ProfilePhoto.fromJson(json['primary_photo'])
          : null,
      whatAreYouLookingFor: (json['what_are_you_looking_for'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      interests: (json['interests'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      photos: (json['photos'] as List? ?? [])
          .map((e) => ProfilePhoto.fromJson(e))
          .toList(),
      trustedScore: json['trusted_score'] != null
          ? TrustedScore.fromJson(json['trusted_score'])
          : null,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class UserAccount {
  final String id;
  final String email;
  final String role;
  final bool isVerified;
  final bool isActive;
  final UserProfile profile;

  UserAccount({
    required this.id,
    required this.email,
    required this.role,
    required this.isVerified,
    required this.isActive,
    required this.profile,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      isVerified: json['is_verified'] ?? false,
      isActive: json['is_active'] ?? false,
      profile: UserProfile.fromJson(json['profile'] ?? {}),
    );
  }
}
