import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/custom_text_form_field.dart';
import 'package:vibe_now/src/presentation/views/common/custom_app_bar.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController _emailController = TextEditingController();

  bool _isEmailEmpty = true;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    setState(() {
      _isEmailEmpty = _emailController.text.trim().isEmpty;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundVariant,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              CustomAppBar(title: 'Email Verification'),
              SizedBox(height: 72.h),
              Text(
                'A 4 digit verification code will be sent to your email address.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 18.h),
              CustomTextFormField(
                controller: _emailController,
                hintText: 'Enter your email address',
              ),

              Spacer(),

              PrimaryButton.text(
                onPressed: _isEmailEmpty
                    ? () {}
                    : () {
                        context.pushNamed(RouteNames.otpVerificationScreen);
                      },
                text: 'Send Code',
                isEnabled: !_isEmailEmpty,
              ),
              SizedBox(height: 48.h),
            ],
          ),
        ),
      ),
    );
  }
}
