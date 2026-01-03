import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/auth_title.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/custom_social_button.dart';
import 'package:vibe_now/src/presentation/views/auth/widgets/notification_permission_dialog.dart';
import 'package:vibe_now/src/presentation/views/common/custom_elevated_button.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundVariant,

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0.w),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 120.h),
                AuthTitle(title: 'Sign In', subtitle: 'Create your account'),
                SizedBox(height: 150.h),
                Text(
                  "By signing in or creating an account, you agree to our Terms and Event. Learn more about how we process your data in our privacy and Cookies Policy",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff727272),
                  ),
                ),

                SizedBox(height: 32.h),
                CustomSocialButton(
                  icon: Assets.icons.facebookIc,
                  title: 'Facebook',
                  onTap: () => context.pushNamed(RouteNames.stepNameScreen),
                ),
                SizedBox(height: 12.h),
                CustomSocialButton(
                  icon: Assets.icons.googleIc,
                  title: 'Google',
                  onTap: () => context.pushNamed(RouteNames.stepNameScreen),
                ),
                SizedBox(height: 12.h),
                CustomSocialButton(
                  icon: Assets.icons.appleIc,
                  title: 'Apple',
                  onTap: () => context.pushNamed(RouteNames.stepNameScreen),
                ),
                SizedBox(height: 12.h),
                TextButton(
                  onPressed: () {
                    context.pushNamed(RouteNames.signUpScreen);
                  },
                  child: Text(
                    'Having trouble in sign up?',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff787878),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Future<dynamic> _buildDialogSection(BuildContext context) {
  //   return showDialog(
  //     context: context,
  //     barrierDismissible: true,
  //     builder: (_) {
  //       return Center(
  //         child: Dialog(
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(20.r),
  //           ),
  //           elevation: 0,
  //           backgroundColor: Colors.transparent,
  //           child: NotificationPermissionDialog(parentContext: context),
  //         ),
  //       );
  //     },
  //   );
  // }
}
