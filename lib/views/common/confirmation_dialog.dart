import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
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
      backgroundColor: Colors.white,
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
                color: Colors.black54,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: CustomElevatedButton(
                    onTap: onCancel,
                    buttonText: "Cancel",

                    btnColor: const Color(0xFFF2F2F2),
                    textColor: Colors.black,
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
