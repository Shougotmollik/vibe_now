import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibe_now/core/constant/api_constant.dart';
import 'package:vibe_now/model/chat.dart';
import 'package:vibe_now/model/chat_message.dart';
import 'package:vibe_now/services/custom_http.dart';

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

  // GET chats list
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

  // GET messages
  Future<void> getChatHistory({required String chatId}) async {
    isLoading(true);
    final response = await CustomHttp.get(
      need_auth: true,
      endpoint: "${ApiConstant.chat}/$chatId/messages",
    );

    if (response.ok) {
      final results = response.data;
      chatMessages.assignAll(
        List<ChatMessage>.from(results.map((e) => ChatMessage.fromJson(e))),
      );
    } else {
      debugPrint('Error fetching chat history: ${response.error}');
    }
    isLoading(false);
  }

  // List<dynamic> _extractResults(dynamic raw) {
  //   if (raw is List) return raw;
  //   if (raw is Map) {
  //     final data = raw['data'];
  //     if (data is List) return data;
  //     if (data is Map) {
  //       final results = data['results'];
  //       if (results is List) return results;
  //     }
  //     final results = raw['results'];
  //     if (results is List) return results;
  //   }
  //   return const [];
  // }
}
