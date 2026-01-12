import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/helper/helper.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.isMyProfile = true});

  final bool isMyProfile;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final tabs = ['Photos'];

  // For photo grid
  final List<String> _photos = [
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800',
    'https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?w=800',
    'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?w=800',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  File? _selectedImage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SafeArea(bottom: false, child: SizedBox(height: 12.h)),
            _buildAppBar(context, widget.isMyProfile),
            _buildProfileHeader(),
            _buildPhotosTab(widget.isMyProfile),
            SizedBox(height: 112.h),
          ],
        ),
      ),
    );
  }

  PreferredSize _buildAppBar(BuildContext context, bool isMyProfile) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            isMyProfile == true
                ? const SizedBox()
                : GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(Icons.arrow_back_ios, color: Colors.black),
                  ),
            GestureDetector(
              onTap: () {
                if (isMyProfile != true) {
                  context.pushNamed(RouteNames.chatScreen);
                } else {
                  context.pushNamed(RouteNames.settingsScreen);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: isMyProfile != true
                    ? Assets.icons.chatting.svg()
                    : Icon(Icons.settings, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        SizedBox(height: 16.h),
        CircleAvatar(
          radius: 60,
          backgroundImage: const NetworkImage(
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'Jenny Gomes, 23',
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on_outlined, size: 16.h),
            const SizedBox(width: 4),
            Text('Approx. 400 km', style: TextStyle(fontSize: 14.sp)),
          ],
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8.h,
            runSpacing: 8.h,
            children: [
              _buildInterestTag(Assets.icons.iceCream, 'Ice-cream'),
              _buildInterestTag(Assets.icons.makeUpBrash, 'Make-up'),
              _buildInterestTag(Assets.icons.kitty, 'Pets'),
              _buildInterestTag(Assets.icons.filmWheel, 'Films'),
              _buildInterestTag(Assets.icons.coffee, 'Coffee'),
              _buildInterestTag(Assets.icons.gift, 'Gifts'),
            ],
          ),
        ),
        SizedBox(height: 28.h),
      ],
    );
  }

  Widget _buildInterestTag(SvgGenImage icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon.svg(height: 16.h, width: 16.h),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12.sp)),
        ],
      ),
    );
  }

  Widget _buildPhotosTab(bool isMyProfile) {
    final width = (1.sw - 40.w - 12.w) / 2;

    // Build photo items separately for clarity
    List<Widget> photoItems = [];

    // Add "Add Photo" button only if it's my profile
    if (isMyProfile) {
      photoItems.add(
        GestureDetector(
          onTap: () async {
            final pickedImage = await CustomImagePicker.pickImage();
            if (pickedImage != null) {
              setState(() {
                _selectedImage = pickedImage;
              });
            }
          },
          child: DottedBorder(
            options: RoundedRectDottedBorderOptions(
              radius: Radius.circular(16.r),
              gradient: AppColors.primaryGradient,
              strokeWidth: 4.w,
              dashPattern: [8, 4],
              borderPadding: EdgeInsets.zero,
              padding: EdgeInsets.zero,
            ),
            child: Container(
              width: width,
              height: width * 1.24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: Colors.white,
              ),
              child: _selectedImage == null
                  ? Center(
                      child: Assets.icons.imagePicker.svg(
                        width: 42.w,
                        height: 42.h,
                        color: AppColors.primary,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        width: width,
                        height: width * 1.24,
                      ),
                    ),
            ),
          ),
        ),
      );
    }

    // Add existing photos
    photoItems.addAll(
      _photos.map((item) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => _openFullImage(item, context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Image.network(
                  item,
                  fit: BoxFit.cover,
                  width: width,
                  height: width * 1.24,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: width,
                      height: width * 1.24,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 56.h,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Delete icon only if my profile
            if (isMyProfile)
              Positioned(
                top: 8.h,
                right: 8.h,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        elevation: 0,
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        title: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Assets.icons.delete.svg(
                            width: 32.w,
                            height: 32.h,
                            color: Colors.red.shade600,
                          ),
                          // child: Icon(
                          //   Icons.delete_sharp,
                          //   color: Colors.red.shade600,
                          //   size: 24.h,
                          // ),
                        ),
                        content: Text(
                          'Are you sure you want to delete this photo?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: AppColors.primaryVariant),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _photos.remove(item);
                              });
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red.shade600),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withAlpha(125),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Assets.icons.delete.svg(
                      width: 20.w,
                      height: 20.h,
                      color: Colors.red.shade600,
                    ),

                    // child: Icon(
                    //   Icons.delete,
                    //   color: Colors.red.shade600,
                    //   size: 20.w,
                    // ),
                  ),
                ),
              ),
          ],
        );
      }),
    );

    return Wrap(spacing: 12.w, runSpacing: 12.w, children: photoItems);
  }
}

void _openFullImage(String imageUrl, BuildContext context) {
  Navigator.push(
    context,
    PageRouteBuilder(
      opaque: true,
      pageBuilder: (_, __, ___) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Dismissible(
            key: const Key('full_image'),
            direction: DismissDirection.down,
            onDismissed: (_) => Navigator.pop(context),
            child: Center(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Image.network(imageUrl, fit: BoxFit.contain),
              ),
            ),
          ),
        );
      },
    ),
  );
}

// /// Helper for SliverPersistentHeader
// class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
//   final TabBar _tabBar;

//   _SliverTabBarDelegate(this._tabBar);

//   @override
//   double get minExtent => _tabBar.preferredSize.height;
//   @override
//   double get maxExtent => _tabBar.preferredSize.height;

//   @override
//   Widget build(
//     BuildContext context,
//     double shrinkOffset,
//     bool overlapsContent,
//   ) {
//     return Container(color: const Color(0xFFF5F5F5), child: _tabBar);
//   }

//   @override
//   bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
// }
