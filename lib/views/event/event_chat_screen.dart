import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';

class Reaction {
  final String emoji;
  int count;
  bool reactedByMe;

  Reaction({
    required this.emoji,
    required this.count,
    this.reactedByMe = false,
  });

  Reaction copyWith({int? count, bool? reactedByMe}) => Reaction(
    emoji: emoji,
    count: count ?? this.count,
    reactedByMe: reactedByMe ?? this.reactedByMe,
  );
}

class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final DateTime time;
  List<Reaction> reactions;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    List<Reaction>? reactions,
  }) : reactions = reactions ?? [];
}

class EventChatScreen extends StatefulWidget {
  const EventChatScreen({super.key});

  @override
  State<EventChatScreen> createState() => _EventChatScreenState();
}

class _EventChatScreenState extends State<EventChatScreen> {
  bool isAdmin = true;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasText = false;

  // Overlay
  OverlayEntry? _overlayEntry;

  final List<ChatMessage> _messages = [
    ChatMessage(
      id: '1',
      text: 'Hi! how can I help? 👋',
      isMe: false,
      time: DateTime.now().subtract(const Duration(minutes: 30)),
      reactions: [
        Reaction(emoji: '❤️', count: 2),
        Reaction(emoji: '🔥', count: 5),
      ],
    ),
    ChatMessage(
      id: '2',
      text: 'What are you doing?',
      isMe: false,
      time: DateTime.now().subtract(const Duration(minutes: 20)),
      reactions: [Reaction(emoji: '😂', count: 3)],
    ),
    ChatMessage(
      id: '3',
      text:
          'Lorem ipsum dolor sit amet consectetur. Rhoncus pretium cursus vestibulum lorem tristique ornare lectus ut erat.',
      isMe: false,
      time: DateTime.now().subtract(const Duration(minutes: 10)),
      reactions: [
        Reaction(emoji: '👏', count: 7, reactedByMe: true),
        Reaction(emoji: '❤️', count: 4),
      ],
    ),
    ChatMessage(
      id: '4',
      text: 'Sounds great! See you there 🎉',
      isMe: true,
      time: DateTime.now().subtract(const Duration(minutes: 5)),
      reactions: [],
    ),
    ChatMessage(
      id: '5',
      text: 'Lorem ipsum dolor sit amet consectetur.',
      isMe: false,
      time: DateTime.now().subtract(const Duration(minutes: 2)),
      reactions: [],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _hasText = _controller.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
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

  // ── Business logic ───────────────────────

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

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          isMe: isAdmin,
          time: DateTime.now(),
        ),
      );
      _controller.clear();
    });
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

  String _formatTime(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // ── Build ────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _removeOverlay,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(child: _buildMessageList()),
              _buildBottomArea(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      shadowColor: Colors.black12,
      leadingWidth: 32,
      leading: GestureDetector(
        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onTap: () => Navigator.maybePop(context),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=200',
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Club House',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF050505),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Admin toggle
        Row(
          children: [
            Text(
              isAdmin ? 'Admin' : 'User',
              style: TextStyle(
                fontSize: 11,
                color: isAdmin ? const Color(0xFF0084FF) : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            Switch(
              value: isAdmin,
              onChanged: (v) => setState(() => isAdmin = v),
              activeColor: const Color(0xFF0084FF),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        IconButton(
          icon: const Icon(
            Icons.more_horiz_rounded,
            color: Color(0xFF050505),
            size: 22,
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      itemCount: _messages.length + 1,
      itemBuilder: (ctx, i) {
        if (i == 0) {
          return Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Today',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          );
        }
        return _MessageTile(
          message: _messages[i - 1],
          formatTime: _formatTime,
          onLongPress: _showReactionOverlay,
          onToggleReaction: _toggleReaction,
        );
      },
    );
  }

  Widget _buildBottomArea() {
    // 1. Non-admin view (Already looks good!)
    if (!isAdmin) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.lock_outline_rounded, size: 15, color: Colors.grey),
            SizedBox(width: 8),
            Text(
              'Only admins can send messages',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Assets.icons.trash.svg(height: 26.sp, width: 26.sp),
          SizedBox(width: 12.w),

          Expanded(
            child: Container(
              padding: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22.r),
                gradient: AppColors.primaryGradient,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22.r),
                  color: Colors.white,
                ),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.black87),
                  decoration: const InputDecoration(
                    hintText: "Type a message",
                    hintStyle: TextStyle(color: AppColors.primaryText),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: 12.w),
          // Send Button
          GestureDetector(
            onTap: _sendMessage,
            child: Assets.icons.send.svg(height: 26.sp, width: 26.sp),
          ),
        ],
      ),
    );
  }

  // Widget _buildBottomArea() {
  //   if (!isAdmin) {
  //     return Container(
  //       padding: const EdgeInsets.all(18),
  //       decoration: BoxDecoration(
  //         color: const Color(0xFFFAFAFA),
  //         border: Border(top: BorderSide(color: Colors.grey.shade200)),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: const [
  //           Icon(Icons.lock_outline_rounded, size: 15, color: Colors.grey),
  //           SizedBox(width: 8),
  //           Text(
  //             'Only admins can send messages',
  //             style: TextStyle(
  //               color: Colors.grey,
  //               fontWeight: FontWeight.w600,
  //               fontSize: 13,
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }

  //   Expanded(
  //     child: Container(
  //       padding: EdgeInsets.all(1.w),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(22.r),
  //         gradient: AppColors.primaryGradient,
  //       ),
  //       child: Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
  //         decoration: BoxDecoration(borderRadius: BorderRadius.circular(21)),
  //         child: TextField(
  //           controller: _controller,
  //           style: const TextStyle(color: AppColors.primaryText),
  //           decoration: const InputDecoration(
  //             hintText: "Type a message",
  //             hintStyle: TextStyle(color: AppColors.primaryText),
  //             border: InputBorder.none,
  //             isDense: true,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );

  //   // return Container(
  //   //   padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
  //   //   decoration: BoxDecoration(
  //   //     color: Colors.white,
  //   //     border: Border(top: BorderSide(color: Colors.grey.shade200)),
  //   //   ),
  //   //   child: Row(
  //   //     children: [
  //   //       _iconBtn(Icons.add_circle_outline_rounded, const Color(0xFF0084FF)),
  //   //       const SizedBox(width: 4),
  //   //       _iconBtn(Icons.image_outlined, const Color(0xFF0084FF)),
  //   //       _iconBtn(Icons.mic_none_rounded, const Color(0xFF0084FF)),
  //   //       const SizedBox(width: 4),
  //   //       Expanded(
  //   //         child: Container(
  //   //           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
  //   //           decoration: BoxDecoration(
  //   //             color: const Color(0xFFF0F2F5),
  //   //             borderRadius: BorderRadius.circular(22),
  //   //           ),
  //   //           child: Row(
  //   //             children: [
  //   //               Expanded(
  //   //                 child: TextField(
  //   //                   controller: _controller,
  //   //                   textInputAction: TextInputAction.send,
  //   //                   onSubmitted: (_) => _sendMessage(),
  //   //                   style: const TextStyle(
  //   //                     fontSize: 15,
  //   //                     color: Color(0xFF050505),
  //   //                   ),
  //   //                   decoration: const InputDecoration(
  //   //                     hintText: 'Aa',
  //   //                     hintStyle: TextStyle(color: Colors.grey),
  //   //                     border: InputBorder.none,
  //   //                     isDense: true,
  //   //                     contentPadding: EdgeInsets.symmetric(vertical: 8),
  //   //                   ),
  //   //                 ),
  //   //               ),
  //   //               const Text('😊', style: TextStyle(fontSize: 20)),
  //   //             ],
  //   //           ),
  //   //         ),
  //   //       ),
  //   //       const SizedBox(width: 4),
  //   //       _hasText
  //   //           ? GestureDetector(
  //   //               onTap: _sendMessage,
  //   //               child: Container(
  //   //                 width: 38,
  //   //                 height: 38,
  //   //                 decoration: BoxDecoration(
  //   //                   color: AppColors.primary,
  //   //                   shape: BoxShape.circle,
  //   //                 ),
  //   //                 child: const Icon(
  //   //                   Icons.send_rounded,
  //   //                   color: Colors.white,
  //   //                   size: 18,
  //   //                 ),
  //   //               ),
  //   //             )
  //   //           : const Padding(
  //   //               padding: EdgeInsets.only(left: 4),
  //   //               child: Text('👍', style: TextStyle(fontSize: 28)),
  //   //             ),
  //   //     ],
  //   //   ),
  //   // );
  // }

  Widget _iconBtn(IconData icon, Color color) => IconButton(
    icon: Icon(icon, color: color, size: 28),
    onPressed: () {},
    padding: const EdgeInsets.symmetric(horizontal: 4),
    constraints: const BoxConstraints(),
  );
}

class _MessageTile extends StatefulWidget {
  final ChatMessage message;
  final String Function(DateTime) formatTime;
  final void Function(ChatMessage, Offset) onLongPress;
  final void Function(ChatMessage, String) onToggleReaction;

  const _MessageTile({
    required this.message,
    required this.formatTime,
    required this.onLongPress,
    required this.onToggleReaction,
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
    final isMe = msg.isMe;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Bubble
          Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: GestureDetector(
              onLongPressStart: (_) {
                _scaleCtrl.forward();
              },
              onLongPress: () {
                _scaleCtrl.reverse();
                widget.onLongPress(msg, _getBubbleTopCenter());
              },
              onLongPressCancel: () => _scaleCtrl.reverse(),
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  key: _bubbleKey,
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? null : const Color(0xFFF0F2F5),
                    gradient: isMe ? AppColors.primaryGradient : null,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: isMe ? Colors.white : const Color(0xFF050505),
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Reactions
          if (msg.reactions.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(
                top: 4,
                left: isMe ? 0 : 8,
                right: isMe ? 8 : 0,
              ),
              child: _ReactionChips(
                reactions: msg.reactions,
                onToggle: (e) => widget.onToggleReaction(msg, e),
              ),
            ),

          // Time
          Padding(
            padding: EdgeInsets.only(
              top: 3,
              left: isMe ? 0 : 6,
              right: isMe ? 6 : 0,
              bottom: 6,
            ),
            child: Text(
              widget.formatTime(msg.time),
              style: const TextStyle(fontSize: 11, color: Color(0xFF8A8D91)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Reaction Chips
// ─────────────────────────────────────────

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
                  ? const Color(0xFFE7F0FD)
                  : const Color(0xFFF0F2F5),
              border: Border.all(
                color: r.reactedByMe
                    ? const Color(0xFF1877F2)
                    : Colors.transparent,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
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

// ─────────────────────────────────────────
//  Reaction Overlay (Facebook-style popup)
// ─────────────────────────────────────────

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
              child: Container(color: Colors.black.withOpacity(0.08)),
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _emojis.asMap().entries.map((entry) {
                      final emoji = entry.value;
                      final alreadyReacted = widget.message.reactions.any(
                        (r) => r.emoji == emoji && r.reactedByMe,
                      );
                      final isHovered = _hoveredEmoji == emoji;

                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: isHovered ? 1.0 : 0.0),
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOut,
                        builder: (ctx, v, _) {
                          return GestureDetector(
                            onTap: () => widget.onReact(emoji),
                            onTapDown: (_) =>
                                setState(() => _hoveredEmoji = emoji),
                            onTapCancel: () =>
                                setState(() => _hoveredEmoji = null),
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
                        },
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

// ─────────────────────────────────────────
//  Entry Point (for standalone testing)
// ─────────────────────────────────────────

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EventChatScreen(),
    ),
  );
}
