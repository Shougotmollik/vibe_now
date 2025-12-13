import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/src/presentation/views/common/custom_app_bar.dart';
import 'package:vibe_now/src/presentation/views/common/custom_elevated_button.dart';

class DeleteReasonScreen extends StatefulWidget {
  const DeleteReasonScreen({super.key});

  @override
  State<DeleteReasonScreen> createState() => _DeleteReasonScreenState();
}

class _DeleteReasonScreenState extends State<DeleteReasonScreen> {
  List<String> reasons = [
    "I need a short break",
    "I want to try something new",
    "I need to get back to work",
    "I’m not meeting people right now",
    "I’m too busy at the moment",
    "I didn’t get the type of connections I expected",
    "I want to try something new",
    "Other (please tell us more) — free text field",
  ];
  int selectedIndex = -1;

  final TextEditingController _explainTEController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              _buildAppBar(),

              SizedBox(height: 14.h),

              Text(
                "Give us a reason why you want to pause the account",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff2a2a2a),
                ),
              ),
              SizedBox(height: 12.h),

              _buildReasonTile(),

              SizedBox(height: 12.h),

              _buildExplainTextField(controller: _explainTEController),
              SizedBox(height: 24.h),
              Row(
                spacing: 8.w,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xffAEAEAE)),
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: CustomElevatedButton(
                        onTap: () {},
                        buttonText: 'Clear',
                        btnColor: Colors.white,
                        textColor: Color(0xff2A2A2A),
                      ),
                    ),
                  ),
                  Expanded(
                    child: PrimaryButton.text(onPressed: () {}, text: 'Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExplainTextField({required TextEditingController controller}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xffAEAEAE)),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: "Explain here",
          hintStyle: TextStyle(fontSize: 14.sp, color: Color(0xffAEAEAE)),
          contentPadding: EdgeInsets.symmetric(
            vertical: 12.h,
            horizontal: 16.w,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildReasonTile() {
    return Expanded(
      child: ListView.builder(
        itemCount: reasons.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  selectedIndex == index
                      ? _selectedCircle()
                      : _unselectedCircle(),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      reasons[index],
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff2a2a2a),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomAppBar(title: "Reason"),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(40.r),
          ),

          child: Text(
            'Send',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _selectedCircle() {
    return Assets.icons.checkboxGradient.svg(
      width: 22.w,
      height: 22.h,
      fit: BoxFit.cover,
    );
  }

  Widget _unselectedCircle() {
    return Container(
      width: 22.w,
      height: 22.h,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        shape: BoxShape.circle,
      ),
    );
  }
}
