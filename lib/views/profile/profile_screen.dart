import 'dart:io';
import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/controller/onboarding_controller.dart';
import 'package:vibe_now/controller/profile_controller.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/core/helper/helper.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/model/category.dart';
import 'package:vibe_now/model/interest_model.dart';
import 'package:vibe_now/model/profile_model.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';
import 'package:vibe_now/views/common/interest_chip.dart';
import 'package:vibe_now/utils.dart' as utils;
// import 'package:vibe_now/views/profile/widget/post_tab.dart';
import 'package:vibe_now/views/settings/widget/respect_score_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.isMyProfile = true});

  final bool isMyProfile;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _bioController = TextEditingController(
    text: '', // Filled from profile or default loc.translate('defaultBio')
  );

  // final _tabs = ['Photos', 'Posts'];

  // For photo grid
  final List<String> _photos = [
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800',
    'https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?w=800',
    'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?w=800',
  ];

  File? _selectedProfileImage;

  // Interest labels use translation keys
  final List<_InterestTagKey> _allInterestKeys = [
    _InterestTagKey(key: 'interestCoffee', icon: Assets.icons.coffee, isSelected: true),
    _InterestTagKey(key: 'interestMusic', icon: Assets.icons.music, isSelected: true),
    _InterestTagKey(key: 'interestBooks', icon: Assets.icons.book, isSelected: true),
    _InterestTagKey(key: 'interestGaming', icon: Assets.icons.aiGame, isSelected: false),
    _InterestTagKey(
      key: 'interestCalendar',
      icon: Assets.icons.calender,
      isSelected: false,
    ),
    _InterestTagKey(key: 'interestTravel', icon: Assets.icons.book, isSelected: false),
    _InterestTagKey(
      key: 'interestFitness',
      icon: Assets.icons.creationStar,
      isSelected: true,
    ),
    _InterestTagKey(key: 'interestCooking', icon: Assets.icons.gift, isSelected: false),
    _InterestTagKey(key: 'interestArt', icon: Assets.icons.community, isSelected: false),
    _InterestTagKey(
      key: 'interestPhotography',
      icon: Assets.icons.camera,
      isSelected: false,
    ),
  ];

  File? _selectedImage;
  // int _selectedTabIndex = 0;

  bool _isEditable = false;
  String? _activeParent;

  final ProfileController profileController = Get.find<ProfileController>();
  final OnBoardingController onBoardingController =
      Get.find<OnBoardingController>();

  @override
  void initState() {
    super.initState();
    profileController.fetchProfile();
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (profileController.isLoading.value &&
            profileController.account.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final account = profileController.account.value;
        final userProfile = account?.profile;
        final loc = AppLocalizations.of(context);
    final fullName = userProfile?.fullName.isNotEmpty == true
            ? utils.titleCase(userProfile!.fullName)
            : loc.translate('defaultUserName');
        final age = _ageFromDob(userProfile?.dateOfBirth);
        final avatarUrl = userProfile?.primaryPhoto?.fullUrl;
        final photoUrls =
            userProfile?.photos.map((p) => p.fullUrl).toList() ?? _photos;
        final bio = userProfile?.bio?.isNotEmpty == true
            ? userProfile!.bio
            : loc.translate('defaultBio');
        final locationName = userProfile?.locationName;
        final interests = userProfile?.interests ?? <String>[];
        final trustScore = userProfile?.trustedScore?.score ?? 0.0;
        final meetsCount = userProfile?.trustedScore?.meetsCount ?? 0;
        if (_bioController.text != bio && !_isEditable) {
          _bioController.text = bio;
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              SafeArea(bottom: false, child: SizedBox(height: 12.h)),
              _buildAppBar(context, widget.isMyProfile),
              _buildProfileHeader(
                fullName: fullName,
                age: age,
                avatarUrl: avatarUrl,
                locationName: locationName,
                bio: bio,
                interests: interests,
              ),
              TrustScoreCard(score: trustScore, meetsCount: meetsCount),
              SizedBox(height: 16.h),
              _buildPhotosTab(widget.isMyProfile, photoUrls),
              SizedBox(height: 112.h),
            ],
          ),
        );
      }),
    );
  }

  int? _ageFromDob(String? dob) {
    if (dob == null || dob.isEmpty) return null;
    try {
      final birth = DateTime.parse(dob);
      final now = DateTime.now();
      var age = now.year - birth.year;
      if (now.month < birth.month ||
          (now.month == birth.month && now.day < birth.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return null;
    }
  }

  PreferredSize _buildAppBar(BuildContext context, bool isMyProfile) {
    final loc = AppLocalizations.of(context);
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
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
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
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: isMyProfile != true
                        ? Assets.icons.chatting.svg()
                        : Icon(
                            Icons.settings,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profilePicWidget({String? avatarUrl}) {
    final loc = AppLocalizations.of(context);
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          backgroundImage: _selectedProfileImage != null
              ? FileImage(_selectedProfileImage!)
              : (avatarUrl != null && avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : NetworkImage(
                            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
                          ))
                    as ImageProvider,
        ),
        if (_isEditable)
          Obx(() {
            final uploading = profileController.isLoading.value;
            return GestureDetector(
              onTap: uploading
                  ? null
                  : () async {
                      utils.showImagePickerOptions(context, (
                        imageSource,
                      ) async {
                        final image = await utils.pickSingleImage(
                          context: context,
                          source: imageSource,
                          compress: true,
                        );

                        if (image != null) {
                          setState(() {
                            _selectedProfileImage = image;
                          });

                          final success = await profileController
                              .updateProfileImage(image);

                          if (!mounted) return;

                          if (success) {
                            AppSnackbar.show(
                              message: loc.translate('profilePhotoUpdated'),
                              type: SnackType.warning,
                            );
                            if (mounted) {
                              setState(() {
                                _selectedProfileImage = null;
                              });
                            }
                          } else {
                            AppSnackbar.show(
                              message: loc.translate('failedToUpdatePhoto'),
                              type: SnackType.warning,
                            );
                          }
                        }
                      });
                    },
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: uploading
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Assets.icons.camera2.svg(),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildBioField() {
    final loc = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                loc.translate('bio'),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: TextFormField(
              controller: _bioController,
              maxLines: 4,
              maxLength: 70,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                counterText: "",
                hintText:
                    loc.translate('enterYourBio'),
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
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
              style: TextStyle(
                fontSize: 12.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader({
    required String fullName,
    int? age,
    String? avatarUrl,
    String? locationName,
    required String bio,
    required List<String> interests,
  }) {
    final loc = AppLocalizations.of(context);
    return Column(
      children: [
        SizedBox(height: 16.h),
        SizedBox(
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _profilePicWidget(avatarUrl: avatarUrl),
              if (widget.isMyProfile)
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
                        color: Theme.of(context).colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).shadowColor.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isEditable ? Icons.done_all : Icons.edit,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          age != null ? '$fullName, $age' : fullName,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 16.h,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                (locationName != null && locationName.isNotEmpty)
                    ? locationName
                    : loc.translate('locationNotSet'),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        if (!_isEditable)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              bio.isNotEmpty ? bio : loc.translate('noBioYet'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
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
              children: interests.isNotEmpty
                  ? interests
                        .map((label) => _buildStringInterestTag(label))
                        .toList()
                  : _allInterestKeys.where((i) => i.isSelected).map((
                      interest,
                    ) {
                      return _buildInterestTag(interest.icon, loc.translate(interest.key));
                    }).toList(),
            ),
          ),
        if (_isEditable) _buildInterestSection(),
        SizedBox(height: 28.h),
      ],
    );
  }

  Widget _buildStringInterestTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon(
          //   Icons.favorite,
          //   size: 14.h,
          //   color: Theme.of(context).colorScheme.primary,
          // ),
          // const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestTag(SvgGenImage icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon.svg(height: 16.h, width: 16.h),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosTab(bool isMyProfile, List<String> photos) {
    final loc = AppLocalizations.of(context);
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

                final uploaded = await onBoardingController
                    .onboardingImageSubmit([image]);

                if (!mounted) return;

                if (uploaded) {
                  AppSnackbar.show(
                    message: loc.translate('photoAdded'),
                    type: SnackType.warning,
                  );
                  await profileController.fetchProfile();
                  if (mounted) {
                    setState(() {
                      _selectedImage = null;
                    });
                  }
                } else {
                  AppSnackbar.show(
                    message: loc.translate('failedToUpload'),
                    type: SnackType.warning,
                  );
                }
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
                color: Theme.of(context).colorScheme.surface,
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
      photos.map((item) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => _openFullImage(item, context),
              onLongPress: () {
                if (isMyProfile && _isEditable) {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        _buildImageDeleteAlertDialog(context, item),
                  );
                }
              },
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
                        color: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          size: 56.h,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
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
    final loc = AppLocalizations.of(context);
    return AlertDialog(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Assets.icons.trash.svg(width: 32.w, height: 32.h),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 18.h,
        children: [
          Text(
            loc.translate('areYouSureDeletePhoto'),
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          SizedBox(
            height: 32.h,
            child: Row(
              spacing: 24.w,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 1.5.w,
                      ),
                    ),
                    child: CustomElevatedButton(
                      btnColor: Theme.of(context).colorScheme.surface,
                      textColor: Theme.of(context).colorScheme.onSurface,
                      onTap: () => Navigator.pop(context),
                      buttonText: loc.translate('cancel'),
                    ),
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
                    text: loc.translate('delete'),
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
    final loc = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.0.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate('interests'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          Obx(() {
            return Column(
              children: profileController.interestGroups.map((group) {
                final isExpanded = profileController.expandedParents.contains(
                  group.parent,
                );
                final isSelected = profileController.isParentSelected(group);

                final isPartial = profileController.isParentPartiallySelected(
                  group,
                );

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                    children: [
                      // Parent
                      GestureDetector(
                        onTap: () =>
                            profileController.toggleExpand(group.parent),
                        child: newMethod(
                          isSelected,
                          isPartial,
                          group,
                          isExpanded,
                        ),
                      ),

                      // Subcategories
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: isExpanded
                              ? Wrap(
                                  alignment: WrapAlignment.start,
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ...group.children.map((sub) {
                                      final selected = profileController
                                          .selectedSubcategories
                                          .contains(sub.name);

                                      return GestureDetector(
                                        onTap: () =>
                                            profileController.toggleSubcategory(
                                              sub.name,
                                              group.parent,
                                            ),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12.w,
                                            vertical: 8.h,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: selected
                                                ? AppColors
                                                      .primaryGradientRotated
                                                : null,
                                            color: selected
                                                ? null
                                                : Theme.of(
                                                    context,
                                                  ).colorScheme.surfaceVariant,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            spacing: 4.w,
                                            children: [
                                              sub.icon.svg(
                                                height: 16.h,
                                                width: 16.h,
                                                color: selected
                                                    ? Colors.white
                                                    : Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                              ),
                                              Text(
                                                sub.name,
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color: selected
                                                      ? Colors.white
                                                      : Theme.of(context)
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),

                      SizedBox(height: 12.h),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
          // GestureDetector(
          //   onTap: () {
          //     _showAddParentInterestDialog();
          //   },
          //   child: Container(
          //     padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 12.h),
          //     width: 160.w,
          //     decoration: BoxDecoration(
          //       gradient: AppColors.primaryGradientRotated,
          //       borderRadius: BorderRadius.circular(16.r),
          //     ),
          //     child: Center(
          //       child: Text(
          //         "Add New Interest",
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontWeight: FontWeight.w500,
          //           fontSize: 14.sp,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  void _showAddParentInterestDialog() {
    final loc = AppLocalizations.of(context);
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            loc.translate('addInterestCategory'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12.h,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: loc.translate('enterInterestName'),
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 32.h,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  spacing: 18.w,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.r),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                            width: 1.5,
                          ),
                        ),
                        child: CustomElevatedButton(
                          btnColor: Theme.of(context).colorScheme.surface,
                          textColor: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                          onTap: () {
                            Navigator.pop(context);
                          },
                          buttonText: loc.translate('cancel'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: PrimaryButton.text(
                        onPressed: () {
                          final value = controller.text.trim();
                          if (value.isNotEmpty) {
                            profileController.addParentInterest(
                              parentName: value,
                            );
                            Navigator.pop(context);
                          }
                        },
                        text: loc.translate('addCategory'),
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
  }

  Widget newMethod(
    bool isSelected,
    bool isPartial,
    Interest group,
    bool isExpanded,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              group.parent,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Icon(
            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  void _showAddInterestDialog() {
    final loc = AppLocalizations.of(context);
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
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text(
                loc.translate('addSubInterest'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _newInterestController,
                    autofocus: true,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: loc.translate('enterInterestName'),
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).dividerColor,
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
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24.r),
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                                width: 1.5.w,
                              ),
                            ),
                            child: CustomElevatedButton(
                              btnColor: Theme.of(context).colorScheme.surface,
                              textColor: Theme.of(
                                context,
                              ).colorScheme.onSurface,
                              onTap: () => Navigator.pop(context),
                              buttonText: loc.translate('cancel'),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Expanded(
                          child: PrimaryButton.text(
                            onPressed: () {
                              final newInterest = _newInterestController.text
                                  .trim();
                              if (newInterest.isNotEmpty) {
                                if (_activeParent != null) {
                                  profileController.addSubInterest(
                                    parent: _activeParent!,
                                    subInterest: SubInterest(
                                      name: newInterest,
                                      icon:
                                          selectedIcon ??
                                          Assets.icons.community,
                                    ),
                                  );
                                }
                                Navigator.pop(context);
                              }
                            },
                            text: loc.translate('addCategory'),
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

class _InterestTagKey {
  final String key;
  final SvgGenImage icon;
  bool isSelected;

  _InterestTagKey({
    required this.key,
    required this.icon,
    required this.isSelected,
  });
}
