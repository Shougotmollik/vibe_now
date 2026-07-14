import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/model/incoming_wave.dart';
import 'package:vibe_now/views/common/cancel_button.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';
import 'package:vibe_now/views/vibe/meet_location_suggestion.dart';

class VibeConnectScreen extends StatelessWidget {
  final IncomingWave wave;

  const VibeConnectScreen({super.key, required this.wave});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final sender = wave.sender;
    final distanceText = wave.distanceText ?? '';

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SizedBox(
            height: 180.h,
            width: double.infinity,
            child: Lottie.asset(
              'assets/lottie/Confetti - Full Screen.json',
              width: double.infinity,
              repeat: true,
              fit: BoxFit.cover,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                Text(
                  loc.translate('itsAVibe'),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.translate('youBothWantToConnect'),
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 40),

                ClipRRect(
                  borderRadius: BorderRadius.circular(55.r),
                  child: sender.avatar.isNotEmpty
                      ? Image.network(
                          AppCredentials.fixurl(sender.avatar),
                          width: 110.w,
                          height: 110.w,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => CircleAvatar(
                            radius: 55.r,
                            child: Icon(Icons.person, size: 44.w),
                          ),
                        )
                      : CircleAvatar(
                          radius: 55.r,
                          child: Icon(Icons.person, size: 44.w),
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  sender.fullName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                if (distanceText.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      Text(
                        ' $distanceText',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),

                const Spacer(flex: 3),

                PrimaryButton.text(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            MeetLocationSuggestionScreen(wave: wave),
                      ),
                    );
                  },
                  text: loc.translate('suggestMeetingSpot'),
                ),
                const SizedBox(height: 12),

                CustomElevatedButton(
                  btnColor: Theme.of(context).colorScheme.surfaceVariant,
                  textColor: Theme.of(context).colorScheme.onSurfaceVariant,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  buttonText: loc.translate('cancel'),
                ),

                SizedBox(height: 48.h),
                const Spacer(flex: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
