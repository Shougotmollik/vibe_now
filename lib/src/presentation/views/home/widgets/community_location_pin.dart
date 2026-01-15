import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/gen/assets.gen.dart';

class CommunityLocationPin extends StatelessWidget {
  const CommunityLocationPin({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Assets.icons.locationPinCommunity.svg(width: 140.w, height: 140.h),

        Align(
          alignment: Alignment(0, -0.15),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40.r),
            child: Image.network(
              'https://www.sbdcnet.org/wp-content/uploads/2020/07/chuttersnap-aEnH4hJ_Mrs-unsplash-e1594836312246.jpg',
              width: 90.w,
              height: 90.w,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Align(
          alignment: Alignment(0, 0.30),
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Assets.icons.communityPin.svg(width: 32.w, height: 32.h),
          ),
        ),
      ],
    );
  }
}
