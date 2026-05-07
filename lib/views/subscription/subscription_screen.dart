import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/subscription/payment_screen.dart';

class PlanModel {
  final String title;
  final String price;
  final String subtitle;
  final List<String> features;
  final bool isMostPopular;
  final bool isCurrent;
  final bool hasGradientHeader;

  const PlanModel({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.features,
    this.isMostPopular = false,
    this.isCurrent = false,
    this.hasGradientHeader = false,
  });
}

// Dummy data
const List<PlanModel> kPlans = [
  PlanModel(
    title: 'Free',
    price: '€0',
    subtitle: 'Get started with local discovery',
    hasGradientHeader: false,
    features: [
      '6 Waves / day',
      'Unlimited vibes',
      'Join up to 3 communities',
      'Create 1 community',
      'Up to 25 members / community',
      'Join events within 200 km',
      'Create 1 event / month',
    ],
  ),
  PlanModel(
    title: 'Plus',
    price: '€9.95',
    subtitle: 'For active community members',
    isMostPopular: true,
    hasGradientHeader: true,
    isCurrent: true,
    features: [
      '12 Waves / day',
      'Unlimited Vibes',
      'Join up to 6 communities',
      'Create up to 3 communities',
      'Up to 50 members / community',
      'Create 4 events / month',
      'Up to 100 participants / event',
    ],
  ),
  PlanModel(
    title: 'Premium',
    price: '€19.95',
    subtitle: 'For organizers and power users',
    hasGradientHeader: true,
    features: [
      'Unlimited Waves',
      'Unlimited Vibes',
      'Join unlimited communities',
      'Create up to 6 communities',
      'Unlimited members / community',
      'Join events without distance limits',
      'Create unlimited events',
      'Unlimited participants / event',
    ],
  ),
];

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _currentPage = 1;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: CustomAppBar(title: 'Upgrade plan'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: CarouselSlider.builder(
                carouselController: _carouselController,
                itemCount: kPlans.length,
                itemBuilder: (context, index, _) => PlanCard(
                  plan: kPlans[index],
                  isCenter: _currentPage == index,
                ),
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height * 0.75,
                  viewportFraction: 0.80,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.15,
                  enableInfiniteScroll: false,
                  initialPage: 1,
                  autoPlay: false,
                  onPageChanged: (index, _) =>
                      setState(() => _currentPage = index),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _PageIndicator(
              count: kPlans.length,
              currentPage: _currentPage,
              onTap: (i) => _carouselController.animateToPage(i),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int count;
  final int currentPage;
  final ValueChanged<int> onTap;

  const _PageIndicator({
    required this.count,
    required this.currentPage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        return GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: currentPage == i
                  ? AppColors.primaryGradient
                  : const LinearGradient(
                      colors: [Color(0xffE0E0E0), Color(0xffE0E0E0)],
                    ),
            ),
          ),
        );
      }),
    );
  }
}

// Subscription card
class PlanCard extends StatelessWidget {
  final PlanModel plan;
  final bool isCenter;

  const PlanCard({super.key, required this.plan, this.isCenter = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            gradient: AppColors.primaryGradientRotated,
            boxShadow: isCenter
                ? [
                    BoxShadow(
                      color: const Color(0xff8663F6).withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.r),
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PlanHeader(plan: plan),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!plan.hasGradientHeader) ...[
                            Center(
                              child: Text(
                                plan.title,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Divider(color: Colors.grey.shade200, height: 1),
                            SizedBox(height: 16.h),
                          ],
                          SizedBox(height: 16.h),
                          ...plan.features.map((f) => _FeatureRow(text: f)),
                          SizedBox(height: 16.h),
                          _UpgradeButton(plan: plan),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (plan.isMostPopular)
          Positioned(
            top: 8.h,
            left: 4.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFAB058),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.r),
                  bottomRight: Radius.circular(12.r),
                ),
              ),
              child: Text(
                'Most Popular',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PlanHeader extends StatelessWidget {
  final PlanModel plan;
  const _PlanHeader({required this.plan});

  @override
  Widget build(BuildContext context) {
    if (!plan.hasGradientHeader) {
      return Padding(
        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 8.h),
        child: Column(
          children: [
            Text(
              plan.title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 4.h),
            _PriceText(price: plan.price, dark: true),
            SizedBox(height: 4.h),
            Text(
              plan.subtitle,
              style: TextStyle(fontSize: 13.sp, color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(18.r),
          topRight: Radius.circular(18.r),
        ),
        gradient: AppColors.primaryGradientRotated,
      ),
      child: Column(
        children: [
          Icon(
            plan.title == 'Plus' ? Icons.workspace_premium : Icons.diamond,
            color: Colors.white,
            size: 32.sp,
          ),
          SizedBox(height: 10.h),
          Text(
            plan.title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 4.h),
          _PriceText(price: plan.price, dark: false),
          SizedBox(height: 4.h),
          Text(
            plan.subtitle,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceText extends StatelessWidget {
  final String price;
  final bool dark;
  const _PriceText({required this.price, required this.dark});

  @override
  Widget build(BuildContext context) {
    final mainColor = dark ? const Color(0xFF111827) : Colors.white;
    final subColor = dark
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : Colors.white.withValues(alpha: 0.85);
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: price,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          TextSpan(
            text: '/month',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: subColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;
  const _FeatureRow({required this.text});

  @override
  Widget build(BuildContext context) {
    final slashIdx = text.indexOf('/');
    final boldEnd = slashIdx != -1 ? slashIdx : text.indexOf(' ');
    final boldPart = boldEnd != -1
        ? text.substring(0, boldEnd).trimRight()
        : text;
    final normalPart = boldEnd != -1 ? text.substring(boldEnd) : '';

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check, color: const Color(0xFF10B981), size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: boldPart,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (normalPart.isNotEmpty) TextSpan(text: ' $normalPart'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpgradeButton extends StatelessWidget {
  final PlanModel plan;
  const _UpgradeButton({required this.plan});

  @override
  Widget build(BuildContext context) {
    final isFree = plan.title == 'Free';
    return Container(
      width: double.infinity,
      height: 48.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: plan.isCurrent == true
            ? AppColors.primaryGradient.withOpacity(0.5)
            : AppColors.primaryGradientRotated,
      ),
      child: ElevatedButton(
        onPressed: () {
          if (plan.isCurrent == false) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PaymentScreen()),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          isFree
              ? 'Free'
              : plan.isCurrent
              ? 'Current Plan'
              : 'Upgrade',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
