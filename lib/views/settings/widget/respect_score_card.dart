import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/localization/app_localizations.dart';

class TrustScoreCard extends StatelessWidget {
  const TrustScoreCard({
    super.key,
    this.score = 0.0,
    this.meetsCount = 0,
  });

  final double score;
  final int meetsCount;

  @override
  Widget build(BuildContext context) {
    final clampedScore = score.clamp(0.0, 5.0);
    final fullStars = clampedScore.floor();
    final hasHalf = (clampedScore - fullStars) >= 0.25 &&
        (clampedScore - fullStars) < 0.75;
    final extraFull = (clampedScore - fullStars) >= 0.75 ? 1 : 0;
    final filledCount = (fullStars + extraFull).clamp(0, 5);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20.sp),
                    const SizedBox(width: 8),
                    Text(
                      clampedScore.toStringAsFixed(
                        clampedScore == clampedScore.roundToDouble() ? 0 : 1,
                      ),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).translate('respectScore'),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.r),
                    gradient: AppColors.primaryGradient,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20.sp),
                      const SizedBox(width: 6),
                      Text(
                        AppLocalizations.of(context).translate('trusted'),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              meetsCount == 0
                  ? AppLocalizations.of(context).translate('noRealLifeMeets')
                  : '${AppLocalizations.of(context).translate('basedOnMeets')} $meetsCount ${AppLocalizations.of(context).translate('realLifeMeets')}',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(5, (index) {
                IconData iconData;
                Color color;
                if (index < filledCount) {
                  iconData = Icons.star;
                  color = Colors.amber;
                } else if (index == filledCount && hasHalf) {
                  iconData = Icons.star_half;
                  color = Colors.amber;
                } else {
                  iconData = Icons.star_border;
                  color = Colors.amber.shade300;
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Icon(iconData, color: color, size: 20.sp),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
