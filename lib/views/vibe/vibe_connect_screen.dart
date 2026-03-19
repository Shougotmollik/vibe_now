import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/gen/assets.gen.dart';
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
        // title: const Text(
        //   'QR Verification',
        //   style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        // ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Decorations (Confetti/Shapes)
          // _buildDecorations(),
          Assets.icons.confetti.svg(
            width: double.infinity,
            height: 180.h,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                // Header Text
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

                // Profile Image
                const CircleAvatar(
                  radius: 55,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
                  ), // Replace with actual image
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

                // Action Buttons
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

                CancelButton(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  btnText: "Chat with Jhon Gomes",
                ),

                const Spacer(flex: 3),

                CancelButton(onTap: () {}, btnText: "Cancel"),

                SizedBox(height: 48.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // // Helper to place decorative icons
  // Widget _buildDecorations() {
  //   return Stack(
  //     children: const [
  //       Positioned(
  //         top: 50,
  //         left: 100,
  //         child: Icon(Icons.auto_awesome, color: Colors.pinkAccent, size: 20),
  //       ),
  //       Positioned(
  //         top: 80,
  //         right: 80,
  //         child: Icon(Icons.star, color: Colors.orangeAccent, size: 15),
  //       ),
  //       Positioned(
  //         top: 150,
  //         left: 40,
  //         child: Icon(Icons.gesture, color: Colors.blueAccent, size: 24),
  //       ),

  //     ],
  //   );
  // }
}
