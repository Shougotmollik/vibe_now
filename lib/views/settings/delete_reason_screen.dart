import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vibe_now/controller/settings_controller.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';
import 'package:vibe_now/views/settings/delete_confirm_screen.dart';

class DeleteReasonScreen extends StatefulWidget {
  const DeleteReasonScreen({super.key, this.isPaused});

  final bool? isPaused;

  @override
  State<DeleteReasonScreen> createState() => _DeleteReasonScreenState();
}

class _DeleteReasonScreenState extends State<DeleteReasonScreen> {
  final SettingsController settingsController = Get.find<SettingsController>();

  List<String> reasons = [
    "I need a short break",
    "I want to try something new",
    "I need to get back to work",
    "I’m not meeting people right now",
    "I’m too busy at the moment",
    "I didn’t get the type of connections I expected",
    "I want to try something new",
    "Other (please tell us more) — free text field",
  ];
  int selectedIndex = -1;
  bool _isSubmitting = false;

  final TextEditingController _explainTEController = TextEditingController();
  final TextEditingController _passwordTEController = TextEditingController();

  @override
  void dispose() {
    _explainTEController.dispose();
    _passwordTEController.dispose();
    super.dispose();
  }

  String get _selectedReason {
    if (selectedIndex >= 0 && selectedIndex < reasons.length) {
      return reasons[selectedIndex];
    }
    return '';
  }

  String get _explanation => _explainTEController.text.trim();
  String get _password => _passwordTEController.text.trim();

  bool get _isPaused => widget.isPaused ?? false;

  Future<void> _handleConfirm() async {
    if (_password.isEmpty) {
      AppSnackbar.show(
        message: 'Please enter your password',
        type: SnackType.info,
      );
      return;
    }

    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    bool success;
    if (_isPaused) {
      success = await settingsController.accountPause(
        reason: _selectedReason,
        explanation: _explanation,
        password: _password,
      );
    } else {
      success = await settingsController.accountDelete(
        reason: _selectedReason,
        explanation: _explanation,
        password: _password,
      );
    }

    setState(() => _isSubmitting = false);
    _passwordTEController.clear();

    if (success && mounted) {
      // Pop the password dialog
      Navigator.of(context).pop();
      // Navigate to the confirm/result screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DeleteConfirmScreen(
            isPaused: _isPaused,
          ),
        ),
      );
    } else if (mounted) {
      AppSnackbar.show(
        message: 'Failed to ${_isPaused ? "pause" : "delete"} account. Please try again.',
        type: SnackType.info,
      );
    }
  }

  void _clearForm() {
    setState(() {
      selectedIndex = -1;
    });
    _explainTEController.clear();
    _passwordTEController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              CustomAppBar(
                title: loc.translate('reason'),
                canBack: true,
              ),

              SizedBox(height: 14.h),

              Text(
                _isPaused
                    ? "Give us a reason why you want to pause the account"
                    : "Give us a reason why you want to delete the account",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 12.h),

              _buildReasonTile(),

              SizedBox(height: 12.h),

              _buildExplainTextField(controller: _explainTEController),
              SizedBox(height: 24.h),
              Row(
                spacing: 8.w,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xffAEAEAE)),
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: CustomElevatedButton(
                        onTap: _clearForm,
                        buttonText: loc.translate('clear'),
                        btnColor: Theme.of(context).colorScheme.surface,
                        textColor: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    child: PrimaryButton.text(
                      onPressed: () => _showPasswordDialog(context),
                      isEnabled: !_isSubmitting,
                      text: loc.translate('save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        contentPadding: EdgeInsets.all(16.w),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "For security reasons, please confirm your password to proceed.",
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            SizedBox(height: 24.h),

            TextFormField(
              obscureText: true,
              controller: _passwordTEController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Enter your password",
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14.sp,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1.w,
                  ),
                ),
              ),
            ),

            SizedBox(height: 18.h),

            SizedBox(
              height: 32.h,
              child: Row(
                spacing: 24.w,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color(0xffAEAEAE),
                        ),
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: CustomElevatedButton(
                        btnColor: Theme.of(context).colorScheme.surface,
                        textColor: Theme.of(context).colorScheme.onSurface,
                        onTap: () => Navigator.pop(dialogContext),
                        buttonText: AppLocalizations.of(context).translate('cancel'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PrimaryButton.text(
                      onPressed: _handleConfirm,
                      text: AppLocalizations.of(context).translate('confirm'),
                      isLoading: _isSubmitting,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExplainTextField({required TextEditingController controller}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xffAEAEAE)),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: "Explain here",
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: 12.h,
            horizontal: 16.w,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildReasonTile() {
    return Expanded(
      child: ListView.builder(
        itemCount: reasons.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  selectedIndex == index
                      ? _selectedCircle()
                      : _unselectedCircle(),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      reasons[index],
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _selectedCircle() {
    return Assets.icons.checkboxGradient.svg(
      width: 22.w,
      height: 22.h,
      fit: BoxFit.cover,
    );
  }

  Widget _unselectedCircle() {
    return Container(
      width: 22.w,
      height: 22.h,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
        shape: BoxShape.circle,
      ),
    );
  }
}
