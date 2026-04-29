import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vibe_now/controller/theme_controller.dart';
import 'package:vibe_now/design_system/tokens/tokens.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/common/gradient_switch.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              const CustomAppBar(title: "Mode"),
              SizedBox(height: 20.h),
              Obx(() => Container(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Column(
                      children: [
                        _buildThemeSwitcher(
                          context: context,
                          title: "System",
                          value: themeController.themeMode == ThemeMode.system,
                          onChanged: (value) {
                            if (value) {
                              themeController.setThemeMode(ThemeMode.system);
                            }
                          },
                        ),
                        Divider(height: 1.h, color: Theme.of(context).dividerColor),
                        _buildThemeSwitcher(
                          context: context,
                          title: "Light",
                          value: themeController.themeMode == ThemeMode.light,
                          onChanged: (value) {
                            if (value) {
                              themeController.setThemeMode(ThemeMode.light);
                            }
                          },
                        ),
                        Divider(height: 1.h, color: Theme.of(context).dividerColor),
                        _buildThemeSwitcher(
                          context: context,
                          title: "Dark",
                          value: themeController.themeMode == ThemeMode.dark,
                          onChanged: (value) {
                            if (value) {
                              themeController.setThemeMode(ThemeMode.dark);
                            }
                          },
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSwitcher({
    required BuildContext context,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.onSurface,
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
}
