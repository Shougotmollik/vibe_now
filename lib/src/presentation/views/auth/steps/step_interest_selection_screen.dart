import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/src/presentation/views/auth/steps/step_upload_image_screen.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/option_card.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/step_page.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/step_title.dart';

class StepInterestSelectionScreen extends StatefulWidget {
  final int step;
  const StepInterestSelectionScreen({this.step = 1, super.key});

  @override
  State<StepInterestSelectionScreen> createState() =>
      _StepInterestSelectionScreenState();
}

class _StepInterestSelectionScreenState
    extends State<StepInterestSelectionScreen> {
  // For multiple selection
  final Set<int> selectedIndexes = {};

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
    return StepPage(
      currentStep: widget.step,
      footer: PrimaryButton.text(
        onPressed: () {
          // if (selectedIndexes.isEmpty) return;

          List<OptionModel> selectedOptions = selectedIndexes
              .map((i) => options[i])
              .toList();

          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
              pageBuilder: (_, __, ___) =>
                  StepUploadImageScreen(step: widget.step + 1),
            ),
          );
        },
        text: 'Continue',
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 32.h),

            const StepTitle(
              title: 'What are you into?',
              subtitle: 'You can update your interests anytime.',
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
    );
  }
}
