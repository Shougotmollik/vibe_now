import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/views/chat/chat_screen.dart';

// Message model
enum MessageType { text, voice, image }

enum MessageStatus { sending, sent, delivered, read, failed }

class ChatMessage {
  final String id;
  final String? content;
  final bool isSent;
  final MessageType messageType;
  final String? imagePath;
  final DateTime timestamp;
  final MessageStatus status;

  ChatMessage({
    String? id,
    required this.content,
    required this.isSent,
    this.messageType = MessageType.text,
    this.imagePath,
    DateTime? timestamp,
    this.status = MessageStatus.sent,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       timestamp = timestamp ?? DateTime.now();

  ChatMessage copyWith({
    String? id,
    String? content,
    bool? isSent,
    MessageType? messageType,
    String? imagePath,
    DateTime? timestamp,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isSent: isSent ?? this.isSent,
      messageType: messageType ?? this.messageType,
      imagePath: imagePath ?? this.imagePath,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }

  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isSent': isSent,
      'messageType': messageType.name,
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
    };
  }

  // Create from API response
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
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
}

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

  final List<ChatMessage> _messages = [
    ChatMessage(content: 'Hi! how can i help?', isSent: false),
    ChatMessage(content: 'Lorem ipsum dolor sit amet', isSent: true),
    ChatMessage(content: 'What are you doing', isSent: false),
    ChatMessage(
      content: 'Voice message',
      isSent: true,
      messageType: MessageType.voice,
    ),
  ];

  bool _isRecording = false;
  bool _hasTextInput = false;
  bool _isSending = false;
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (_hasTextInput != hasText) {
      setState(() {
        _hasTextInput = hasText;
      });
    }
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
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildMessageWidget(message);
                  },
                ),
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageWidget(ChatMessage message) {
    Widget messageWidget;

    switch (message.messageType) {
      case MessageType.image:
        messageWidget = message.isSent
            ? SentImageMessage(
                imagePath: message.imagePath!,
                caption: message.content,
                status: message.status,
              )
            : ReceivedImageMessage(
                imagePath: message.imagePath!,
                caption: message.content,
              );
        break;
      case MessageType.voice:
        messageWidget = message.isSent
            ? SentVoiceMessage(status: message.status)
            : const ReceivedVoiceMessage();
        break;
      case MessageType.text:
      default:
        messageWidget = message.isSent
            ? SentMessage(message: message.content!, status: message.status)
            : ReceivedMessage(message: message.content!);
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: messageWidget,
    );
  }

  Widget _buildInputArea() {
    final canSend = (_isRecording || _hasTextInput) && !_isSending;

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
            // Delete/Cancel button - only shows when recording
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
              // Attachment button - shows when not recording
              GestureDetector(
                onTap: _isSending ? null : _showImagePickerSheet,
                child: Assets.icons.attachedFile.svg(
                  width: 24.w,
                  height: 24.h,
                  color: _isSending
                      ? Colors.grey.withValues(alpha: 0.5)
                      : AppColors.primary,
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
                      // Mic button
                      IconButton(
                        icon: Icon(
                          _isRecording ? Icons.pause : Icons.mic,
                          color: _isRecording
                              ? Colors.white
                              : Colors.purpleAccent,
                        ),
                        onPressed: _isSending ? null : _toggleRecording,
                      ),

                      /// TEXT OR WAVEFORM
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
                                  style: const TextStyle(color: Colors.black87),
                                  decoration: const InputDecoration(
                                    hintText: 'Message...',
                                    hintStyle: TextStyle(color: Colors.black26),
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

            // Send button
            _isSending
                ? SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.primaryGradientRotated.createShader(bounds),
                      child: Assets.icons.send.svg(
                        width: 24.w,
                        height: 24.h,
                        color: canSend ? null : Colors.grey,
                      ),
                    ),
                    onPressed: canSend
                        ? () {
                            if (_isRecording) {
                              _sendVoiceMessage();
                            } else {
                              _sendTextMessage();
                            }
                          }
                        : null,
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
        // Clear text input when starting recording
        FocusScope.of(context).unfocus();
        _startRecording();
      } else {
        _pauseRecording();
      }
    });
  }

  void _startRecording() {
    // TODO: Implement actual audio recording
    // Example: using record package
    // await _audioRecorder.start();
    debugPrint('🎤 Recording started');
  }

  void _pauseRecording() {
    // TODO: Pause recording if needed
    debugPrint('⏸️ Recording paused');
  }

  void _cancelRecording() {
    setState(() {
      _isRecording = false;
      _recordingPath = null;
    });
    // TODO: Delete the recorded file
    debugPrint('🗑️ Recording cancelled and deleted');
  }

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

    // TODO: Send message to API
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Example API call:
      // final response = await _chatRepository.sendMessage(
      //   receiverId: receiverId,
      //   content: text,
      //   type: 'text',
      // );

      // Update message status to sent
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        setState(() {
          _messages[index] = message.copyWith(status: MessageStatus.sent);
        });
      }

      debugPrint('📨 Text sent: $text');
    } catch (e) {
      // Update message status to failed
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        setState(() {
          _messages[index] = message.copyWith(status: MessageStatus.failed);
        });
      }
      debugPrint('❌ Failed to send message: $e');
      _showErrorSnackBar('Failed to send message');
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _sendVoiceMessage() async {
    if (_isSending) return;

    // TODO: Stop recording and get file path
    // final path = await _audioRecorder.stop();

    final message = ChatMessage(
      content: 'Voice message',
      isSent: true,
      messageType: MessageType.voice,
      imagePath: _recordingPath, // Store audio file path here
      status: MessageStatus.sending,
    );

    setState(() {
      _messages.add(message);
      _isRecording = false;
      _isSending = true;
    });

    _scrollToBottom();

    // TODO: Upload voice message to API
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Example API call:
      // final response = await _chatRepository.sendVoiceMessage(
      //   receiverId: receiverId,
      //   audioFile: File(path),
      // );

      // Update message status
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        setState(() {
          _messages[index] = message.copyWith(status: MessageStatus.sent);
        });
      }

      debugPrint('🎤 Voice message sent');
    } catch (e) {
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        setState(() {
          _messages[index] = message.copyWith(status: MessageStatus.failed);
        });
      }
      debugPrint('❌ Failed to send voice message: $e');
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

    // TODO: Upload image to API
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Example API call:
      // final response = await _chatRepository.sendImageMessage(
      //   receiverId: receiverId,
      //   imageFile: File(imagePath),
      //   caption: caption,
      // );

      // Update message status
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        setState(() {
          _messages[index] = message.copyWith(status: MessageStatus.sent);
        });
      }

      debugPrint(
        '📷 Image sent${caption?.isNotEmpty == true ? ' with caption' : ''}',
      );
    } catch (e) {
      final index = _messages.indexWhere((m) => m.id == message.id);
      if (index != -1) {
        setState(() {
          _messages[index] = message.copyWith(status: MessageStatus.failed);
        });
      }
      debugPrint('❌ Failed to send image: $e');
      _showErrorSnackBar('Failed to send image');
    } finally {
      setState(() {
        _isSending = false;
      });
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
          onPressed: () {
            // TODO: Implement retry logic
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, avatar, name) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        spacing: 8.w,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16.w),
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
                    errorBuilder: (_, __, ___) => Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey[300],
                      child: const Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: const Color(0xff303030),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Text(
                    //   'Online',
                    //   style: TextStyle(color: Colors.green, fontSize: 12.sp),
                    // ),
                  ],
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
                  spacing: 8.w,
                  children: [
                    Assets.icons.block.svg(width: 20.w, height: 20.h),
                    const Text('Block'),
                  ],
                ),
                onTap: () {
                  Future.delayed(
                    Duration.zero,
                    () => context.pushNamed(RouteNames.reportScreen),
                  );
                },
              ),
              PopupMenuItem<String>(
                value: 'report',
                child: Row(
                  spacing: 8.w,
                  children: [
                    Assets.icons.report.svg(width: 20.w, height: 20.h),
                    const Text('Report'),
                  ],
                ),
                onTap: () {
                  Future.delayed(
                    Duration.zero,
                    () => context.pushNamed(RouteNames.reportScreen),
                  );
                },
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
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
      debugPrint('❌ Error picking image: $e');
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

// Message Widgets
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
      child: GestureDetector(
        onLongPress: () => _buildMoreOption(
          context,
          onDelete: () {
            Navigator.pop(context);
          },
          onEdit: () {
            Navigator.pop(context);
          },
        ),
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
                child: SentMessage(message: caption!, status: status),
              ),
            _MessageStatusIndicator(status: status),
          ],
        ),
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
        constraints: BoxConstraints(maxWidth: 280.w),
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
          style: TextStyle(color: Colors.black87, fontSize: 14.sp),
        ),
      ),
    );
  }
}

class SentMessage extends StatelessWidget {
  final String message;
  final MessageStatus status;

  const SentMessage({
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
          GestureDetector(
            onLongPress: () {
              // _openMoreOptions(context);
              _buildMoreOption(
                context,
                onDelete: () {
                  Navigator.pop(context);
                },
                onEdit: () {
                  Navigator.pop(context);
                },
              );
            },
            child: Container(
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
          ),
          _MessageStatusIndicator(status: status),
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
      child: GestureDetector(
        onLongPress: () => _buildMoreOption(
          context,
          onDelete: () {
            Navigator.pop(context);
          },
          onEdit: () {
            Navigator.pop(context);
          },
        ),
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
        decoration: const BoxDecoration(
          color: Color(0xffF3F4F6),
          borderRadius: BorderRadius.only(
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
              color: Colors.black87,
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
              style: TextStyle(color: Colors.black87, fontSize: 12.sp),
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
            color: AppColors.backgroundVariant,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 4.w,
                    children: [
                      Assets.icons.trash.svg(
                        width: 20.w,
                        height: 20.h,
                        // color: Colors.red,
                      ),
                      Text(
                        'Delete Chat',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.red,
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 4.w,
                    children: [
                      Icon(
                        Icons.edit_note_rounded,
                        color: Colors.grey[600],
                        size: 20.sp,
                      ),

                      Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
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
