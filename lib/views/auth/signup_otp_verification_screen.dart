import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:vibe_now/controller/auth_controller.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/core/routes/routes.dart';
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
  final AuthController controller = Get.find<AuthController>();

  late Map<String, String> data;
  String email = '';
  String userId = '';

  @override
  void initState() {
    super.initState();
    _otpTEController.addListener(_onOtpChanged);
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    data = GoRouterState.of(context).extra as Map<String, String>;
    email = data['email_address'] ?? '';
    userId = data['user_id'] ?? '';
    super.didChangeDependencies();
  }

  void _onOtpChanged() {
    final otp = _otpTEController.text.trim();
    setState(() {
      // _isOtpEmpty = _otpTEController.text.trim().isEmpty;
      _isOtpEmpty = otp.length != 6;
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

  void _onResendPressed() async {
    final result = await controller.otpResent(
      userId: userId,
      purpose: "signup",
      context: context,
    );
    if (result && mounted) {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
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
                'Check your inbox',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),

              SizedBox(height: 36.h),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'We sent you a 6-digit code to\n',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14.sp,
                  ),
                  children: [
                    TextSpan(
                      text: email,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
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
                length: 6,
                defaultPinTheme: PinTheme(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                  ),

                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
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
                          color: Theme.of(context).colorScheme.primary,
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
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 14.sp,
                              ),
                        ),
                        Text(
                          '$_secondsRemaining s',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

              Spacer(),
              Obx(
                () => PrimaryButton.text(
                  onPressed: _isOtpEmpty
                      ? () {}
                      : () async {
                          if (_otpTEController.text.isEmpty) {
                            AppSnackbar.show(
                              message: 'OTP is not matched',
                              type: SnackType.info,
                            );
                          } else {
                            final result = await controller
                                .signupOtpVerification(
                                  userId: userId,
                                  otp: _otpTEController.text,
                                  context: context,
                                );

                            if (result && mounted) {
                              appRouter.pushNamed(RouteNames.stepNameScreen);
                            }
                          }
                        },
                  text: 'Verify',
                  isEnabled: !_isOtpEmpty,
                  isLoading: controller.isLoading.value,
                ),
              ),

              SizedBox(height: 48.h),
            ],
          ),
        ),
      ),
    );
  }
}
