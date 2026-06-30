class VibeModel {
  final bool? success;
  final String? message;
  final VibeData? data;

  VibeModel({
    this.success,
    this.message,
    this.data,
  });

  factory VibeModel.fromJson(Map<String, dynamic> json) => VibeModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : VibeData.fromJson(json["data"]),
      );
}

class VibeData {
  final int? total;
  final int? page;
  final int? pageSize;
  final int? totalPages;
  final Vibe? ownVibe;
  final List<Vibe>? othersVibe;

  VibeData({
    this.total,
    this.page,
    this.pageSize,
    this.totalPages,
    this.ownVibe,
    this.othersVibe,
  });

  factory VibeData.fromJson(Map<String, dynamic> json) => VibeData(
        total: json["total"],
        page: json["page"],
        pageSize: json["page_size"],
        totalPages: json["total_pages"],
        ownVibe: json["own_vibe"] == null ? null : Vibe.fromJson(json["own_vibe"]),
        othersVibe: json["others_vibe"] == null
            ? []
            : List<Vibe>.from(json["others_vibe"]!.map((x) => Vibe.fromJson(x))),
      );
}

class Vibe {
  final int? id;
  final String? title;
  final String? duration;
  final String? coverImage;
  final String? status;
  final DateTime? startedAt;
  final DateTime? endsAt;
  final dynamic endedAt;
  final CreatedBy? createdBy;
  final DateTime? createdAt;
  final bool hasSentWave;
  final String? waveStatus;

  Vibe({
    this.id,
    this.title,
    this.duration,
    this.coverImage,
    this.status,
    this.startedAt,
    this.endsAt,
    this.endedAt,
    this.createdBy,
    this.createdAt,
    this.hasSentWave = false,
    this.waveStatus,
  });

  factory Vibe.fromJson(Map<String, dynamic> json) => Vibe(
        id: json["id"],
        title: json["title"],
        duration: json["duration"],
        coverImage: json["cover_image"],
        status: json["status"],
        startedAt: json["started_at"] == null
            ? null
            : DateTime.parse(json["started_at"]),
        endsAt:
            json["ends_at"] == null ? null : DateTime.parse(json["ends_at"]),
        endedAt: json["ended_at"],
        createdBy: json["created_by"] == null
            ? null
            : CreatedBy.fromJson(json["created_by"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        hasSentWave: json["has_sent_wave"] ?? false,
        waveStatus: json["wave_status"],
      );
}

class CreatedBy {
  final String? id;
  final String? email;
  final String? fullName;
  final String? avatar;

  CreatedBy({
    this.id,
    this.email,
    this.fullName,
    this.avatar,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
        id: json["id"],
        email: json["email"],
        fullName: json["full_name"],
        avatar: json["avatar"],
      );
}
