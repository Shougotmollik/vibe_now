import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/src/presentation/views/chat/chat_screen.dart';
import 'package:vibe_now/src/presentation/views/common/custom_elevated_button.dart';

// Message model
enum MessageType { text, voice, image }

class ChatMessage {
  final String? content;
  final bool isSent;
  final MessageType messageType;
  final String? imagePath;
  final bool isVoice;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isSent,
    this.isVoice = false,
    this.messageType = MessageType.text,
    this.imagePath,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatInboxScreen extends StatefulWidget {
  const ChatInboxScreen({super.key});

  @override
  State<ChatInboxScreen> createState() => _ChatInboxScreenState();
}

class _ChatInboxScreenState extends State<ChatInboxScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [
    ChatMessage(content: 'Hi! how can i help?', isSent: false),
    ChatMessage(content: 'Lorem ipsum dolor sit amet', isSent: true),
    ChatMessage(content: 'What are you doing', isSent: false),
    ChatMessage(content: 'Voice message', isSent: true, isVoice: true),
  ];

  bool _isRecording = false;
  bool _waveAccepted = false;

  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra as Chat;
      final wave = extra.wave;
    });
  }

  @override
  void dispose() {
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

  void _showWaveDialog(Map<String, dynamic> extra) {
    final name = extra['name'] ?? 'User';
    final avatar = extra['avatar'] ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          contentPadding: EdgeInsets.all(24.w),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              ClipRRect(
                borderRadius: BorderRadius.circular(50.r),
                child: Image.network(
                  avatar,
                  width: 80.w,
                  height: 80.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person, size: 40.sp),
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),

              Text('👋', style: TextStyle(fontSize: 48.sp)),
              SizedBox(height: 16.h),

              Text(
                '$name sent you a wave!',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),

              Text(
                'Would you like to start chatting?',
                style: TextStyle(fontSize: 14.sp, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

              Row(
                children: [
                  Expanded(
                    child: CustomElevatedButton(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      buttonText: 'Reject',
                      btnColor: Colors.black87,
                      textColor: Colors.white,
                    ),
                  ),
                  SizedBox(width: 18.w),

                  Expanded(
                    child: PrimaryButton.text(
                      onPressed: () {
                        setState(() {
                          _waveAccepted = true;
                        });
                        Navigator.pop(context);
                      },
                      text: 'Accept',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Chat;
    final name = extra.name;
    final avatar = extra.avatar;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, avatar, name),

            /// CHAT LIST
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];

                  if (message.messageType == MessageType.image) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: message.isSent
                          ? SentImageMessage(
                              imagePath: message.imagePath!,
                              caption: message.content,
                            )
                          : ReceivedImageMessage(
                              imagePath: message.imagePath!,
                              caption: message.content,
                            ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: message.isSent
                        ? (message.isVoice
                              ? const SentVoiceMessage()
                              : SentMessage(message: message.content!))
                        : ReceivedMessage(message: message.content!),
                  );
                },
              ),
            ),

            /// INPUT AREA
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          spacing: 10.w,
          children: [
            GestureDetector(
              onTap: _deleteLastMessage,
              child: Assets.icons.trash.svg(width: 24.w, height: 24.h),
            ),

            // ! image added
            GestureDetector(
              onTap: _showImagePickerSheet,
              child: Assets.icons.attachedFile.svg(
                width: 24.w,
                height: 24.h,
                color: AppColors.primary,
              ),
            ),

            /// INPUT BOX
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
                    color: !_isRecording ? const Color(0xffffffff) : null,
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
                          color: Colors.purpleAccent,
                        ),
                        onPressed: () {
                          setState(() {
                            _isRecording = !_isRecording;
                          });
                        },
                      ),

                      /// TEXT OR WAVEFORM
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: _isRecording
                              ? CustomPaint(
                                  painter: WaveformPainter(isAnimating: true),
                                )
                              : TextField(
                                  controller: _messageController,
                                  style: const TextStyle(color: Colors.black87),
                                  decoration: const InputDecoration(
                                    hintText: 'Message...',
                                    hintStyle: TextStyle(color: Colors.black26),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  onSubmitted: (_) => _sendTextMessage(),
                                ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),

            IconButton(
              icon: ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.primaryGradientRotated.createShader(bounds),
                child: Assets.icons.send.svg(width: 24.w, height: 24.h),
              ),
              onPressed: () {
                if (_isRecording) {
                  _sendVoiceMessage();
                } else {
                  _sendTextMessage();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sendTextMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(content: text, isSent: true, isVoice: false));
    });

    debugPrint('📨 Text sent: $text');
    _messageController.clear();
    _scrollToBottom();
  }

  void _sendVoiceMessage() {
    setState(() {
      _messages.add(
        ChatMessage(content: 'Voice message', isSent: true, isVoice: true),
      );
      _isRecording = false;
    });

    debugPrint('🎤 Voice message sent');
    _scrollToBottom();
  }

  void _deleteLastMessage() {
    if (_messages.isNotEmpty) {
      setState(() {
        _messages.removeLast();
      });
      debugPrint('🗑️ Last message deleted');
    }
  }

  Widget _buildAppBar(BuildContext context, avatar, name) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            child: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onTap: () => Navigator.pop(context),
          ),
        ),
        GestureDetector(
          onTap: () => context.pushNamed(RouteNames.profileScreen),
          behavior: HitTestBehavior.translucent,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Image.network(
                  avatar,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(
                  color: const Color(0xff303030),
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          offset: const Offset(0, 50),
          color: AppColors.backgroundVariant,
          itemBuilder: (_) => [
            PopupMenuItem<String>(
              value: 'block',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 6.w,
                children: [
                  Assets.icons.block.svg(width: 16.w, height: 16.h),
                  Text('Block'),
                ],
              ),
              onTap: () {
                context.pushNamed(RouteNames.reportScreen);
              },
            ),
            PopupMenuItem<String>(
              value: 'report',
              child: Row(
                spacing: 6.w,
                children: [
                  Assets.icons.report.svg(width: 16.w, height: 16.h),
                  Text('Report'),
                ],
              ),
              onTap: () {
                context.pushNamed(RouteNames.reportScreen);
              },
            ),
          ],
        ),
      ],
    );
  }

  // ? image section

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (image == null) return;

    setState(() {
      _messages.add(
        ChatMessage(
          content: _messageController.text.isNotEmpty
              ? _messageController.text.trim()
              : null,
          isSent: true,
          messageType: MessageType.image,
          imagePath: image.path,
        ),
      );
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SentImageMessage extends StatelessWidget {
  final String imagePath;
  final String? caption;

  const SentImageMessage({super.key, required this.imagePath, this.caption});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(imagePath),
              width: 180.w,
              height: 220.h,
              fit: BoxFit.cover,
            ),
          ),
          if (caption != null && caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: SentMessage(message: caption!),
            ),
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
              width: 180.w,
              height: 220.h,
              fit: BoxFit.cover,
            ),
          ),
          if (caption != null && caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: ReceivedMessage(message: caption!),
            ),
        ],
      ),
    );
  }
}

class ReceivedMessage extends StatelessWidget {
  final String message;
  const ReceivedMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xffF3F4F6),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(color: Colors.black, fontSize: 12.sp),
        ),
      ),
    );
  }
}

class SentMessage extends StatelessWidget {
  final String message;
  const SentMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
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
          style: TextStyle(color: Colors.white, fontSize: 12.sp),
        ),
      ),
    );
  }
}

class SentVoiceMessage extends StatelessWidget {
  final bool isPaused;
  const SentVoiceMessage({super.key, this.isPaused = false});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
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
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80.w,
              height: 24.h,
              child: CustomPaint(
                painter: WaveformPainter(isAnimating: !isPaused, isWhite: true),
              ),
            ),
          ],
        ),
      ),
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
      ..color = isWhite ? Colors.white : Colors.white.withOpacity(0.8)
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
