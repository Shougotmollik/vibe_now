import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/tokens/tokens.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/common/gradient_switch.dart';

class ThemeSelectionScreen extends StatefulWidget {
  const ThemeSelectionScreen({super.key});

  @override
  State<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
  bool lightValue = true;
  bool darkValue = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              const CustomAppBar(title: "Mode"),

              SizedBox(height: 20.h),

              Container(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xffE0E0E0), width: 1.5),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  children: [
                    _buildThemeSwitcher(
                      title: "Light",
                      value: lightValue,
                      onChanged: (value) {
                        setState(() {
                          lightValue = value;
                          if (value) darkValue = false;
                        });
                      },
                    ),
                    Divider(height: 1.h, color: Colors.black12),
                    _buildThemeSwitcher(
                      title: "Dark",
                      value: darkValue,
                      onChanged: (value) {
                        setState(() {
                          darkValue = value;
                          if (value) lightValue = false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSwitcher({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16.sp)),
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
