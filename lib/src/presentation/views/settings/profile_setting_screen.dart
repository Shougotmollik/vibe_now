import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/gen/assets.gen.dart' as svgs;
import 'package:vibe_now/src/presentation/views/common/custom_app_bar.dart';
import 'package:vibe_now/src/presentation/views/common/custom_elevated_button.dart';
import 'package:vibe_now/src/presentation/views/common/interest_chip.dart';
import 'package:vibe_now/src/presentation/views/settings/edit_profile_screen.dart';

class ProfileSettingScreen extends StatelessWidget {
  const ProfileSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                CustomAppBar(title: 'Settings'),
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
                              height: 78.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Assets.icons.camera2.svg(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Jhon Gomes',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Assets.icons.coffeeColor.svg(height: 16.h),
                          SizedBox(width: 4.w),
                          Text(
                            'Coffee enthusiast   |',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Assets.icons.musicColor.svg(height: 16.h),
                          SizedBox(width: 4.w),
                          Text(
                            'Music lover',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 28.h),

                Text(
                  'Interests',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Color(0XFF555555),
                  ),
                ),
                SizedBox(height: 12.h),

                // Interest Tags
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    InterestChip(icon: Assets.icons.kitty, label: 'Pets'),
                    InterestChip(icon: Assets.icons.filmWheel, label: 'Films'),
                    InterestChip(icon: Assets.icons.coffee, label: 'Coffee'),
                  ],
                ),
                SizedBox(height: 28.h),

                Text(
                  'Account Information',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Color(0XFF555555),
                  ),
                ),
                SizedBox(height: 12.h),

                _buildProfileInfo(label: "Your name", value: "Jhon Gomes"),
                SizedBox(height: 12.h),
                _buildProfileInfo(
                  label: "Email",
                  value: "jhon.gomes@example.com",
                ),
                SizedBox(height: 12.h),
                _buildProfileInfo(
                  label: "Password",
                  value: "*****************",
                ),
                SizedBox(height: 12.h),

                Container(
                  width: double.infinity,
                  height: 54.h,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xffE0E0E0)),
                    borderRadius: BorderRadius.circular(40.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Pause your Profile",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Color(0xFF202020),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16.h,
                        color: Color(0xFFCFCFCF),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 28.h),
                Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Color(0XFF555555),
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  width: double.infinity,
                  height: 72.h,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xffE0E0E0)),
                    borderRadius: BorderRadius.circular(40.r),
                  ),
                  child: Row(
                    spacing: 8.w,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Color(0xffEAF0FB),
                          shape: BoxShape.circle,
                        ),

                        child: svgs.Assets.icons.locationColor.svg(
                          height: 20.h,
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 12.w),
                          Text(
                            'Started a vibe at Central Park',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Color(0xff171135),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '2 hours ago',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Color(0xff908F90),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  width: double.infinity,
                  height: 72.h,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xffE0E0E0)),
                    borderRadius: BorderRadius.circular(40.r),
                  ),
                  child: Row(
                    spacing: 8.w,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Color(0xffEAF0FB),
                          shape: BoxShape.circle,
                        ),

                        child: svgs.Assets.icons.calendarColor.svg(
                          height: 20.h,
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 12.w),
                          Text(
                            'Met with Sarah for coffee',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Color(0xff171135),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '1 day ago',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Color(0xff908F90),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 80.h),

                CustomElevatedButton(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(),
                      ),
                    );
                  },
                  buttonText: 'Edit Profile',
                ),
                SizedBox(height: 80.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfo({required String label, required String value}) {
    return Container(
      width: double.infinity,
      height: 70.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),

      decoration: BoxDecoration(
        border: Border.all(color: Color(0xffE0E0E0)),
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              color: Color(0xff202020),
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: Color(0xff908F90),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
