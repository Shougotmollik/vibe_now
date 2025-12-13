import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/src/presentation/views/create_vibe/create_vibe_screen.dart';
import 'package:vibe_now/src/presentation/views/event/event_or_community_screen.dart';
import 'package:vibe_now/src/presentation/views/home/home_screen.dart';
import 'package:vibe_now/src/presentation/views/settings/profile_setting_screen.dart';
import 'package:vibe_now/src/presentation/views/settings/settings_screen.dart';

class MainNavBarScreen extends StatefulWidget {
  const MainNavBarScreen({super.key});

  @override
  State<MainNavBarScreen> createState() => _MainNavBarScreenState();
}

class _MainNavBarScreenState extends State<MainNavBarScreen> {
  int selectedIndex = 0;

  final List<Widget> screens = [
    HomeScreen(),
    EventOrCommunityScreen(),
    CreateVibeScreen(),
    Placeholder(),
    SettingsScreen(),
  ];

  /// Colored icons (active)
  final List<SvgGenImage> colorIcons = [
    Assets.icons.locationColor,
    Assets.icons.communityColor,
    Assets.icons.plus,
    Assets.icons.chatting,
    Assets.icons.peopleColor,
  ];

  /// Gray icons (inactive)
  final List<SvgGenImage> grayIcons = [
    Assets.icons.location,
    Assets.icons.communityLight,
    Assets.icons.plus,
    Assets.icons.chattingLight,
    Assets.icons.people,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: screens[selectedIndex],
      bottomNavigationBar: CustomNavBar(
        currentIndex: selectedIndex,
        colorIcons: colorIcons,
        grayIcons: grayIcons,
        onTap: (index) => setState(() => selectedIndex = index),
      ),
    );
  }
}

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  final List<SvgGenImage> colorIcons;
  final List<SvgGenImage> grayIcons;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.colorIcons,
    required this.grayIcons,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: 90,
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// BACKGROUND WHITE BAR
            Positioned(
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildIcon(0),
                    _buildIcon(1),
                    const SizedBox(width: 50),
                    _buildIcon(3),
                    _buildIcon(4),
                  ],
                ),
              ),
            ),

            /// CENTER BUTTON
            Positioned(
              bottom: 20,
              child: GestureDetector(
                onTap: () => onTap(2),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,

                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF5A7FFF).withValues( alpha: 0.45),
                        blurRadius: 35,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Assets.icons.plus.svg(
                      height: 30.h,
                      width: 30.w,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(int index) {
    final bool isSelected = currentIndex == index;

    final SvgGenImage icon = isSelected ? colorIcons[index] : grayIcons[index];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => onTap(index),
      child: icon.svg(height: 26.h, width: 26.w),
    );
  }
}
