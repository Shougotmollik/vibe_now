import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/model/chat.dart';
import 'package:vibe_now/views/common/cancel_button.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';
import 'package:vibe_now/views/vibe/meet_location_suggestion.dart';

class VibeConnectScreen extends StatelessWidget {
  const VibeConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
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

                const CircleAvatar(
                  radius: 55,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Jhon Gomes",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
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
                      " 300m away",
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
                        builder: (context) => MeetLocationSuggestionScreen(),
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
