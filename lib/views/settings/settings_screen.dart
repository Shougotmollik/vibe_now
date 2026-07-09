import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/controller/auth_controller.dart';
import 'package:vibe_now/controller/profile_controller.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/utils.dart' as utils;
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';
import 'package:vibe_now/views/common/gradient_switch.dart';
import 'package:vibe_now/views/settings/blocked_accounts_screen.dart';
import 'package:vibe_now/views/settings/language_screen.dart';
import 'package:vibe_now/views/settings/manage_password.dart';
import 'package:vibe_now/views/settings/profile_setting_screen.dart';
import 'package:vibe_now/views/settings/terms_and_privacy.dart';
import 'package:vibe_now/views/settings/theme_selection_screen.dart';
import 'package:vibe_now/views/settings/widget/respect_score_card.dart';

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

  final AuthController authController = Get.find<AuthController>();
  final ProfileController profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: CustomAppBar(title: loc.translate('settings'), canBack: true),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),

                    // Profile Section
                    Obx(() {
                      final userProfile =
                          profileController.account.value?.profile;
                      final fullName = userProfile?.fullName.isNotEmpty == true
                          ? utils.titleCase(userProfile!.fullName)
                          : loc.translate('defaultUserName');
                      final avatarUrl = userProfile?.primaryPhoto?.fullUrl;
                      final bio = userProfile?.bio ?? '';

                      return Center(
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 50.r,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.surfaceVariant,
                                  backgroundImage:
                                      (avatarUrl != null && avatarUrl.isNotEmpty
                                              ? NetworkImage(avatarUrl)
                                              : const NetworkImage(
                                                  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
                                                ))
                                          as ImageProvider,
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              fullName,
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            if (bio.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24.w),
                                child: Text(
                                  bio,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                    SizedBox(height: 32.h),
                    Obx(() {
                      final userProfile =
                          profileController.account.value?.profile;
                      final trustScore =
                          userProfile?.trustedScore?.score ?? 0.0;
                      final meetsCount =
                          userProfile?.trustedScore?.meetsCount ?? 0;
                      return TrustScoreCard(
                        score: trustScore,
                        meetsCount: meetsCount,
                      );
                    }),
                    SizedBox(height: 24.h),
                    // Profile Information
                    _buildMenuItem(
                      icon: Assets.icons.userColor,
                      iconColor: Colors.purple,
                      title: loc.translate('account'),
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
                    _buildMenuItem(
                      icon: Assets.icons.lock,
                      iconColor: Theme.of(context).colorScheme.onSurface,
                      title: loc.translate('subscription'),
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
                        loc.translate('privacy'),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    _buildSwitchItem(
                      icon: Assets.icons.locationColor,
                      iconColor: Colors.purple,
                      title: loc.translate('locationSharing'),
                      subtitle: loc.translate('locationSharingDesc'),
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
                      title: loc.translate('blocked'),
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
                        loc.translate('notifications'),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    _buildSwitchItem(
                      icon: Assets.icons.messageCircleColor,
                      iconColor: Colors.purple,
                      title: loc.translate('messages'),
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
                      title: loc.translate('waves'),
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
                      title: loc.translate('community'),
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
                      title: loc.translate('events'),
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
                        loc.translate('appSetting'),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    _buildMenuItem(
                      icon: Assets.icons.basketballColor,
                      iconColor: Colors.purple,
                      title: loc.translate('language'),
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
                      title: loc.translate('theme'),
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
                    SizedBox(height: 24.h),

                    // About Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        loc.translate('about'),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    _buildMenuItem(
                      icon: Assets.icons.shieldColor,
                      iconColor: Colors.purple,
                      title: loc.translate('termsAndPrivacy'),
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
                      title: loc.translate('logOut'),
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
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context).translate('areYouSureLogOut'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                        buttonText: AppLocalizations.of(context).translate('cancel'),
                        btnColor: Theme.of(context).colorScheme.surfaceVariant,
                        textColor: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: CustomElevatedButton(
                        onTap: () {
                          authController.logout();
                        },
                        buttonText: AppLocalizations.of(context).translate('logOut'),
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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: borderRadius,
          border: Border.all(color: Theme.of(context).dividerColor),
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
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (hasArrow)
              Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(0.5),
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: borderRadius,
        border: Border.all(color: Theme.of(context).dividerColor),
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
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
