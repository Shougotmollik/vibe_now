class IncomingWave {
  final int waveId;
  final String waveType;
  final String status;
  final String createdAt;
  final WaveVibe? vibe;
  final WaveSender sender;
  final WaveSender? receiver;
  final int? distanceInMeters;
  final String? distanceText;
  final WaveMeetup? meetup;
  final String? qrCodeValue;
  final String? qrCodeImage;

  IncomingWave({
    required this.waveId,
    required this.waveType,
    required this.status,
    required this.createdAt,
    this.vibe,
    required this.sender,
    this.receiver,
    this.distanceInMeters,
    this.distanceText,
    this.meetup,
    this.qrCodeValue,
    this.qrCodeImage,
  });

  factory IncomingWave.fromJson(Map<String, dynamic> json) => IncomingWave(
        waveId: json['wave_id'],
        waveType: json['wave_type'] ?? '',
        status: json['status'] ?? '',
        createdAt: json['created_at'] ?? '',
        vibe: json['vibe'] != null
            ? WaveVibe.fromJson(json['vibe'])
            : null,
        sender: WaveSender.fromJson(json['sender']),
        receiver: json['receiver'] != null
            ? WaveSender.fromJson(json['receiver'])
            : null,
        distanceInMeters: json['distance_in_meters'],
        distanceText: json['distance_text'],
        meetup: json['meetup'] != null
            ? WaveMeetup.fromJson(json['meetup'])
            : null,
        qrCodeValue: json['qr_code_value'],
        qrCodeImage: json['qr_code_image'],
      );
}

class WaveVibe {
  final int id;
  final String? title;
  final String status;
  final String? qrCodeValue;
  final String? qrCodeImage;

  WaveVibe({
    required this.id,
    this.title,
    required this.status,
    this.qrCodeValue,
    this.qrCodeImage,
  });

  factory WaveVibe.fromJson(Map<String, dynamic> json) => WaveVibe(
        id: json['id'],
        title: json['title'],
        status: json['status'] ?? '',
        qrCodeValue: json['qr_code_value'],
        qrCodeImage: json['qr_code_image'],
      );
}

class WaveLocation {
  final double? latitude;
  final double? longitude;
  final String? locationName;

  WaveLocation({this.latitude, this.longitude, this.locationName});

  factory WaveLocation.fromJson(Map<String, dynamic> json) => WaveLocation(
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        locationName: json['location_name'],
      );
}

class WaveSender {
  final String id;
  final String email;
  final String fullName;
  final String avatar;
  final WaveLocation? currentLocation;
  final int? toMeetupDistanceInMeters;
  final String? toMeetupDistanceText;

  WaveSender({
    required this.id,
    required this.email,
    required this.fullName,
    required this.avatar,
    this.currentLocation,
    this.toMeetupDistanceInMeters,
    this.toMeetupDistanceText,
  });

  factory WaveSender.fromJson(Map<String, dynamic> json) => WaveSender(
        id: json['id'] ?? '',
        email: json['email'] ?? '',
        fullName: json['full_name'] ?? '',
        avatar: json['avatar'] ?? '',
        currentLocation: json['current_location'] != null
            ? WaveLocation.fromJson(json['current_location'])
            : null,
        toMeetupDistanceInMeters: json['to_meetup_distance_in_meters'],
        toMeetupDistanceText: json['to_meetup_distance_text'],
      );
}

class WaveMeetup {
  final int? id;
  final String? meetupType;
  final String? locationType;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? scheduledAt;
  final String? status;
  final String? createdAt;

  WaveMeetup({
    this.id,
    this.meetupType,
    this.locationType,
    this.latitude,
    this.longitude,
    this.address,
    this.scheduledAt,
    this.status,
    this.createdAt,
  });

  factory WaveMeetup.fromJson(Map<String, dynamic> json) => WaveMeetup(
        id: json['id'],
        meetupType: json['meetup_type'],
        locationType: json['location_type'],
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        address: json['address'],
        scheduledAt: json['scheduled_at'],
        status: json['status'],
        createdAt: json['created_at'],
      );
}
