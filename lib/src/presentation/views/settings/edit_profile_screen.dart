import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/tokens/tokens.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/src/presentation/views/common/custom_app_bar.dart';
import 'package:vibe_now/src/presentation/views/common/custom_elevated_button.dart';
import 'package:vibe_now/src/presentation/views/common/interest_chip.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

final TextEditingController bioController = TextEditingController();

class _EditProfileScreenState extends State<EditProfileScreen> {
  // ---------- Interests Data ----------
  List<String> selectedInterests = [];

  final List<Map<String, dynamic>> allInterests = [
    {"label": "Coffee", "icon": Assets.icons.coffee},
    {"label": "Music", "icon": Assets.icons.music},
    {"label": "Books", "icon": Assets.icons.book},
    {"label": "Gaming", "icon": Assets.icons.aiGame},
    {"label": "Calendar", "icon": Assets.icons.calender},
    {"label": "Travel", "icon": Assets.icons.book},
    {"label": "Fitness", "icon": Assets.icons.creationStar},
    {"label": "Cooking", "icon": Assets.icons.gift},
    {"label": "Art", "icon": Assets.icons.community},
    {"label": "Photography", "icon": Assets.icons.camera},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomAppBar(title: "Settings"),
              SizedBox(height: 20),
              _buildProfileSection(),
              SizedBox(height: 28.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile Completion',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff908F90),
                    ),
                  ),
                  Text(
                    '60%',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Color(0xff908F90),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),

              _buildProgressIndicator(),
              SizedBox(height: 28.h),

              // Name
              _buildHeadingText(text: 'Name'),
              SizedBox(height: 12.h),
              _buildInputField(hint: 'John Gomes'),
              SizedBox(height: 28.h),

              // Bio
              _buildHeadingText(text: 'Bio'),
              SizedBox(height: 12.h),
              _buildBioField(),
              SizedBox(height: 28.h),

              // Password
              _buildHeadingText(text: 'Password'),
              SizedBox(height: 12.h),
              _buildInputField(hint: '********'),
              SizedBox(height: 28.h),

              // Interests
              _buildHeadingText(text: "Interests (select up to 5)"),
              SizedBox(height: 16.h),
              _buildInterestSection(),
              SizedBox(height: 84.h),
              CustomElevatedButton(onTap: () {}, buttonText: "Save"),
              SizedBox(height: 74.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeadingText({required String text}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: Color(0xff555555),
      ),
    );
  }

  Widget _buildInputField({required String hint}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xffAEAEAE)),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 14.sp, color: Color(0xff202020)),
          contentPadding: EdgeInsets.symmetric(
            vertical: 12.h,
            horizontal: 16.w,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Color(0xffAEAEAE)),
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: TextFormField(
            controller: bioController,
            maxLines: 4,
            maxLength: 70,
            decoration: InputDecoration(
              counterText: "",
              hintText:
                  "Coffee enthusiast. Music lover. Avid traveler. Foodie.",
              hintStyle: TextStyle(fontSize: 14.sp, color: Color(0xff202020)),
              contentPadding: EdgeInsets.symmetric(
                vertical: 12.h,
                horizontal: 16.w,
              ),
              border: InputBorder.none,
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 4.h, right: 4.w),
          child: Text(
            "${bioController.text.length}/70",
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50.r),
                child: Image.network(
                  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
                  width: 78.w,
                  height: 78.h,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Assets.icons.camera2.svg(),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'John Gomes',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Assets.icons.coffeeColor.svg(height: 16.h),
              SizedBox(width: 4.w),
              Text(
                'Coffee enthusiast |',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
              ),
              SizedBox(width: 8.w),
              Assets.icons.musicColor.svg(height: 16.h),
              SizedBox(width: 4.w),
              Text(
                'Music lover',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      height: 4.h,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r)),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          Expanded(flex: 4, child: Container(color: Color(0xffE6E6E6))),
        ],
      ),
    );
  }

  Widget _buildInterestSection() {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: allInterests.map((item) {
        final String label = item["label"];
        final icon = item["icon"];
        return InterestChip(icon: icon, label: label);
      }).toList(),
    );
  }
}
