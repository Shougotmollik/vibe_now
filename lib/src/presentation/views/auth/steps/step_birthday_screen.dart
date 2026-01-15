import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/src/presentation/views/auth/steps/step_gender_screen.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/custom_text_form_field.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/step_page.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/step_title.dart';

class StepBirthdayScreen extends StatefulWidget {
  final int step;
  const StepBirthdayScreen({this.step = 2, super.key});

  @override
  State<StepBirthdayScreen> createState() => _StepBirthdayScreenState();
}

class _StepBirthdayScreenState extends State<StepBirthdayScreen> {
  final TextEditingController _birthdayController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _birthdayController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

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
              pageBuilder: (_, _, _) => StepGenderScreen(step: widget.step + 1),
            ),
          );
        },
        text: 'Continue',
      ),
      isSkippable: true,
      onSkip: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            pageBuilder: (_, __, ___) =>
                StepGenderScreen(step: widget.step + 1),
          ),
        );
      },
      child: Column(
        children: [
          SizedBox(height: 32.h),
          StepTitle(
            title: 'What\'s your birthday?',
            subtitle:
                'Your profile will only show your age, never your full birth date.',
          ),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: AbsorbPointer(
              child: CustomTextFormField(
                controller: _birthdayController,
                hintText: 'DD/MM/YYYY',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
