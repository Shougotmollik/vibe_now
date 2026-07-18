import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vibe_now/controller/community_controller.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/model/community_member.dart';
import 'package:vibe_now/utils.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/community/community_manage_member_screen.dart';
import 'package:vibe_now/views/notification/widgets/animated_dialog_content.dart';

class CommunityMemberScreen extends StatefulWidget {
  const CommunityMemberScreen({super.key, required this.communityId});
  final int communityId;

  @override
  State<CommunityMemberScreen> createState() => _CommunityMemberScreenState();
}

class _CommunityMemberScreenState extends State<CommunityMemberScreen> {
  final CommunityController _controller = Get.find<CommunityController>();

  final List<_TabConfig> _tabs = [
    _TabConfig(labelKey: 'activeTab', apiTab: 'joined'),
    _TabConfig(labelKey: 'requestedTab', apiTab: 'requested'),
  ];

  String _selectedTab = 'joined';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchMembers());
  }

  void _fetchMembers({bool showLoading = true}) {
    _controller.manageCommunityMembers(
      id: widget.communityId,
      tab: _selectedTab,
      showLoading: showLoading,
    );
  }

  Widget _buildEmptyState() {
    final loc = AppLocalizations.of(context);
    String titleKey;
    String descKey;

    switch (_selectedTab) {
      case 'joined':
        titleKey = 'noActiveMembersTitle';
        descKey = 'noActiveMembersDesc';
        break;
      case 'requested':
        titleKey = 'noPendingRequestsTitle';
        descKey = 'noPendingRequestsDesc';
        break;
      default:
        titleKey = 'noMembersFoundTitle';
        descKey = 'noMembersFoundDesc';
        break;
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Assets.icons.users.svg(
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomAppBar(title: loc.translate('manageRequest')),
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommunityManageMemberScreen(
                            communityId: widget.communityId,
                          ),
                        ),
                      );
                      _fetchMembers(showLoading: false);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        loc.translate('manage'),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: _tabs.map((tab) {
                  return Padding(
                    padding: EdgeInsets.only(right: 12.w),
                    child: _buildTabTrigger(tab),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Obx(() {
                if (_controller.isManageMembersLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final members = _controller.manageMembers;
                if (members.isEmpty) {
                  return _buildEmptyState();
                }

                return _selectedTab == 'joined'
                    ? _buildMemberList(members)
                    : _buildRequestList(members);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberList(List<CommunityMember> members) {
    return ListView.separated(
      itemCount: members.length,
      separatorBuilder: (context, index) => Divider(
        indent: 20,
        endIndent: 20,
        color: Theme.of(context).dividerColor,
      ),
      itemBuilder: (context, index) {
        final member = members[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(
              AppCredentials.fixurl(member.user.avatar),
            ),
          ),
          title: Text(
            member.user.fullName,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            // member.requestedAt?.timeAgo,
            timeAgo(DateTime.parse(member.requestedAt!), context: context),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          onTap: () {},
        );
      },
    );
  }

  Widget _buildRequestList(List<CommunityMember> members) {
    return ListView.separated(
      itemCount: members.length,
      separatorBuilder: (context, index) => Divider(
        indent: 20,
        endIndent: 20,
        color: Theme.of(context).dividerColor,
      ),
      itemBuilder: (context, index) {
        final member = members[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(
              AppCredentials.fixurl(member.user.avatar),
            ),
          ),
          title: Text(
            member.user.fullName,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          subtitle: Text(
            AppLocalizations.of(context).translate('requestedToJoin'),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: SizedBox(
            width: 60.w,
            child: Row(
              spacing: 8.w,
              children: [
                GestureDetector(
                  onTap: () async {
                    final success = await _controller.joinRequestManage(
                      memberId: member.memberId,
                      action: 'approve',
                    );
                    if (!context.mounted) return;
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) {
                        return Center(
                          child: Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            elevation: 0,
                            backgroundColor: Colors.transparent,                              child: AnimatedDialogContent(
                              content: success
                                  ? '${AppLocalizations.of(context).translate('youHaveAcceptedJoinRequest')}${member.user.fullName}${AppLocalizations.of(context).translate('sJoinRequest')}'
                                  : AppLocalizations.of(context).translate('failedToAccept'),
                              accept: success,
                            ),
                          ),
                        );
                      },
                    );
                    if (success) _fetchMembers(showLoading: false);
                  },
                  child: Assets.icons.accept.svg(
                    width: 20.w,
                    height: 20.h,
                    color: AppColors.primary,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final success = await _controller.joinRequestManage(
                      memberId: member.memberId,
                      action: 'reject',
                    );
                    if (!context.mounted) return;
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (context) {
                        return Center(
                          child: Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            elevation: 0,
                            backgroundColor: Colors.transparent,                              child: AnimatedDialogContent(
                              content: success
                                  ? '${AppLocalizations.of(context).translate('youHaveRejectedJoinRequest')}${member.user.fullName}${AppLocalizations.of(context).translate('sJoinRequestRejected')}'
                                  : AppLocalizations.of(context).translate('failedToReject'),
                              accept: success,
                            ),
                          ),
                        );
                      },
                    );
                    if (success) _fetchMembers(showLoading: false);
                  },
                  child: Assets.icons.decline.svg(width: 22.w, height: 22.h),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabTrigger(_TabConfig tab) {
    final loc = AppLocalizations.of(context);
    bool isActive = _selectedTab == tab.apiTab;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tab.apiTab;
        });
        _fetchMembers();
      },
      child: _buildStatusTab(loc.translate(tab.labelKey), isActive),
    );
  }

  Widget _buildStatusTab(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: isActive ? AppColors.primaryGradient : null,
        border: isActive
            ? null
            : Border.all(color: Theme.of(context).dividerColor),
        color: isActive
            ? null
            : Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive
              ? Colors.white
              : Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _TabConfig {
  final String labelKey;
  final String apiTab;

  const _TabConfig({required this.labelKey, required this.apiTab});
}
