import 'package:flutter/material.dart';
import 'package:vibe_now/core/constant/api_constant.dart';
import 'package:vibe_now/model/incoming_wave.dart';
import 'package:vibe_now/services/custom_http.dart';

import 'package:get/get.dart';

class WaveController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isWavesLoading = false.obs;
  final RxList<IncomingWave> incomingWaves = <IncomingWave>[].obs;

  // ── Wave list ────────────────────────────────

  Future<void> getWaves() async {
    isWavesLoading(true);
    final response = await CustomHttp.get(
      need_auth: true,
      endpoint: ApiConstant.waves,
      // queries: {'status': status},
    );

    if (response.ok) {
      final data = response.data['data'];
      final results = data['results'] as List? ?? [];
      incomingWaves.assignAll(
        results.map((e) => IncomingWave.fromJson(e as Map<String, dynamic>)),
      );
    } else {
      debugPrint('Error fetching waves: ${response.error}');
    }
    isWavesLoading(false);
  }

  // ── Wave action (accept / reject) ────────────

  Future<bool> waveAction({required int waveId, required String action}) async {
    isLoading(true);
    final response = await CustomHttp.post(
      need_auth: true,
      endpoint: ApiConstant.waveOperation(waveId: waveId),
      body: {'action': action},
    );
    isLoading(false);
    return response.ok;
  }

  // ── Suggest meetup (now) ─────────────────────

  Future<bool> suggestMeetup({
    required int waveId,
    required String meetupType,
    required String locationType,
    required String latitude,
    required String longitude,
    required String address,
  }) async {
    isLoading(true);
    final response = await CustomHttp.post(
      need_auth: true,
      endpoint: ApiConstant.waveMeetup(waveId: waveId),
      body: {
        "meetup_type": meetupType,
        "location_type":
            locationType, // "creator_location" | "midpoint", "custom"
        "latitude": latitude,
        "longitude": longitude,
        "address": address,
      },
    );
    isLoading(false);
    return response.ok;
  }

  // ── Meetup reschedule (later) ────────────────

  Future<bool> meetupReschedule({
    required int waveId,
    required String meetupType,
    required String locationType,
    required String latitude,
    required String longitude,
    required String address,
    required String reason,
    required String requestedAt,
  }) async {
    isLoading(true);
    final response = await CustomHttp.post(
      need_auth: true,
      endpoint: ApiConstant.waveMeetup(waveId: waveId),
      body: {
        "meetup_type": meetupType,
        "location_type":
            locationType, // "creator_location" | "midpoint", "custom"
        "latitude": latitude,
        "longitude": longitude,
        "address": address,
        "scheduled_at": requestedAt,
      },
    );
    isLoading(false);
    return response.ok;
  }
}
