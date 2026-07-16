import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/views/common/interest_chip.dart';

class LockedProfileScreen extends StatelessWidget {
  const LockedProfileScreen({
    super.key,
    this.userName,
    this.avatarUrl,
    this.distanceKm,
  });

  final String? userName;
  final String? avatarUrl;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    final resolvedAvatar = avatarUrl != null && avatarUrl!.isNotEmpty
        ? AppCredentials.fixurl(avatarUrl!)
        : null;
    final dist = distanceKm ?? 0.0;
    final distText = dist < 1
        ? 'Approximate ${(dist * 1000).toStringAsFixed(0)} m'
        : 'Approximate ${dist.toStringAsFixed(1)} km';
    final displayName = userName?.isNotEmpty == true ? userName! : 'Jenny Gomes 23';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Column(
                          children: [
                            SizedBox(height: 52.h),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
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
                              child: Column(
                                children: [
                                  SizedBox(height: 56.h),
                                  // Name
                                  Text(
                                    displayName,
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Distance
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 16.h,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        distText,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  // Interest Tags
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      // InterestChip(
                                      //   icon: Assets.icons.iceCream,
                                      //   label: 'Ice-cream',
                                      // ),
                                      // InterestChip(
                                      //   icon: Assets.icons.makeUpBrash,
                                      //   label: 'Make-up',
                                      // ),
                                      // InterestChip(
                                      //   icon: Assets.icons.kitty,
                                      //   label: 'Pets',
                                      // ),
                                      // InterestChip(
                                      //   icon: Assets.icons.filmWheel,
                                      //   label: 'Films',
                                      // ),
                                      // InterestChip(
                                      //   icon: Assets.icons.coffee,
                                      //   label: 'Coffee',
                                      // ),
                                      // InterestChip(
                                      //   icon: Assets.icons.gift,
                                      //   label: 'Gifts',
                                      // ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Wave Button
                                  PrimaryButton(
                                    onPressed: () {},
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '👋',
                                            style: TextStyle(fontSize: 24),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            AppLocalizations.of(context).translate('wave'),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Profile Picture
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(4),
                              child: ClipOval(
                                child: resolvedAvatar != null
                                    ? Image.network(
                                        resolvedAvatar,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceVariant,
                                            child: Icon(
                                              Icons.person,
                                              size: 60,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceVariant,
                                        child: Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Information Text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'The Wave feature lets you show friendly interest in someone nearby.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'If you like someone, you can send them a Wave.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildBulletPoint(
                          context: context,
                          text:
                              'Before acceptance: Both users only see an approximate location (for privacy).',
                        ),
                        const SizedBox(height: 12),
                        _buildBulletPoint(
                          context: context,
                          text:
                              'After acceptance: Once the other person accepts the Wave, their exact location becomes visible, and both know that it\'s okay to approach or meet.',
                        ),
                      ],
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSize _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              child: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onTap: () => Navigator.pop(context),
            ),
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
              child: Assets.icons.chatting.svg(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint({
    required String text,
    required BuildContext context,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
