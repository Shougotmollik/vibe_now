import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/controller/auth_controller.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/core/routes/routes.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/tokens.dart';
import 'package:vibe_now/views/auth/widgets/custom_text_form_field.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthController controller = Get.find<AuthController>();
  late Map<String, String> data;
  String secretKey = "";
  String userId = "";

  // bool _isFieldsFilled = true;
  bool _isPasswordValid = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onPasswordChanged);
  }

  @override
  void didChangeDependencies() {
    data = GoRouterState.of(context).extra as Map<String, String>;
    secretKey = data['secret_key'] ?? '';
    userId = data['user_id'] ?? '';
    super.didChangeDependencies();
  }

  void _onPasswordChanged() {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    setState(() {
      _isPasswordValid =
          newPassword.isNotEmpty &&
          confirmPassword.isNotEmpty &&
          newPassword == confirmPassword;
    });
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.surfaceVariant,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 18.h,
            children: [
              SizedBox(height: 24.h),
              Text(
                "Set New Password",
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 24.h),

              CustomTextFormField(
                controller: _newPasswordController,
                hintText: 'Enter New Password',
              ),
              CustomTextFormField(
                controller: _confirmPasswordController,
                hintText: 'Enter Confirm Password',
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              Spacer(),
              Obx(
                () => PrimaryButton.text(
                  onPressed: !_isPasswordValid
                      ? () {}
                      : () async {
                          final result = await controller.resetPassword(
                            newPassword: _newPasswordController.text,
                            confirmPassword: _confirmPasswordController.text,
                            secretKey: secretKey,
                            userId: userId,
                            context: context,
                          );
                          if (result && mounted) {
                            appRouter.goNamed(RouteNames.signInScreen);
                          }
                        },
                  text: 'Set Password',
                  isEnabled: _isPasswordValid,
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
