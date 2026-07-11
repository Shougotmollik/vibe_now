import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vibe_now/controller/profile_controller.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/model/blocked_user.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/common/custom_elevated_button.dart';
import 'package:vibe_now/views/settings/widgets/blocked_accounts_shimmer.dart';

class BlockedAccountsScreen extends StatefulWidget {
  const BlockedAccountsScreen({super.key});

  @override
  State<BlockedAccountsScreen> createState() => _BlockedAccountsScreenState();
}

class _BlockedAccountsScreenState extends State<BlockedAccountsScreen> {
  final ProfileController _profileController = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    _profileController.fetchBlockedUsers();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              CustomAppBar(title: loc.translate('blockedAccounts')),
              SizedBox(height: 20.h),
              Expanded(
                child: Obx(() {
                  if (_profileController.blockedUsersLoading.value) {
                    return const BlockedAccountsShimmer();
                  }

                  if (_profileController.blockedUsers.isEmpty) {
                    return Center(
                      child: Text(
                        loc.translate('noBlockedAccounts'),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: _profileController.blockedUsers.length,
                    itemBuilder: (context, index) {
                      final blockedUser =
                          _profileController.blockedUsers[index];
                      return _buildAccountTile(context, blockedUser);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTile(BuildContext context, BlockedUser blockedUser) {
    final loc = AppLocalizations.of(context);
    final avatarUrl = blockedUser.blockedUser.fullAvatarUrl;
    final displayName = blockedUser.blockedUser.name.isNotEmpty
        ? blockedUser.blockedUser.name
        : loc.translate('defaultUserName');

    return Obx(() {
      final isUnblocking =
          _profileController.unblockingUserId.value == blockedUser.id;

      return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: avatarUrl.isNotEmpty
                  ? Image.network(
                      avatarUrl,
                      width: 40.w,
                      height: 40.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildFallbackAvatar(displayName),
                    )
                  : _buildFallbackAvatar(displayName),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                displayName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: isUnblocking
                  ? null
                  : () => _showUnblockDialog(context, blockedUser),
              child: isUnblocking
                  ? SizedBox(
                      width: 16.w,
                      height: 16.h,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      loc.translate('unblock'),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFallbackAvatar(String name) {
    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showUnblockDialog(BuildContext context, BlockedUser blockedUser) {
    final loc = AppLocalizations.of(context);
    final displayName = blockedUser.blockedUser.name.isNotEmpty
        ? blockedUser.blockedUser.name
        : loc.translate('defaultUserName');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${loc.translate('areYouSureUnblock')} $displayName?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: CustomElevatedButton(
                        onTap: () => Navigator.pop(dialogContext),
                        buttonText: loc.translate('cancel'),
                        btnColor: Theme.of(context).colorScheme.surfaceVariant,
                        textColor: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: CustomElevatedButton(
                        onTap: () async {
                          Navigator.pop(dialogContext);
                          final success = await _profileController.unblockUser(
                            targetUserId: blockedUser.blockedUser.id,
                            blockRecordId: blockedUser.id,
                          );
                          if (context.mounted) {
                            AppSnackbar.show(
                              message: success
                                  ? loc.translate('unblockSuccess')
                                  : loc.translate('unblockFailed'),
                              type: success ? SnackType.info : SnackType.error,
                            );
                          }
                        },
                        buttonText: loc.translate('unblock'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
