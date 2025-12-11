import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/src/presentation/views/auth/steps/step_interest_selection_screen.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/option_card.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/step_page.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/step_title.dart';

class StepLookingForScreen extends StatefulWidget {
  final int step;
  const StepLookingForScreen({this.step = 1, super.key});

  @override
  State<StepLookingForScreen> createState() => _StepLookingForScreenState();
}

class _StepLookingForScreenState extends State<StepLookingForScreen> {
  int? selectedIndex;

  final List<OptionModel> options = [
    OptionModel(icon: Assets.icons.friendShip, title: "Friendship"),
    OptionModel(icon: Assets.icons.calender, title: "Event"),
    OptionModel(icon: Assets.icons.community, title: "Community"),
    OptionModel(icon: Assets.icons.relationShip, title: "Relationship"),
    OptionModel(icon: Assets.icons.stashQuestion, title: "I’m not sure yet"),
  ];

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
                  StepInterestSelectionScreen(step: widget.step + 1),
            ),
          );
        },
        text: 'Continue',
      ),
      child: Column(
        children: [
          SizedBox(height: 32.h),

          const StepTitle(
            title: 'What are you looking for?',
            subtitle: 'No pressure — you can change this anytime.',
          ),

          SizedBox(height: 16.h),

          Expanded(
            child: GridView.builder(
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
                  isSelected: selectedIndex == index,
                  onTap: () {
                    setState(() => selectedIndex = index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// class OptionCard extends StatelessWidget {
//   final OptionModel model;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const OptionCard({
//     required this.model,
//     required this.isSelected,
//     required this.onTap,
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.all(2),
//         decoration: BoxDecoration(
//           gradient: isSelected
//               ? const LinearGradient(
//                   colors: [
//                     Color(0xFF8663F6),
//                     Color(0xFFC470F5),
//                     Color(0XFF57C2FF),
//                   ],
//                   begin: Alignment.topRight,
//                   end: Alignment.bottomLeft,
//                 )
//               : null,
//           borderRadius: BorderRadius.circular(24.r),
//         ),
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
//           decoration: BoxDecoration(
//             color: const Color(0xffFEFEFE),
//             borderRadius: BorderRadius.circular(22.r),
//           ),
//           child: Center(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 model.icon.svg(width: 32.w, height: 32.h),
//                 SizedBox(height: 7.h),
//                 Text(
//                   model.title,
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.w400,
//                     color: const Color(0xff6E6E6E),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class OptionModel {
//   final SvgGenImage icon;
//   final String title;

//   OptionModel({required this.icon, required this.title});
// }
