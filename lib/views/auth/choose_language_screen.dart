import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/localization/language_controller.dart';

class ChooseLanguageScreen extends StatefulWidget {
  const ChooseLanguageScreen({super.key});

  @override
  State<ChooseLanguageScreen> createState() => _ChooseLanguageScreenState();
}

class _ChooseLanguageScreenState extends State<ChooseLanguageScreen>
    with SingleTickerProviderStateMixin {
  final LanguageController _langController = Get.find<LanguageController>();

  late int _selectedIndex;

  final List<_LanguageOption> _languages = [
    _LanguageOption(
      name: 'English',
      flag: Assets.flags.unitedKingdom,
      code: 'en',
    ),
    _LanguageOption(name: 'Deutsch', flag: Assets.flags.germany, code: 'de'),
  ];

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _languages.indexWhere(
      (l) => l.code == _langController.currentLanguageCode,
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
          CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onLanguageSelected(int index) {
    setState(() => _selectedIndex = index);
    _langController.changeLanguage(Locale(_languages[index].code));
  }

  void _onContinue() {
    context.pushNamed(RouteNames.introScreen);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  Spacer(flex: 1),
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.primaryGradient.createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),
                    child: Text(
                      'vybin',
                      style: TextStyle(
                        fontSize: 44.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Subtitle
                  Text(
                    loc.translate('chooseLanguage'),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),

                  SizedBox(height: 48.h),

                  // Language cards
                  ...List.generate(_languages.length, (index) {
                    final lang = _languages[index];
                    final isSelected = _selectedIndex == index;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: GestureDetector(
                        onTap: () => _onLanguageSelected(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 18.h,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                            color: isSelected
                                ? AppColors.primary.withAlpha(20)
                                : Theme.of(context).colorScheme.surfaceVariant,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Theme.of(context).dividerColor,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Flag
                              Container(
                                width: 48.w,
                                height: 34.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: lang.flag.svg(
                                  width: 48.w,
                                  height: 34.h,
                                  fit: BoxFit.cover,
                                ),
                              ),

                              SizedBox(width: 16.w),

                              // Language name
                              Expanded(
                                child: Text(
                                  lang.name,
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                              ),

                              // Selected indicator
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 24.w,
                                height: 24.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: isSelected
                                      ? AppColors.primaryGradient
                                      : null,
                                  color: isSelected
                                      ? null
                                      : Theme.of(context).colorScheme.surface,
                                  border: isSelected
                                      ? null
                                      : Border.all(
                                          color: Theme.of(context).dividerColor,
                                          width: 1.5,
                                        ),
                                ),
                                child: isSelected
                                    ? Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16.w,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const Spacer(flex: 1),

                  // Continue button
                  SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, 1),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _fadeController,
                            curve: const Interval(
                              0.4,
                              0.8,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                        ),
                    child: FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _fadeController,
                        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
                      ),
                      child: PrimaryButton.text(
                        onPressed: _onContinue,
                        text: loc.translate('continueText'),
                      ),
                    ),
                  ),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageOption {
  final String name;
  final SvgGenImage flag;
  final String code;

  const _LanguageOption({
    required this.name,
    required this.flag,
    required this.code,
  });
}
