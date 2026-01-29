import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/tokens.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/custom_text_form_field.dart';
import 'package:vibe_now/src/presentation/views/common/custom_app_bar.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isFieldsFilled = true;

  @override
  void initState() {
    super.initState();
    _confirmPasswordController.addListener(_onConfirmPasswordChanged);
  }

  void _onConfirmPasswordChanged() {
    setState(() {
      _isFieldsFilled =
          _confirmPasswordController.text.trim().isEmpty &&
          _newPasswordController.text.trim().isEmpty;
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
        color: AppColors.backgroundVariant,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: SafeArea(
          child: Column(
            spacing: 18.h,
            children: [
              CustomAppBar(title: "Set New Password", canBack: false),
              SizedBox(height: 24.h),

              // CustomTextFormField(hintText: 'Current Password'),
              CustomTextFormField(
                controller: _newPasswordController,
                hintText: 'Enter New Password',
              ),
              CustomTextFormField(
                controller: _confirmPasswordController,
                hintText: 'Enter Confirm Password',
              ),

              Spacer(),
              PrimaryButton.text(
                onPressed: _isFieldsFilled
                    ? () {}
                    : () {
                        context.goNamed(RouteNames.signInScreen);
                      },
                text: 'Set Password',
                isEnabled: !_isFieldsFilled,
              ),
              SizedBox(height: 48.h),
            ],
          ),
        ),
      ),
    );
  }
}
