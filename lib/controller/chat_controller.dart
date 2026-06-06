import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_now/core/constant/api_constant.dart';
import 'package:vibe_now/model/chat.dart';
import 'package:vibe_now/model/chat_message.dart';
import 'package:vibe_now/services/custom_http.dart';
import 'package:vibe_now/services/web_socket_registry.dart';

class ChatController extends GetxController {
  var isLoading = false.obs;

  final RxMap<String, bool> loadingTabs = <String, bool>{
    'event': false,
    'community': false,
    'private': false,
  }.obs;

  final RxList<Chat> eventChats = <Chat>[].obs;
  final RxList<Chat> communityChats = <Chat>[].obs;
  final RxList<Chat> privateChats = <Chat>[].obs;

  final RxList<ChatMessage> chatMessages = <ChatMessage>[].obs;

  StreamSubscription<dynamic>? _wsSubscription;
  String? _activeChatId;

  bool isLoadingTab(String tab) => loadingTabs[tab] ?? false;

  RxList<Chat> chatsForTab(String tab) {
    switch (tab) {
      case 'event':
        return eventChats;
      case 'community':
        return communityChats;
      case 'private':
        return privateChats;
      default:
        return privateChats;
    }
  }

  @override
  void onClose() {
    disconnectFromChat();
    super.onClose();
  }

  // ── Chat list ─────────────────────────────────

  Future<void> getChatList({
    required String type,
    int page = 1,
    int pageSize = 50,
    bool refresh = true,
  }) async {
    loadingTabs[type] = true;
    final response = await CustomHttp.get(
      need_auth: true,
      endpoint: ApiConstant.chat,
      queries: {
        'type': type,
        'page': page.toString(),
        'page_size': pageSize.toString(),
      },
    );

    if (response.ok) {
      final results = response.data;
      final chats = List<Chat>.from(
        results.map((e) => Chat.fromJson(e as Map<String, dynamic>)),
      );
      final list = chatsForTab(type);
      if (refresh) {
        list.assignAll(chats);
      } else {
        list.addAll(chats);
      }
    } else {
      debugPrint('Error fetching chat list ($type): ${response.error}');
    }
    loadingTabs[type] = false;
  }

  // ── Message history ──────────────────────────

  Future<void> getChatHistory({required String chatId}) async {
    isLoading(true);
    final response = await CustomHttp.get(
      need_auth: true,
      endpoint: "${ApiConstant.chat}/$chatId/messages",
    );

    if (response.ok) {
      final raw = response.data;
      final list = raw is List
          ? raw
          : (raw['data'] is List
                ? raw['data']
                : (raw['results'] is List
                      ? raw['results']
                      : (raw['data']?['results'] is List
                            ? raw['data']['results']
                            : <dynamic>[])));
      chatMessages.assignAll(
        List<ChatMessage>.from(list.map((e) => ChatMessage.fromJson(e))),
      );
    } else {
      debugPrint('Error fetching chat history: ${response.error}');
    }
    isLoading(false);
  }

  // ── Send message (text / file / voice) ───────

  Future<CustomHttpResult> sendTextMessage({
    required String chatId,
    required String content,
  }) async {
    final result = await CustomHttp.post(
      need_auth: true,
      endpoint: "${ApiConstant.chat}/$chatId/messages",
      body: {'content': content},
    );
    if (result.ok) {
      final msg = ChatMessage.fromJson(result.data);
      final exists = chatMessages.any((m) => m.id == msg.id);
      if (!exists) chatMessages.insert(0, msg);
    }
    return result;
  }

  Future<CustomHttpResult> sendVoiceMessage({
    required String chatId,
    required String voicePath,
  }) async {
    final result = await CustomHttp.multipart(
      endpoint: "${ApiConstant.chat}/$chatId/messages",
      fieldName: 'voice',
      filePath: voicePath,
      method: 'POST',
      need_auth: true,
    );
    if (result.ok) {
      final msg = ChatMessage.fromJson(result.data);
      final exists = chatMessages.any((m) => m.id == msg.id);
      if (!exists) chatMessages.insert(0, msg);
    }
    return result;
  }

  Future<CustomHttpResult> sendFileMessage({
    required String chatId,
    required String filePath,
    String? content,
  }) async {
    final fields = <String, String>{};
    if (content != null) fields['content'] = content;

    final result = await CustomHttp.multipart(
      endpoint: "${ApiConstant.chat}/$chatId/messages",
      fieldName: 'file',
      filePath: filePath,
      fields: fields.isNotEmpty ? fields : null,
      method: 'POST',
      need_auth: true,
    );
    if (result.ok) {
      final msg = ChatMessage.fromJson(result.data);
      final exists = chatMessages.any((m) => m.id == msg.id);
      if (!exists) chatMessages.insert(0, msg);
    }
    return result;
  }

  // ── Mark as read ─────────────────────────────

  Future<void> markAsRead({
    required String chatId,
    required String messageId,
  }) async {
    await CustomHttp.post(
      need_auth: true,
      endpoint: "${ApiConstant.chat}/$chatId/messages/$messageId/read",
      body: {},
    );
  }

  // ── Reactions (sent via WebSocket) ───────────

  void sendReaction({
    required String chatId,
    required String messageId,
    required String reactionType,
  }) {
    WebSocketRegistry.instance.send(chatId, {
      'type': 'add_reaction',
      'message_id': messageId,
      'reaction': reactionType,
    });
  }

  // ── WebSocket ────────────────────────────────

  Future<void> connectToChat(String chatId) async {
    if (_activeChatId == chatId) return;
    disconnectFromChat();
    _activeChatId = chatId;

    try {
      final stream = await WebSocketRegistry.instance.acquire(chatId);
      _wsSubscription = stream.listen(
        _onWsEvent,
        onError: (e) => debugPrint('WS error [$chatId]: $e'),
        onDone: () => debugPrint('WS closed [$chatId]'),
      );
    } catch (e) {
      debugPrint('WS connect failed [$chatId]: $e');
    }
  }

  void disconnectFromChat() {
    _wsSubscription?.cancel();
    _wsSubscription = null;
    if (_activeChatId != null) {
      WebSocketRegistry.instance.release(_activeChatId!);
      _activeChatId = null;
    }
  }

  void sendTypingIndicator({required String chatId, required bool isTyping}) {
    WebSocketRegistry.instance.send(chatId, {
      'type': 'typing',
      'is_typing': isTyping,
    });
  }

  void _onWsEvent(dynamic raw) {
    try {
      final data = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = data['type'] as String?;

      switch (type) {
        case 'message':
          final msg = ChatMessage.fromJson(data);
          final exists = chatMessages.any((m) => m.id == msg.id);
          if (!exists) {
            chatMessages.insert(0, msg);
          }
          break;

        case 'reaction_added':
        case 'reaction_removed':
          if (_activeChatId != null) {
            getChatHistory(chatId: _activeChatId!);
          }
          break;

        case 'typing':
          debugPrint('User typing: $data');
          break;

        case 'user_status':
          debugPrint('User status: $data');
          break;

        default:
          debugPrint('WS unhandled event: $type');
      }
    } catch (e) {
      debugPrint('WS parse error: $e');
    }
  }
}
