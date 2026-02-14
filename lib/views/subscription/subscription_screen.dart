import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int currentPage = 1; // Start with Premium (middle card)
  final CarouselSliderController carouselController =
      CarouselSliderController();

  final List<PlanData> plans = [
    PlanData(
      title: 'Free',
      price: '€0',
      subtitle: 'Free — upgrade to connect more',
      features: [
        'Waves: 5 per hour',
        'Range: fixed 500 m',
        'Create community: 1 per month (up to 20 members)',
        'Create event: 1 per month (up to 20 participants)',
        'Filters: Age, gender, 1—2 interests',
        'Visibility: Standard, no prioritization',
      ],
      isSelected: false,
    ),
    PlanData(
      title: 'Premium',
      price: '€9.99',
      subtitle: 'Premium — unlimited connections',
      features: [
        'Waves: Unlimited',
        'Range: up to 5 km',
        'Create community: Unlimited',
        'Create event: Unlimited',
        'Filters: All filters available',
        'Visibility: Priority in search',
      ],
      isSelected: true,
    ),
    PlanData(
      title: 'Pro',
      price: '€19.99',
      subtitle: 'Pro — for power users',
      features: [
        'Waves: Unlimited',
        'Range: up to 10 km',
        'Create community: Unlimited',
        'Create event: Unlimited',
        'Filters: Advanced filters + AI matching',
        'Visibility: Top priority + verified badge',
      ],
      isSelected: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: CustomAppBar(title: "Upgrade plan"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: CarouselSlider.builder(
                carouselController: carouselController,
                itemCount: plans.length,
                itemBuilder: (context, index, realIndex) {
                  // Calculate rotation based on distance from center
                  double rotationAngle = (currentPage - index) * 0.3;
                  
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // perspective
                      ..rotateY(rotationAngle),
                    alignment: Alignment.center,
                    child: PlanCard(
                      plan: plans[index],
                      isCenter: currentPage == index,
                    ),
                  );
                },
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height * 0.70,
                  viewportFraction: 0.8,
                  aspectRatio: 1.2,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.3,
                  enableInfiniteScroll: false,
                  initialPage: 1,
                  autoPlay: false,
                  onPageChanged: (index, reason) {
                    setState(() => currentPage = index);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            _pageIndicator(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _pageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        plans.length,
        (index) => GestureDetector(
          onTap: () => carouselController.animateToPage(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: currentPage == index ? 8 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: currentPage == index
                  ? AppColors.primaryGradient
                  : const LinearGradient(
                      colors: [
                        Color(0xffE0E0E0),
                        Color(0xffE0E0E0),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class PlanData {
  final String title;
  final String price;
  final String subtitle;
  final List<String> features;
  bool isSelected;

  PlanData({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.features,
    this.isSelected = false,
  });
}

class PlanCard extends StatelessWidget {
  final PlanData plan;
  final bool isCenter;

  const PlanCard({
    super.key,
    required this.plan,
    required this.isCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
      padding: EdgeInsets.all(1.5.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xff8663F6), Color(0xff57C2FF), Color(0xffC470F5)],
        ),
        boxShadow: isCenter
            ? [
                BoxShadow(
                  color: Color(0xff8663F6).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                  spreadRadius: 0,
                ),
              ]
            : [],
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: plan.isSelected ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _header(),
              _features(),
              const SizedBox(height: 10),
              _upgradeButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      height: 160.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: AppColors.primaryGradientRotated,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Assets.icons.subscription.svg(
            width: 40.w,
            height: 40.h,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            '${plan.price} / month',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            plan.subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _features() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 12.w,
            children: [
              Text(
                plan.title,
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
              _buildBadge(),
            ],
          ),
          const SizedBox(height: 20),
          ...plan.features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check, color: Color(0xFF10B981), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Color(0xFF374151),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    String text;
    Color bgColor;

    switch (plan.title) {
      case 'Free':
        text = 'Standard';
        bgColor = Colors.grey.shade400;
        break;
      case 'Premium':
        text = 'Recommended';
        bgColor = Colors.green.shade400;
        break;
      case 'Pro':
        text = 'Premium';
        bgColor = Colors.orange.shade400;
        break;
      default:
        text = '';
        bgColor = Colors.transparent;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _upgradeButton() {
    return Container(
      width: double.infinity,
      height: 42.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: plan.isSelected ? Colors.grey : null,
        gradient: plan.isSelected ? null : AppColors.primaryGradientRotated,
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Text(
          plan.isSelected ? 'Current Plan' : 'Upgrade',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}