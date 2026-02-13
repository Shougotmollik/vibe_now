import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/env.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/views/chat/chat_screen.dart';
import 'package:vibe_now/views/create_vibe/create_vibe_screen.dart';
import 'package:vibe_now/views/event/event_or_community_screen.dart';
import 'package:vibe_now/views/home/home_screen.dart';
import 'package:vibe_now/views/home/widgets/google_map.dart';
import 'package:vibe_now/views/profile/profile_screen.dart';
import 'package:vibe_now/views/settings/settings_screen.dart';

class MainNavBarScreen extends StatefulWidget {
  const MainNavBarScreen({super.key});

  @override
  State<MainNavBarScreen> createState() => _MainNavBarScreenState();
}

class _MainNavBarScreenState extends State<MainNavBarScreen> {
  int selectedIndex = 0;
  DateTime? lastBackPressed;

  final List<Widget> screens = [
    // HomeScreen(),
    GoogleMapScreen(apiKey: EnvHandler.google_map_api_key),
    EventOrCommunityScreen(),
    CreateVibeScreen(),
    ChatScreen(),
    ProfileScreen(isMyProfile: true),
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

  Future<bool> _onWillPop() async {
    if (selectedIndex != 0) {
      setState(() => selectedIndex = 0);
      return false;
    }

    final now = DateTime.now();
    if (lastBackPressed == null ||
        now.difference(lastBackPressed!) > const Duration(seconds: 2)) {
      lastBackPressed = now;

      // Show snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tap again to exit'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }

    // Exit the app
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        extendBody: true,
        body: screens[selectedIndex],
        bottomNavigationBar: CustomNavBar(
          currentIndex: selectedIndex,
          colorIcons: colorIcons,
          grayIcons: grayIcons,
          onTap: (index) => setState(() => selectedIndex = index),
        ),
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final barHeight = 60.0;

    return SizedBox(
      height: barHeight + bottomPadding,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          /// BACKGROUND WHITE BAR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: barHeight + bottomPadding + 4,
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 8,
                bottom: bottomPadding > 0 ? bottomPadding : 8,
              ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIcon(0),
                  _buildIcon(1),
                  const SizedBox(width: 44),
                  _buildIcon(3),
                  _buildIcon(4),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: (bottomPadding > 0 ? bottomPadding : 8) + 4,
            child: GestureDetector(
              onTap: () => onTap(2),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF5A7FFF).withValues(alpha: 0.45),
                      blurRadius: 35,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Assets.icons.plus.svg(
                    height: 22.h,
                    width: 22.w,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(int index) {
    final bool isSelected = currentIndex == index;
    final SvgGenImage icon = isSelected ? colorIcons[index] : grayIcons[index];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: icon.svg(height: 26.h, width: 26.w),
      ),
    );
  }
}
