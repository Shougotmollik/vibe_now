import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibe_now/controller/chat_controller.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/chat.dart';
import 'package:vibe_now/utils.dart' as utils;

// ─────────────────────────────────────────────────────────────────────────────
//  Enums & Models
// ─────────────────────────────────────────────────────────────────────────────

enum MessageType { text, voice, image }

enum MessageStatus { sending, sent, delivered, read, failed }

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
  final String? content;
  final bool isSent;
  final MessageType messageType;
  final String? imagePath;
  final DateTime timestamp;
  final MessageStatus status;
  final List<Reaction> reactions;

  ChatMessage({
    String? id,
    required this.content,
    required this.isSent,
    this.messageType = MessageType.text,
    this.imagePath,
    DateTime? timestamp,
    this.status = MessageStatus.sent,
    List<Reaction>? reactions,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       timestamp = timestamp ?? DateTime.now(),
       reactions = reactions ?? [];

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isSent,
    MessageType? messageType,
    String? imagePath,
    DateTime? timestamp,
    MessageStatus? status,
    List<Reaction>? reactions,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isSent: isSent ?? this.isSent,
      messageType: messageType ?? this.messageType,
      imagePath: imagePath ?? this.imagePath,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      reactions: reactions ?? this.reactions,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'isSent': isSent,
    'messageType': messageType.name,
    'imagePath': imagePath,
    'timestamp': timestamp.toIso8601String(),
    'status': status.name,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'],
    content: json['content'],
    isSent: json['isSent'] ?? false,
    messageType: MessageType.values.firstWhere(
      (e) => e.name == json['messageType'],
      orElse: () => MessageType.text,
    ),
    imagePath: json['imagePath'],
    timestamp: DateTime.parse(json['timestamp']),
    status: MessageStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => MessageStatus.sent,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  ChatInboxScreen
// ─────────────────────────────────────────────────────────────────────────────

class ChatInboxScreen extends StatefulWidget {
  const ChatInboxScreen({super.key});

  @override
  State<ChatInboxScreen> createState() => _ChatInboxScreenState();
}

class _ChatInboxScreenState extends State<ChatInboxScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  final FocusNode _textFocusNode = FocusNode();
  final ChatController _chatController = Get.find<ChatController>();
  File? _selectedProfileImage;

  // Overlay for emoji reaction bar
  OverlayEntry? _overlayEntry;

  Timer? _typingDebounce;
  bool _typingIndicatorSent = false;

  final List<ChatMessage> _messages = [
    ChatMessage(content: 'Hi! how can I help? 👋', isSent: false),
    ChatMessage(content: 'Lorem ipsum dolor sit amet', isSent: true),
    ChatMessage(content: 'What are you doing?', isSent: false),
    ChatMessage(
      content: 'Voice message',
      isSent: true,
      messageType: MessageType.voice,
    ),
    ChatMessage(
      content: 'Sure, sounds good!',
      isSent: false,
      reactions: [
        Reaction(emoji: '❤️', count: 2),
        Reaction(emoji: '😂', count: 1, reactedByMe: true),
      ],
    ),
  ];

  bool _isRecording = false;
  bool _hasTextInput = false;
  bool _isSending = false;
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onMessageChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra as Chat;
      if (extra.id.isNotEmpty) {
        _chatController.connectToChat(extra.id);
      }
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _messageController.removeListener(_onMessageChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _textFocusNode.dispose();
    _typingDebounce?.cancel();
    _chatController.disconnectFromChat();
    super.dispose();
  }

  // ── Text input listener & Typing Indicator ──

  void _onMessageChanged() {
    final has = _messageController.text.trim().isNotEmpty;
    if (has != _hasTextInput) setState(() => _hasTextInput = has);

    final extra = GoRouterState.of(context).extra as Chat;
    final chatId = extra.id;

    _typingDebounce?.cancel();
    if (has) {
      if (!_typingIndicatorSent) _sendTypingStatus(chatId, true);
      _typingDebounce = Timer(const Duration(seconds: 2), () {
        if (_typingIndicatorSent) _sendTypingStatus(chatId, false);
      });
    } else {
      if (_typingIndicatorSent) _sendTypingStatus(chatId, false);
    }
  }

  void _sendTypingStatus(String chatId, bool isTyping) {
    _typingIndicatorSent = isTyping;
    _chatController.sendTypingIndicator(
      chatId: chatId,
      isTyping: isTyping,
    );
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
              child: SpinKitThreeBounce(
                color: AppColors.primary,
                size: 10,
              ),
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

  // ── Overlay / Reaction helpers ───────────

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
    setState(() {
      final idx = msg.reactions.indexWhere((r) => r.emoji == emoji);
      if (idx != -1) {
        final r = msg.reactions[idx];
        if (r.reactedByMe) {
          r.count--;
          r.reactedByMe = false;
          if (r.count <= 0) msg.reactions.removeAt(idx);
        } else {
          r.count++;
          r.reactedByMe = true;
        }
      } else {
        msg.reactions.add(Reaction(emoji: emoji, count: 1, reactedByMe: true));
      }
    });
  }

  // ── Build ────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Chat;
    final name = extra.name;
    final avatar = extra.avatars;

    return GestureDetector(
      onTap: () {
        _removeOverlay();
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, avatar.first, name),
              Expanded(child: _buildMessageList()),
              _buildTypingIndicator(),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  // ── App Bar ──────────────────────────────

  Widget _buildAppBar(BuildContext context, dynamic avatar, String name) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 4.w),
          GestureDetector(
            onTap: () => context.pushNamed(RouteNames.profileScreen),
            behavior: HitTestBehavior.translucent,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: CachedNetworkImage(
                    imageUrl: AppCredentials.fixurl(avatar),
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 40,
                      height: 40,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 40,
                      height: 40,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: const Icon(Icons.person),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            offset: const Offset(0, 50),
            color: Theme.of(context).colorScheme.surfaceVariant,
            itemBuilder: (_) => [
              PopupMenuItem<String>(
                value: 'block',
                child: Row(
                  children: [
                    Assets.icons.block.svg(width: 20.w, height: 20.h),
                    SizedBox(width: 8.w),
                    const Text('Block'),
                  ],
                ),
                onTap: () => Future.delayed(
                  Duration.zero,
                  () => context.pushNamed(RouteNames.blockScreen),
                ),
              ),
              PopupMenuItem<String>(
                value: 'report',
                child: Row(
                  children: [
                    Assets.icons.report.svg(width: 20.w, height: 20.h),
                    SizedBox(width: 8.w),
                    const Text('Report'),
                  ],
                ),
                onTap: () => Future.delayed(
                  Duration.zero,
                  () => context.pushNamed(RouteNames.reportScreen),
                ),
              ),
            ],
          ),
          SizedBox(width: 8.w),
        ],
      ),
    );
  }

  // ── Message List ─────────────────────────

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _MessageTile(
            message: _messages[index],
            onLongPress: _showReactionOverlay,
            onToggleReaction: _toggleReaction,
            onMoreOptions: (msg) => _buildMoreOption(
              context,
              onDelete: () {
                Navigator.pop(context);
                setState(() => _messages.remove(msg));
              },
              onEdit: () => Navigator.pop(context),
            ),
          ),
        );
      },
    );
  }

  // ── Input Area ───────────────────────────

  Widget _buildInputArea() {
    final canSend = (_isRecording || _hasTextInput) && !_isSending;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
        child: Row(
          children: [
            // Delete/Attachment button
            if (_isRecording)
              GestureDetector(
                onTap: _cancelRecording,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Assets.icons.trash.svg(width: 24.w, height: 24.h),
                ),
              )
            else
              GestureDetector(
                onTap: _isSending
                    ? null
                    : () {
                        utils.showImagePickerOptions(context, (
                          imageSource,
                        ) async {
                          final image = await utils.pickSingleImage(
                            context: context,
                            source: imageSource,
                            compress: true,
                          );

                          if (image != null) {
                            setState(() {
                              _selectedProfileImage = image;
                            });
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

            // Input box
            Expanded(
              child: Container(
                padding: !_isRecording
                    ? const EdgeInsets.all(2)
                    : EdgeInsets.zero,
                decoration: !_isRecording
                    ? BoxDecoration(
                        gradient: AppColors.primaryGradientRotated,
                        borderRadius: BorderRadius.circular(30),
                      )
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: !_isRecording
                        ? Theme.of(context).colorScheme.surface
                        : null,
                    gradient: _isRecording
                        ? AppColors.primaryGradientRotated
                        : null,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isRecording ? Icons.pause : Icons.mic,
                          color: _isRecording
                              ? Colors.white
                              : Colors.purpleAccent,
                        ),
                        onPressed: _isSending ? null : _toggleRecording,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: _isRecording
                              ? CustomPaint(
                                  painter: WaveformPainter(
                                    isAnimating: true,
                                    isWhite: true,
                                  ),
                                )
                              : TextField(
                                  controller: _messageController,
                                  focusNode: _textFocusNode,
                                  enabled: !_isSending,
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Message...',
                                    hintStyle: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  onSubmitted: (_) {
                                    if (canSend) _sendTextMessage();
                                  },
                                ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(width: 10.w),

            // Send button
            _isSending
                ? SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : GestureDetector(
                    onTap: canSend
                        ? () {
                            if (_isRecording) {
                              _sendVoiceMessage();
                            } else {
                              _sendTextMessage();
                            }
                          }
                        : null,
                    child: ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.primaryGradientRotated.createShader(bounds),
                      child: Assets.icons.send.svg(
                        width: 24.w,
                        height: 24.h,
                        color: canSend ? null : Colors.grey,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // ── Recording ────────────────────────────

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (_isRecording) {
        FocusScope.of(context).unfocus();
        _startRecording();
      } else {
        _pauseRecording();
      }
    });
  }

  void _startRecording() => debugPrint('🎤 Recording started');
  void _pauseRecording() => debugPrint('⏸️ Recording paused');

  void _cancelRecording() {
    setState(() {
      _isRecording = false;
      _recordingPath = null;
    });
    debugPrint('🗑️ Recording cancelled');
  }

  // ── Send helpers ─────────────────────────

  Future<void> _sendTextMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    final message = ChatMessage(
      content: text,
      isSent: true,
      messageType: MessageType.text,
      status: MessageStatus.sending,
    );

    setState(() {
      _messages.add(message);
      _isSending = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      await Future.delayed(const Duration(seconds: 1));
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        setState(
          () => _messages[index] = message.copyWith(status: MessageStatus.sent),
        );
      }
    } catch (e) {
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        setState(
          () =>
              _messages[index] = message.copyWith(status: MessageStatus.failed),
        );
      }
      _showErrorSnackBar('Failed to send message');
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _sendVoiceMessage() async {
    if (_isSending) return;

    final message = ChatMessage(
      content: 'Voice message',
      isSent: true,
      messageType: MessageType.voice,
      imagePath: _recordingPath,
      status: MessageStatus.sending,
    );

    setState(() {
      _messages.add(message);
      _isRecording = false;
      _isSending = true;
    });
    _scrollToBottom();

    try {
      await Future.delayed(const Duration(seconds: 2));
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        setState(
          () => _messages[index] = message.copyWith(status: MessageStatus.sent),
        );
      }
    } catch (e) {
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        setState(
          () =>
              _messages[index] = message.copyWith(status: MessageStatus.failed),
        );
      }
      _showErrorSnackBar('Failed to send voice message');
    } finally {
      setState(() {
        _isSending = false;
        _recordingPath = null;
      });
    }
  }

  Future<void> _sendImageMessage(String imagePath, String? caption) async {
    final message = ChatMessage(
      content: caption,
      isSent: true,
      messageType: MessageType.image,
      imagePath: imagePath,
      status: MessageStatus.sending,
    );

    setState(() {
      _messages.add(message);
      _isSending = true;
    });
    _scrollToBottom();

    try {
      await Future.delayed(const Duration(seconds: 2));
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        setState(
          () => _messages[index] = message.copyWith(status: MessageStatus.sent),
        );
      }
    } catch (e) {
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        setState(
          () =>
              _messages[index] = message.copyWith(status: MessageStatus.failed),
        );
      }
      _showErrorSnackBar('Failed to send image');
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (image == null) return;
      final caption = _messageController.text.trim();
      _messageController.clear();
      await _sendImageMessage(image.path, caption.isNotEmpty ? caption : null);
    } catch (e) {
      _showErrorSnackBar('Failed to pick image');
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _MessageTile — handles all message types + long press
// ─────────────────────────────────────────────────────────────────────────────

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

  @override
  Widget build(BuildContext context) {
    final msg = widget.message;

    return Column(
      crossAxisAlignment: msg.isSent
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onLongPressStart: (_) => _scaleCtrl.forward(),
          onLongPress: () {
            _scaleCtrl.reverse();

            if (msg.isSent) {
              widget.onMoreOptions(msg);
            } else {
              widget.onLongPress(msg, _getBubbleTopCenter());
            }
          },
          onLongPressCancel: () => _scaleCtrl.reverse(),

          onDoubleTap: () => widget.onLongPress(msg, _getBubbleTopCenter()),
          child: ScaleTransition(
            scale: _scaleAnim,
            child: _buildBubble(context, msg),
          ),
        ),

        // Reactions
        if (msg.reactions.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              top: 4,
              left: msg.isSent ? 0 : 8,
              right: msg.isSent ? 8 : 0,
            ),
            child: _ReactionChips(
              reactions: msg.reactions,
              onToggle: (e) => widget.onToggleReaction(msg, e),
            ),
          ),
      ],
    );
  }

  Widget _buildBubble(BuildContext context, ChatMessage msg) {
    switch (msg.messageType) {
      case MessageType.image:
        return msg.isSent
            ? SentImageMessage(
                key: _bubbleKey,
                imagePath: msg.imagePath!,
                caption: msg.content,
                status: msg.status,
              )
            : ReceivedImageMessage(
                key: _bubbleKey,
                imagePath: msg.imagePath!,
                caption: msg.content,
              );

      case MessageType.voice:
        return msg.isSent
            ? SentVoiceMessage(key: _bubbleKey, status: msg.status)
            : ReceivedVoiceMessage(key: _bubbleKey);

      case MessageType.text:
      default:
        return msg.isSent
            ? _SentTextBubble(
                key: _bubbleKey,
                message: msg.content!,
                status: msg.status,
              )
            : _ReceivedTextBubble(key: _bubbleKey, message: msg.content!);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Text Bubble Widgets (no long-press handler — handled by _MessageTile)
// ─────────────────────────────────────────────────────────────────────────────

class _SentTextBubble extends StatelessWidget {
  final String message;
  final MessageStatus status;

  const _SentTextBubble({
    super.key,
    required this.message,
    this.status = MessageStatus.sent,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 280.w),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradientRotated,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Text(
              message,
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
            ),
          ),
          _MessageStatusIndicator(status: status),
        ],
      ),
    );
  }
}

class _ReceivedTextBubble extends StatelessWidget {
  final String message;

  const _ReceivedTextBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 280.w),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}

//  Reaction Chips

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
              color: r.reactedByMe
                  ? Theme.of(context).colorScheme.surfaceVariant
                  : Theme.of(context).colorScheme.surfaceVariant,
              border: Border.all(
                color: r.reactedByMe ? AppColors.primary : Colors.transparent,
                width: 1.w,
              ),
              borderRadius: BorderRadius.circular(50.r),
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

class SentImageMessage extends StatelessWidget {
  final String imagePath;
  final String? caption;
  final MessageStatus status;

  const SentImageMessage({
    super.key,
    required this.imagePath,
    this.caption,
    this.status = MessageStatus.sent,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(imagePath),
                  width: 200.w,
                  height: 240.h,
                  fit: BoxFit.cover,
                ),
              ),
              if (status == MessageStatus.sending)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          if (caption != null && caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: _SentTextBubble(message: caption!, status: status),
            ),
          _MessageStatusIndicator(status: status),
        ],
      ),
    );
  }
}

class ReceivedImageMessage extends StatelessWidget {
  final String imagePath;
  final String? caption;

  const ReceivedImageMessage({
    super.key,
    required this.imagePath,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(imagePath),
              width: 200.w,
              height: 240.h,
              fit: BoxFit.cover,
            ),
          ),
          if (caption != null && caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: _ReceivedTextBubble(message: caption!),
            ),
        ],
      ),
    );
  }
}

class SentVoiceMessage extends StatelessWidget {
  final bool isPaused;
  final MessageStatus status;

  const SentVoiceMessage({
    super.key,
    this.isPaused = false,
    this.status = MessageStatus.sent,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradientRotated,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPaused ? Icons.play_arrow : Icons.pause,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100.w,
                  height: 24.h,
                  child: CustomPaint(
                    painter: WaveformPainter(
                      isAnimating: !isPaused,
                      isWhite: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '0:15',
                  style: TextStyle(color: Colors.white, fontSize: 12.sp),
                ),
              ],
            ),
          ),
          _MessageStatusIndicator(status: status),
        ],
      ),
    );
  }
}

class ReceivedVoiceMessage extends StatelessWidget {
  final bool isPaused;

  const ReceivedVoiceMessage({super.key, this.isPaused = true});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPaused ? Icons.play_arrow : Icons.pause,
              color: Theme.of(context).colorScheme.onSurface,
              size: 20,
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 100.w,
              height: 24.h,
              child: CustomPaint(
                painter: WaveformPainter(isAnimating: !isPaused),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '0:15',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageStatusIndicator extends StatelessWidget {
  final MessageStatus status;

  const _MessageStatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        color = Colors.grey;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.grey;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.grey;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.blue;
        break;
      case MessageStatus.failed:
        icon = Icons.error_outline;
        color = Colors.red;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 2, right: 4),
      child: Icon(icon, size: 14, color: color),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final bool isAnimating;
  final bool isWhite;

  WaveformPainter({this.isAnimating = false, this.isWhite = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isWhite ? Colors.white : Colors.black54
      ..strokeWidth = 2
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
      canvas.drawLine(Offset(x, y1), Offset(x, y2), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => isAnimating;
}

Future<dynamic> _buildMoreOption(
  BuildContext context, {
  required VoidCallback onDelete,
  required VoidCallback onEdit,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
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
              InkWell(
                onTap: onDelete,
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
              InkWell(
                onTap: onDelete,
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
              const Divider(height: 1),
              InkWell(
                onTap: onEdit,
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
                        size: 20.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
