import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/gen/assets.gen.dart';

class EventLocationPin extends StatelessWidget {
  const EventLocationPin({
    super.key,
    this.imageUrl,
  });

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = imageUrl != null && imageUrl!.isNotEmpty
        ? AppCredentials.fixurl(imageUrl)
        : 'https://jandevents.com/wp-content/uploads/jand-party.jpg';

    return Stack(
      alignment: Alignment.center,
      children: [
        Assets.icons.locationPinEvent.svg(width: 140.w, height: 140.h),
        Align(
          alignment: const Alignment(0, -0.15),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40.r),
            child: Image.network(
              resolvedUrl,
              width: 90.w,
              height: 90.w,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 90.w,
                height: 90.w,
                color: Colors.grey[300],
                child: Icon(Icons.image, size: 30.w, color: Colors.grey[500]),
              ),
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0, 0.30),
          child: Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Assets.icons.calendarColor.svg(width: 32.w, height: 32.h),
          ),
        ),
      ],
    );
  }
}
