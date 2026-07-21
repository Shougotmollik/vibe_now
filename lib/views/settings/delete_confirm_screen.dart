import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/tokens/tokens.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/localization/app_localizations.dart';

class DeleteConfirmScreen extends StatefulWidget {
  const DeleteConfirmScreen({super.key, this.isPaused});
  final bool? isPaused;

  @override
  State<DeleteConfirmScreen> createState() => _DeleteConfirmScreenState();
}

class _DeleteConfirmScreenState extends State<DeleteConfirmScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconScaleAnimation;

  int _countdown = 5;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _iconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();

    // Countdown then redirect
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _countdown--);
      return _countdown > 0;
    }).then((_) {
      if (mounted) {
        _redirectToSignIn();
      }
    });
  }

  Future<void> _redirectToSignIn() async {
    context.goNamed(RouteNames.signInScreen);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final bool isPaused = widget.isPaused ?? false;

    final String title = isPaused
        ? loc.translate('profilePaused')
        : loc.translate('accountDeleted');

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
                child: Column(
                  children: [
                    SizedBox(height: 40.h),

                    // App logo
                    ScaleTransition(
                      scale: _iconScaleAnimation,
                      child: Assets.icons.vivenowlogo.image(
                        width: 100.w,
                        height: 100.w,
                        fit: BoxFit.contain,
                      ),
                    ),

                    SizedBox(height: 28.h),

                    // Title
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Description
                    if (isPaused) ...[
                      _buildInfoCard(
                        icon: Icons.check_circle_outline,
                        text:
                            "Your profile is now paused. You won't appear on the map and others won't be able to find you.",
                      ),
                      SizedBox(height: 10.h),
                      _buildInfoCard(
                        icon: Icons.login_rounded,
                        text:
                            "When you log back in, your profile will be active again — all your activity, chats, and connections will be right where you left them.",
                      ),
                      SizedBox(height: 10.h),
                      _buildInfoCard(
                        icon: Icons.history_rounded,
                        text:
                            "You can see your full history, messages, and past meetups whenever you return.",
                      ),
                    ] else ...[
                      _buildInfoCard(
                        icon: Icons.info_outline_rounded,
                        text:
                            "Your account has been permanently deleted. This process may take some time to complete.",
                      ),
                      SizedBox(height: 10.h),
                      _buildInfoCard(
                        icon: Icons.error_outline_rounded,
                        text:
                            "Once deleted, this action cannot be undone. All your data will be removed.",
                      ),
                    ],

                    SizedBox(height: 32.h),

                    // Countdown indicator
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: _countdown / 5,
                              color: isPaused
                                  ? const Color(0xff7B61FF)
                                  : const Color(0xffE53935),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            isPaused
                                ? "Redirecting to sign in in $_countdown..."
                                : "Redirecting in $_countdown...",
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22.sp, color: Theme.of(context).colorScheme.primary),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                height: 1.4,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
