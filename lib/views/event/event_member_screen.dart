import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';

class EventMembersScreen extends StatefulWidget {
  const EventMembersScreen({super.key});

  @override
  State<EventMembersScreen> createState() => _EventMembersScreenState();
}

class _EventMembersScreenState extends State<EventMembersScreen> {
  int selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: CustomAppBar(title: "Members", canBack: true),
            ),
            SizedBox(height: 12.h),
            _buildTabs(),
            Expanded(
              child: IndexedStack(
                index: selectedIndex,
                children: [_buildActiveList(), _buildInvitedList()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          _tabButton(label: "Active members", index: 0),
          SizedBox(width: 10.w),
          _tabButton(label: "Invited members", index: 1),
        ],
      ),
    );
  }

  Widget _tabButton({required String label, required int index}) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(20.r),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveList() {
    return ListView(
      children: const [
        MemberTile(name: "Jenny smith", status: "Accepted"),
        MemberTile(name: "Jenny smith", status: "Accepted"),
      ],
    );
  }

  Widget _buildInvitedList() {
    return ListView(
      children: const [
        MemberTile(name: "Jenny smith", status: "Invited"),
        MemberTile(name: "Jenny smith", status: "Rejected"),
        MemberTile(name: "Jenny smith", status: "Accepted"),
        MemberTile(name: "Jenny smith", status: "Rejected"),
      ],
    );
  }
}

class MemberTile extends StatelessWidget {
  final String name;
  final String status;

  const MemberTile({super.key, required this.name, required this.status});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: const CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage('https://i.pravatar.cc/300?img=10'),
          ),
          title: Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: AppColors.primaryText,
            ),
          ),
          subtitle: Text(
            "Open for small talk",
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: _buildStatusLabel(status),
        ),
        const Divider(
          indent: 16,
          endIndent: 16,
          height: 1,
          color: Color(0xff_EAEAEA),
        ),
      ],
    );
  }

  Widget _buildStatusLabel(String status) {
    if (status == "Invited") {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status,
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      );
    }

    Color textColor = status == "Rejected" ? Colors.red : Colors.lightBlue;
    return Text(
      status,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w500,
        fontSize: 12.sp,
      ),
    );
  }
}
