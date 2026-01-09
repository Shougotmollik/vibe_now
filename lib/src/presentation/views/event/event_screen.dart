import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/src/presentation/views/event/event_card.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildAppBar(context),
                // Body
                SizedBox(height: 12),

                Column(
                  spacing: 12.h,
                  children: List.generate(3, (index) => EventCard()),
                ),

                // EventCard(),
                SizedBox(height: 24),

                //
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row _buildAppBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        Text('Create Post', style: TextStyle(fontSize: 18)),
        Spacer(),
        GestureDetector(
          onTap: () => context.pushNamed(RouteNames.qrVerificationScreen),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: Assets.icons.scan.svg(),
          ),
        ),
        SizedBox(width: 8),
        GestureDetector(
          onTap: () => context.pushNamed(RouteNames.createEventScreen),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradientRotated,
            ),
            child: Assets.icons.add.svg(),
          ),
        ),
      ],
    );
  }
}
