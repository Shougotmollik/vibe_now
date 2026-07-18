import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:vibe_now/controller/community_controller.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/model/community_member.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/views/common/custom_time_picker.dart';
import 'package:vibe_now/views/community/community_awaiting_qrscreen.dart';
import 'package:vibe_now/views/notification/widgets/animated_dialog_content.dart';

class CommunityManageMemberScreen extends StatefulWidget {
  const CommunityManageMemberScreen({super.key, required this.communityId});
  final int communityId;

  @override
  State<CommunityManageMemberScreen> createState() =>
      _CommunityManageMemberScreenState();
}

class _CommunityManageMemberScreenState
    extends State<CommunityManageMemberScreen> {
  final CommunityController _controller = Get.find<CommunityController>();
  String _tab = 'pending';
  bool isApproved = false;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool _hasSelectedDateTime = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchMembers());
  }

  void _fetchMembers({bool showLoading = true}) {
    _controller.manageCommunityMembers(
      id: widget.communityId,
      tab: _tab,
      showLoading: showLoading,
    );
  }

  Future<void> _selectDateTime(loc) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      helpText: 'SELECT MEETUP DATE',
      cancelText: loc.translate('cancel').toUpperCase(),
      confirmText: loc.translate('confirm').toUpperCase(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        _hasSelectedDateTime = true;
      });
      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => CustomTimePicker(
          onTimeSelected: (time) {
            setState(() {
              selectedTime = time;
              _hasSelectedDateTime = true;
            });
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.translate('manageRequest'),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildToggleTabs(loc),
          SizedBox(height: 20.h),
          Expanded(
            child: Obx(() {
              if (_controller.isManageMembersLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final members = _controller.manageMembers;
              final member = members.isNotEmpty ? members.first : null;

              if (members.isEmpty) {
                return _buildEmptyState(loc);
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    if (_tab == 'pending')
                      isApproved
                          ? _buildApprovedView(member, loc)
                          : _buildPendingView(member)
                    else
                      _buildAwaitingList(members, loc),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingView(dynamic member) {
    final loc = AppLocalizations.of(context);
    final title = member?.communityTitle ?? 'Community';
    final address = member?.communityAddress ?? 'Location not set';
    final description =
        member?.communityDescription ?? 'No description available';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileHeader(member),
        const SizedBox(height: 20),
        _buildInfoCard(
          children: [
            _buildIconTextRow(Assets.icons.community, title),
            const SizedBox(height: 12),
            _buildIconTextRow(Assets.icons.location, address),
          ],
        ),
        const SizedBox(height: 30),
        PrimaryButton.text(
          onPressed: () => setState(() => isApproved = true),
          text: loc.translate('approve'),
        ),
        const SizedBox(height: 30),
        Text(
          loc.translate('aboutCommunity'),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          description,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildApprovedView(dynamic member, loc) {
    final name = member?.user.fullName ?? '';
    final address = member?.communityAddress ?? ' address not found';

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
        Text(
          '$name is ready for Meetup! Please confirm the schedule.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  address,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        _buildInfoCard(
          children: [
            GestureDetector(
              onTap: () => _selectDateTime(loc),
              child: _buildIconTextRow(
                Assets.icons.calendarColor,
                _hasSelectedDateTime
                    ? DateFormat("EEE,MMM d , yyyy 'at' hh:mm a").format(
                        DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        ),
                      )
                    : loc.translate('selectDateAndTimeFirst'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        PrimaryButton.text(
          onPressed: () async {
            if (!_hasSelectedDateTime) {
              AppSnackbar.show(message: loc.translate('selectDateAndTimeFirst'));
              return;
            }
            final scheduledAt = DateFormat("EEE,MMM d , yyyy 'at' hh:mm a").format(
              DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime.hour,
                selectedTime.minute,
              ),
            );
            final success = await _controller.communitySchedule(
              memberId: member.memberId,
              scheduleAt: scheduledAt,
            );
            if (!context.mounted) return;
            if (success) {
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
                        content: 'You have scheduled a meetup with $name.',
                        accept: true,
                      ),
                    ),
                  );
                },
              );
              if (!context.mounted) return;
              Navigator.pop(context);
            }
          },
          text: loc.translate('scheduleMeetup'),
        ),
        const SizedBox(height: 40),
        _buildBulletPoint(
          loc.translate('scheduleMeetupConfirm').replaceAll('{name}', name),
        ),
        const SizedBox(height: 15),
        _buildBulletPoint(loc.translate('scheduleQRDesc')),
        const SizedBox(height: 40),
        _buildCancelButton(loc),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations loc) {
    final titleKey = _tab == 'pending' ? 'noPendingRequestsTitle' : 'noAwaitingMembersTitle';
    final descKey = _tab == 'pending' ? 'noPendingRequestsDesc' : 'noAwaitingMembersDesc';

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

  Widget _buildToggleTabs(loc) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.w,
        children: [
          GestureDetector(
            onTap: () {
              if (_tab == 'pending') return;
              setState(() {
                _tab = 'pending';
                isApproved = false;
              });
              _fetchMembers();
            },
            child: _buildStatusTab(loc.translate('pending'), _tab == 'pending'),
          ),
          GestureDetector(
            onTap: () {
              if (_tab == 'awaiting') return;
              setState(() {
                _tab = 'awaiting';
                isApproved = false;
              });
              _fetchMembers();
            },
            child: _buildStatusTab(loc.translate('awaitingMeetup'), _tab == 'awaiting'),
          ),
        ],
      ),
    );
  }

  Widget _buildAwaitingList(List<CommunityMember> members, loc) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: members.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final member = members[index];
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(
                  AppCredentials.fixurl(member.user.avatar),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.user.fullName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      loc.translate('awaitingApproval'),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommunityAwaitingQrScreen(
                        memberName: member.user.fullName,
                        memberAvatar: member.user.avatar,
                        scheduledAt: member.scheduledAt,
                        qrCodeValue: member.qrCodeValue,
                        qrCodeImage: member.qrCodeImage,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    loc.translate('viewQR'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton(loc) {
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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextButton(
          onPressed: () => setState(() => isApproved = false),
          child: Text(
            loc.translate('cancelMeetup'),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic member) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: member != null
              ? NetworkImage(AppCredentials.fixurl(member.user.avatar))
              : null,
          backgroundColor: Colors.grey,
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              member?.user.fullName ?? 'No name',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              member?.requestedAt != null
                  ? timeago.format(DateTime.parse(member!.requestedAt!))
                  : '',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconTextRow(SvgGenImage icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        icon.svg(
          height: 20.h,
          width: 20.h,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
