import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/src/presentation/views/common/custom_app_bar.dart';

class MemberScreen extends StatelessWidget {
  const MemberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(title: 'Members'),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      "Jenny smith",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff2A2A2A),
                      ),
                    ),
                    subtitle: Text(
                      'Open for small talk',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    leading: CircleAvatar(
                      radius: 24.r,
                      backgroundImage: const NetworkImage(
                        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
                      ),
                    ),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],

                        border: Border.all(
                          color: Color(0xfff6f6f6),
                          width: 1.w,
                        ),
                        borderRadius: BorderRadius.circular(40.r),
                      ),
                      width: 80.w,
                      height: 40.h,

                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Assets.icons.hi.svg(width: 24.w, height: 24.h),

                            Text(
                              'Hi!!',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16.sp,
                                color: Color(0xff008CFF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
