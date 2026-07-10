import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/localization/app_localizations.dart';

class _IntroTileData {
  final String key;
  final SvgGenImage icon;

  static const Color _defaultIconColor = Color(0xff4DBEFF);

  Color get iconColor => _defaultIconColor;

  _IntroTileData({
    required this.key,
    required this.icon,
  });
}

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  late AnimationController _buttonController;
  late Animation<Offset> _buttonSlideAnimation;
  late Animation<double> _buttonFadeAnimation;

  late AnimationController _titleController;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _titleFadeAnimation;

  List<_IntroTileData> get _tileData => [
    _IntroTileData(key: 'discoverVibesDesc', icon: Assets.icons.location),
    _IntroTileData(key: 'spontaneousConnections', icon: Assets.icons.user),
    _IntroTileData(key: 'createOwnEvents', icon: Assets.icons.calender),
    _IntroTileData(key: 'createOwnCommunities', icon: Assets.icons.usersColor),
    _IntroTileData(key: 'safePrivacyFirst', icon: Assets.icons.shieldColor),
  ];

  // Kept for controller count used in initState
  int get _tileCount => _tileData.length;

  @override
  void initState() {
    super.initState();

    //Title animation
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );

    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic),
        );

    _titleFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeOut));

    //Tile animations
    _controllers = List.generate(
      _tileCount,
      (_) => AnimationController(
        duration: const Duration(milliseconds: 1000),
        vsync: this,
      ),
    );

    _slideAnimations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, 0.8),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      );
    }).toList();

    _fadeAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, 0.85, curve: Curves.easeOut),
        ),
      );
    }).toList();

    // Button animation
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _buttonSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 1.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _buttonController,
            curve: Curves.easeOutCubic,
          ),
        );

    _buttonFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    //Title first
    _titleController.forward();

    await Future.delayed(const Duration(milliseconds: 300));

    // Tiles staggered
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 180));
      if (mounted) {
        _controllers[i].forward();
      }
    }

    // Button last
    await Future.delayed(const Duration(milliseconds: 350));
    if (mounted) {
      _buttonController.forward();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 52.h),

              /// Title
              SlideTransition(
                position: _titleSlideAnimation,
                child: FadeTransition(
                  opacity: _titleFadeAnimation,
                  child: Text(
                    loc.translate('letsVibeTogether'),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // Intro tiles
              Column(
                children: List.generate(
                  _tileData.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: SlideTransition(
                      position: _slideAnimations[index],
                      child: FadeTransition(
                        opacity: _fadeAnimations[index],
                        child: _buildIntroTile(loc, _tileData[index]),
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 80.h),

              // Button
              SlideTransition(
                position: _buttonSlideAnimation,
                child: FadeTransition(
                  opacity: _buttonFadeAnimation,
                  child: PrimaryButton.text(
                    onPressed: () {
                      context.pushNamed(RouteNames.signInScreen);
                    },
                    text: loc.translate('getStarted'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroTile(AppLocalizations loc, _IntroTileData data) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: data.icon.svg(
              width: 24.w,
              height: 24.h,
              color: data.iconColor,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              loc.translate(data.key),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
