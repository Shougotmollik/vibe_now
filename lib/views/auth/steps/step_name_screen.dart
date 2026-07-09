import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vibe_now/controller/onboarding_controller.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/views/auth/steps/step_birthday_screen.dart';
import 'package:vibe_now/views/auth/widgets/custom_text_form_field.dart';
import 'package:vibe_now/views/auth/widgets/step_page.dart';
import 'package:vibe_now/views/auth/widgets/step_title.dart';

class StepNameScreen extends StatefulWidget {
  final int step;

  const StepNameScreen({this.step = 1, super.key});

  @override
  State<StepNameScreen> createState() => _StepNameScreenState();
}

class _StepNameScreenState extends State<StepNameScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isNameFilled = true;
  final OnBoardingController controller = Get.find<OnBoardingController>();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    setState(() {
      _isNameFilled = _nameController.text.trim().isEmpty;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return StepPage(
      currentStep: widget.step,
      footer: PrimaryButton.text(
        onPressed: _isNameFilled
            ? () {}
            : () {
                if (_nameController.text.isNotEmpty) {
                  controller.fullName = _nameController.text;
                  print("--------name ${controller.fullName}");
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                      pageBuilder: (_, __, ___) =>
                          StepBirthdayScreen(step: widget.step + 1),
                    ),
                  );
                } else {
                  AppSnackbar.show(
                    message: loc.translate('enterYourName'),
                    type: SnackType.info,
                  );
                }
              },
        text: loc.translate('continueText'),
        isEnabled: !_isNameFilled,
      ),
      isSkippable: false,
      onSkip: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            pageBuilder: (_, __, ___) =>
                StepBirthdayScreen(step: widget.step + 1),
          ),
        );
      },

      child: Column(
        children: [
          SizedBox(height: 32.h),
          StepTitle(
            title: loc.translate('stepName'),
            subtitle: loc.translate('enterYourName'),
          ),
          SizedBox(height: 16.h),
          CustomTextFormField(
            controller: _nameController,
            hintText: loc.translate('enterYourName'),
          ),
        ],
      ),
    );
  }
}
