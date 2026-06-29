import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/gen/assets.gen.dart';

class UserLocationPin extends StatelessWidget {
  const UserLocationPin({
    super.key,
    required this.imagePath,
    this.hasVibe = false,
  });

  final String imagePath;
  final bool? hasVibe;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Assets.icons.locationPin.svg(width: 140.w, height: 140.h),

        Align(
          alignment: Alignment(0, -0.15),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40.r),
            child: CachedNetworkImage(
              imageUrl: imagePath,
              width: 90.w,
              height: 90.w,
              fit: BoxFit.cover,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, error, stackTrace) => Container(
                width: 90.w,
                height: 90.w,
                color: Colors.grey[300],
                child: Icon(Icons.image, size: 30.w, color: Colors.grey[500]),
              ),
            ),
          ),
        ),

        if (hasVibe!)
          Align(
            alignment: Alignment(0, 0.30),
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Assets.icons.creationStar.svg(width: 32.w, height: 32.h),
            ),
          ),
      ],
    );
  }
}
