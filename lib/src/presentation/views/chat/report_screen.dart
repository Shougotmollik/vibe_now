import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/src/presentation/views/common/custom_app_bar.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),

            SizedBox(height: 32.h),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    'If you want to report something here you can explain',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff555555),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Explain here',
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: Color(0xffAEAEAE),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomAppBar(title: 'What happened?'),
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: SizedBox(
            width: 80.w,
            height: 32.h,
            child: PrimaryButton.text(onPressed: () {}, text: 'Send'),
          ),
        ),
      ],
    );
  }
}
