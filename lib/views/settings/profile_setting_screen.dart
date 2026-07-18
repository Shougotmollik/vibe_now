import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/controller/profile_controller.dart';
import 'package:vibe_now/controller/settings_controller.dart';
import 'package:vibe_now/core/helper/helper.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/tokens.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/gen/assets.gen.dart' as svgs;
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/utils.dart' as utils;
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';
import 'package:vibe_now/views/common/interest_chip.dart';
import 'package:vibe_now/views/settings/delete_confirm_screen.dart';
import 'package:vibe_now/views/settings/delete_reason_screen.dart';
import 'package:vibe_now/views/settings/edit_profile_screen.dart';
import 'package:vibe_now/views/settings/manage_password.dart';
import 'package:vibe_now/views/settings/pause_profile_screen.dart';

class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({super.key});

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  final TextEditingController _passwordTEController = TextEditingController();
  final ProfileController profileController = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar(title: loc.translate('accountInformation')),
                SizedBox(height: 16.h),
                Obx(() {
                  final account = profileController.account.value;
                  final userProfile = account?.profile;
                  final fullName = userProfile?.fullName.isNotEmpty == true
                      ? utils.titleCase(userProfile!.fullName)
                      : 'User';
                  final email = account?.email ?? '';
                  final avatarUrl = userProfile?.primaryPhoto?.fullUrl;

                  return Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50.r),
                              child: avatarUrl != null && avatarUrl.isNotEmpty
                                  ? Image.network(
                                      avatarUrl,
                                      width: 78.w,
                                      height: 78.w,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
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
                          fullName,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (email.isNotEmpty)
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
                SizedBox(height: 18.h),
                SizedBox(height: 12.h),
                _buildOption(
                  context,
                  title: loc.translate('changeYourPassword'),
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
                  title: loc.translate('pauseYourAccount'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DeleteReasonScreen(isPaused: true),
                      ),
                    );
                  },
                ),
                SizedBox(height: 12.h),
                _buildOption(
                  context,
                  title: loc.translate('deleteYourAccount'),
                  onTap: () {
                    context.pushNamed(RouteNames.reasonScreen);
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
    final loc = AppLocalizations.of(context);
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
            loc.translate('deleteConfirmation'),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          SizedBox(height: 8.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              loc.translate('deleteAccountDesc'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          SizedBox(height: 24.h),

          SizedBox(
            height: 28.h,
            child: Row(
              spacing: 24.w,
              children: [
                Expanded(
                  child: CustomElevatedButton(
                    btnColor: Theme.of(context).colorScheme.surfaceVariant,
                    textColor: Theme.of(context).colorScheme.onSurface,
                    onTap: () => Navigator.pop(context),
                    buttonText: loc.translate('cancel'),
                  ),
                ),

                Expanded(
                  child: PrimaryButton.text(
                    onPressed: () {
                      context.pushNamed(RouteNames.reasonScreen);
                      Navigator.pop(context);
                    },
                    text: loc.translate('delete'),
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
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w400,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.h,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
