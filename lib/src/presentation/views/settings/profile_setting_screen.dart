import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/helper/helper.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/gen/assets.gen.dart' as svgs;
import 'package:vibe_now/src/presentation/views/common/custom_app_bar.dart';
import 'package:vibe_now/src/presentation/views/common/custom_elevated_button.dart';
import 'package:vibe_now/src/presentation/views/common/interest_chip.dart';
import 'package:vibe_now/src/presentation/views/settings/delete_reason_screen.dart';
import 'package:vibe_now/src/presentation/views/settings/edit_profile_screen.dart';
import 'package:vibe_now/src/presentation/views/settings/manage_password.dart';
import 'package:vibe_now/src/presentation/views/settings/pause_profile_screen.dart';

class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({super.key});

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  final TextEditingController _passwordTEController = TextEditingController();
  // File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                CustomAppBar(title: 'Account Information'),
                SizedBox(height: 16.h),
                // Profile Section
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50.r),
                            child: Image.network(
                              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
                              width: 78.w,
                              height: 78.w,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Jhon Gomes',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'john.gomes@me.com',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18.h),
                // Text(
                //   'Account Information',
                //   style: TextStyle(
                //     fontSize: 14.sp,
                //     fontWeight: FontWeight.w400,
                //     color: Color(0XFF555555),
                //   ),
                // ),
                SizedBox(height: 12.h),
                _buildOption(
                  context,
                  title: 'Change Your Password',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ManagePassword()),
                    );
                  },
                ),
                SizedBox(height: 12.h),

                _buildOption(
                  context,
                  title: 'Pause Your Account',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeleteReasonScreen(),
                      ),
                    );
                  },
                ),
                SizedBox(height: 12.h),
                _buildOption(
                  context,
                  title: 'Delete Your Account',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return _buildDeleteDialog(context);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteDialog(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      contentPadding: EdgeInsets.all(16.w),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Assets.icons.trash.svg(
                width: 32.w,
                height: 32.w,
                color: Colors.white,
              ),
            ),
          ),

          SizedBox(height: 16.h),

          Text(
            "Delete Confirmation",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),

          SizedBox(height: 8.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              "You can delete your account, but please note the process may take some time to complete. Once deleted, it cannot be undone later.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Color(0xff908F90)),
            ),
          ),

          SizedBox(height: 24.h),

          // Buttons
          SizedBox(
            height: 28.h,
            child: Row(
              spacing: 24.w,
              children: [
                Expanded(
                  child: CustomElevatedButton(
                    onTap: () => Navigator.pop(context),
                    buttonText: 'Cancel',
                  ),
                ),

                Expanded(
                  child: PrimaryButton.text(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          contentPadding: EdgeInsets.all(16.w),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Confirm your password to delete your account",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),

                              SizedBox(height: 36.h),

                              TextFormField(
                                obscureText: true,
                                controller: _passwordTEController,
                                decoration: InputDecoration(
                                  hintText: "Enter your password",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14.sp,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 1.w,
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 18.h),

                              SizedBox(
                                height: 28.h,
                                child: Row(
                                  spacing: 24.w,
                                  children: [
                                    Expanded(
                                      child: CustomElevatedButton(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        buttonText: 'Cancel',
                                      ),
                                    ),
                                    Expanded(
                                      child: PrimaryButton.text(
                                        onPressed: () {
                                          context.pushNamed(
                                            RouteNames.reasonScreen,
                                          );
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          _passwordTEController.clear();
                                        },
                                        text: 'Delete',
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
                    text: 'Delete',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xffE0E0E0)),
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                color: Color(0xFF202020),
                fontWeight: FontWeight.w400,
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16.h, color: Color(0xFFCFCFCF)),
          ],
        ),
      ),
    );
  }

  // Widget _buildPauseAccountSection(BuildContext context) {
  //   return GestureDetector(
  //     onTap: () {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (context) => ManagePassword()),
  //       );
  //     },
  //     child: Container(
  //       width: double.infinity,
  //       padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
  //       decoration: BoxDecoration(
  //         border: Border.all(color: Color(0xffE0E0E0)),
  //         borderRadius: BorderRadius.circular(40.r),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Text(
  //             "Pause Your Account",
  //             style: TextStyle(
  //               fontSize: 16.sp,
  //               color: Color(0xFF202020),
  //               fontWeight: FontWeight.w400,
  //             ),
  //           ),
  //           Icon(Icons.arrow_forward_ios, size: 16.h, color: Color(0xFFCFCFCF)),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildProfileInfo({required String label, required String value}) {
  //   return Container(
  //     width: double.infinity,
  //     // height: 70.h,
  //     padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),

  //     decoration: BoxDecoration(
  //       border: Border.all(color: Color(0xffE0E0E0)),
  //       borderRadius: BorderRadius.circular(40.r),
  //     ),
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           label,
  //           style: TextStyle(
  //             fontSize: 16.sp,
  //             color: Color(0xff202020),
  //             fontWeight: FontWeight.w400,
  //           ),
  //         ),
  //         Text(
  //           value,
  //           style: TextStyle(
  //             fontSize: 14.sp,
  //             color: Color(0xff908F90),
  //             fontWeight: FontWeight.w400,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  // Widget _buildOptionTile({required String title, VoidCallback? onTap}) {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 20.h),
  //     child: GestureDetector(
  //       onTap: onTap,
  //       behavior: HitTestBehavior.translucent,
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Text(
  //             title,
  //             style: TextStyle(
  //               fontSize: 16.sp,
  //               color: Color(0xff2A2A2A),
  //               fontWeight: FontWeight.w400,
  //             ),
  //           ),

  //           Icon(Icons.arrow_forward_ios, size: 20.h, color: Color(0xFFCFCFCF)),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
