import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/subscription/payment_success.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? selectedPayment; // selected payment method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundVariant,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            SafeArea(
              child: CustomAppBar(title: "Payment Method", canBack: true),
            ),

            SizedBox(height: 40.h),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  _buildPaymentTile(
                    title: "PayPal",
                    value: "paypal",
                    imagePath: "assets/icons/paypal.svg",
                  ),

                  Divider(color: Colors.grey[300], height: 1.h),

                  _buildPaymentTile(
                    title: "Stripe",
                    value: "stripe",
                    imagePath: "assets/icons/stripe.svg",
                  ),
                ],
              ),
            ),
            Spacer(),

            PrimaryButton.text(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentSuccess()),
                );
              },
              text: "Next",
              isEnabled: selectedPayment != null,
            ),
            SizedBox(height: 48.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTile({
    required String title,
    required String imagePath,
    required String value,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedPayment = value;
        });
      },
      child: Row(
        children: [
          SvgPicture.asset(imagePath, height: 24.h, width: 24.w),

          SizedBox(width: 8.w),

          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryText,
            ),
          ),

          Spacer(),

          Radio<String>(
            value: value,
            groupValue: selectedPayment,
            onChanged: (value) {
              setState(() {
                selectedPayment = value;
              });
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
