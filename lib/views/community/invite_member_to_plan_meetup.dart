import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/community/widgets/invitation_success_dialog.dart';

class MemberModel {
  final String id;
  final String name;
  final String role;
  final String image;

  MemberModel({
    required this.id,
    required this.name,
    required this.role,
    required this.image,
  });
}

class InviteMemberToPlanMeetup extends StatefulWidget {
  const InviteMemberToPlanMeetup({super.key});

  @override
  State<InviteMemberToPlanMeetup> createState() =>
      _InviteMemberToPlanMeetupState();
}

class _InviteMemberToPlanMeetupState extends State<InviteMemberToPlanMeetup> {
  //  Mock Data
  final List<MemberModel> _members = [
    MemberModel(
      id: '1',
      name: 'Jenny Smith',
      role: 'Member',
      image: 'https://i.pravatar.cc/150?u=1',
    ),
    MemberModel(
      id: '2',
      name: 'Lisa Smith',
      role: 'Member',
      image: 'https://i.pravatar.cc/150?u=2',
    ),
    MemberModel(
      id: '3',
      name: 'Luisa Smith',
      role: 'Member',
      image: 'https://i.pravatar.cc/150?u=3',
    ),
    MemberModel(
      id: '4',
      name: 'jeff Smith',
      role: 'Member',
      image: 'https://i.pravatar.cc/150?u=4',
    ),
    MemberModel(
      id: '5',
      name: 'kate Smith',
      role: 'Member',
      image: 'https://i.pravatar.cc/150?u=5',
    ),
  ];

  final Set<String> _selectedIds = {};

  void _toggleSelectAll() {
    setState(() {
      if (_selectedIds.length == _members.length) {
        _selectedIds.clear();
      } else {
        _selectedIds.addAll(_members.map((m) => m.id));
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

  @override
  Widget build(BuildContext context) {
    bool isAllSelected = _selectedIds.length == _members.length;

    return Scaffold(
      backgroundColor: Colors.white,

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: PrimaryButton.text(
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => const InviteSuccessDialog(),
              );
              if (mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
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
              child: SingleChildScrollView(
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
                        color: const Color(0xffF3F3F5),
                      ),
                      child: Text(
                        "Selected members will receive an invitation to join for the event",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14.sp,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Invited All Toggle
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
                              color: AppColors.primaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    const Divider(color: Color(0xffEEEEEE)),
                    // Member List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _members.length,
                      separatorBuilder: (context, index) =>
                          const Divider(color: Color(0xffEEEEEE), height: 1),
                      itemBuilder: (context, index) {
                        final member = _members[index];
                        final isSelected = _selectedIds.contains(member.id);

                        return ListTile(
                          dense: true,
                          splashColor: Colors.transparent,
                          onTap: () => _toggleMember(member.id),
                          contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                          leading: CircleAvatar(
                            radius: 24.r,
                            backgroundImage: NetworkImage(member.image),
                          ),
                          title: Text(
                            member.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            member.role,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey,
                            ),
                          ),
                          trailing: _buildCheckbox(isSelected),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom Circular Checkbox Widget
  Widget _buildCheckbox(bool isSelected) {
    return Container(
      width: 18.w,
      height: 18.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isSelected ? AppColors.primaryGradient : null,
        border: isSelected
            ? null
            : Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: isSelected
          ? Icon(Icons.check, size: 14.sp, color: Colors.white)
          : null,
    );
  }
}
