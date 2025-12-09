import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool locationSharing = true;
  bool waves = true;
  bool matches = true;
  bool messages = true;
  bool events = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                    onPressed: () {},
                  ),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
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
                                        color: Colors.black.withOpacity(0.1),
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
                      title: 'Profile information',
                      hasArrow: true,
                      isFullRounded: true,
                      onTap: () {},
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
                      onTap: () {},
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
                      icon: Assets.icons.notificationColor,
                      iconColor: Colors.purple,
                      title: 'Waves',
                      value: waves,
                      isTopRound: true,
                      onChanged: (val) {
                        setState(() {
                          waves = val;
                        });
                      },
                    ),

                    _buildSwitchItem(
                      icon: Assets.icons.colorPaletteColor,
                      iconColor: Colors.purple,
                      title: 'Matches',
                      value: matches,
                      onChanged: (val) {
                        setState(() {
                          matches = val;
                        });
                      },
                    ),

                    _buildSwitchItem(
                      icon: Assets.icons.messageCircleColor,
                      iconColor: Colors.purple,
                      title: 'Messages',
                      value: messages,
                      onChanged: (val) {
                        setState(() {
                          messages = val;
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
                      onTap: () {},
                    ),

                    _buildMenuItem(
                      icon: Assets.icons.gridColor,
                      iconColor: Colors.purple,
                      title: 'Theme',
                      isBottomRound: true,
                      hasArrow: true,
                      onTap: () {},
                    ),
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
                      onTap: () {},
                    ),
                    SizedBox(height: 32.h),

                    // Log Out
                    _buildMenuItem(
                      icon: Assets.icons.logoutColor,
                      iconColor: Colors.red,
                      title: 'Log Out',
                      isFullRounded: true,
                      hasArrow: true,
                      onTap: () {},
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            Container(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.location_on_outlined, false),
                  _buildNavItem(Icons.people_outline, false),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9C6FFF), Color(0xFF6B9FFF)],
                      ),
                    ),
                    child: Icon(Icons.add, color: Colors.white, size: 24.sp),
                  ),
                  _buildNavItem(Icons.home_outlined, false),
                  _buildNavItem(Icons.person, true),
                ],
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildNavItem(IconData icon, bool isActive) {
    return Icon(
      icon,
      color: isActive ? Colors.purple : Colors.grey.shade400,
      size: 28.sp,
    );
  }
}

/// Reusable GradientSwitch
class GradientSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Gradient activeGradient;
  final Color inactiveColor;
  final Gradient? thumbGradient;
  final double width;
  final double height;
  final Duration duration;
  final double padding;
  final bool disabled;

  const GradientSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.activeGradient,
    this.inactiveColor = const Color(0xFFE0E0E0),
    this.thumbGradient,
    this.width = 56,
    this.height = 30,
    this.duration = const Duration(milliseconds: 200),
    this.padding = 0,
    this.disabled = false,
  });

  @override
  State<GradientSwitch> createState() => _GradientSwitchState();
}

class _GradientSwitchState extends State<GradientSwitch>
    with SingleTickerProviderStateMixin {
  // For subtle thumb scaling animation on tap
  late final AnimationController _tapController;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.disabled) return;
    widget.onChanged(!widget.value);
    // small tap animation
    _tapController.forward().then((_) => _tapController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final thumbSize = widget.height - 2 * widget.padding;
    final trackRadius = widget.height / 2;
    final thumbLeft = widget.padding;
    final thumbRight = widget.width - widget.padding - thumbSize;

    return Semantics(
      container: true,
      toggled: widget.value,
      enabled: !widget.disabled,
      child: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.translucent,
        child: AnimatedContainer(
          duration: widget.duration,
          width: widget.width,
          height: widget.height,
          padding: EdgeInsets.all(widget.padding),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            // Use gradient when on, otherwise flat color
            gradient: widget.value && !widget.disabled
                ? widget.activeGradient
                : null,
            color: (!widget.value || widget.disabled)
                ? widget.inactiveColor
                : null,
            borderRadius: BorderRadius.circular(trackRadius),
            boxShadow: [
              // subtle elevation
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: widget.duration,
                left: widget.value ? thumbRight : thumbLeft,
                top: 0,
                bottom: 0,
                curve: Curves.easeInOut,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 0.96).animate(
                    CurvedAnimation(
                      parent: _tapController,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: widget.thumbGradient,
                      color: widget.thumbGradient == null ? Colors.white : null,
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Optional disabled overlay
              if (widget.disabled)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(trackRadius),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
