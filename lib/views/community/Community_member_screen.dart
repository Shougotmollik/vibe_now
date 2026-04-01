import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/community/community_manage_member_screen.dart';
import 'package:vibe_now/views/notification/widgets/animated_dialog_content.dart';

class CommunityMemberScreen extends StatefulWidget {
  const CommunityMemberScreen({super.key});

  @override
  State<CommunityMemberScreen> createState() => _CommunityMemberScreenState();
}

class _CommunityMemberScreenState extends State<CommunityMemberScreen> {
  String selectedStatus = "Active";

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomAppBar(title: "Manage Request"),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommunityManageMemberScreen(),
                        ),
                      );
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
                        "Manage",
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
                children: [
                  _buildTabTrigger("Active"),
                  const SizedBox(width: 12),
                  _buildTabTrigger("Requested"),
                  const SizedBox(width: 12),
                  // _buildTabTrigger("Awaiting Meetup"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: selectedStatus == "Active"
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
          trailing: SizedBox(
            width: 60.w,
            child: Row(
              spacing: 8.w,
              children: [
                GestureDetector(
                  onTap: () {
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
                            backgroundColor: Colors.transparent,
                            child: AnimatedDialogContent(
                              content:
                                  'You have accepted jenny smith\'s community join request.',
                              accept: true,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Assets.icons.accept.svg(
                    width: 20.w,
                    height: 20.h,
                    color: AppColors.primary,
                  ),
                ),
                GestureDetector(
                  onTap: () {
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
                            backgroundColor: Colors.transparent,
                            child: AnimatedDialogContent(
                              content:
                                  'You have rejected jenny smith\'s community join request.',
                              accept: false,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Assets.icons.decline.svg(
                    width: 22.w,
                    height: 22.h,
                    // color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabTrigger(String label) {
    bool isActive = selectedStatus == label;
    return GestureDetector(
      onTap: () => setState(() => selectedStatus = label),
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
