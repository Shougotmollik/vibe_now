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
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vibe_now/env.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/views/common/location_selection_screen.dart';
import 'package:vibe_now/model/category.dart';
import 'package:vibe_now/model/interest_model.dart';
import 'package:vibe_now/model/chat.dart';
import 'package:vibe_now/model/profile_model.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';
import 'package:vibe_now/views/common/interest_chip.dart';
import 'package:vibe_now/utils.dart' as utils;
// import 'package:vibe_now/views/profile/widget/post_tab.dart';
import 'package:vibe_now/views/settings/widget/respect_score_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.isMyProfile = true, this.userId});

  final bool isMyProfile;
  final String? userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _bioController = TextEditingController(
    text: '', // Filled from profile or default loc.translate('defaultBio')
  );
  final TextEditingController _searchInterestController =
      TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Edit-mode state fields
  String _editGender = 'male';
  String _editDob = '';
  List<String> _editLookingFor = [];
  double? _editLatitude;
  double? _editLongitude;
  String? _editLocationName;

  // final _tabs = ['Photos', 'Posts'];

  // For photo grid
  final List<String> _photos = [
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800',
    'https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?w=800',
    'https://images.unsplash.com/photo-1518791841217-8f162f1e1131?w=800',
  ];

  File? _selectedProfileImage;

  File? _selectedImage;
  // int _selectedTabIndex = 0;

  bool _isEditable = false;
  bool _isSaving = false;

  final ProfileController profileController = Get.find<ProfileController>();
  final OnBoardingController onBoardingController =
      Get.find<OnBoardingController>();

  @override
  void initState() {
    super.initState();
    // Pass targetUserId when viewing another user's profile.
    profileController.fetchProfile(
      targetUserId: widget.isMyProfile ? null : widget.userId,
    );
  }

  @override
  void dispose() {
    _bioController.dispose();
    _searchInterestController.dispose();
    _locationController.dispose();
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
              _buildAppBar(context, widget.isMyProfile, account: account),
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

  PreferredSize _buildAppBar(
    BuildContext context,
    bool isMyProfile, {
    UserAccount? account,
  }) {
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
                  final chatId = account?.chatId;
                  if (chatId != null && chatId.isNotEmpty) {
                    // Navigate directly to chat inbox with the existing chat
                    final profile = account?.profile;
                    final avatarUrl = profile?.primaryPhoto?.fullUrl ?? '';
                    context.pushNamed(
                      RouteNames.chatInboxScreen,
                      extra: Chat(
                        id: chatId,
                        name: (profile?.fullName ?? '').isNotEmpty
                            ? utils.titleCase(profile!.fullName)
                            : loc.translate('defaultUserName'),
                        avatars: avatarUrl.isNotEmpty ? [avatarUrl] : [],
                        otherMember: OtherMember(
                          id: account?.id,
                          fullName: profile?.fullName,
                          avatar: profile?.primaryPhoto?.image,
                        ),
                      ),
                    );
                  } else {
                    context.pushNamed(RouteNames.chatScreen);
                  }
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
                hintText: loc.translate('enterYourBio'),
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
                    onTap: () async {
                      if (_isEditable && _isSaving) return;
                      if (_isEditable) {
                        _isSaving = true;
                        // Save and exit edit mode
                        final success = await profileController
                            .updateFullProfile(
                              fullName:
                                  profileController
                                      .account
                                      .value
                                      ?.profile
                                      .fullName ??
                                  '',
                              bio: _bioController.text.trim(),
                              dateOfBirth: _editDob,
                              gender: _editGender,
                              latitude: _editLatitude,
                              longitude: _editLongitude,
                              locationName: _editLocationName,
                              lookingFor: _editLookingFor,
                            );
                        if (!context.mounted) return;
                        _isSaving = false;
                        // Sync the typed location name
                        _editLocationName = _locationController.text.trim();
                        if (success) {
                          AppSnackbar.show(
                            message: loc.translate('interestUpdateSuccess'),
                            type: SnackType.warning,
                          );
                          setState(() => _isEditable = false);
                        } else {
                          AppSnackbar.show(
                            message: loc.translate('interestUpdateFailed'),
                            type: SnackType.error,
                          );
                        }
                      } else {
                        // Enter edit mode
                        setState(() => _isEditable = true);
                        final p = profileController.account.value?.profile;
                        if (p != null) {
                          _editGender = p.gender ?? 'male';
                          _editDob = p.dateOfBirth ?? '';
                          _editLookingFor = List.from(p.whatAreYouLookingFor);
                          _editLatitude = p.latitude;
                          _editLongitude = p.longitude;
                          _editLocationName = p.locationName;
                          _locationController.text = p.locationName ?? '';
                        }
                        _searchInterestController.clear();
                        profileController.fetchFlatInterests();
                      }
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
                      child: Obx(() {
                        final saving = profileController.isLoading.value;
                        if (saving) {
                          return SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          );
                        }
                        return Icon(
                          _isEditable ? Icons.done_all : Icons.edit,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        );
                      }),
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
        if (_isEditable) SizedBox(height: 16.h),
        if (_isEditable) _buildGenderField(),
        if (_isEditable) SizedBox(height: 16.h),
        if (_isEditable) _buildDobField(),
        if (_isEditable) SizedBox(height: 16.h),
        if (_isEditable) _buildLookingForField(),
        if (_isEditable) SizedBox(height: 16.h),
        if (_isEditable) _buildLocationField(),
        if (_isEditable) SizedBox(height: 16.h),
        if (!_isEditable)
          interests.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8.h,
                    runSpacing: 8.h,
                    children: interests
                        .map((label) => _buildStringInterestTag(label))
                        .toList(),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    loc.translate('noInterestAddedYet'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
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

  // ──── EDIT-MODE FIELD BUILDERS ────

  Widget _buildGenderField() {
    final loc = AppLocalizations.of(context);
    final options = ['male', 'female', 'other'];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate('stepGender'),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            children: options.map((g) {
              final selected = _editGender == g;
              return GestureDetector(
                onTap: () => setState(() => _editGender = g),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: selected
                        ? AppColors.primaryGradientRotated
                        : null,
                    color: selected
                        ? null
                        : Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    g == 'male'
                        ? loc.translate('male')
                        : g == 'female'
                        ? loc.translate('female')
                        : loc.translate('other'),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: selected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDobField() {
    final loc = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate('stepBirthday'),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: _editDob.isNotEmpty
                    ? DateTime.tryParse(_editDob) ?? DateTime(now.year - 25)
                    : DateTime(now.year - 25),
                firstDate: DateTime(now.year - 100),
                lastDate: DateTime(now.year - 13),
              );
              if (picked != null) {
                setState(() {
                  _editDob =
                      '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                });
              }
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Text(
                _editDob.isNotEmpty ? _editDob : loc.translate('selectDate'),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: _editDob.isNotEmpty
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLookingForField() {
    final loc = AppLocalizations.of(context);
    final options = [
      'Community',
      'Friendship',
      'Event',
      'Relationship',
      'Networking',
    ];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate('stepLookingFor'),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: options.map((opt) {
              final selected = _editLookingFor.contains(opt);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selected) {
                      _editLookingFor.remove(opt);
                    } else {
                      _editLookingFor.add(opt);
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: selected
                        ? AppColors.primaryGradientRotated
                        : null,
                    color: selected
                        ? null
                        : Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    opt,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: selected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField() {
    final loc = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate('location'),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: TextFormField(
                    controller: _locationController,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: loc.translate('enterYourLocation'),
                      hintStyle: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                        size: 16.h,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 16.w,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LocationSelectionScreen(
                        apiKey: EnvHandler.google_map_api_key,
                        initialPosition:
                            _editLatitude != null && _editLongitude != null
                            ? LatLng(_editLatitude!, _editLongitude!)
                            : null,
                        canSelectLocation: true,
                        onLocationSelect: (location) {
                          setState(() {
                            _editLatitude = location.position.latitude;
                            _editLongitude = location.position.longitude;
                            _editLocationName = location.name;
                            _locationController.text = location.name;
                          });
                        },
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradientRotated,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: Icon(
                    Icons.map_outlined,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          if (_editLatitude != null && _editLongitude != null)
            Padding(
              padding: EdgeInsets.only(left: 4.w),
              child: Text(
                '${_editLatitude!.toStringAsFixed(4)}, ${_editLongitude!.toStringAsFixed(4)}',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build the flat interest picker used in edit mode.
  Widget _buildInterestSection() {
    final loc = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.0.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title + selection counter
          Row(
            children: [
              Text(
                loc.translate('interests'),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Obx(() {
                final count = profileController.selectedInterestNames.length;
                final max = ProfileController.maxInterestSelection;
                final isAtMax = count >= max;
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: isAtMax
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : Theme.of(
                            context,
                          ).colorScheme.surfaceVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '$count/$max selected',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: isAtMax
                          ? AppColors.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }),
            ],
          ),
          SizedBox(height: 12.h),

          // Search bar
          TextField(
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: loc.translate('searchInterestHint'),
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 20.sp,
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              filled: true,
              fillColor: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24.r),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              profileController.interestSearchQuery.value = value;
            },
          ),
          SizedBox(height: 14.h),

          // Interest chips (flat list)
          Obx(() {
            final searchQuery = profileController.interestSearchQuery.value
                .trim()
                .toLowerCase();
            final all = profileController.flatInterests;

            if (profileController.isFlatInterestsLoading.value && all.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }

            List<FlatInterest> displayList;
            if (searchQuery.isNotEmpty) {
              // Filter all by name, then sort selected first
              displayList = all
                  .where((i) => i.name.toLowerCase().contains(searchQuery))
                  .toList();
              displayList.sort((a, b) {
                final aSel = profileController.selectedInterestNames.contains(
                  a.name,
                );
                final bSel = profileController.selectedInterestNames.contains(
                  b.name,
                );
                if (aSel && !bSel) return -1;
                if (!aSel && bSel) return 1;
                return 0;
              });
            } else {
              // Show only selected + unselected up to 20
              final selectedSet = profileController.selectedInterestNames;
              final List<FlatInterest> selected = [];
              final List<FlatInterest> unselected = [];
              for (final item in all) {
                if (selectedSet.contains(item.name)) {
                  selected.add(item);
                } else if (unselected.length < 20) {
                  unselected.add(item);
                }
              }
              displayList = [...selected, ...unselected];
            }

            if (displayList.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    loc.translate('noResultsFound'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              );
            }

            return Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: displayList.map((interest) {
                final selected = profileController.selectedInterestNames
                    .contains(interest.name);
                return GestureDetector(
                  onTap: () =>
                      profileController.toggleInterestSelection(interest.name),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: selected
                          ? AppColors.primaryGradientRotated
                          : null,
                      color: selected
                          ? null
                          : Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      interest.name,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: selected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),

          SizedBox(height: 8.h),

          // Clear all button (inline)
          Align(
            alignment: Alignment.centerLeft,
            child: Obx(() {
              final hasSelections =
                  profileController.selectedInterestNames.isNotEmpty;
              return IgnorePointer(
                ignoring: !hasSelections,
                child: Opacity(
                  opacity: hasSelections ? 1.0 : 0.4,
                  child: GestureDetector(
                    onTap: () => profileController.clearAllInterests(),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Text(
                        'Clear all',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
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
