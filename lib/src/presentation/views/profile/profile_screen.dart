import 'dart:io';
import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/core/helper/helper.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibe_now/src/presentation/views/common/custom_elevated_button.dart';
import 'package:vibe_now/src/presentation/views/common/interest_chip.dart';
import 'package:vibe_now/src/presentation/views/profile/unlocked_profile_screen.dart';
import 'package:vibe_now/utils.dart' as utils;

class InterestTag {
  final String label;
  final SvgGenImage icon;
  bool isSelected;

  InterestTag({
    required this.label,
    required this.icon,
    required this.isSelected,
  });
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.isMyProfile = true});

  final bool isMyProfile;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _bioController = TextEditingController();

  final _tabs = ['Photos', 'Posts'];

  // For photo grid
  final List<String> _photos = [
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800',
    'https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?w=800',
    'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?w=800',
  ];

  File? _selectedProfileImage;

  final List<InterestTag> _allInterests = [
    InterestTag(label: 'Coffee', icon: Assets.icons.coffee, isSelected: true),
    InterestTag(label: 'Music', icon: Assets.icons.music, isSelected: true),
    InterestTag(label: 'Books', icon: Assets.icons.book, isSelected: true),
    InterestTag(label: 'Gaming', icon: Assets.icons.aiGame, isSelected: false),
    InterestTag(
      label: 'Calendar',
      icon: Assets.icons.calender,
      isSelected: false,
    ),
    InterestTag(label: 'Travel', icon: Assets.icons.book, isSelected: false),
    InterestTag(
      label: 'Fitness',
      icon: Assets.icons.creationStar,
      isSelected: true,
    ),
    InterestTag(label: 'Cooking', icon: Assets.icons.gift, isSelected: false),
    InterestTag(label: 'Art', icon: Assets.icons.community, isSelected: false),
    InterestTag(
      label: 'Photography',
      icon: Assets.icons.camera,
      isSelected: false,
    ),
  ];

  File? _selectedImage;
  int _selectedTabIndex = 0;

  bool _isEditable = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Move _tabWidgets here so it rebuilds when setState is called
    final _tabWidgets = [_buildPhotosTab(widget.isMyProfile), PostsTab()];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SafeArea(bottom: false, child: SizedBox(height: 12.h)),
            _buildAppBar(context, widget.isMyProfile),

            _buildProfileHeader(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _tabs.map((item) {
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedTabIndex = _tabs.indexOf(item)),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _selectedTabIndex == _tabs.indexOf(item)
                              ? Colors.black
                              : Colors.transparent,
                          width: 2.w,
                        ),
                      ),
                    ),
                    width: (1.sw - 40.w) / 2,
                    height: 48.w,
                    child: Center(
                      child: Text(
                        item,
                        style: TextStyle(
                          color: AppColors.onBackground,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),
            _tabWidgets[_selectedTabIndex],
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
              child: Column(
                children: [
                  Container(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profilePicWidget() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: _selectedProfileImage != null
              ? FileImage(_selectedProfileImage!)
              : NetworkImage(
                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
                ),
        ),
        if (_isEditable)
          GestureDetector(
            onTap: () async {
              utils.showImagePickerOptions(context, (imageSource) async {
                final image = await utils.pickSingleImage(
                  context: context,
                  source: imageSource,
                  compress: true,
                );

                if (image != null) {
                  setState(() {
                    _selectedProfileImage = image;
                  });
                }
              });
            },
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
    );
  }

  Widget _buildBioField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Bio',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff555555),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xffAEAEAE)),
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: TextFormField(
              controller: _bioController,
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
              "${_bioController.text.length}/70",
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _profilePicWidget(),
              Positioned(
                right: 16.w,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _isEditable = !_isEditable;
                    });
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
                    child: Icon(
                      _isEditable ? Icons.done_all : Icons.edit,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ],
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
        SizedBox(height: 8.h),
        if (!_isEditable)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Assets.icons.coffeeColor.svg(height: 16.h),
              SizedBox(width: 4.w),
              Text(
                'Coffee enthusiast   |',
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
        if (_isEditable) _buildBioField(),
        SizedBox(height: 16.h),
        if (!_isEditable)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8.h,
              runSpacing: 8.h,
              children: _allInterests
                  .where((interest) => interest.isSelected)
                  .map((interest) {
                    return _buildInterestTag(interest.icon, interest.label);
                  })
                  .toList(),
            ),
          ),
        if (_isEditable) _buildInterestSection(),
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

    List<Widget> photoItems = [];

    if (isMyProfile) {
      photoItems.add(
        GestureDetector(
          onTap: () async {
            utils.showImagePickerOptions(context, (imageSource) async {
              final image = await utils.pickSingleImage(
                context: context,
                source: imageSource,
                compress: true,
              );

              if (image != null) {
                setState(() {
                  _selectedImage = image;
                });
              }
            });
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
                      builder: (context) =>
                          _buildImageDeleteAlertDialog(context, item),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.w),
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
                    child: Assets.icons.trash.svg(
                      width: 24.w,
                      height: 24.h,
                      color: Colors.red.shade600,
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );

    return Wrap(spacing: 12.w, runSpacing: 12.w, children: photoItems);
  }

  Widget _buildImageDeleteAlertDialog(BuildContext context, String item) {
    return AlertDialog(
      elevation: 0,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
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
        child: Assets.icons.trash.svg(
          width: 32.w,
          height: 32.h,
          color: Colors.red.shade600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 18.h,
        children: [
          Text('Are you sure you want to delete this photo?'),
          SizedBox(
            height: 24.h,
            child: Row(
              spacing: 24.w,
              children: [
                Expanded(
                  child: CustomElevatedButton(
                    onTap: () => Navigator.pop(context),
                    buttonText: 'Cancel',
                  ),
                ),
                Expanded(
                  child: PrimaryButton.text(
                    onPressed: () {
                      setState(() {
                        _photos.remove(item);
                        Navigator.pop(context);
                      });
                    },
                    text: 'Delete',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Interests',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff555555),
                ),
              ),
              // Add new interest button
              GestureDetector(
                onTap: () => _showAddInterestDialog(),
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.grey[400]!, width: 1.5),
                    gradient: AppColors.primaryGradientRotated,
                  ),
                  child: Icon(Icons.add, color: Colors.white, size: 20.sp),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: _allInterests.map((item) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    item.isSelected = !item.isSelected;
                  });
                },
                child: InterestChip(
                  icon: item.icon,
                  label: item.label,
                  isSelected: item.isSelected,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showAddInterestDialog() {
    final TextEditingController _newInterestController =
        TextEditingController();
    SvgGenImage? selectedIcon;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            // Helper moved inside StatefulBuilder
            Widget _buildSelectableIcon(SvgGenImage icon) {
              final bool isSelected = selectedIcon == icon;
              return GestureDetector(
                onTap: () {
                  setStateDialog(() {
                    selectedIcon = icon;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    gradient: isSelected ? AppColors.primaryGradient : null,
                  ),
                  child: icon.svg(
                    height: 24.h,
                    width: 24.h,
                    color: isSelected ? Colors.white : null,
                  ),
                ),
              );
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              backgroundColor: AppColors.backgroundVariant,
              title: Text("Add New Interest"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _newInterestController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Enter interest name",
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey[400]!,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 12.w,
                    children: [
                      _buildSelectableIcon(Assets.icons.coffee),
                      _buildSelectableIcon(Assets.icons.music),
                      _buildSelectableIcon(Assets.icons.book),
                      _buildSelectableIcon(Assets.icons.community),
                    ],
                  ),
                  SizedBox(height: 18.h),
                  SizedBox(
                    height: 28.h,
                    child: Row(
                      spacing: 24.w,
                      children: [
                        Expanded(
                          child: CustomElevatedButton(
                            onTap: () => Navigator.pop(context),
                            buttonText: 'Cancel',
                          ),
                        ),
                        Expanded(
                          child: PrimaryButton.text(
                            onPressed: () {
                              final newInterest = _newInterestController.text
                                  .trim();
                              if (newInterest.isNotEmpty) {
                                setState(() {
                                  _allInterests.add(
                                    InterestTag(
                                      label: newInterest,
                                      icon:
                                          selectedIcon ??
                                          Assets.icons.community,
                                      isSelected: true,
                                    ),
                                  );
                                });
                                Navigator.pop(context);
                              }
                            },
                            text: 'Add',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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

class PostsTab extends StatefulWidget {
  const PostsTab({super.key});

  @override
  State<PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends State<PostsTab> {
  final List<Map<String, dynamic>> _posts = [
    {"is_liked": true},
    {"is_liked": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _posts.map((item) {
        return PostItem(
          isLiked: item["is_liked"],
          onLikeTap: () {
            setState(() => item["is_liked"] = !item["is_liked"]);
          },
        );
      }).toList(),
    );
  }
}

class PostItem extends StatelessWidget {
  final bool isLiked;
  final VoidCallback onLikeTap;

  const PostItem({super.key, required this.isLiked, required this.onLikeTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jenny smith',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  Row(
                    children: [
                      Assets.icons.earth.svg(
                        width: 16,
                        height: 16,
                        color: Color(0xFF9D9D9D),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        ' 20 Oct',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9D9D9D),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Column(
                spacing: 8.h,
                children: [
                  GestureDetector(
                    onTap: onLikeTap,
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.grey,
                      size: 30,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.pushNamed(RouteNames.likeScreen),
                    child: Text(
                      '100',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Anybody wants to have coffee?',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
