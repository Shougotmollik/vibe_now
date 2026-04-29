import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';
import 'package:vibe_now/views/settings/delete_confirm_screen.dart';

class DeleteReasonScreen extends StatefulWidget {
  const DeleteReasonScreen({super.key, this.isPaused});

  final bool? isPaused;

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
  final TextEditingController _passwordTEController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // _buildAppBar(),
              CustomAppBar(title: "Reason", canBack: true),

              SizedBox(height: 14.h),

              Text(
                "Give us a reason why you want to pause the account",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSurface,
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
                        btnColor: Theme.of(context).colorScheme.surface,
                        textColor: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    child: PrimaryButton.text(
                      onPressed: () {
                        // Navigator.pop(context);

                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            contentPadding: EdgeInsets.all(16.w),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "For security reasons, please confirm your password to proceed.",
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),

                                SizedBox(height: 24.h),

                                TextFormField(
                                  obscureText: true,
                                  controller: _passwordTEController,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    hintText: "Enter your password",
                                    hintStyle: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontSize: 14.sp,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                      borderSide: BorderSide(
                                        color: Theme.of(context).dividerColor,
                                        width: 1.w,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    } else if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),

                                SizedBox(height: 18.h),

                                SizedBox(
                                  height: 32.h,
                                  child: Row(
                                    spacing: 24.w,
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Color(0xffAEAEAE),
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              24.r,
                                            ),
                                          ),
                                          child: CustomElevatedButton(
                                            btnColor: Theme.of(context).colorScheme.surface,
                                            textColor: Theme.of(context).colorScheme.onSurface,
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            buttonText: 'Cancel',
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: PrimaryButton.text(
                                          onPressed: () {
                                            if (_passwordTEController
                                                .text
                                                .isNotEmpty) {
                                              // Navigator.pop(context);
                                              // Navigator.pop(context);
                                              // context.pushNamed(
                                              //   RouteNames.deleteConfirmScreen,
                                              //   extra: {
                                              //     'isPaused': true,},
                                              // );

                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DeleteConfirmScreen(
                                                        isPaused:
                                                            widget.isPaused,
                                                      ),
                                                ),
                                              );
                                            } else {
                                              AppSnackbar.show(
                                                message:
                                                    'Please enter your password',
                                                type: SnackType.info,
                                              );
                                            }
                                            // // Navigator.pop(context);
                                            _passwordTEController.clear();
                                          },
                                          text: 'Confirm',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      text: 'Save',
                    ),
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
          hintStyle: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
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
                        color: Theme.of(context).colorScheme.onSurface,
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
        border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
        shape: BoxShape.circle,
      ),
    );
  }
}
