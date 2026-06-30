class IncomingWave {
  final int waveId;
  final String status;
  final String createdAt;
  final WaveVibe vibe;
  final WaveSender sender;
  final dynamic meetup;

  IncomingWave({
    required this.waveId,
    required this.status,
    required this.createdAt,
    required this.vibe,
    required this.sender,
    this.meetup,
  });

  factory IncomingWave.fromJson(Map<String, dynamic> json) => IncomingWave(
        waveId: json['wave_id'],
        status: json['status'] ?? '',
        createdAt: json['created_at'] ?? '',
        vibe: WaveVibe.fromJson(json['vibe']),
        sender: WaveSender.fromJson(json['sender']),
        meetup: json['meetup'],
      );
}

class WaveVibe {
  final int id;
  final String title;
  final String status;
  final String? qrCodeValue;
  final String? qrCodeImage;

  WaveVibe({
    required this.id,
    required this.title,
    required this.status,
    this.qrCodeValue,
    this.qrCodeImage,
  });

  factory WaveVibe.fromJson(Map<String, dynamic> json) => WaveVibe(
        id: json['id'],
        title: json['title'] ?? '',
        status: json['status'] ?? '',
        qrCodeValue: json['qr_code_value'],
        qrCodeImage: json['qr_code_image'],
      );
}

class WaveSender {
  final String id;
  final String email;
  final String fullName;
  final String avatar;

  WaveSender({
    required this.id,
    required this.email,
    required this.fullName,
    required this.avatar,
  });

  factory WaveSender.fromJson(Map<String, dynamic> json) => WaveSender(
        id: json['id'] ?? '',
        email: json['email'] ?? '',
        fullName: json['full_name'] ?? '',
        avatar: json['avatar'] ?? '',
      );
}
