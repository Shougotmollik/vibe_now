import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/controller/profile_controller.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/notification/widgets/animated_dialog_content.dart';

class BlockScreen extends StatefulWidget {
  final String? userId;
  final String? userName;

  const BlockScreen({super.key, this.userId, this.userName});

  @override
  State<BlockScreen> createState() => _BlockScreenState();
}

class _BlockScreenState extends State<BlockScreen> {
  final TextEditingController _controller = TextEditingController();
  final ProfileController _profileController = Get.find<ProfileController>();
  bool _isBlocking = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBlock() async {
    final loc = AppLocalizations.of(context);

    if (_isBlocking) return;
    if (widget.userId == null || widget.userId!.isEmpty) {
      AppSnackbar.show(
        message: loc.translate('somethingWentWrong'),
        type: SnackType.error,
      );
      return;
    }

    setState(() => _isBlocking = true);

    final reason = _controller.text.trim().isNotEmpty
        ? _controller.text.trim()
        : '${loc.translate('block')} ${loc.translate('chat')}';

    final success = await _profileController.blockUser(
      userId: widget.userId!,
      reason: reason,
    );

    if (!mounted) return;
    setState(() => _isBlocking = false);

    if (success) {
      final displayName = widget.userName ?? loc.translate('defaultUserName');
      final blockSuccess = loc.translate('blockSuccess')
          .replaceFirst('{userName}', displayName);

      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Center(
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: AnimatedDialogContent(
                content: blockSuccess,
                accept: false,
              ),
            ),
          );
        },
      );
      if (mounted) {
        context.pop();
        context.pop();
      }
    } else {
      AppSnackbar.show(
        message: loc.translate('blockFailed'),
        type: SnackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, loc),
            SizedBox(height: 32.h),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    loc.translate('blockDescription'),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.85),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  TextField(
                    controller: _controller,
                    maxLines: 3,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.85),
                    ),
                    decoration: InputDecoration(
                      hintText: loc.translate('explainHere'),
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xffAEAEAE),
                        fontWeight: FontWeight.w400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.12),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.12),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.12),
                        ),
                      ),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.05),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 16.h,
                        horizontal: 16.w,
                      ),
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomAppBar(title: loc.translate('whatHappened')),
          GestureDetector(
            onTap: _isBlocking ? null : _handleBlock,
            child: Container(
              width: 80.w,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40.r),
                shape: BoxShape.rectangle,
                gradient: AppColors.primaryGradientRotated,
              ),
              child: Center(
                child: _isBlocking
                    ? SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        loc.translate('send'),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
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
}
