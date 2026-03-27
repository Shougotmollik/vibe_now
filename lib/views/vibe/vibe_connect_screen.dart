import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/model/chat.dart';
import 'package:vibe_now/views/common/cancel_button.dart';
import 'package:vibe_now/views/vibe/meet_location_suggestion.dart';

class VibeConnectScreen extends StatelessWidget {
  const VibeConnectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.black),
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

                const Text(
                  "It's a Vibe",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "You both want to connect!",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                const CircleAvatar(
                  radius: 55,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Jhon Gomes",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: Colors.grey,
                    ),
                    Text(
                      " 300m away",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
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
                  text: "Suggest meeting spot",
                ),
                const SizedBox(height: 12),

                // CancelButton(
                //   onTap: () {
                //     context.pushNamed(
                //       RouteNames.chatInboxScreen,
                //       extra: Chat(
                //         avatars: [
                //           'https://randomuser.me/api/portraits/women/12.jpg',
                //         ],
                //         name: 'Jhon Gomes',
                //         message: 'Sent you a wave!',
                //         time: '10:30 AM',
                //         type: ChatType.wave,
                //       ),
                //     );
                //   },
                //   btnText: "Chat with Jhon Gomes",
                // ),

                const Spacer(flex: 3),

                CancelButton(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  btnText: "Cancel",
                ),

                SizedBox(height: 48.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
