import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';

class ChatInboxScreen extends StatefulWidget {
  const ChatInboxScreen({super.key});

  @override
  State<ChatInboxScreen> createState() => _ChatInboxScreenState();
}

class _ChatInboxScreenState extends State<ChatInboxScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>;
    final name = extra['name'];
    final avatar = extra['avatar'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, avatar, name),

            // Chat messages
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const ReceivedMessage(message: 'Hi! how can i help?'),
                  const SizedBox(height: 12),
                  const SentMessage(message: 'Lorem ipsum dolor sit amet'),
                  const SizedBox(height: 12),
                  const ReceivedMessage(message: 'What are you doing'),
                  const SizedBox(height: 12),
                  const SentVoiceMessage(),
                  const SizedBox(height: 12),
                  const ReceivedMessage(
                    message:
                        'Lorem ipsum dolor sit amet consectetur. Rhoncus pretium cursus vestibulum lorem tristique ornare lectus ut erat.',
                  ),
                  const SizedBox(height: 12),
                  const ReceivedMessage(
                    message: 'Lorem ipsum dolor sit amet consectetur.',
                  ),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [SentMessage(message: 'This is client')],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SentVoiceMessage(isPaused: true),
                ],
              ),
            ),

            // Input Area
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: Row(
                  spacing: 10.w,
                  children: [
                    Assets.icons.trash.svg(
                      width: 24.w,
                      height: 24.h,
                      fit: BoxFit.cover,
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradientRotated,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _isRecording ? Icons.pause : Icons.mic,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isRecording = !_isRecording;
                                });
                              },
                            ),
                            Expanded(
                              child: SizedBox(
                                height: 30,
                                child: CustomPaint(
                                  painter: WaveformPainter(
                                    isAnimating: _isRecording,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: ShaderMask(
                        shaderCallback: (bounds) => AppColors
                            .primaryGradientRotated
                            .createShader(bounds),
                        child: Assets.icons.send.svg(
                          width: 24.w,
                          height: 24.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, avatar, name) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
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
          style: const TextStyle(
            color: Color(0xff303030),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),

        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.black),
          color: AppColors.backgroundVariant,
          onSelected: (value) {
            if (value == 'Block') {
              context.pushNamed(RouteNames.reportScreen);
            } else if (value == 'Report') {
              context.pushNamed(RouteNames.reportScreen);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'Block',
              child: Row(
                spacing: 8.w,
                children: [
                  Assets.icons.block.svg(width: 16.w, height: 16.h),
                  Text('Block'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'Report',
              child: Row(
                spacing: 8.w,
                children: [
                  Assets.icons.report.svg(width: 16.w, height: 16.h),
                  Text('Report'),
                ],
              ),
            ),
          ],
        ),
      ],
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
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xffF3F4F6),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Text(
          message,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
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
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradientRotated,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(
          message,
          style: const TextStyle(fontSize: 15, color: Colors.white),
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
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.6,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradientRotated,
          borderRadius: const BorderRadius.only(
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
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 24,
                child: CustomPaint(
                  painter: WaveformPainter(
                    isAnimating: !isPaused,
                    isWhite: true,
                  ),
                ),
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

    final barCount = 30;
    final barWidth = 2.0;
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => isAnimating;
}
