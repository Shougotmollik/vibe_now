import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';

class StepPage extends StatelessWidget {
  final String? title;
  final int stepCount;
  final int currentStep;
  final Widget child;
  final bool? isSkippable;
  final VoidCallback? onSkip;
  final Widget? footer;
  const StepPage({
    required this.child,
    this.title,
    this.stepCount = 7,
    this.currentStep = 1,
    this.footer,
    super.key,
    this.isSkippable = false,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundVariant,
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back_ios),
                ),
              )
            : null,
        backgroundColor: AppColors.backgroundVariant,
        centerTitle: true,
        title: title == null
            ? null
            : Text(title!, style: Theme.of(context).textTheme.headlineMedium),

        actions: [
          isSkippable!
              ? TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'Skip',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      spacing: 4.w,
                      children: [
                        ...List.generate(
                          stepCount,
                          (index) => Expanded(
                            child: Container(
                              height: 4.h,
                              decoration: BoxDecoration(
                                color: index + 1 <= currentStep
                                    ? null
                                    : Colors.white,
                                gradient: index + 1 <= currentStep
                                    ? AppColors.primaryGradient
                                    : null,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(child: child),
                  ],
                ),
              ),
              // child,
              if (footer != null) footer!,
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}


// class StepTitle extends StatelessWidget {
//   const StepTitle({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [

//       ],
//     );
//   }
// }