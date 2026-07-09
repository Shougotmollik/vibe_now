import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vibe_now/controller/onboarding_controller.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/views/auth/steps/step_interest_selection_screen.dart';
import 'package:vibe_now/views/auth/widgets/option_card.dart';
import 'package:vibe_now/views/auth/widgets/step_page.dart';
import 'package:vibe_now/views/auth/widgets/step_title.dart';

class StepLookingForScreen extends StatefulWidget {
  final int step;
  const StepLookingForScreen({this.step = 1, super.key});

  @override
  State<StepLookingForScreen> createState() => _StepLookingForScreenState();
}

class _StepLookingForScreenState extends State<StepLookingForScreen> {
  int? selectedIndex;
  final Set<int> selectedIndexes = {};
  final OnBoardingController controller = Get.find<OnBoardingController>();

  final List<OptionModel> options = [
    OptionModel(icon: Assets.icons.friendShip, title: "Friendship"),
    OptionModel(icon: Assets.icons.calender, title: "Event"),
    OptionModel(icon: Assets.icons.community, title: "Community"),
    OptionModel(icon: Assets.icons.relationShip, title: "Relationship"),
    OptionModel(icon: Assets.icons.stashQuestion, title: "I\u2019m not sure yet"),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: StepPage(
        currentStep: widget.step,
        footer: PrimaryButton.text(
          onPressed: () {
            List<OptionModel> selectedOptions = selectedIndexes
                .map((i) => options[i])
                .toList();
            controller.lookingFor = selectedOptions
                .map((e) => e.title)
                .toList();
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
                pageBuilder: (_, __, ___) =>
                    StepInterestSelectionScreen(step: widget.step + 1),
              ),
            );
          },
          text: loc.translate('continueText'),
          isEnabled: selectedIndexes.isNotEmpty,
        ),
        isSkippable: true,
        onSkip: () {
          controller.lookingFor = [];
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              pageBuilder: (_, __, ___) =>
                  StepInterestSelectionScreen(step: widget.step + 1),
            ),
          );
        },
        child: Column(
          children: [
            SizedBox(height: 32.h),
            StepTitle(
              title: loc.translate('stepLookingFor'),
              subtitle: loc.translate('stepLookingFor'),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.4,
                ),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  return OptionCard(
                    model: options[index],
                    isSelected: selectedIndexes.contains(index),
                    onTap: () {
                      setState(() {
                        if (selectedIndexes.contains(index)) {
                          selectedIndexes.remove(index);
                        } else {
                          selectedIndexes.add(index);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
