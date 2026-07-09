import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/controller/auth_controller.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/core/routes/routes.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/localization/app_localizations.dart';
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
  final AuthController controller = Get.find<AuthController>();
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
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              CustomAppBar(title: loc.translate('emailVerification')),
              SizedBox(height: 72.h),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  loc.translate('enterOtp'),
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
              ),

              const Spacer(),

              Obx(
                () => PrimaryButton.text(
                  onPressed: !_isEmailValid
                      ? () {}
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            final result = await controller.forgetPassword(
                              emailAddress: _emailController.text,
                              context: context,
                            );
                            if (result != null && mounted) {
                              appRouter.pushNamed(
                                RouteNames.otpVerificationScreen,
                                extra: result,
                              );
                            }
                          }
                        },
                  text: loc.translate('sendOtp'),
                  isEnabled: _isEmailValid,
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
