import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/tokens.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';

class SignupOtpVerificationScreen extends StatefulWidget {
  const SignupOtpVerificationScreen({super.key});

  @override
  State<SignupOtpVerificationScreen> createState() =>
      _SignupOtpVerificationScreenState();
}

class _SignupOtpVerificationScreenState
    extends State<SignupOtpVerificationScreen> {
  int _secondsRemaining = 60;
  Timer? _timer;
  bool _canResend = false;
  bool _isOtpEmpty = true;

  final TextEditingController _otpTEController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _otpTEController.addListener(_onOtpChanged);
    _startTimer();
  }

  void _onOtpChanged() {
    final otp = _otpTEController.text.trim();
    setState(() {
      // _isOtpEmpty = _otpTEController.text.trim().isEmpty;
      _isOtpEmpty = otp.length != 4;
    });
  }

  void _startTimer() {
    setState(() {
      _canResend = false;
      _secondsRemaining = 60;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpTEController.dispose();
    super.dispose();
  }

  void _onResendPressed() {
    debugPrint("Resend Code clicked");
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundVariant,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomAppBar(title: "", canBack: true),
              SizedBox(height: 100.h),
              Text(
                'Enter OTP',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),

              SizedBox(height: 36.h),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'A 4 digit verification code has been sent to ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryText,
                    fontSize: 14.sp,
                  ),
                  children: [
                    TextSpan(
                      text: 'example@gmail.com',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              Pinput(
                controller: _otpTEController,
                keyboardType: TextInputType.number,
                defaultPinTheme: PinTheme(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                  ),

                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  width: 48.w,
                  height: 48.h,
                ),
              ),

              SizedBox(height: 24.h),

              _canResend
                  ? GestureDetector(
                      onTap: _onResendPressed,
                      child: Text(
                        'Resend Code',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Resend Code in ',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                fontSize: 14.sp,
                              ),
                        ),
                        Text(
                          '$_secondsRemaining s',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

              Spacer(),
              PrimaryButton.text(
                onPressed: _isOtpEmpty
                    ? () {}
                    : () {
                        if (_otpTEController.text.isEmpty) {
                          AppSnackbar.show(
                            message: 'OTP is not matched',
                            type: SnackType.info,
                          );
                        } else {
                          context.goNamed(RouteNames.stepNameScreen);
                        }
                      },
                text: 'Verify',
                isEnabled: !_isOtpEmpty,
              ),

              SizedBox(height: 48.h),
            ],
          ),
        ),
      ),
    );
  }
}
