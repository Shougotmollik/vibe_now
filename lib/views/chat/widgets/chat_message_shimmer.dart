import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton loader for a chat thread (Messenger / WhatsApp style).
/// Renders a list of placeholder message bubbles with a shimmer effect.
class ChatMessageShimmer extends StatelessWidget {
  const ChatMessageShimmer({super.key, this.itemCount = 8});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;
    final incomingBubbleColor = Theme.of(context).colorScheme.surfaceVariant;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // Alternate between incoming (left) and outgoing (right) bubbles,
          // and vary widths so it feels like a real conversation loading.
          final isMe = index.isOdd;
          final widthFraction = _widthFractionFor(index);
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: isMe
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (!isMe) ...[
                      _shimmerCircle(36.r),
                      SizedBox(width: 8.w),
                    ],
                    Flexible(
                      child: Container(
                        width: widthFraction.sw,
                        height: _heightFor(index),
                        decoration: BoxDecoration(
                          color: incomingBubbleColor,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                            bottomLeft: Radius.circular(isMe ? 20 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Padding(
                  padding: EdgeInsets.only(
                    left: isMe ? 0 : 44.w,
                    right: isMe ? 8 : 0,
                  ),
                  child: _shimmerBar(28.w, 9.sp),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _shimmerCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _shimmerBar(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }

  double _widthFractionFor(int index) {
    // Cycle through a few realistic widths.
    const fractions = [0.55, 0.4, 0.7, 0.45, 0.6, 0.5, 0.35, 0.65];
    return fractions[index % fractions.length];
  }

  double _heightFor(int index) {
    // Mostly short text, with a couple of longer messages mixed in.
    if (index % 4 == 0) return 60.h;
    if (index % 5 == 0) return 48.h;
    return 36.h;
  }
}
