import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/views/notification/widgets/animated_dialog_content.dart';

class WaveNotificationCard extends StatelessWidget {
  const WaveNotificationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xffEAEAEA), width: 1.w),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50.r),
            child: Image.network(
              'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              width: 48.w,
              height: 48.w,
              fit: BoxFit.cover,
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Jenny Smith",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff303030),
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (context) {
                                return Center(
                                  child: Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    elevation: 0,
                                    backgroundColor: Colors.transparent,
                                    child: AnimatedDialogContent(
                                      content:
                                          'John Smith has accepted your request. You both may now proceed to walk over to the other person.',
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Assets.icons.acceptIc.svg(
                            width: 24.w,
                            height: 24.h,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (context) {
                                return Center(
                                  child: Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    elevation: 0,
                                    backgroundColor: Colors.transparent,
                                    child: AnimatedDialogContent(
                                      content:
                                          'You have declined John Smith\'s request.',
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Assets.icons.deniedIc.svg(
                            width: 24.w,
                            height: 24.h,
                            color: const Color(0xff707070),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Assets.icons.location.svg(
                      width: 16.w,
                      height: 16.h,
                      color: const Color(0xff707070),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      '300km away',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff707070),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 4.h),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Assets.icons.timeCircle.svg(
                      width: 16.w,
                      height: 16.h,
                      color: const Color(0xff707070),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      'Wave will expire in 1hrs',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff707070),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
