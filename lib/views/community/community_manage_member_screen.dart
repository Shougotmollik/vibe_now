import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/tokens.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/views/community/community_awaiting_qrscreen.dart';
import 'package:vibe_now/views/notification/widgets/animated_dialog_content.dart';

class CommunityManageMemberScreen extends StatefulWidget {
  const CommunityManageMemberScreen({super.key});

  @override
  State<CommunityManageMemberScreen> createState() =>
      _CommunityManageMemberScreenState();
}

class _CommunityManageMemberScreenState
    extends State<CommunityManageMemberScreen> {
  bool isApproved = false;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      helpText: 'SELECT MEETUP DATE',
      cancelText: 'CANCEL',
      confirmText: 'CONFIRM',
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: selectedTime,
        helpText: 'SELECT MEETUP TIME',
        cancelText: 'CANCEL',
        confirmText: 'CONFIRM',
      );

      if (pickedTime != null) {
        setState(() {
          selectedDate = pickedDate;
          selectedTime = pickedTime;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Manage Request',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildToggleTabs(),
            const SizedBox(height: 40),
            isApproved ? _buildApprovedView() : _buildPendingView(),
          ],
        ),
      ),
    );
  }

  // --- Views ---

  Widget _buildPendingView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileHeader(),
        const SizedBox(height: 20),
        _buildInfoCard(
          children: [
            _buildIconTextRow(Assets.icons.location, "New york, USA"),
            const SizedBox(height: 12),
            _buildIconTextRow(
              Assets.icons.location,
              "Music. Fitness Rock Concert",
            ),
          ],
        ),
        const SizedBox(height: 30),
        PrimaryButton.text(
          onPressed: () => setState(() => isApproved = true),
          text: "Approve for Meetup",
        ),
        const SizedBox(height: 30),
        const Text(
          'About Community',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 15),
        const Text(
          'tincidunt dolor in ex quam amet, varius non adipiscing dolor ipsum hendrerit cursus...',
          style: TextStyle(color: Colors.grey, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildApprovedView() {
    return Column(
      children: [
        Container(
          height: 80.w,
          width: 80.w,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 45),
        ),
        const SizedBox(height: 20),
        const Text(
          'Jhon has been approved!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
            SizedBox(width: 4),
            Text(
              'Central Park Cafe',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 25),
        _buildInfoCard(
          children: [
            GestureDetector(
              onTap: _selectDateTime,
              child: _buildIconTextRow(
                Assets.icons.calendarColor,
                "${DateFormat('EEE, MMM d').format(selectedDate)} at ${selectedTime.format(context)}",
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        PrimaryButton.text(
          onPressed: () async {
            await showDialog(
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
                      content: 'You have scheduled a meetup with Jhon.',
                      accept: false,
                    ),
                  ),
                );
              },
            );
            Navigator.pop(context);
          },
          text: "Schedule Meetup",
        ),
        const SizedBox(height: 40),
        _buildBulletPoint(
          "Schedule a meetup to verify Jhon before he can join.",
        ),
        const SizedBox(height: 15),
        _buildBulletPoint(
          "They need to scan your QR code to join the community.",
        ),
        const SizedBox(height: 40),
        _buildCancelButton(),
      ],
    );
  }

  Widget _buildToggleTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.w,
        children: [
          _buildStatusTab("Pending", true),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommunityAwaitingQrScreen(),
                ),
              );
            },
            child: _buildStatusTab("Awaiting Meetup", false),
          ),
        ],
      ),
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

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          height: 12,
          width: 12,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Color(0xFF4F4F4F), fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: AppColors.primaryGradient,
      ),
      child: Container(
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextButton(
          onPressed: () => setState(() => isApproved = false),
          child: const Text(
            "Cancel Request",
            style: TextStyle(color: Colors.black87, fontSize: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        const CircleAvatar(radius: 30, backgroundColor: Colors.grey),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Jhon Gomes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text('Music • New york, USA', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildIconTextRow(SvgGenImage icon, String text) {
    return Row(
      children: [
        icon.svg(height: 20.h, width: 20.h),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 16)),
      ],
    );
  }
}
