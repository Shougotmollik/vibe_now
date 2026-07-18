import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/controller/community_controller.dart';
import 'package:vibe_now/core/constant/qrcontext_enum.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/model/community.dart';
import 'package:vibe_now/views/common/custom_search_bar.dart';
import 'package:vibe_now/views/community/widgets/community_card.dart';
import 'package:vibe_now/views/community/widgets/community_filter.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final selectedTab = 'all'.obs;
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  final CommunityController communityController = Get.find<CommunityController>();

  @override
  void initState() {
    super.initState();
    communityController.getCommunities(tab: 'all');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: RefreshIndicator(
            onRefresh: () => communityController.getCommunities(
              tab: selectedTab.value,
            ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Obx(() {
                return Column(
                  children: [
                    _buildAppBar(context, loc),
                    SizedBox(height: 12.h),

                    CustomSearchBar(
                      controller: searchController,
                      onFilterTap: () => showDialog(
                        context: context,
                        builder: (context) => const CommunityFilterDialog(),
                      ),
                      hintText: loc.translate('searchForCommunities'),
                      onChanged: (query) {
                        _debounce?.cancel();
                        _debounce = Timer(const Duration(milliseconds: 500), () {
                          communityController.getCommunities(
                            tab: selectedTab.value.toLowerCase(),
                            search: query,
                          );
                        });
                      },
                    ),

                    SizedBox(height: 12.h),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTab(context, 'all', loc.translate('all')),
                          _buildTab(context, 'joined', loc.translate('joined')),
                          _buildTab(context, 'organized', loc.translate('organized')),
                          _buildTab(context, 'interested', loc.translate('interested')),
                        ],
                      ),
                    ),

                    SizedBox(height: 14.h),

                    Obx(() {
                      final isLoading = communityController.isLoading.value;
                      final communities = communityController.communityList;

                      if (isLoading) {
                        return Column(
                          children: List.generate(
                            3,
                            (index) => Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: CommunityCard(
                                community: Community(
                                  title: "",
                                  description: "",
                                  accessLevel: "",
                                  coverImage: "",
                                  address: "",
                                  communityDate: "",
                                  communityTime: "",
                                  maxAttendees: 0,
                                  joinedCount: 0,
                                  isJoined: false,
                                  isInterested: false,
                                ),
                                isLoading: true,
                              ),
                            ),
                          ),
                        );
                      }

                      if (communities.isEmpty) {
                        return _buildEmptyState(context, selectedTab.value, loc);
                      }

                      return Column(
                        children: communities
                            .map(
                              (c) => Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: CommunityCard(community: c),
                              ),
                            )
                            .toList(),
                      );
                    }),

                    SizedBox(height: 24),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Row _buildAppBar(BuildContext context, AppLocalizations loc) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(RouteNames.mainNavBar);
            }
          },
          child: Icon(Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.onSurface),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            loc.translate('communities'),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        GestureDetector(
          onTap: () => context.pushNamed(
            RouteNames.qrVerificationScreen,
            extra: {'qrContext': QRContext.community, 'showScanOnly': true},
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Assets.icons.scan.svg(
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: () => context.pushNamed(RouteNames.createCommunityScreen),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradientRotated,
            ),
            child: Assets.icons.add.svg(),
          ),
        ),
      ],
    );
  }

  Widget _buildTab(BuildContext context, String tabKey, String label) {
    final isSelected = selectedTab.value == tabKey;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () async {
          selectedTab.value = tabKey;
          await communityController.getCommunities(
            tab: tabKey,
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
            vertical: 8.w,
          ),
          decoration: BoxDecoration(
            gradient: isSelected
                ? AppColors.primaryGradientRotated
                : null,
            color: isSelected
                ? null
                : Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String tab, AppLocalizations loc) {
    String titleKey;
    String descKey;

    switch (tab) {
      case 'joined':
        titleKey = 'noCommunitiesJoinedTitle';
        descKey = 'noCommunitiesJoinedDesc';
        break;
      case 'organized':
        titleKey = 'noCommunitiesOrganizedTitle';
        descKey = 'noCommunitiesOrganizedDesc';
        break;
      case 'interested':
        titleKey = 'noCommunitiesInterestedTitle';
        descKey = 'noCommunitiesInterestedDesc';
        break;
      default:
        titleKey = 'noCommunitiesAllTitle';
        descKey = 'noCommunitiesAllDesc';
        break;
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Assets.icons.community.svg(
                  width: 80.w,
                  height: 80.h,
                  colorFilter: const ColorFilter.mode(
                    AppColors.secondaryText,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              loc.translate(titleKey),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              loc.translate(descKey),
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
