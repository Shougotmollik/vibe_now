import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/utils.dart' as utils;
import 'package:vibe_now/views/chat/chat_screen.dart';

//  Models

enum MessageType { text, image, audio }

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

  ChatMessage({
    String? id,
    this.text,
    this.mediaUrl,
    required this.senderAvatar,
    required this.senderName,
    required this.isMe,
    required this.type,
    required this.time,
    List<Reaction>? reactions,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
       reactions = reactions ?? [];
}

//  CommunityChatInboxScreen

class CommunityChatInboxScreen extends StatefulWidget {
  const CommunityChatInboxScreen({super.key});

  @override
  State<CommunityChatInboxScreen> createState() =>
      _CommunityChatInboxScreenState();
}

class _CommunityChatInboxScreenState extends State<CommunityChatInboxScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  OverlayEntry? _overlayEntry;

  bool _hasText = false;

  bool _isRecording = false;
  bool _isSending = false;
  String? _recordingPath;
  File? _selectedProfileImage;

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Hey how are you',
      senderAvatar: 'https://randomuser.me/api/portraits/men/1.jpg',
      senderName: 'Jony',
      isMe: false,
      type: MessageType.text,
      time: DateTime.now().subtract(const Duration(minutes: 20)),
      reactions: [
        Reaction(emoji: '❤️', count: 3),
        Reaction(emoji: '😂', count: 1, reactedByMe: true),
      ],
    ),
    ChatMessage(
      text: "I'm fine!",
      senderAvatar: '',
      senderName: 'Me',
      isMe: true,
      type: MessageType.text,
      time: DateTime.now().subtract(const Duration(minutes: 18)),
    ),
    ChatMessage(
      mediaUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e',
      senderAvatar: 'https://randomuser.me/api/portraits/women/2.jpg',
      senderName: 'Sarah',
      isMe: false,
      type: MessageType.image,
      time: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    ChatMessage(
      mediaUrl: 'audio_file_url',
      senderAvatar: '',
      senderName: 'Me',
      isMe: true,
      type: MessageType.audio,
      time: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    ChatMessage(
      text: 'See you all there! 🎉',
      senderAvatar: 'https://randomuser.me/api/portraits/men/1.jpg',
      senderName: 'Jony',
      isMe: false,
      type: MessageType.text,
      time: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      final has = _messageController.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _removeOverlay();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  // ── Overlay helpers ──────────────────────

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

  // ── Send ─────────────────────────────────

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          senderAvatar: '',
          senderName: 'Me',
          isMe: true,
          type: MessageType.text,
          time: DateTime.now(),
        ),
      );
    });
    _messageController.clear();
    _scrollToBottom();
  }

  // ── Build ────────────────────────────────

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
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                itemCount: _messages.length,
                itemBuilder: (context, index) => _CommunityMessageTile(
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
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  // ── App Bar ──────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0.5,
      shadowColor: Theme.of(context).colorScheme.shadow,
      surfaceTintColor: Colors.transparent,
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.onSurface),
      ),
      title: GestureDetector(
        onTap: () => context.pushNamed(RouteNames.communityMemberScreen),
        child: Row(
          children: [
            const CommunityAvatar(
              avatars: [
                'https://randomuser.me/api/portraits/men/32.jpg',
                'https://randomuser.me/api/portraits/women/44.jpg',
              ],
              size: 40,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Coffee Meetup at Central Park',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface),
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
      ],
    );
  }

  // ── Input Area ───────────────────────────

  Widget _buildInputArea() {
    final canSend = (_isRecording || _hasText) && !_isSending;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: [
            /// 📎 Attachment (optional)
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

            /// 🧠 Input Container
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
                    color: !_isRecording ? Theme.of(context).colorScheme.surface : null,
                    gradient: _isRecording ? AppColors.primaryGradient : null,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      /// 🎤 Mic Button
                      IconButton(
                        icon: Icon(
                          _isRecording ? Icons.pause : Icons.mic,
                          color: _isRecording
                              ? Colors.white
                              : AppColors.primary,
                        ),
                        onPressed: _isSending ? null : _toggleRecording,
                      ),

                      /// ✍️ Text OR Waveform
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: _isRecording
                              ? CustomPaint(
                                  painter: _WaveformPainter(
                                    isWhite: true,
                                    isAnimating: true,
                                  ),
                                )
                              : TextField(
                                  controller: _messageController,
                                  enabled: !_isSending,
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                                  decoration: InputDecoration(
                                    hintText: 'Message...',
                                    hintStyle: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  onSubmitted: (_) {
                                    if (canSend) _sendMessage();
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

            /// 🚀 Send Button
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
    );
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;

      if (_isRecording) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  Future<void> _sendVoiceMessage() async {
    if (_isSending) return;

    setState(() {
      _isSending = true;
      _isRecording = false;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _messages.add(
        ChatMessage(
          text: '🎤 Voice message',
          senderAvatar: '',
          senderName: 'Me',
          isMe: true,
          type: MessageType.audio,
          mediaUrl: 'voice_path',
          time: DateTime.now(),
        ),
      );
      _isSending = false;
    });

    _scrollToBottom();
  }
}

//  _CommunityMessageTile — long press + reactions

class _CommunityMessageTile extends StatefulWidget {
  final ChatMessage message;
  final void Function(ChatMessage, Offset) onLongPress;
  final void Function(ChatMessage, String) onToggleReaction;
  final void Function(ChatMessage) onMoreOptions;

  const _CommunityMessageTile({
    required this.message,
    required this.onLongPress,
    required this.onToggleReaction,
    required this.onMoreOptions,
  });

  @override
  State<_CommunityMessageTile> createState() => _CommunityMessageTileState();
}

class _CommunityMessageTileState extends State<_CommunityMessageTile>
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
                CircleAvatar(
                  radius: 18.r,
                  backgroundImage: NetworkImage(msg.senderAvatar),
                  onBackgroundImageError: (_, __) {},
                ),
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
            Padding(
              padding: EdgeInsets.only(
                top: 4,
                left: msg.isMe ? 0 : 44.w,
                right: msg.isMe ? 8 : 0,
              ),
              child: _ReactionChips(
                reactions: msg.reactions,
                onToggle: (e) => widget.onToggleReaction(msg, e),
              ),
            ),
        ],
      ),
    );
  }
}

//  Bubble content (original ChatBubble design preserved)

class _BubbleContent extends StatelessWidget {
  final ChatMessage message;

  const _BubbleContent({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: message.isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Container(
          padding: message.type == MessageType.image
              ? EdgeInsets.all(4.w)
              : EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: message.isMe ? null : Theme.of(context).colorScheme.surfaceVariant,
            gradient: message.isMe ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(message.isMe ? 20 : 0),
              bottomRight: Radius.circular(message.isMe ? 0 : 20),
            ),
          ),
          child: _buildTypeSpecificUI(context),
        ),
        Padding(
          padding: EdgeInsets.only(top: 4.h, left: 4.w, right: 4.w),
          child: Text(
            '${message.time.hour.toString().padLeft(2, '0')}:${message.time.minute.toString().padLeft(2, '0')}',
            style: TextStyle(fontSize: 10.sp, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSpecificUI(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.text ?? '',
          style: TextStyle(
            color: message.isMe ? Colors.white : Theme.of(context).colorScheme.onSurface,
            fontSize: 14.sp,
          ),
        );

      case MessageType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            message.mediaUrl!,
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

      case MessageType.audio:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pause_circle_filled, color: Colors.white),
            SizedBox(width: 8.w),
            SizedBox(
              width: 100.w,
              height: 24.h,
              child: CustomPaint(painter: _WaveformPainter(isWhite: true)),
            ),
            SizedBox(width: 8.w),
            Text(
              '0:15',
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
          ],
        );
    }
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

//  Reaction Overlay

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
              child: Container(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08)),
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
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.18),
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

//  Waveform Painter

class _WaveformPainter extends CustomPainter {
  final bool isWhite;
  final bool isAnimating;

  _WaveformPainter({this.isWhite = false, this.isAnimating = false});

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

//  More options bottom sheet

Future<dynamic> _buildMoreOption(
  BuildContext context, {
  required VoidCallback onDelete,
  required VoidCallback onEdit,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.12),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Copy
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
            // Delete
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
            // Edit
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
    ),
  );
}
