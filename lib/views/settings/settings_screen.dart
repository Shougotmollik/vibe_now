import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';
import 'package:vibe_now/views/common/gradient_switch.dart';
import 'package:vibe_now/views/settings/blocked_accounts_screen.dart';
import 'package:vibe_now/views/settings/language_screen.dart';
import 'package:vibe_now/views/settings/manage_password.dart';
import 'package:vibe_now/views/settings/profile_setting_screen.dart';
import 'package:vibe_now/views/settings/terms_and_privacy.dart';
import 'package:vibe_now/views/settings/theme_selection_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool locationSharing = true;
  bool waves = true;
  bool communities = true;
  bool messages = true;
  bool events = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: CustomAppBar(title: 'Settings', canBack: true),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),

                    // Profile Section
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 50.r,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: const NetworkImage(
                                  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
                                ),
                              ),
                              // Positioned(
                              //   bottom: 0,
                              //   right: 0,
                              //   child: Container(
                              //     padding: EdgeInsets.all(6.w),
                              //     decoration: BoxDecoration(
                              //       color: Colors.white,
                              //       shape: BoxShape.circle,
                              //       boxShadow: [
                              //         BoxShadow(
                              //           color: Colors.black.withOpacity(0.1),
                              //           blurRadius: 4,
                              //           offset: const Offset(0, 2),
                              //         ),
                              //       ],
                              //     ),
                              //     // child: Assets.icons.camera2.svg(),
                              //   ),
                              // ),
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
                              // Text('☕', style: TextStyle(fontSize: 16.sp)),
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
                              // Text('🎵', style: TextStyle(fontSize: 16.sp)),
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
                    SizedBox(height: 32.h),

                    // Profile Information
                    _buildMenuItem(
                      icon: Assets.icons.userColor,
                      iconColor: Colors.purple,
                      title: 'Account information',
                      hasArrow: true,
                      isFullRounded: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileSettingScreen(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 12.h),
                    // Profile Information
                    _buildMenuItem(
                      icon: Assets.icons.lock,
                      iconColor: Colors.black,
                      title: 'Subscriptions',
                      hasArrow: true,
                      isFullRounded: true,
                      onTap: () {
                        context.pushNamed(RouteNames.subscriptionScreen);
                      },
                    ),
                    SizedBox(height: 24.h),

                    // Privacy & Safety Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'Privacy & safety',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    _buildSwitchItem(
                      icon: Assets.icons.locationColor,
                      iconColor: Colors.purple,
                      title: 'Location Sharing',
                      subtitle: 'Only active during vibes',
                      value: locationSharing,
                      isTopRound: true,
                      onChanged: (val) {
                        setState(() {
                          locationSharing = val;
                        });
                      },
                    ),

                    _buildMenuItem(
                      icon: Assets.icons.shieldColor,
                      iconColor: Colors.purple,
                      title: 'Blocked',
                      hasArrow: true,
                      isBottomRound: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BlockedAccountsScreen(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 24.h),

                    // Notification Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'Notification',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    _buildSwitchItem(
                      icon: Assets.icons.messageCircleColor,
                      iconColor: Colors.purple,
                      title: 'Messages',
                      value: messages,
                      isTopRound: true,
                      onChanged: (val) {
                        setState(() {
                          messages = val;
                        });
                      },
                    ),

                    _buildSwitchItem(
                      icon: Assets.icons.notificationColor,
                      iconColor: Colors.purple,
                      title: 'Waves',
                      value: waves,
                      onChanged: (val) {
                        setState(() {
                          waves = val;
                        });
                      },
                    ),

                    _buildSwitchItem(
                      icon: Assets.icons.communityColor,
                      iconColor: Colors.purple,
                      title: 'Community',
                      value: communities,
                      onChanged: (val) {
                        setState(() {
                          communities = val;
                        });
                      },
                    ),

                    _buildSwitchItem(
                      icon: Assets.icons.calendarColor,
                      iconColor: Colors.purple,
                      title: 'Events',
                      value: events,
                      isBottomRound: true,
                      onChanged: (val) {
                        setState(() {
                          events = val;
                        });
                      },
                    ),
                    SizedBox(height: 24.h),

                    // App Setting Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'App setting',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    _buildMenuItem(
                      icon: Assets.icons.basketballColor,
                      iconColor: Colors.purple,
                      title: 'Language',
                      isTopRound: true,
                      hasArrow: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LanguageScreen(),
                          ),
                        );
                      },
                    ),

                    _buildMenuItem(
                      icon: Assets.icons.gridColor,
                      iconColor: Colors.purple,
                      title: 'Theme',
                      isBottomRound: true,
                      hasArrow: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ThemeSelectionScreen(),
                          ),
                        );
                      },
                    ),
                    // _buildMenuItem(
                    //   icon: Assets.icons.gridColor,
                    //   iconColor: Colors.purple,
                    //   title: 'Manage Password',
                    //   isBottomRound: true,
                    //   hasArrow: true,
                    //   onTap: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => ManagePassword(),
                    //       ),
                    //     );
                    //   },
                    // ),
                    SizedBox(height: 24.h),

                    // About Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'About',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    _buildMenuItem(
                      icon: Assets.icons.shieldColor,
                      iconColor: Colors.purple,
                      title: 'Terms & Privacy',
                      isFullRounded: true,
                      hasArrow: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TermsAndPrivacy(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 32.h),

                    // Log Out
                    _buildMenuItem(
                      icon: Assets.icons.logoutColor,
                      iconColor: Colors.red,
                      title: 'Log Out',
                      isFullRounded: true,
                      hasArrow: true,
                      onTap: () {
                        _buildLogOutDialog(context);
                      },
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> _buildLogOutDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Are you sure you want to log out?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff908F90),
                  ),
                ),

                SizedBox(height: 20.h),

                Row(
                  children: [
                    Expanded(
                      child: CustomElevatedButton(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        buttonText: "Cancel",
                        btnColor: Color(0xffF2F2F2),
                        textColor: Color(0xFF202020),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: CustomElevatedButton(
                        onTap: () {},
                        buttonText: "Log Out",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required SvgGenImage icon,
    required Color iconColor,
    required String title,
    required bool hasArrow,
    required VoidCallback onTap,
    bool isFullRounded = false,
    bool isTopRound = false,
    bool isBottomRound = false,
  }) {
    BorderRadius borderRadius = isFullRounded
        ? BorderRadius.circular(40.r)
        : BorderRadius.circular(0);
    if (isTopRound) {
      borderRadius = BorderRadius.only(
        topLeft: Radius.circular(14.r),
        topRight: Radius.circular(14.r),
      );
    }
    if (isBottomRound) {
      borderRadius = BorderRadius.only(
        bottomLeft: Radius.circular(14.r),
        bottomRight: Radius.circular(14.r),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            icon.svg(),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            if (hasArrow)
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required SvgGenImage icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool value,
    required Function(bool) onChanged,
    bool isFullRounded = false,
    bool isTopRound = false,
    bool isBottomRound = false,
  }) {
    BorderRadius borderRadius = isFullRounded
        ? BorderRadius.circular(40.r)
        : BorderRadius.circular(0);
    if (isTopRound) {
      borderRadius = BorderRadius.only(
        topLeft: Radius.circular(14.r),
        topRight: Radius.circular(14.r),
      );
    }
    if (isBottomRound) {
      borderRadius = BorderRadius.only(
        bottomLeft: Radius.circular(14.r),
        bottomRight: Radius.circular(14.r),
      );
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          icon.svg(),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          GradientSwitch(
            value: value,
            onChanged: onChanged,
            activeGradient: AppColors.primaryGradient,
            // activeColor: Colors.white,
            // activeTrackColor: Colors.purple,
            // inactiveThumbColor: Colors.white,
            // inactiveTrackColor: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  // Widget _buildNavItem(IconData icon, bool isActive) {
  //   return Icon(
  //     icon,
  //     color: isActive ? Colors.purple : Colors.grey.shade400,
  //     size: 28.sp,
  //   );
  // }
}
