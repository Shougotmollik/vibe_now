import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/tokens/tokens.dart';
import 'package:vibe_now/gen/assets.gen.dart';

class EventOrCommunityScreen extends StatefulWidget {
  const EventOrCommunityScreen({super.key});

  @override
  State<EventOrCommunityScreen> createState() => _EventOrCommunityScreenState();
}

class _EventOrCommunityScreenState extends State<EventOrCommunityScreen> {
  @override
  void initState() {
    super.initState();
    // Show the popup after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showProTipsDialog();
    });
  }

  void _showProTipsDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Color(0xFFE9D4FF), width: 1.5.w),
              gradient: LinearGradient(
                colors: [Color(0xFFFAF5FF), Color(0xFFFDF2F8)],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF8200DB)),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pro tip:',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF8200DB),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Communities are for long-term connections, Events are for specific occasions, and Vibes are for capturing fleeting moments.',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF364153),
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradientRotated,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        "Got it!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 0),
              child: Row(
                children: [
                  Text(
                    'Create Event or Community',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 24.h),
                    // Creation Star
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF3E8FF), Color(0xFFFCE7F3)],
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Assets.icons.creationStar.svg(
                        width: 32.w,
                        height: 32.w,
                      ),
                    ),
                    SizedBox(height: 12),

                    // Title
                    Text(
                      'What do you want to create?',
                      style: TextStyle(fontSize: 20.sp),
                    ),
                    Text(
                      'Choose the type of vibe you want to share',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Event Card
                    CreateCard(
                      onTap: () {
                        context.pushNamed(RouteNames.eventScreen);
                      },
                      title: 'Event',
                      subtitle:
                          'Organize gatherings, meetups, or special occasions that bring people together',
                      icon: Assets.icons.calender2.svg(),
                      iconBackground: Color(0xfff0b7eb),
                      gradient: LinearGradient(
                        colors: [Color(0xfffbadd8), Color(0xffdeb5fe)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    CreateCard(
                      onTap: () {
                        context.pushNamed(RouteNames.communityScreen);
                      },
                      title: 'Community',
                      subtitle:
                          'Build a space where people with shared interests can connect and grow together',
                      icon: Assets.icons.community.svg(
                        color: AppColors.onBackground,
                      ),
                      iconBackground: Color(0xffa9dbf8),
                      gradient: LinearGradient(
                        colors: [Color(0xff99e2f1), Color(0xffaaccff)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    SizedBox(height: 80.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget icon;
  final Color iconBackground;
  final LinearGradient gradient;
  final VoidCallback onTap;
  const CreateCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBackground,
    required this.gradient,
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            height: 260.h,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(gradient: gradient),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: iconBackground,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: icon,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 24.h),
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
