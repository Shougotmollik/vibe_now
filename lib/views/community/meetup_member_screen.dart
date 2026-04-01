import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/community/community_awaiting_qrscreen.dart';

class MeetupMemberScreen extends StatefulWidget {
  const MeetupMemberScreen({super.key});

  @override
  State<MeetupMemberScreen> createState() => _MeetupMemberScreenState();
}

class _MeetupMemberScreenState extends State<MeetupMemberScreen> {
  String selectedStatus = "Participants";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomAppBar(title: "Meetup Members"),
            ),
            const SizedBox(height: 16),

            // Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildTabTrigger("Participants"),
                  const SizedBox(width: 12),
                  _buildTabTrigger("Invited"),
                  // const SizedBox(width: 12),
                  // _buildTabTrigger("Awaiting Meetup"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: selectedStatus == "Participants"
                  ? _buildActiveList()
                  : _buildPendingList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveList() {
    return ListView.separated(
      itemCount: 5,
      separatorBuilder: (context, index) =>
          const Divider(indent: 20, endIndent: 20),
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=a"),
          ),
          title: const Text(
            "Jenny smith",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: const Text("Open for small talk"),
          onTap: () {},
        );
      },
    );
  }

  Widget _buildPendingList() {
    return ListView.separated(
      itemCount: 3,
      separatorBuilder: (context, index) =>
          const Divider(indent: 20, endIndent: 20),
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=p"),
          ),
          title: const Text(
            "Jenny smith",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: const Text("Open for small talk"),
          trailing: Text(
            "Pending",
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
              fontSize: 12.sp,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabTrigger(String label) {
    bool isActive = selectedStatus == label;
    return GestureDetector(
      onTap: () {
        setState(() => selectedStatus = label);

        if (label == "Awaiting Meetup") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CommunityAwaitingQrScreen(),
            ),
          );
        }
      },
      child: _buildStatusTab(label, isActive),
    );
  }

  Widget _buildStatusTab(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: isActive ? AppColors.primaryGradient : null,
        border: isActive ? null : Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
