import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:vibe_now/controller/wave_controller.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/model/incoming_wave.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';
import 'package:vibe_now/views/notification/widgets/animated_dialog_content.dart';
import 'package:vibe_now/views/vibe/vibe_connect_screen.dart';

class ChatWaveScreen extends StatefulWidget {
  const ChatWaveScreen({super.key});

  @override
  State<ChatWaveScreen> createState() => _ChatWaveScreenState();
}

class _ChatWaveScreenState extends State<ChatWaveScreen> {
  final WaveController _waveController = Get.find<WaveController>();
  bool _isProcessing = false;

  Future<void> _handleAccept(IncomingWave wave, BuildContext context) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final success = await _waveController.waveAction(
      waveId: wave.waveId,
      action: 'accept',
    );

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => VibeConnectScreen(wave: wave)),
      );
    } else {
      AppSnackbar.show(
        message: AppLocalizations.of(context).translate('failedToAcceptWave'),
        type: SnackType.error,
      );
    }
  }

  Future<void> _handleReject(IncomingWave wave) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    await _waveController.waveAction(waveId: wave.waveId, action: 'reject');

    if (!mounted) return;
    setState(() => _isProcessing = false);

    Navigator.pop(context);

    // Use Get.dialog to avoid context-after-pop issues
    Get.dialog(
      Center(
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: AnimatedDialogContent(
            content: AppLocalizations.of(context)
                .translate('youHaveRejectedWave')
                .replaceFirst('{name}', wave.sender.fullName),
            accept: false,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final extra = GoRouterState.of(context).extra;
    final IncomingWave wave;
    if (extra is IncomingWave) {
      wave = extra;
    } else {
      return Scaffold(
        body: Center(child: Text(loc.translate('invalidWaveData'))),
      );
    }

    final name = wave.sender.fullName;
    final avatar = wave.sender.avatar;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 16.w,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 88.w,
                        height: 88.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(2.5.w),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          padding: EdgeInsets.all(2.w),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(44.r),
                            child: avatar.isNotEmpty
                                ? Image.network(
                                    AppCredentials.fixurl(avatar),
                                    width: 88.w,
                                    height: 88.w,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _defaultAvatar(),
                                  )
                                : _defaultAvatar(),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Lottie.asset(
                        "assets/lottie/Hello Lottie.json",
                        height: 160.w,
                        fit: BoxFit.cover,
                        reverse: false,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '$name ${loc.translate('wantsToMeetYou')}',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        loc.translate('acceptToSuggest'),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 48.h),
                      Column(
                        spacing: 12.w,
                        children: [
                          PrimaryButton.text(
                            onPressed: () => _handleAccept(wave, context),
                            isEnabled: !_isProcessing,
                            isLoading: _isProcessing,
                            text: loc.translate('accept'),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24.r),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.1),
                                width: 1.w,
                              ),
                            ),
                            child: CustomElevatedButton(
                              onTap: _isProcessing
                                  ? () {}
                                  : () => _handleReject(wave),
                              buttonText: loc.translate('rejectWave'),
                              btnColor: Theme.of(context).colorScheme.surface,
                              textColor: Theme.of(
                                context,
                              ).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      width: 88.w,
      height: 88.w,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: 44.w,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
