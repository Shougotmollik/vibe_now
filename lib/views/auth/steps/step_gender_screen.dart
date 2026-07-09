import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vibe_now/controller/onboarding_controller.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/views/auth/steps/step_looking_for_screen.dart';
import 'package:vibe_now/views/auth/widgets/step_page.dart';
import 'package:vibe_now/views/auth/widgets/step_title.dart';

final Map<String, String> genderMapping = {
  'Man': 'male',
  'Woman': 'female',
  'Beyond Binary': 'other',
  'Prefer not to say': 'prefer_not_to_say',
};

class StepGenderScreen extends StatefulWidget {
  final int step;
  const StepGenderScreen({this.step = 1, super.key});

  @override
  State<StepGenderScreen> createState() => _StepGenderScreenState();
}

class _StepGenderScreenState extends State<StepGenderScreen> {
  String selected = "Man";
  final OnBoardingController controller = Get.find<OnBoardingController>();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return StepPage(
      currentStep: widget.step,
      footer: PrimaryButton.text(
        onPressed: () {
          controller.gender = genderMapping[selected] ?? '';
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              pageBuilder: (_, __, ___) =>
                  StepLookingForScreen(step: widget.step + 1),
            ),
          );
        },
        text: loc.translate('continueText'),
      ),
      isSkippable: true,
      onSkip: () async {
        controller.gender = 'prefer_not_to_say';
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            pageBuilder: (_, __, ___) =>
                StepLookingForScreen(step: widget.step + 1),
          ),
        );
      },
      child: Column(
        children: [
          SizedBox(height: 32.h),
          StepTitle(
            title: loc.translate('stepGender'),
            subtitle: loc.translate('stepGender'),
          ),
          SizedBox(height: 16.h),
          _buildRadio(loc.translate('male')),
          _buildRadio(loc.translate('female')),
          _buildRadio(loc.translate('other')),
          _buildRadio(loc.translate('preferNotToSay')),
        ],
      ),
    );
  }

  Widget _buildRadio(String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          setState(() {
            selected = label;
          });
        },
        child: Row(
          children: [
            selected == label
                ? Assets.icons.gradientCheck.svg(width: 20.h, height: 20.h)
                : Assets.icons.uncheckedCircle.svg(width: 20.h, height: 20.h),
            SizedBox(width: 8.w),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w400,
                color: selected == label
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
