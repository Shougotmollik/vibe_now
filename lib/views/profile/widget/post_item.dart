import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/gen/assets.gen.dart';

class PostItem extends StatelessWidget {
  final bool isLiked;
  final VoidCallback onLikeTap;

  const PostItem({super.key, required this.isLiked, required this.onLikeTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jenny smith',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  Row(
                    children: [
                      Assets.icons.earth.svg(
                        width: 16,
                        height: 16,
                        color: Color(0xFF9D9D9D),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        ' 20 Oct',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9D9D9D),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Column(
                spacing: 8.h,
                children: [
                  GestureDetector(
                    onTap: onLikeTap,
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.grey,
                      size: 30,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.pushNamed(RouteNames.likeScreen),
                    child: Text(
                      '100',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Anybody wants to have coffee?',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
