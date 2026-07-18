import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/controller/chat_controller.dart';
import 'package:vibe_now/controller/profile_controller.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/chat.dart';
import 'package:vibe_now/model/chat_message.dart' as api;
import 'package:vibe_now/services/local_storage.dart';
import 'package:vibe_now/utils.dart' as utils;
import 'package:vibe_now/views/chat/widgets/chat_message_shimmer.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audio_waveforms/audio_waveforms.dart' as aw;
import 'package:http/http.dart' as http;
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';

enum MessageType { text, image, audio, mixed, deleted }

class Reaction {
  final String emoji;
  int count;
  bool reactedByMe;

  Reaction({
    required this.emoji,
    required this.count,
    this.reactedByMe = false,
  });
}

class ChatMessage {
  final String id;
  final String? text;
  final String? mediaUrl;
  final String senderAvatar;
  final String senderName;
  final bool isMe;
  final MessageType type;
  final DateTime time;
  final List<Reaction> reactions;
  final bool isEdited;
  final bool isDeleted;

  ChatMessage({
    String? id,
    this.text,
    this.mediaUrl,
    this.senderAvatar = '',
    this.senderName = '',
    this.isMe = false,
    this.type = MessageType.text,
    required this.time,
    this.reactions = const [],
    this.isEdited = false,
    this.isDeleted = false,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();
}

class ChatInboxScreen extends StatefulWidget {
  const ChatInboxScreen({super.key});

  @override
  State<ChatInboxScreen> createState() => _ChatInboxScreenState();
}

class _ChatInboxScreenState extends State<ChatInboxScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatController _chatController = Get.find<ChatController>();
  final ProfileController _profileController = Get.find<ProfileController>();
  final FocusNode _textFocusNode = FocusNode();

  bool _canMessage = true;

  OverlayEntry? _overlayEntry;

  bool _hasText = false;
  bool _isRecording = false;
  bool _isSending = false;
  String? _editingMessageId;
  String? _recordingPath;

  late final aw.RecorderController _recorderController;
  late final aw.PlayerController _playerController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  bool _isRecorded = false;
  int _recordDuration = 0;
  Timer? _recordTimer;

  late final ap.AudioPlayer _previewPlayer;
  bool _isPreviewPlaying = false;
  int _previewCurrentMs = 0;
  int _previewMaxMs = 0;

  String? _currentUserId;
  bool _initialLoading = true;
  Timer? _typingDebounce;
  bool _typingIndicatorSent = false;

  Chat? get _chat => GoRouterState.of(context).extra as Chat?;

  @override
  void initState() {
    super.initState();

    _recorderController = aw.RecorderController()
      ..androidEncoder = aw.AndroidEncoder.aac
      ..androidOutputFormat = aw.AndroidOutputFormat.mpeg4
      ..iosEncoder = aw.IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100
      ..bitRate = 48000;

    _playerController = aw.PlayerController();
    _playerController.setFinishMode(finishMode: aw.FinishMode.pause);
    _playerController.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPreviewPlaying = state == aw.PlayerState.playing);
      }
    });
    _playerController.onCurrentDurationChanged.listen((duration) {
      if (!mounted) return;
      setState(() {
        _previewCurrentMs = duration;
        _previewMaxMs = _playerController.maxDuration;
      });
    });
    _playerController.onCompletion.listen((_) async {
      if (!mounted) return;
      setState(() {
        _isPreviewPlaying = false;
        _previewCurrentMs = _previewMaxMs;
      });
      if (_recordingPath != null) {
        await _playerController.stopPlayer();
        await _playerController.preparePlayer(path: _recordingPath!);
        await _playerController.setFinishMode(finishMode: aw.FinishMode.pause);
      }
    });
    _playerController.addListener(() {
      if (mounted) setState(() {});
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnimation = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _previewPlayer = ap.AudioPlayer();
    _previewPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPreviewPlaying = state == ap.PlayerState.playing);
      }
    });
    _previewPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPreviewPlaying = false);
    });

    _messageController.addListener(_onMessageChanged);
    _loadInitialData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // GoRouterState depends on InheritedWidget, so it must be accessed
    // after initState, during or after the first build.
    _canMessage = _chat?.canMessage ?? true;
  }

  Future<void> _loadInitialData() async {
    _currentUserId = await LocalStorage.user_id.get();
    if (!mounted) return;

    final chatId = _chat?.id;
    if (chatId != null && chatId.isNotEmpty) {
      _chatController.chatMessages.clear();
      await _chatController.getChatHistory(chatId: chatId);
      _chatController.connectToChat(chatId);
    }

    if (!mounted) return;
    setState(() => _initialLoading = false);
    _scrollToBottom();

    if (chatId != null) {
      _chatController.markChatAsRead(chatId: chatId);
    }
  }

  @override
  void dispose() {
    _recorderController.dispose();
    _playerController.dispose();
    _previewPlayer.dispose();
    _pulseController.dispose();
    _recordTimer?.cancel();
    _typingDebounce?.cancel();
    _removeOverlay();
    _messageController.dispose();
    _scrollController.dispose();
    _textFocusNode.dispose();
    _chatController.disconnectFromChat();
    super.dispose();
  }

  //Typing Indicator

  void _onMessageChanged() {
    final has = _messageController.text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);

    final chatId = _chat?.id;
    _typingDebounce?.cancel();
    if (has) {
      if (!_typingIndicatorSent && chatId != null)
        _sendTypingStatus(chatId, true);
      _typingDebounce = Timer(const Duration(seconds: 2), () {
        if (_typingIndicatorSent && chatId != null)
          _sendTypingStatus(chatId, false);
      });
    } else {
      if (_typingIndicatorSent && chatId != null)
        _sendTypingStatus(chatId, false);
    }
  }

  void _sendTypingStatus(String chatId, bool isTyping) {
    _typingIndicatorSent = isTyping;
    _chatController.sendTypingIndicator(chatId: chatId, isTyping: isTyping);
  }

  Widget _buildTypingIndicator() {
    return Obx(() {
      if (!_chatController.isOtherUserTyping.value) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        child: Row(
          children: [
            SizedBox(
              width: 22.w,
              height: 12.w,
              child: SpinKitThreeBounce(color: AppColors.primary, size: 10),
            ),
            SizedBox(width: 6.w),
            Text(
              'typing...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12.sp,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  ChatMessage _mapApiToUi(api.ChatMessage m) {
    final senderId = m.sender?.id;
    final isMe = senderId != null && senderId == _currentUserId;

    final type = _resolveMessageType(m);
    final reactions = (m.reactions ?? []).map((r) {
      final reactedByMe = (r.users ?? []).any((u) => u.id == _currentUserId);
      return Reaction(
        emoji: r.emoji ?? '',
        count: r.count ?? 0,
        reactedByMe: reactedByMe,
      );
    }).toList();

    return ChatMessage(
      id: m.id ?? '',
      text: m.content,
      mediaUrl: m.file ?? m.voice,
      senderAvatar: m.sender?.avatar ?? '',
      senderName: m.sender?.fullName ?? '',
      isMe: isMe,
      type: type,
      time: m.createdAt ?? DateTime.now(),
      reactions: reactions,
      isEdited: m.isEdited ?? false,
      isDeleted: m.isDeleted ?? false,
    );
  }

  MessageType _resolveMessageType(api.ChatMessage m) {
    if (m.isDeleted == true) return MessageType.deleted;
    final apiType = m.type?.toLowerCase();
    switch (apiType) {
      case 'voice':
        return MessageType.audio;
      case 'image':
        return MessageType.image;
      case 'mixed':
        return MessageType.mixed;
      case 'text':
      default:
        if ((m.file ?? '').isNotEmpty) {
          return (m.content ?? '').isNotEmpty
              ? MessageType.mixed
              : MessageType.image;
        }
        if ((m.voice ?? '').isNotEmpty) return MessageType.audio;
        return MessageType.text;
    }
  }

  //  Overlay helpers
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showReactionOverlay(ChatMessage msg, Offset bubbleTopCenter) {
    _removeOverlay();
    HapticFeedback.mediumImpact();

    _overlayEntry = OverlayEntry(
      builder: (_) => _ReactionOverlay(
        message: msg,
        bubbleTopCenter: bubbleTopCenter,
        onReact: (emoji) {
          _removeOverlay();
          _toggleReaction(msg, emoji);
        },
        onDismiss: _removeOverlay,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _toggleReaction(ChatMessage msg, String emoji) {
    final chatId = _chat?.id;
    if (chatId == null) return;

    const emojiToType = {
      '❤️': 'heart',
      '😂': 'laugh',
      '😮': 'wow',
      '😢': 'sad',
      '😡': 'angry',
      '👍': 'like',
    };
    final reactionType = emojiToType[emoji] ?? 'like';

    _chatController.sendReaction(
      chatId: chatId,
      messageId: msg.id,
      reactionType: reactionType,
    );
  }

  //  Send / Edit

  void _sendMessage() async {
    final text = _messageController.text.trim();
    final chatId = _chat?.id;
    if (text.isEmpty || chatId == null) return;
    _messageController.clear();
    setState(() => _isSending = true);

    if (_editingMessageId != null) {
      _chatController.editMessage(
        chatId: chatId,
        messageId: _editingMessageId!,
        content: text,
      );
      if (mounted) setState(() => _editingMessageId = null);
    } else {
      await _chatController.sendTextMessage(chatId: chatId, content: text);
    }

    if (mounted) setState(() => _isSending = false);
    _scrollToBottom();
  }

  // ── Copy / Edit / Delete ──────────────────────────────────────────────────

  void _copyMessage(ChatMessage msg) {
    final text = msg.text;
    if (text == null || text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).translate('messageCopied')),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startEditMessage(ChatMessage msg) {
    final text = msg.text;
    if (text == null) return;
    setState(() => _editingMessageId = msg.id);
    _messageController.text = text;
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
    _scrollToBottom();
  }

  Future<void> _deleteMessage(ChatMessage msg) async {
    final chatId = _chat?.id;
    if (chatId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).translate('deleteMessage')),
        content: Text(AppLocalizations.of(context).translate('areYouSureDelete')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context).translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(context).translate('delete'), style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (_editingMessageId == msg.id) {
      _messageController.clear();
      setState(() => _editingMessageId = null);
    }

    _chatController.deleteMessage(chatId: chatId, messageId: msg.id);
  }

  void _showMessageOptions(ChatMessage msg) {
    final hasText = (msg.text ?? '').isNotEmpty;
    final canCopy =
        hasText &&
        (msg.type == MessageType.text || msg.type == MessageType.mixed);
    final canEdit =
        hasText &&
        (msg.type == MessageType.text || msg.type == MessageType.mixed);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.shadow.withValues(alpha: 0.12),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canCopy) ...[
                InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                    _copyMessage(msg);
                  },
                  splashColor: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.file_copy_outlined,
                          color: AppColors.primary,
                          size: 20.w,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Copy',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(height: 1.h),
              ],
              if (canEdit) ...[
                InkWell(
                  onTap: () {
                    Navigator.pop(ctx);
                    _startEditMessage(msg);
                  },
                  splashColor: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          color: AppColors.primary,
                          size: 20.w,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(height: 1.h),
              ],
              InkWell(
                onTap: () {
                  Navigator.pop(ctx);
                  _deleteMessage(msg);
                },
                splashColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  child: Row(
                    children: [
                      Assets.icons.trash.svg(width: 20.w, height: 20.h),
                      SizedBox(width: 4.w),
                      Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _removeOverlay();
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: _buildAppBar(context),
        body: Column(
          children: [
            Expanded(child: _buildMessageList()),
            _buildTypingIndicator(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final chat = _chat;
    final name = chat?.name ?? '';
    final avatar = chat?.avatars.isNotEmpty == true
        ? chat!.avatars.first
        : null;

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0.5,
      shadowColor: Theme.of(context).colorScheme.shadow,
      surfaceTintColor: Colors.transparent,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Icon(
          Icons.arrow_back_ios,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      title: Row(
        children: [
          GestureDetector(
            onTap: () => context.pushNamed(
              RouteNames.profileScreen,
              extra: _chat?.otherMember?.id,
            ),
            behavior: HitTestBehavior.translucent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: avatar != null
                  ? CachedNetworkImage(
                      imageUrl: AppCredentials.fixurl(avatar),
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 40,
                        height: 40,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: 40,
                        height: 40,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: const Icon(Icons.person),
                      ),
                    )
                  : CircleAvatar(
                      radius: 20,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      child: Icon(
                        Icons.person,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: GestureDetector(
              onTap: () => context.pushNamed(
                RouteNames.profileScreen,
                extra: _chat?.otherMember?.id,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Obx(
                    () => Text(
                      _chatController.isOtherUserOnline.value
                          ? 'Online'
                          : 'Offline',
                      style: TextStyle(
                        color: _chatController.isOtherUserOnline.value
                            ? const Color(0xFF34C759)
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          offset: const Offset(0, 50),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          itemBuilder: (_) => [
            PopupMenuItem<String>(
              value: 'block',
              child: Row(
                children: [
                  Assets.icons.block.svg(width: 20.w, height: 20.h),
                  SizedBox(width: 8.w),
                  Text(AppLocalizations.of(context).translate('block')),
                ],
              ),
              onTap: () => Future.delayed(
                Duration.zero,
                () => context.pushNamed(
                  RouteNames.blockScreen,
                  extra: {
                    'userId': _chat?.otherMember?.id,
                    'userName': _chat?.otherMember?.fullName ?? _chat?.name,
                  },
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: 'report',
              child: Row(
                children: [
                  Assets.icons.report.svg(width: 20.w, height: 20.h),
                  SizedBox(width: 8.w),
                  Text(AppLocalizations.of(context).translate('report')),
                ],
              ),
              onTap: () {
                final goRouter = GoRouter.of(context);
                final reportedUserId = _chat?.otherMember?.id;
                Future.delayed(
                  Duration.zero,
                  () => goRouter.pushNamed(
                    RouteNames.reportScreen,
                    extra: {'reportedUserId': reportedUserId},
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // ── Message List ──────────────────────────────────────────────────────────

  Widget _buildMessageList() {
    if (_initialLoading) {
      return const ChatMessageShimmer();
    }

    return Obx(() {
      final apiMessages = _chatController.chatMessages;
      final messages = apiMessages.reversed.map(_mapApiToUi).toList();

      if (messages.isEmpty) {
        return Center(
          child: Text(
            'No messages yet',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14.sp,
            ),
          ),
        );
      }

      return ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        itemCount: messages.length,
        itemBuilder: (context, index) => _MessageTile(
          message: messages[index],
          onLongPress: _showReactionOverlay,
          onToggleReaction: _toggleReaction,
          onMoreOptions: (msg) => _showMessageOptions(msg),
        ),
      );
    });
  }

  // ── Input Area ────────────────────────────────────────────────────────────

  void _showFullScreenImagePreview(File image) {
    final captionController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black,
      builder: (ctx) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () {
                  final caption = captionController.text.trim();
                  Navigator.of(ctx).pop();
                  if (mounted) {
                    _sendImageMessage(image, caption: caption);
                  }
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => Center(
                    child: InteractiveViewer(
                      child: Image.file(
                        image,
                        fit: BoxFit.contain,
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.broken_image,
                          color: Colors.white54,
                          size: 64,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                color: Colors.black,
                child: TextField(
                  controller: captionController,
                  decoration: InputDecoration(
                    hintText: 'Add a caption...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white12,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  minLines: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendImageMessage(File image, {String caption = ''}) async {
    final chatId = _chat?.id;
    if (_isSending || chatId == null) return;

    setState(() => _isSending = true);

    await _chatController.sendFileMessage(
      chatId: chatId,
      filePath: image.path,
      content: caption.isNotEmpty ? caption : 'Sent a file',
    );

    if (!mounted) return;
    setState(() => _isSending = false);
    _scrollToBottom();
  }

  void _showUnblockDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final displayName = _chat?.otherMember?.fullName ??
        _chat?.name ??
        loc.translate('defaultUserName');
    final targetUserId = _chat?.otherMember?.id;

    if (targetUserId == null || targetUserId.isEmpty) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.translate('areYouSureUnblock')
                      .replaceFirst('{userName}', displayName),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomElevatedButton(
                        onTap: () => Navigator.pop(dialogContext),
                        buttonText: loc.translate('cancel'),
                        btnColor: Theme.of(context).colorScheme.surfaceVariant,
                        textColor: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: CustomElevatedButton(
                        onTap: () async {
                          Navigator.pop(dialogContext);
                          final success = await _profileController.unblockUser(
                            targetUserId: targetUserId,
                            blockRecordId: 0,
                          );
                          if (!context.mounted) return;
                          if (success) {
                            setState(() => _canMessage = true);
                            // Refresh the private chat list so the can_message update
                            // is reflected when returning to the chat list screen.
                            _chatController.getChatList(
                              type: 'private',
                              refresh: true,
                            );
                          }
                          AppSnackbar.show(
                            message: success
                                ? loc.translate('unblockSuccess')
                                : loc.translate('unblockFailed'),
                            type: success ? SnackType.info : SnackType.error,
                          );
                        },
                        buttonText: loc.translate('unblock'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea() {
    final chat = _chat;

    // If messaging is blocked (can_message is false), show a blocked banner
    if (!_canMessage) {
      final loc = AppLocalizations.of(context);
      // During initial load, _currentUserId may not be available yet.
      // Show a generic message until we can determine who blocked whom.
      final iBlocked = _currentUserId != null && chat?.blockBy == _currentUserId;
      final blockMessage = _currentUserId == null
          ? loc.translate('youHaveBeenBlocked')
          : (iBlocked
              ? loc.translate('youBlockedThisUser')
              : loc.translate('youHaveBeenBlocked'));

      return SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .colorScheme
                    .shadow
                    .withValues(alpha: 0.1),
                blurRadius: 5,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                Icon(
                  Icons.block,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20.w,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    blockMessage,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (iBlocked) ...[  // Only show unblock button if current user initiated the block
                  SizedBox(width: 10.w),
                  GestureDetector(
                    onTap: () => _showUnblockDialog(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 7.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Obx(() {
                        final isUnblocking = _profileController
                                .unblockingUserId.value !=
                            null;
                        return isUnblocking
                            ? SizedBox(
                                width: 14.w,
                                height: 14.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                loc.translate('unblock'),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              );
                      }),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    final canSend = (_isRecorded || _hasText) && !_isRecording && !_isSending;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit mode banner
            if (_editingMessageId != null)
              Container(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 8,
                  top: 6,
                  bottom: 2,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        'Editing message',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _messageController.clear();
                        setState(() => _editingMessageId = null);
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  /// 📎 Attachment
                  GestureDetector(
                    onTap: _isSending
                        ? null
                        : () {
                            utils.showImagePickerOptions(context, (
                              imageSource,
                            ) async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => const Center(
                                  child: Card(
                                    child: Padding(
                                      padding: EdgeInsets.all(24),
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                ),
                              );

                              final image = await utils.pickSingleImage(
                                context: context,
                                source: imageSource,
                                compress: true,
                              );

                              if (mounted) Navigator.of(context).pop();

                              if (image != null && mounted) {
                                _showFullScreenImagePreview(image);
                              }
                            });
                          },
                    child: Assets.icons.attachedFile.svg(
                      width: 24.w,
                      height: 24.h,
                      color: _isSending
                          ? Colors.grey.withValues(alpha: 0.5)
                          : AppColors.primary,
                    ),
                  ),

                  SizedBox(width: 10.w),

                  /// Input Container
                  Expanded(
                    child: Container(
                      padding: !_isRecording
                          ? const EdgeInsets.all(2)
                          : EdgeInsets.zero,
                      decoration: !_isRecording
                          ? BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(30),
                            )
                          : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: (!_isRecording && !_isRecorded)
                              ? Theme.of(context).colorScheme.surface
                              : null,
                          gradient: (_isRecording || _isRecorded)
                              ? AppColors.primaryGradient
                              : null,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            /// Mic Button
                            if (!_isRecorded)
                              GestureDetector(
                                onTap: _isSending ? null : _toggleRecording,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    _isRecording ? Icons.stop : Icons.mic,
                                    color: _isRecording
                                        ? Colors.white
                                        : AppColors.primary,
                                    size: 22,
                                  ),
                                ),
                              ),

                            /// Text OR Waveform OR Preview
                            Expanded(
                              child: _isRecorded
                                  ? SizedBox(
                                      height: 45,
                                      child: Row(
                                        children: [
                                          GestureDetector(
                                            onTap: _togglePreviewPlay,
                                            behavior: HitTestBehavior.opaque,
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              alignment: Alignment.center,
                                              child: Icon(
                                                _isPreviewPlaying
                                                    ? Icons.pause_rounded
                                                    : Icons.play_arrow_rounded,
                                                color: Colors.white,
                                                size: 26,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: aw.AudioFileWaveforms(
                                              size: const Size(150, 45),
                                              playerController:
                                                  _playerController,
                                              playerWaveStyle:
                                                  const aw.PlayerWaveStyle(
                                                    fixedWaveColor:
                                                        Colors.white60,
                                                    liveWaveColor: Colors.white,
                                                    spacing: 6.0,
                                                    showSeekLine: true,
                                                    seekLineColor: Colors.white,
                                                    seekLineThickness: 2,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${_formatMs(_previewCurrentMs)} / ${_formatMs(_previewMaxMs)}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          GestureDetector(
                                            onTap: _deleteRecording,
                                            behavior: HitTestBehavior.opaque,
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              alignment: Alignment.center,
                                              child: const Icon(
                                                Icons.delete_outline_rounded,
                                                color: Colors.white,
                                                size: 22,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : _isRecording
                                  ? SizedBox(
                                      height: 45,
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 8),
                                          AnimatedBuilder(
                                            animation: _pulseAnimation,
                                            builder: (_, __) {
                                              return Container(
                                                width: 12,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: Color.lerp(
                                                    Colors.red.withValues(
                                                      alpha: 0.5,
                                                    ),
                                                    Colors.red,
                                                    _pulseAnimation.value,
                                                  ),
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.red
                                                          .withValues(
                                                            alpha:
                                                                0.4 *
                                                                _pulseAnimation
                                                                    .value,
                                                          ),
                                                      blurRadius: 6,
                                                      spreadRadius: 1,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _formatDuration(_recordDuration),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: aw.AudioWaveforms(
                                              size: const Size(100, 45),
                                              recorderController:
                                                  _recorderController,
                                              enableGesture: false,
                                              waveStyle: const aw.WaveStyle(
                                                waveColor: Colors.white,
                                                showDurationLabel: false,
                                                spacing: 4.0,
                                                waveThickness: 2.5,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                      ),
                                    )
                                  : TextField(
                                      controller: _messageController,
                                      focusNode: _textFocusNode,
                                      enabled: !_isSending,
                                      maxLines: 3,
                                      minLines: 1,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Type a message...',
                                        hintStyle: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                          fontSize: 14.sp,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            14.r,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 8.h,
                                        ),
                                        isDense: true,
                                      ),
                                      onSubmitted: (_) {
                                        if (canSend) _sendMessage();
                                      },
                                    ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: 10.w),

                  /// Send Button
                  _isSending
                      ? SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : GestureDetector(
                          onTap: canSend
                              ? () {
                                  if (_isRecorded && _recordingPath != null) {
                                    _sendVoiceMessage();
                                  } else {
                                    _sendMessage();
                                  }
                                }
                              : null,
                          child: Assets.icons.send.svg(
                            width: 24.w,
                            height: 24.h,
                            color: canSend ? null : Colors.grey,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Recording ─────────────────────────────────────────────────────────────

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      _recordTimer?.cancel();
      _pulseController.stop();
      final path = await _recorderController.stop(false);
      if (path == null) return;
      await _playerController.stopPlayer();
      await _playerController.preparePlayer(path: path);
      if (!mounted) return;
      setState(() {
        _isRecording = false;
        _isRecorded = true;
        _isPreviewPlaying = false;
        _recordingPath = path;
      });
    } else {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) return;

      if (_editingMessageId != null) {
        _messageController.clear();
        setState(() => _editingMessageId = null);
      }
      if (_isRecorded) {
        await _playerController.stopPlayer();
      }
      final tempDir = await getTemporaryDirectory();
      final path =
          '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorderController.record(path: path);
      if (!mounted) return;
      setState(() {
        _isRecording = true;
        _isRecorded = false;
        _recordDuration = 0;
      });
      _pulseController.repeat(reverse: true);
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) setState(() => _recordDuration++);
      });
      FocusScope.of(context).unfocus();
    }
  }

  void _deleteRecording() {
    _recordTimer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
    _playerController.stopPlayer();
    _previewPlayer.stop();
    setState(() {
      _isRecorded = false;
      _isRecording = false;
      _isPreviewPlaying = false;
      _recordingPath = null;
      _recordDuration = 0;
    });
  }

  void _togglePreviewPlay() async {
    if (_playerController.playerState.isPlaying) {
      await _playerController.pausePlayer();
      if (mounted) setState(() => _isPreviewPlaying = false);
      return;
    }

    if (_recordingPath == null) return;

    if (_playerController.playerState.isStopped) {
      await _playerController.preparePlayer(path: _recordingPath!);
      await _playerController.setFinishMode(finishMode: aw.FinishMode.pause);
    }

    await _playerController.seekTo(0);
    await _playerController.startPlayer();
    if (mounted) setState(() => _isPreviewPlaying = true);
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _formatMs(int milliseconds) {
    final totalSeconds = (milliseconds / 1000).floor();
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _sendVoiceMessage() async {
    final chatId = _chat?.id;
    if (_isSending || _recordingPath == null || chatId == null) return;

    await _playerController.stopPlayer();
    _previewPlayer.stop();

    setState(() => _isSending = true);

    await _chatController.sendVoiceMessage(
      chatId: chatId,
      voicePath: _recordingPath!,
    );

    if (!mounted) return;
    setState(() {
      _isSending = false;
      _isRecorded = false;
      _isPreviewPlaying = false;
      _recordingPath = null;
      _recordDuration = 0;
    });

    _scrollToBottom();
  }
}

// ── _MessageTile ────────────────────────────────────────────────────────────

class _MessageTile extends StatefulWidget {
  final ChatMessage message;
  final void Function(ChatMessage, Offset) onLongPress;
  final void Function(ChatMessage, String) onToggleReaction;
  final void Function(ChatMessage) onMoreOptions;

  const _MessageTile({
    required this.message,
    required this.onLongPress,
    required this.onToggleReaction,
    required this.onMoreOptions,
  });

  @override
  State<_MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<_MessageTile>
    with SingleTickerProviderStateMixin {
  final GlobalKey _bubbleKey = GlobalKey();
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  Offset _getBubbleTopCenter() {
    final box = _bubbleKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return Offset.zero;
    final pos = box.localToGlobal(Offset.zero);
    return Offset(pos.dx + box.size.width / 2, pos.dy);
  }

  String _formatTime(DateTime t) {
    final local = t.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.message;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: msg.isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Avatar row + bubble
          Row(
            mainAxisAlignment: msg.isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!msg.isMe) ...[
                _Avatar(url: msg.senderAvatar, radius: 18.r),
                SizedBox(width: 8.w),
              ],

              // Bubble with scale animation
              Flexible(
                child: GestureDetector(
                  onLongPressStart: (_) => _scaleCtrl.forward(),
                  onLongPress: () {
                    _scaleCtrl.reverse();
                    if (msg.isMe) {
                      widget.onMoreOptions(msg);
                    } else {
                      widget.onLongPress(msg, _getBubbleTopCenter());
                    }
                  },
                  onLongPressCancel: () => _scaleCtrl.reverse(),
                  onDoubleTap: () =>
                      widget.onLongPress(msg, _getBubbleTopCenter()),
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: _BubbleContent(key: _bubbleKey, message: msg),
                  ),
                ),
              ),
            ],
          ),

          // Reactions
          if (msg.reactions.isNotEmpty)
            Transform.translate(
              offset: const Offset(0, -2),
              child: Padding(
                padding: EdgeInsets.only(
                  top: 0,
                  left: msg.isMe ? 0 : 44.w,
                  right: msg.isMe ? 8 : 0,
                ),
                child: _ReactionChips(
                  reactions: msg.reactions,
                  onToggle: (e) => widget.onToggleReaction(msg, e),
                ),
              ),
            ),

          // Time & edited label
          Padding(
            padding: EdgeInsets.only(
              top: 4.h,
              left: msg.isMe ? 0 : 44.w,
              right: msg.isMe ? 8 : 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(msg.time),
                  style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                ),
                if (msg.isEdited) ...[
                  SizedBox(width: 4.w),
                  Text(
                    '(edited)',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── _Avatar ─────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String url;
  final double radius;

  const _Avatar({required this.url, required this.radius});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.person,
          size: radius,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundImage: CachedNetworkImageProvider(AppCredentials.fixurl(url)),
      onBackgroundImageError: (_, __) {},
    );
  }
}

// ── _BubbleContent ──────────────────────────────────────────────────────────

class _BubbleContent extends StatelessWidget {
  final ChatMessage message;

  const _BubbleContent({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.type == MessageType.deleted) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(message.isMe ? 20 : 0),
            bottomRight: Radius.circular(message.isMe ? 0 : 20),
          ),
        ),
        child: Text(
          '🚫 This message was deleted',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13.sp,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Container(
      padding: _bubblePaddingFor(message.type),
      decoration: BoxDecoration(
        gradient: message.isMe
            ? AppColors.primaryGradient
            : LinearGradient(
                colors: [
                  Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                  Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.1),
                ],
              ),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(message.isMe ? 20 : 0),
          bottomRight: Radius.circular(message.isMe ? 0 : 20),
        ),
      ),
      child: _buildTypeSpecificUI(context),
    );
  }

  EdgeInsets _bubblePaddingFor(MessageType type) {
    switch (type) {
      case MessageType.image:
        return EdgeInsets.all(4.w);
      case MessageType.mixed:
        return EdgeInsets.all(6.w);
      case MessageType.audio:
      case MessageType.text:
      case MessageType.deleted:
        return EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h);
    }
  }

  Widget _buildTypeSpecificUI(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.text ?? '',
          style: TextStyle(
            color: message.isMe
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
            fontSize: 14.sp,
          ),
        );

      case MessageType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            AppCredentials.fixurl(message.mediaUrl),
            width: 200.w,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 200.w,
              height: 150.h,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        );

      case MessageType.mixed:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if ((message.text ?? '').isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 6.h, left: 4.w, right: 4.w),
                child: Text(
                  message.text!,
                  style: TextStyle(
                    color: message.isMe
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                AppCredentials.fixurl(message.mediaUrl),
                width: 200.w,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 200.w,
                  height: 150.h,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ],
        );

      case MessageType.audio:
        return _MessageAudioPlayer(
          url: message.mediaUrl ?? '',
          isMe: message.isMe,
        );

      case MessageType.deleted:
        return const SizedBox.shrink();
    }
  }
}

// ── _ReactionChips ──────────────────────────────────────────────────────────

class _ReactionChips extends StatelessWidget {
  final List<Reaction> reactions;
  final void Function(String) onToggle;

  const _ReactionChips({required this.reactions, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: reactions.map((r) {
        return GestureDetector(
          onTap: () => onToggle(r.emoji),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border.all(
                color: r.reactedByMe ? AppColors.primary : Colors.transparent,
                width: 1.w,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(r.emoji, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 3),
                Text(
                  '${r.count}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: r.reactedByMe
                        ? const Color(0xFF1877F2)
                        : const Color(0xFF65676B),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── _ReactionOverlay ────────────────────────────────────────────────────────

class _ReactionOverlay extends StatefulWidget {
  final ChatMessage message;
  final Offset bubbleTopCenter;
  final void Function(String) onReact;
  final VoidCallback onDismiss;

  const _ReactionOverlay({
    required this.message,
    required this.bubbleTopCenter,
    required this.onReact,
    required this.onDismiss,
  });

  @override
  State<_ReactionOverlay> createState() => _ReactionOverlayState();
}

class _ReactionOverlayState extends State<_ReactionOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;
  String? _hoveredEmoji;

  static const _emojis = ['❤️', '😂', '😮', '😢', '😡', '👍'];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  double _clampedLeft(double screenWidth, double barWidth) {
    double x = widget.bubbleTopCenter.dx - barWidth / 2;
    return x.clamp(12.0, screenWidth - barWidth - 12);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    const barWidth = 300.0;
    const barHeight = 60.0;

    double top = widget.bubbleTopCenter.dy - barHeight - 12;
    if (top < MediaQuery.of(context).padding.top + 60) {
      top = widget.bubbleTopCenter.dy + 60;
    }

    return Stack(
      children: [
        // Scrim
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onDismiss,
            behavior: HitTestBehavior.translucent,
            child: FadeTransition(
              opacity: _fade,
              child: Container(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.08),
              ),
            ),
          ),
        ),

        // Emoji bar
        Positioned(
          top: top,
          left: _clampedLeft(size.width, barWidth),
          child: ScaleTransition(
            scale: _scale,
            alignment: Alignment.bottomCenter,
            child: FadeTransition(
              opacity: _fade,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: barWidth,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _emojis.map((emoji) {
                      final alreadyReacted = widget.message.reactions.any(
                        (r) => r.emoji == emoji && r.reactedByMe,
                      );
                      final isHovered = _hoveredEmoji == emoji;

                      return GestureDetector(
                        onTap: () => widget.onReact(emoji),
                        onTapDown: (_) => setState(() => _hoveredEmoji = emoji),
                        onTapCancel: () => setState(() => _hoveredEmoji = null),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          width: isHovered ? 50 : 40,
                          height: isHovered ? 50 : 40,
                          decoration: BoxDecoration(
                            color: alreadyReacted
                                ? const Color(0xFFE7F0FD)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            emoji,
                            style: TextStyle(fontSize: isHovered ? 30 : 24),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── _WaveformPainter ────────────────────────────────────────────────────────

class _WaveformPainter extends CustomPainter {
  final Color color;
  final double progress;

  _WaveformPainter({required this.color, this.progress = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    const barCount = 30;
    const barWidth = 2.0;
    final spacing = (size.width - (barCount * barWidth)) / (barCount - 1);

    for (int i = 0; i < barCount; i++) {
      final x = i * (barWidth + spacing);
      final heightFactor = (i % 3 == 0)
          ? 0.8
          : (i % 2 == 0)
          ? 0.5
          : 0.3;
      final barHeight = size.height * heightFactor;
      final y1 = (size.height - barHeight) / 2;
      final y2 = y1 + barHeight;

      final barCenter = x + barWidth / 2;
      final barProgress = barCenter / size.width;
      final paint = barProgress <= progress ? progressPaint : basePaint;

      canvas.drawLine(Offset(x, y1), Offset(x, y2), paint);
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

// ── _MessageAudioPlayer ─────────────────────────────────────────────────────

class _MessageAudioPlayer extends StatefulWidget {
  final String url;
  final bool isMe;

  const _MessageAudioPlayer({required this.url, required this.isMe});

  @override
  State<_MessageAudioPlayer> createState() => _MessageAudioPlayerState();
}

class _MessageAudioPlayerState extends State<_MessageAudioPlayer> {
  late ap.AudioPlayer _player;
  bool _isPlaying = false;
  bool _isDownloading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  late final String _resolvedUrl;
  String? _localPath;

  @override
  void initState() {
    super.initState();
    _resolvedUrl = AppCredentials.fixurl(widget.url);
    _player = ap.AudioPlayer();
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == ap.PlayerState.playing);
      }
    });
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    if (_localPath != null) {
      File(_localPath!).delete().then((_) {}, onError: (_) {});
    }
    super.dispose();
  }

  Future<String> _downloadAudio() async {
    if (_localPath != null) return _localPath!;

    final dir = await getTemporaryDirectory();
    final ext = _resolvedUrl.endsWith('.m4a') ? '.m4a' : '.mp3';
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}$ext';

    final response = await http.get(Uri.parse(_resolvedUrl));
    if (response.statusCode == 200) {
      final file = File(path);
      await file.writeAsBytes(response.bodyBytes);
      _localPath = path;
      return path;
    }
    throw Exception('Failed to download audio: ${response.statusCode}');
  }

  void _togglePlay() async {
    if (_resolvedUrl.isEmpty) return;

    if (_isPlaying) {
      await _player.pause();
      return;
    }

    if (_localPath != null) {
      await _playLocal();
      return;
    }

    setState(() => _isDownloading = true);
    try {
      final localPath = await _downloadAudio();
      if (!mounted) return;
      setState(() => _isDownloading = false);
      await _player.stop();
      await _player.play(ap.DeviceFileSource(localPath));
      if (mounted) setState(() => _isPlaying = true);
    } catch (e) {
      debugPrint('Audio download/play error: $e');
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _playLocal() async {
    await _player.stop();
    await _player.play(ap.DeviceFileSource(_localPath!));
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isMe
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;
    final displayDuration = _isPlaying ? _position : _duration;
    final progress = _duration.inMilliseconds > 0
        ? (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _isDownloading ? null : _togglePlay,
          child: SizedBox(
            width: 32,
            height: 32,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  _isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: _isDownloading ? color.withValues(alpha: 0.4) : color,
                  size: 32,
                ),
                if (_isDownloading)
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: color,
                    ),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Opacity(
          opacity: _isDownloading ? 0.35 : 1.0,
          child: SizedBox(
            width: 100.w,
            height: 24.h,
            child: CustomPaint(
              painter: _WaveformPainter(color: color, progress: progress),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          _isDownloading ? '-- : --' : _formatDuration(displayDuration),
          style: TextStyle(
            color: _isDownloading ? color.withValues(alpha: 0.4) : color,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}
