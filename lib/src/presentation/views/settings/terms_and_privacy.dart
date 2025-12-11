import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/src/presentation/views/common/custom_app_bar.dart';

class TermsAndPrivacy extends StatelessWidget {
  const TermsAndPrivacy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar(title: "Terms and Privacy"),
                SizedBox(height: 20.h),
                _buildHeadingText(text: "1. How They Use and Share Your Data"),
                SizedBox(height: 6.h),

                _buildTextCard(
                  text: "• User-Provided Data: ",
                  subText:
                      "This includes your name, email, payment details (processed via trusted services), social login credentials, profile info, and any other details you voluntarily share.",
                ),
                SizedBox(height: 6.h),
                _buildTextCard(
                  text: "• Automatically Collected Data:  ",
                  subText:
                      "Includes IP address, device type, operating system, unique device identifiers, app usage behavior (captured via analytics like Firebase), and mobile network info.",
                ),
                SizedBox(height: 24.h),
                _buildHeadingText(text: "2. How They Use and Share Your Data"),
                SizedBox(height: 6.h),

                _buildTextCard(
                  text: "• Use: ",
                  subText:
                      "To maintain and improve app functionality, manage billing, support user accounts, and for internal analytics. ",
                ),
                SizedBox(height: 6.h),
                _buildTextCard(
                  text: "• Sharing: Your data may be shared with:",
                  subText:
                      "Affiliates or partners (e.g., during business transfers such as mergers or acquisitions)Legal authorities if required by lawThird-party service providers (e.g., payment processors), who are contractually bound to follow the privacy policy",
                ),
                _buildTextCard(
                  text: "• International Transfers:",
                  subText:
                      "Data is stored and processed in the United States, and by using the app, you consent to such transfers—even from countries with stricter privacy laws.",
                ),
                SizedBox(height: 24.h),
                _buildHeadingText(text: "3. Data Retention & Security"),
                SizedBox(height: 6.h),
                _buildTextCard(text: "• Retention Period:", subText: ""),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: _buildTextCard(
                    text: "• Service-related data and usage logs:",
                    subText: "retained for up to 12 months or as law mandates",
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: _buildTextCard(
                    text: "• Billing and invoice records: ",
                    subText: " retained up to 7 years",
                  ),
                ),
                _buildTextCard(
                  text: "• Security Measures:",
                  subText:
                      "They implement industry-standard protocols like encryption and secure servers to protect your personal data. However, no method is entirely foolproof",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeadingText({required String text}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18.sp,
        color: Color(0xff202020),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextCard({required String text, required String subText}) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Color(0xff202020),
              height: 1.5,
              letterSpacing: 0.5,
            ),
          ),
          TextSpan(
            text: subText,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Color(0xff908F90),
              height: 1.5,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.start,
    );
  }
}
