import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/controller/profile_controller.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/tokens.dart';
import 'package:vibe_now/views/auth/widgets/custom_text_form_field.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';

class ManagePassword extends StatefulWidget {
  const ManagePassword({super.key});

  @override
  State<ManagePassword> createState() => _ManagePasswordState();
}

class _ManagePasswordState extends State<ManagePassword> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordValid = false;
  bool _hasCurrentPassword = false;
  String? _passwordError;
  bool _isSubmitting = false;

  final ProfileController profileController = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    _currentPasswordController.addListener(_onFieldsChanged);
    _newPasswordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _currentPasswordController.removeListener(_onFieldsChanged);
    _newPasswordController.removeListener(_onPasswordChanged);
    _confirmPasswordController.removeListener(_onPasswordChanged);
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onFieldsChanged() {
    setState(() {
      _hasCurrentPassword = _currentPasswordController.text.trim().isNotEmpty;
    });
  }

  void _onPasswordChanged() {
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();

    setState(() {
      // Check minimum length
      if (newPass.length < 6 || confirmPass.length < 6) {
        _isPasswordValid = false;
        _passwordError = 'Password must be at least 6 characters';
      }
      // Check match
      else if (newPass != confirmPass) {
        _isPasswordValid = false;
        _passwordError = 'Passwords do not match';
      } else {
        _isPasswordValid = true;
        _passwordError = null;
      }
    });
  }

  Future<void> _onUpdatePassword() async {
    if (!_isPasswordValid || !_hasCurrentPassword || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    final success = await profileController.changePassword(
      currentPassword: _currentPasswordController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
      confirmPassword: _confirmPasswordController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      AppSnackbar.show(
        message: 'Password updated successfully',
        type: SnackType.warning,
      );
      context.pop();
    } else {
      AppSnackbar.show(
        message: 'Failed to update password. Please try again.',
        type: SnackType.warning,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _isPasswordValid && _hasCurrentPassword && !_isSubmitting;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              spacing: 18.h,
              children: [
                CustomAppBar(title: "Manage Password"),
                SizedBox(height: 24.h),
                CustomTextFormField(
                  hintText: 'Current Password',
                  controller: _currentPasswordController,
                  isPassword: true,
                ),
                CustomTextFormField(
                  hintText: 'New Password',
                  controller: _newPasswordController,
                  isPassword: true,
                ),
                CustomTextFormField(
                  hintText: 'Confirm Password',
                  controller: _confirmPasswordController,
                  isPassword: true,
                ),

                if (_passwordError != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    _passwordError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12.sp,
                    ),
                  ),
                ],

                SizedBox(height: 12.h),

                PrimaryButton.text(
                  onPressed: canSubmit ? _onUpdatePassword : () {},
                  text: _isSubmitting ? 'Updating...' : 'Update Password',
                  isEnabled: canSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
