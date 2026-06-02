import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vibe_now/controller/community_controller.dart';
import 'package:vibe_now/controller/meetup_controller.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/model/community_member.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/community/widgets/invitation_success_dialog.dart';

class InviteMemberToPlanMeetup extends StatefulWidget {
  const InviteMemberToPlanMeetup({
    super.key,
    required this.communityId,
    required this.meetupId,
  });
  final String communityId;
  final String meetupId;

  @override
  State<InviteMemberToPlanMeetup> createState() =>
      _InviteMemberToPlanMeetupState();
}

class _InviteMemberToPlanMeetupState extends State<InviteMemberToPlanMeetup> {
  final CommunityController _communityController =
      Get.find<CommunityController>();
  final MeetupController _meetupController = Get.find<MeetupController>();

  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _communityController.manageCommunityMembers(
        id: int.parse(widget.communityId),
        tab: 'joined',
      );
    });
  }

  void _toggleSelectAll() {
    final members = _communityController.manageMembers;
    setState(() {
      if (_selectedIds.length == members.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(members.map((m) => m.user.id));
      }
    });
  }

  void _toggleMember(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _sendInvitation() {
    if (_selectedIds.isEmpty) return;

    _meetupController.inviteMemberToMeetupPlan(
      meetupId: widget.meetupId,
      memberIds: _selectedIds.toList(),
    ).then((success) {
      if (!mounted) return;
      if (success) {
        showDialog(
          context: context,
          builder: (context) => const InviteSuccessDialog(),
        ).then((_) {
          if (mounted) {
            Navigator.pop(context);
            Navigator.pop(context);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: PrimaryButton.text(
            onPressed: _sendInvitation,
            isEnabled: _selectedIds.isNotEmpty,
            text: "Send Invitation",
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: CustomAppBar(
                title: "Invite members to meetup plan",
                canBack: true,
              ),
            ),
            Expanded(
              child: Obx(() {
                if (_communityController.isManageMembersLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final members = _communityController.manageMembers;
                final isAllSelected =
                    _selectedIds.length == members.length && members.isNotEmpty;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 16.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          color: Theme.of(context).colorScheme.surfaceVariant,
                        ),
                        child: Text(
                          "Selected members will receive an invitation to join for the event",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14.sp,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      GestureDetector(
                        onTap: _toggleSelectAll,
                        child: Row(
                          children: [
                            _buildCheckbox(isAllSelected),
                            SizedBox(width: 12.w),
                            Text(
                              "Invited All",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                      const Divider(color: Colors.transparent),

                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: members.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Theme.of(context).dividerColor,
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final member = members[index];
                          final isSelected =
                              _selectedIds.contains(member.user.id);

                          return ListTile(
                            dense: true,
                            splashColor: Colors.transparent,
                            onTap: () => _toggleMember(member.user.id),
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 8.h),
                            leading: CircleAvatar(
                              radius: 24.r,
                              backgroundImage: NetworkImage(
                                AppCredentials.fixurl(member.user.avatar),
                              ),
                            ),
                            title: Text(
                              member.user.fullName,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color:
                                    Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              "Member",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                            trailing: _buildCheckbox(isSelected),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(bool isSelected) {
    return Container(
      width: 18.w,
      height: 18.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isSelected ? AppColors.primaryGradient : null,
        border: isSelected
            ? null
            : Border.all(color: Theme.of(context).dividerColor, width: 1.5),
      ),
      child: isSelected
          ? Icon(Icons.check, size: 14.sp, color: Colors.white)
          : null,
    );
  }
}
