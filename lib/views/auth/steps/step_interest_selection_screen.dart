import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vibe_now/controller/onboarding_controller.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/views/auth/steps/step_upload_image_screen.dart';
import 'package:vibe_now/views/auth/widgets/option_card.dart';
import 'package:vibe_now/views/auth/widgets/step_page.dart';
import 'package:vibe_now/views/auth/widgets/step_title.dart';

class StepInterestSelectionScreen extends StatefulWidget {
  final int step;
  const StepInterestSelectionScreen({this.step = 1, super.key});

  @override
  State<StepInterestSelectionScreen> createState() =>
      _StepInterestSelectionScreenState();
}

class _StepInterestSelectionScreenState
    extends State<StepInterestSelectionScreen> {
  final Set<int> selectedIndexes = {};
  final OnBoardingController controller = Get.find<OnBoardingController>();

  final List<OptionModel> options = [
    OptionModel(icon: Assets.icons.coffee, title: "Coffee"),
    OptionModel(icon: Assets.icons.music, title: "Music"),
    OptionModel(icon: Assets.icons.chatting, title: "Chat"),
    OptionModel(icon: Assets.icons.sports, title: "Sports"),
    OptionModel(icon: Assets.icons.book, title: "Books"),
    OptionModel(icon: Assets.icons.camera, title: "Photo"),
    OptionModel(icon: Assets.icons.paintBoard, title: "Art"),
    OptionModel(icon: Assets.icons.nanoTechnology, title: "Tech"),
    OptionModel(icon: Assets.icons.organicFood, title: "Food"),
    OptionModel(icon: Assets.icons.locationColor, title: "Travel"),
    OptionModel(icon: Assets.icons.dumbbell, title: "Fitness"),
    OptionModel(icon: Assets.icons.aiGame, title: "Gaming"),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: StepPage(
        currentStep: widget.step,
        footer: Obx(
          () => PrimaryButton.text(
            onPressed: () async {
              List<OptionModel> selectedOptions = selectedIndexes
                  .map((i) => options[i])
                  .toList();
              controller.interests = selectedOptions
                  .map((e) => e.title)
                  .toList();
              final success = await controller.onboardingDataSubmit();
              if (success) {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                    pageBuilder: (_, __, ___) =>
                        StepUploadImageScreen(step: widget.step + 1),
                  ),
                );
              } else {
                AppSnackbar.show(
                  message: loc.translate('somethingWentWrong'),
                  type: SnackType.info,
                );
              }
            },
            text: loc.translate('continueText'),
            isEnabled: selectedIndexes.isNotEmpty,
            isLoading: controller.isLoading.value,
          ),
        ),
        isSkippable: true,
        onSkip: () async {
          controller.interests = [];
          final success = await controller.onboardingDataSubmit();
          if (success) {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
                pageBuilder: (_, __, ___) =>
                    StepUploadImageScreen(step: widget.step + 1),
              ),
            );
          } else {
            AppSnackbar.show(
              message: loc.translate('somethingWentWrong'),
              type: SnackType.info,
            );
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 32.h),
              StepTitle(
                title: loc.translate('stepInterests'),
                subtitle: loc.translate('selectInterests'),
              ),
              SizedBox(height: 16.h),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.7,
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
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
