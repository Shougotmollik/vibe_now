import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';

class MemberConfirmationDialog extends StatefulWidget {
  final String title;
  final String confirmBtnText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const MemberConfirmationDialog({
    super.key,
    required this.title,
    required this.confirmBtnText,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<MemberConfirmationDialog> createState() =>
      _MemberConfirmationDialogState();
}

class _MemberConfirmationDialogState extends State<MemberConfirmationDialog> {
  String _selectedReason = 'Spam';

  final List<String> _reasons = [
    'Spam',
    'Violation of rules',
    'Inappropriate behavior',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 18.sp,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
            SizedBox(height: 24.h),
            ..._reasons.map((reason) => _buildRadioOption(reason)),
            SizedBox(height: 32.h),
            Row(
              children: [
                Expanded(
                  child: CustomElevatedButton(
                    onTap: widget.onCancel,
                    buttonText: "Cancel",
                    btnColor: Theme.of(context).colorScheme.surfaceVariant,
                    textColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: PrimaryButton.text(
                    onPressed: widget.onConfirm,
                    text: widget.confirmBtnText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper for the Gradient Radio items
  Widget _buildRadioOption(String title) {
    bool isSelected = _selectedReason == title;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => setState(() => _selectedReason = title),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isSelected
                    ? null
                    : Border.all(
                        color: Theme.of(context).dividerColor, width: 2),
                gradient: isSelected ? AppColors.primaryGradient : null,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 12.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildButton({
  //   required String text,
  //   required VoidCallback onTap,
  //   required bool isGradient,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       height: 48.h,
  //       alignment: Alignment.center,
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(24.r),
  //         color: isGradient ? null : const Color(0xFFF2F2F2),
  //         gradient: isGradient
  //             ? const LinearGradient(
  //                 colors: [Color(0xFF63C2FF), Color(0xFFB066FE)],
  //               )
  //             : null,
  //       ),
  //       child: Text(
  //         text,
  //         style: TextStyle(
  //           color: isGradient ? Colors.white : Colors.black87,
  //           fontWeight: FontWeight.w500,
  //           fontSize: 16.sp,
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
