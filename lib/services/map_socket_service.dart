import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/model/map_item.dart';
import 'package:vibe_now/services/local_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MapSocketService {
  MapSocketService._();
  static final MapSocketService instance = MapSocketService._();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;

  bool get isConnected => _channel != null;

  void Function(MapItemsResponse response)? onItemsReceived;
  void Function(String error)? onError;

  Future<bool> connect() async {
    disconnect();

    final token = await LocalStorage.access_token.get();
    if (token == null || token.isEmpty) return false;

    final domain = AppCredentials.domain;
    final encodedToken = Uri.encodeQueryComponent(token);
    String url = '$domain/ws/maps?token=$encodedToken';
    if (url.startsWith('https://')) {
      url = url.replaceFirst('https://', 'wss://');
    } else if (url.startsWith('http://')) {
      url = url.replaceFirst('http://', 'ws://');
    }

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _subscription = _channel!.stream.listen(
        (raw) {
          debugPrint('📥 WS[map]: $raw');
          try {
            final decoded = jsonDecode(raw as String) as Map<String, dynamic>;
            final response = MapItemsResponse.fromJson(decoded);
            if (response.success) {
              onItemsReceived?.call(response);
            } else {
              onError?.call(response.message ?? 'Unknown error');
            }
          } catch (e) {
            debugPrint('⚠️ WS[map] parse error: $e');
            onError?.call('Failed to parse map data: $e');
          }
        },
        onError: (e) {
          debugPrint('⚠️ WS[map] error: $e');
          onError?.call('WebSocket error: $e');
        },
        onDone: () {
          debugPrint('🔌 WS[map] disconnected');
          _channel = null;
        },
      );
      debugPrint('✅ WS[map] connected');
      return true;
    } catch (e) {
      debugPrint('❌ WS[map] connect failed: $e');
      onError?.call('Failed to connect: $e');
      return false;
    }
  }

  void sendLocation({
    required double latitude,
    required double longitude,
    String type = 'all',
    String search = '',
    int radius = 50,
  }) {
    if (_channel == null) {
      debugPrint('⚠️ WS[map] not connected, cannot send');
      return;
    }
    final data = {
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
      'search': search,
      'radius': radius,
    };
    _channel!.sink.add(jsonEncode(data));
    debugPrint('📡 WS[map] >> $data');
  }

  void disconnect() {
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    debugPrint('🔌 WS[map] fully disconnected');
  }
}
