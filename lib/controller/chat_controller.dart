import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_now/core/constant/api_constant.dart';
import 'package:vibe_now/model/chat.dart';
import 'package:vibe_now/model/chat_message.dart';
import 'package:vibe_now/model/incoming_wave.dart';
import 'package:vibe_now/services/custom_http.dart';
import 'package:vibe_now/services/local_storage.dart';
import 'package:vibe_now/services/web_socket_registry.dart';

class ChatController extends GetxController {
  var isLoading = false.obs;

  final RxMap<String, bool> loadingTabs = <String, bool>{
    'event': false,
    'community': false,
    'private': false,
    'waves': false,
  }.obs;

  final RxList<Chat> eventChats = <Chat>[].obs;
  final RxList<Chat> communityChats = <Chat>[].obs;
  final RxList<Chat> privateChats = <Chat>[].obs;
  final RxList<Chat> wavesChats = <Chat>[].obs;
  final RxList<IncomingWave> incomingWaves = <IncomingWave>[].obs;

  final RxList<ChatMessage> chatMessages = <ChatMessage>[].obs;

  final RxBool isOtherUserTyping = false.obs;
  final RxBool isOtherUserOnline = false.obs;
  String _currentUserId = '';

  StreamSubscription<dynamic>? _wsSubscription;
  String? _activeChatId;
  Timer? _typingDebounce;

  bool isLoadingTab(String tab) => loadingTabs[tab] ?? false;

  RxList<Chat> chatsForTab(String tab) {
    switch (tab) {
      case 'event':
        return eventChats;
      case 'community':
        return communityChats;
      case 'private':
        return privateChats;
      case 'waves':
        return wavesChats;
      default:
        return wavesChats;
    }
  }

  @override
  void onClose() {
    _typingDebounce?.cancel();
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

  // ── Incoming waves ──────────────────────────

  Future<void> getWaves() async {
    loadingTabs['waves'] = true;
    final response = await CustomHttp.get(
      need_auth: true,
      endpoint: ApiConstant.waves,
      queries: {'status': 'pending'},
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
    loadingTabs['waves'] = false;
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

  // ── Mark as read (via WebSocket) ────────────

  void _markMessageAsRead({required String chatId, required String messageId}) {
    WebSocketRegistry.instance.send(chatId, {
      'type': 'read_message',
      'message_id': messageId,
    });
  }

  void markChatAsRead({required String chatId}) {
    Future.microtask(() async {
      final userId = await LocalStorage.user_id.get();
      if (userId == null || userId.isEmpty) return;

      final unread = chatMessages.where((m) {
        if (m.sender?.id == userId) return false;
        final reads = m.reads as List?;
        if (reads != null) {
          final alreadyRead = reads.any((r) {
            if (r is Map) return r['id'] == userId;
            return false;
          });
          if (alreadyRead) return false;
        }
        return true;
      }).toList();

      if (unread.isEmpty) return;

      for (final m in unread) {
        if (m.id != null) {
          _markMessageAsRead(chatId: chatId, messageId: m.id!);
        }
      }
    });
  }

  // ── Edit message (via WebSocket) ────────────
  void editMessage({
    required String chatId,
    required String messageId,
    required String content,
  }) {
    WebSocketRegistry.instance.send(chatId, {
      'type': 'edit_message',
      'message_id': messageId,
      'content': content,
    });
    // Optimistic update — server echoes back via message_edited
    final idx = chatMessages.indexWhere((m) => m.id == messageId);
    if (idx >= 0) {
      chatMessages[idx].content = content;
      chatMessages[idx].isEdited = true;
      chatMessages.refresh();
    }
  }

  // ── Delete message (via WebSocket) ───────────

  void deleteMessage({required String chatId, required String messageId}) {
    WebSocketRegistry.instance.send(chatId, {
      'type': 'delete_message',
      'message_id': messageId,
    });
    // Optimistic update — server echoes back via message_deleted
    final idx = chatMessages.indexWhere((m) => m.id == messageId);
    if (idx >= 0) {
      chatMessages[idx].isDeleted = true;
      chatMessages.refresh();
    }
  }

  //   Reactions (sent via WebSocket)
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

  //   WebSocket
  Future<void> connectToChat(String chatId) async {
    if (_activeChatId == chatId) return;
    disconnectFromChat();
    _activeChatId = chatId;
    _currentUserId = (await LocalStorage.user_id.get()) ?? '';

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
    _typingDebounce?.cancel();
    isOtherUserTyping.value = false;
    isOtherUserOnline.value = false;
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

  // WS event handlers
  void _handleMessageRead(Map<String, dynamic> data) {
    final messageId = data['message_id'] as String?;
    if (messageId == null) return;
    final idx = chatMessages.indexWhere((m) => m.id == messageId);
    if (idx < 0) return;

    final userId = data['user_id'] as String?;
    if (userId == null) return;

    final msg = chatMessages[idx];
    final reads = ((msg.reads as List?) ?? []).toList();

    // Check if this user already has a read entry
    final alreadyRead = reads.any((r) {
      if (r is Map) {
        final user = r['user'];
        if (user is Map) return user['id'] == userId;
        return r['id'] == userId;
      }
      return false;
    });

    if (!alreadyRead) {
      reads.add({
        'user': {'id': userId},
        'read_at':
            data['read_at'] as String? ??
            DateTime.now().toUtc().toIso8601String(),
      });
      msg.reads = reads;
      msg.readCount = (msg.readCount ?? 0) + 1;
      chatMessages.refresh();
    }
  }

  void _handleMessageDeleted(Map<String, dynamic> data) {
    final messageId = data['message_id'] as String?;
    if (messageId == null) return;
    final idx = chatMessages.indexWhere((m) => m.id == messageId);
    if (idx < 0) return;
    chatMessages[idx].isDeleted = true;
    chatMessages.refresh();
  }

  void _handleMessageEdited(Map<String, dynamic> data) {
    final messageId = data['message_id'] as String?;
    if (messageId == null) return;
    final idx = chatMessages.indexWhere((m) => m.id == messageId);
    if (idx < 0) return;
    chatMessages[idx].content =
        data['content'] as String? ?? chatMessages[idx].content;
    chatMessages[idx].isEdited = data['is_edited'] as bool? ?? true;
    chatMessages.refresh();
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

        case 'user_typing':
        case 'typing':
          final userId = data['user_id'] as String?;
          if (userId != null && userId == _currentUserId) break;
          final isTyping = data['is_typing'] as bool? ?? false;
          isOtherUserTyping.value = isTyping;
          if (isTyping) {
            _typingDebounce?.cancel();
            _typingDebounce = Timer(const Duration(seconds: 3), () {
              isOtherUserTyping.value = false;
            });
          }
          break;

        case 'message_read':
          _handleMessageRead(data);
          break;

        case 'message_deleted':
          _handleMessageDeleted(data);
          break;

        case 'message_edited':
          _handleMessageEdited(data);
          break;

        case 'user_status':
          final userId = data['user_id'] as String?;
          if (userId != null && userId == _currentUserId) break;
          isOtherUserOnline.value = data['is_online'] as bool? ?? false;
          break;

        default:
          debugPrint('WS unhandled event: $type');
      }
    } catch (e) {
      debugPrint('WS parse error: $e');
    }
  }
}
