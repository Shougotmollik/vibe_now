import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:vibe_now/core/constant/api_constant.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/services/local_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class _SocketEntry {
  WebSocketChannel channel;
  Stream<dynamic> broadcastStream;
  int refCount;

  _SocketEntry({
    required this.channel,
    required this.broadcastStream,
    this.refCount = 0,
  });
}

class WebSocketRegistry {
  WebSocketRegistry._();
  static final WebSocketRegistry instance = WebSocketRegistry._();

  final Map<String, _SocketEntry> _sockets = {};

  Future<Stream<dynamic>> acquire(String conversationId) async {
    if (_sockets.containsKey(conversationId)) {
      _sockets[conversationId]!.refCount++;
      return _sockets[conversationId]!.broadcastStream;
    }

    final token = await LocalStorage.access_token.get();
    final domain = AppCredentials.domain;

    final encodedToken = token != null ? Uri.encodeQueryComponent(token) : '';
    String url = '$domain${ApiConstant.chatSocket}$conversationId?token=$encodedToken';
    if (url.startsWith('https://')) {
      url = url.replaceFirst('https://', 'wss://');
    } else if (url.startsWith('http://')) {
      url = url.replaceFirst('http://', 'ws://');
    }

    final channel = WebSocketChannel.connect(Uri.parse(url));
    final broadcastStream = channel.stream.map((event) {
      debugPrint('📥 WS[$conversationId]: $event');
      return event;
    }).asBroadcastStream();

    _sockets[conversationId] = _SocketEntry(
      channel: channel,
      broadcastStream: broadcastStream,
      refCount: 1,
    );
    debugPrint('✅ WS connected: $conversationId');
    return broadcastStream;
  }

  void send(String conversationId, Map<String, dynamic> data) {
    final entry = _sockets[conversationId];
    if (entry != null) {
      entry.channel.sink.add(jsonEncode(data));
      debugPrint('📡 WS[$conversationId] >> $data');
    } else {
      debugPrint('⚠️ WS: no socket for $conversationId');
    }
  }

  void release(String conversationId) {
    final entry = _sockets[conversationId];
    if (entry == null) return;
    entry.refCount--;
    if (entry.refCount <= 0) {
      entry.channel.sink.close();
      _sockets.remove(conversationId);
      debugPrint('🔌 WS disconnected: $conversationId');
    }
  }
}
