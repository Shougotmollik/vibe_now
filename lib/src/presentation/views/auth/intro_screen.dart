import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroTileModel {
  final String title;
  final SvgGenImage icon;
  final Color iconColor;
  final String image;

  IntroTileModel({
    required this.title,
    required this.icon,
    required this.image,
    this.iconColor = const Color(0xff4DBEFF),
  });
}

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  // List of intro tiles
  final List<IntroTileModel> _introItems = [
    IntroTileModel(
      title: "Discover vibes happening around you",
      icon: Assets.icons.location,
      image: "assets/images/onbording/map.png",
    ),
    IntroTileModel(
      title: "Make spontaneous real-life connections",
      icon: Assets.icons.user,
      image: "assets/images/onbording/map.png",
    ),
    IntroTileModel(
      title: "Create your own events",
      icon: Assets.icons.calender,
      image: "assets/images/onbording/create_event.png",
    ),
    IntroTileModel(
      title: "Create your own community's",
      icon: Assets.icons.usersColor,
      image: "assets/images/onbording/create_event.png",
    ),
    IntroTileModel(
      title: "Safe & privacy-first by design",
      icon: Assets.icons.shieldColor,
      image: "assets/images/onbording/map.png",
    ),
  ];

  final PageController _pageController = PageController(initialPage: 0);

  int _selectedItemIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: 472.h,
              child: PageView(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() => _selectedItemIndex = value);
                },
                children: _introItems.map(buildIntroTile).toList(),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    if (_selectedItemIndex == 0) return;

                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 372),
                      curve: Curves.easeInOut,
                    );

                    setState(() {
                      _selectedItemIndex--;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xffEAF0FB),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Center(
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xff242424),
                        size: 16.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                AnimatedSmoothIndicator(
                  count: _introItems.length,
                  activeIndex: _selectedItemIndex,
                  duration: const Duration(milliseconds: 372),
                  curve: Curves.easeInOut,
                  onDotClicked: (index) => _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 372),
                    curve: Curves.easeInOut,
                  ),
                  effect: ExpandingDotsEffect(
                    activeDotColor: AppColors.primary,
                    dotColor: Colors.black.withValues(alpha: .3),
                    dotWidth: 8,
                    dotHeight: 8,
                    spacing: 8,
                    expansionFactor: 2.5,
                  ),
                ),
                SizedBox(width: 16.w),
                GestureDetector(
                  onTap: () {
                    if (_selectedItemIndex == _introItems.length - 1) return;

                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 372),
                      curve: Curves.easeInOut,
                    );

                    setState(() {
                      _selectedItemIndex++;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xffEAF0FB),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Center(
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color(0xff242424),
                        size: 16.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 100.h),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: PrimaryButton.text(
                onPressed: () {
                  context.pushNamed(RouteNames.signInScreen);
                },
                text: 'Get Started',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Intro tile widget
  Widget buildIntroTile(IntroTileModel model) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Image.asset(
              model.image,
              width: 1.sw,
              height: 400.h,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 24.h),
        Row(
          spacing: 8.w,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xffEAF0FB),
                borderRadius: BorderRadius.circular(50.r),
              ),
              child: model.icon.svg(
                width: 24.w,
                height: 24.h,
                color: model.iconColor,
              ),
            ),
            Text(
              model.title,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xff171135)),
            ),
          ],
        ),
      ],
    );
  }
}
