import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/tokens.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/custom_text_form_field.dart';
import 'package:vibe_now/src/presentation/views/common/custom_app_bar.dart';

class ManagePassword extends StatelessWidget {
  const ManagePassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: AppColors.backgroundVariant,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SafeArea(
          child: Column(
            spacing: 18.h,
            children: [
              CustomAppBar(title: "Manage Password"),
              SizedBox(height: 24.h),
              CustomTextFormField(hintText: 'Current Password'),
              CustomTextFormField(hintText: 'New Password'),
              CustomTextFormField(hintText: 'Confirm Password'),

              SizedBox(height: 12.h),

              PrimaryButton.text(onPressed: () {}, text: 'Update Password'),
            ],
          ),
        ),
      ),
    );
  }
}
