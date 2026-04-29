import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/views/auth/widgets/custom_text_form_field.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/utils.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController _emailController = TextEditingController();

  // bool _isEmailEmpty = true;
  bool _isEmailValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    final email = _emailController.text.trim();

    setState(() {
      _isEmailValid = email.isNotEmpty && isValidEmail(email);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              CustomAppBar(title: 'Email Verification'),
              SizedBox(height: 72.h),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'A 4 digit verification code will be sent to your email address.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(height: 38.h),
              Form(
                key: _formKey,
                child: CustomTextFormField(
                  controller: _emailController,
                  hintText: 'Enter your email address',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!isValidEmail(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
              ),

              Spacer(),

              PrimaryButton.text(
                onPressed: !_isEmailValid
                    ? () {}
                    : () {
                        if (_formKey.currentState!.validate()) {
                          context.pushNamed(RouteNames.otpVerificationScreen);
                        }
                      },
                text: 'Send Code',
                isEnabled: _isEmailValid,
              ),
              SizedBox(height: 48.h),
            ],
          ),
        ),
      ),
    );
  }
}
