import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/auth_title.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/custom_social_button.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/custom_text_form_field.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/notification_permission_dialog.dart';
import 'package:vibe_now/src/presentation/views/common/custom_elevated_button.dart';
import 'package:vibe_now/utils.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isFieldsValid = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onFieldsChanged);
    _passwordController.addListener(_onFieldsChanged);
  }

  void _onFieldsChanged() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isFieldsValid =
          email.isNotEmpty && isValidEmail(email) && password.isNotEmpty&& password.length >= 6;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundVariant,

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0.w),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 58.h),
                  AuthTitle(
                    title: 'Sign In',
                    subtitle: 'Enter you credentials to continue',
                  ),
                  SizedBox(height: 36.h),
                  CustomTextFormField(
                    controller: _emailController,
                    hintText: 'Enter your email',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!isValidEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 18.h),
                  CustomTextFormField(
                    controller: _passwordController,
                    hintText: 'Enter your password',
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your password';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        context.pushNamed(RouteNames.emailVerificationScreen);
                      },
                      child: Text(
                        'Forgot Password?',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.primary,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  PrimaryButton.text(
                    onPressed: _isFieldsValid
                        ? () {
                            context.goNamed(RouteNames.mainNavBar);
                          }
                        : () {},
                    text: 'Get Started',
                    isEnabled: _isFieldsValid,
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    "By signing in or creating an account, you agree to our Terms and Event. Learn more about how we process your data in our privacy and Cookies Policy",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff727272),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  CustomSocialButton(
                    icon: Assets.icons.facebookIc,
                    title: 'Facebook',
                    onTap: () => context.goNamed(RouteNames.mainNavBar),
                  ),
                  SizedBox(height: 12.w),
                  CustomSocialButton(
                    icon: Assets.icons.googleIc,
                    title: 'Google',
                    onTap: () => context.goNamed(RouteNames.mainNavBar),
                  ),
                  SizedBox(height: 12.w),
                  CustomSocialButton(
                    icon: Assets.icons.appleIc,
                    title: 'Apple',
                    onTap: () => context.goNamed(RouteNames.mainNavBar),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        " Don't have an account?",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color(0xff787878),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.pushNamed(RouteNames.signUpScreen);
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color.fromARGB(255, 172, 137, 255),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
