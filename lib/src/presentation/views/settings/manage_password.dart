import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/tokens.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/custom_text_form_field.dart';

class ManagePassword extends StatelessWidget {
  const ManagePassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: AppColors.backgroundVariant,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          spacing: 18.h,
          children: [
            SafeArea(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Manage Password',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            CustomTextFormField(hintText: 'Current Password'),
            CustomTextFormField(hintText: 'New Password'),
            CustomTextFormField(hintText: 'Confirm Password'),

            SizedBox(height: 12.h),

            PrimaryButton.text(onPressed: () {}, text: 'Update Password'),
          ],
        ),
      ),
    );
  }
}
