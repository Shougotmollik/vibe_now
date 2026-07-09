import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/controller/auth_controller.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/core/routes/routes.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/views/auth/widgets/auth_title.dart';
import 'package:vibe_now/views/auth/widgets/custom_social_button.dart';
import 'package:vibe_now/views/auth/widgets/custom_text_form_field.dart';
import 'package:vibe_now/utils.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isFieldsValid = false;
  final AuthController controller = Get.find<AuthController>();

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
          email.isNotEmpty &&
          isValidEmail(email) &&
          password.isNotEmpty &&
          password.length >= 6;
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
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0.w),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 58.h),
                  AuthTitle(
                    title: loc.translate('signUp'),
                    subtitle: loc.translate('createAccount'),
                  ),
                  SizedBox(height: 36.h),
                  CustomTextFormField(
                    controller: _emailController,
                    hintText: loc.translate('enterEmail'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return loc.translate('pleaseEnterEmail');
                      }
                      if (!isValidEmail(value)) {
                        return loc.translate('pleaseEnterValidEmail');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 18.h),
                  CustomTextFormField(
                    controller: _passwordController,
                    hintText: loc.translate('enterPassword'),
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return loc.translate('pleaseEnterPassword');
                      } else if (value.length < 6) {
                        return loc.translate('passwordMinLength');
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24.h),
                  Obx(
                    () => PrimaryButton.text(
                      onPressed: !_isFieldsValid
                          ? () {}
                          : () async {
                              final data = await controller.signup(
                                emailAddress: _emailController.text,
                                password: _passwordController.text,
                                context: context,
                              );

                              if (data != null && mounted) {
                                appRouter.pushNamed(
                                  RouteNames.signupOtpVerificationScreen,
                                  extra: data,
                                );
                              }
                            },
                      text: loc.translate('getStarted'),
                      isEnabled: _isFieldsValid,
                      isLoading: controller.isLoading.value,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    loc.translate('createAccount'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  CustomSocialButton(
                    icon: Assets.icons.facebookIc,
                    title: 'Facebook',
                    onTap: () => context.goNamed(RouteNames.stepNameScreen),
                  ),
                  SizedBox(height: 12.h),
                  CustomSocialButton(
                    icon: Assets.icons.googleIc,
                    title: 'Google',
                    onTap: () => context.goNamed(RouteNames.stepNameScreen),
                  ),
                  SizedBox(height: 12.h),
                  CustomSocialButton(
                    icon: Assets.icons.appleIc,
                    title: 'Apple',
                    onTap: () => context.goNamed(RouteNames.stepNameScreen),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        loc.translate('alreadyHaveAccount'),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.pushNamed(RouteNames.signInScreen);
                        },
                        child: Text(
                          loc.translate('signIn'),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
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
