import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.confirmBtnText,
    required this.onConfirm,
    required this.onCancel,
  });
  final String title;
  final String confirmBtnText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Container(
        padding: EdgeInsets.all(18.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: CustomElevatedButton(
                    onTap: onCancel,
                    buttonText: AppLocalizations.of(context).translate('cancel'),
                    btnColor: Theme.of(context).colorScheme.surfaceVariant,
                    textColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: PrimaryButton.text(
                    onPressed: onConfirm,
                    text: confirmBtnText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
