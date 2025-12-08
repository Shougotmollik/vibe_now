import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/src/presentation/views/auth/steps/step_birthday_screen.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/custom_text_form_field.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/step_page.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/step_title.dart';

class StepNameScreen extends StatelessWidget {
  final int step;
  const StepNameScreen({this.step = 1, super.key});

  @override
  Widget build(BuildContext context) {
    return StepPage(
      currentStep: step,
      footer: PrimaryButton.text(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              pageBuilder: (_, __, ___) => StepBirthdayScreen(step: step + 1),
            ),
          );
        },
        text: 'Continue',
      ),
      child: Column(
        children: [
          SizedBox(height: 32.h),
          StepTitle(
            title: 'What\'s your name',
            subtitle:
                'This is how others will see you on vibe.now. You won’t be able to change it later.',
          ),
          SizedBox(height: 16.h),
          CustomTextFormField(hintText: 'Enter your name'),
        ],
      ),
    );
  }
}
