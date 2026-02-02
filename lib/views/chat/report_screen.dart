import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomAppBar(title: 'What happened?'),
          GestureDetector(
            onTap: () {
              AppSnackbar.show(
                message: 'you have reported the user',
                type: SnackType.warning,
              );
            },
            child: Container(
              width: 80.w,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40.r),
                shape: BoxShape.rectangle,
                gradient: AppColors.primaryGradientRotated,
              ),
              child: Center(
                child: Text(
                  'Send',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
