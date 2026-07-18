import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/controller/profile_controller.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';
import 'package:vibe_now/views/notification/widgets/animated_dialog_content.dart';

class ReportScreen extends StatefulWidget {
  final String? reportedUserId;

  const ReportScreen({super.key, this.reportedUserId});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final List<String> _reasons = [
    'Spam or Misinformation',
    'Hate Speech or Violence',
    'Threats or Harassment',
    'Other',
  ];

  int _selectedIndex = -1;
  final TextEditingController _detailsController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  String _getLocalizedReason(String reason, AppLocalizations loc) {
    switch (reason) {
      case 'Spam or Misinformation':
        return loc.translate('reportSpam');
      case 'Hate Speech or Violence':
        return loc.translate('reportHateSpeech');
      case 'Threats or Harassment':
        return loc.translate('reportThreats');
      case 'Other':
        return loc.translate('others');
      default:
        return reason;
    }
  }

  Future<void> _submitReport() async {
    if (_selectedIndex < 0) {
      AppSnackbar.show(
        message: AppLocalizations.of(context).translate('selectReason'),
        type: SnackType.info,
      );
      return;
    }

    if (widget.reportedUserId == null || widget.reportedUserId!.isEmpty) {
      AppSnackbar.show(
        message: AppLocalizations.of(context).translate('somethingWentWrong'),
        type: SnackType.error,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final reason = _reasons[_selectedIndex];
    final details = _detailsController.text.trim();

    final profileController = Get.find<ProfileController>();
    final success = await profileController.reportUser(
      reportedUserId: widget.reportedUserId!,
      reason: reason,
      details: details.isNotEmpty ? details : reason,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      final loc = AppLocalizations.of(context);
      final reportMessage = '${loc.translate('youHaveReported')}\n\n${loc.translate('youWillNotReceive')}';

      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => Center(
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: AnimatedDialogContent(
              content: reportMessage,
              accept: true,
            ),
          ),
        ),
      );
      if (mounted) {
        context.pop();
      }
    } else {
      AppSnackbar.show(
        message: AppLocalizations.of(context).translate('somethingWentWrong'),
        type: SnackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar(
                title: loc.translate('report'),
                canBack: true,
              ),
              SizedBox(height: 14.h),
              Text(
                loc.translate('whatHappened'),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                loc.translate('reportHint'),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 16.h),
              // Reason list
              Expanded(
                child: ListView.builder(
                  itemCount: _reasons.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIndex = index),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.w),
                        child: Row(
                          children: [
                            _selectedIndex == index
                                ? Assets.icons.checkboxGradient.svg(
                                    width: 22.w,
                                    height: 22.h,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 22.w,
                                    height: 22.h,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Theme.of(context).dividerColor,
                                        width: 1.5,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                _getLocalizedReason(_reasons[index], loc),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Details text field
              if (_selectedIndex >= 0) ...[
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xffAEAEAE)),
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: TextFormField(
                    controller: _detailsController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: loc.translate('reportHint'),
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 16.w,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
              // Buttons
              Row(
                spacing: 8.w,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xffAEAEAE)),
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: CustomElevatedButton(
                        onTap: () {
                          setState(() {
                            _selectedIndex = -1;
                            _detailsController.clear();
                          });
                        },
                        buttonText: loc.translate('clear'),
                        btnColor: Theme.of(context).colorScheme.surface,
                        textColor: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _isSubmitting
                        ? Center(
                            child: SizedBox(
                              width: 24.w,
                              height: 24.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : PrimaryButton.text(
                            onPressed: _submitReport,
                            text: loc.translate('submit'),
                          ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }
}
