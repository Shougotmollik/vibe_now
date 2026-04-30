import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
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
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
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
                  onPressed: _isPasswordValid
                      ? () {
                          context.pop();
                        }
                      : () {},
                  text: 'Update Password',
                  isEnabled: _isPasswordValid,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
