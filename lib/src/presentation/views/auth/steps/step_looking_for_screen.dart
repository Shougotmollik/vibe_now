import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/src/presentation/views/auth/steps/step_birthday_screen.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/step_page.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/step_title.dart';

class StepLookingForScreen extends StatefulWidget {
  final int step;
  const StepLookingForScreen({this.step = 1, super.key});

  @override
  State<StepLookingForScreen> createState() => _StepLookingForScreenState();
}

class _StepLookingForScreenState extends State<StepLookingForScreen> {
  @override
  Widget build(BuildContext context) {
    return StepPage(
      currentStep: widget.step,
      footer: PrimaryButton.text(
        onPressed: () {
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
        text: 'Continue',
      ),
      child: Column(
        children: [
          SizedBox(height: 32.h),
          StepTitle(
            title: 'What are you looking for?',
            subtitle: 'No pressure — you can change this anytime.',
          ),
          SizedBox(height: 16.h),
          
        ],
      ),
    );
  }
}
