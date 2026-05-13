import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vibe_now/controller/event_controller.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/event_participants.dart';
import 'package:vibe_now/services/local_storage.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/common/member_confirmation_dialog.dart';
import 'package:vibe_now/views/notification/widgets/animated_dialog_content.dart';

class EventMemberScreen extends StatefulWidget {
  final int eventId;

  const EventMemberScreen({super.key, required this.eventId});

  @override
  State<EventMemberScreen> createState() => _EventMemberScreenState();
}

class _EventMemberScreenState extends State<EventMemberScreen> {
  final EventController _eventController = Get.find<EventController>();
  String selectedStatus = "Participant";
  String? _currentUserId;
  bool _isEventCreator = false;
  List<ParticipantData> _joinedParticipants = [];
  List<ParticipantData> _requestedParticipants = [];
  bool _isLoading = true;

  // If user is NOT event creator, show all participants by default
  bool get _showAllParticipants => !_isEventCreator;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _currentUserId = await LocalStorage.user_id.get();

    // Fetch participants (get all at once without tab filter)
    await _eventController.getEventParticipants(eventId: widget.eventId);

    final creatorId = _eventController.eventCreator?.id;
    _isEventCreator = creatorId != null && creatorId == _currentUserId;

    // Get participants from controller
    _joinedParticipants = _eventController.joinedParticipants.toList();
    _requestedParticipants = _eventController.requestedParticipants.toList();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEventCreator ? "Manage Request" : "Participants";

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomAppBar(title: title),
            ),
            const SizedBox(height: 16),

            // Tabs - show tabs only if user is event creator
            if (!_isLoading && _isEventCreator)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildTabTrigger("Participant"),
                    const SizedBox(width: 12),
                    _buildTabTrigger("Requested"),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _showAllParticipants
                  ? _buildAllParticipantsList()
                  : (selectedStatus == "Participant"
                        ? _buildJoinedList()
                        : _buildRequestedList()),
            ),
          ],
        ),
      ),
    );
  }

  // For non-creator users: show all participants (both joined and requested)
  Widget _buildAllParticipantsList() {
    final allParticipants = [..._joinedParticipants, ..._requestedParticipants];

    if (allParticipants.isEmpty) {
      return Center(
        child: Text(
          'No participants yet',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: allParticipants.length,
      separatorBuilder: (context, index) => Divider(
        indent: 20,
        endIndent: 20,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(122),
      ),
      itemBuilder: (context, index) {
        final participant = allParticipants[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundImage: participant.user?.avatar != null
                ? NetworkImage(AppCredentials.fixurl(participant.user!.avatar))
                : null,
            child: participant.user?.avatar == null
                ? Text(
                    (participant.user?.fullName ?? 'U')
                        .substring(0, 1)
                        .toUpperCase(),
                  )
                : null,
          ),
          title: Text(
            participant.user?.fullName ?? 'Unknown',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(participant.user?.email ?? ''),
          trailing: _isEventCreator
              ? PopupMenuButton<String>(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  icon: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                  ),
                  onSelected: (value) {
                    // Handle accept/reject/remove based on status
                    if (participant.status == 'requested') {
                      showDialog(
                        context: context,
                        builder: (context) => MemberConfirmationDialog(
                          confirmBtnText: "Accept",
                          onCancel: () {
                            Navigator.pop(context);
                          },
                          onConfirm: () {
                            Navigator.pop(context);
                          },
                          title: "Accept ${participant.user?.fullName ?? 'user'}?",
                        ),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    if (participant.status == 'requested')
                      const PopupMenuItem(
                        value: 'accept',
                        child: Text(
                          'Accept',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: Text(
                        'Remove',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: participant.status == 'joined'
                        ? AppColors.primary.withAlpha(30)
                        : Colors.orange.withAlpha(30),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    participant.status ?? '',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: participant.status == 'joined'
                          ? AppColors.primary
                          : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
          onTap: () {},
        );
      },
    );
  }

  Widget _buildJoinedList() {
    if (_joinedParticipants.isEmpty) {
      return Center(
        child: Text(
          'No participants yet',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _joinedParticipants.length,
      separatorBuilder: (context, index) => Divider(
        indent: 20,
        endIndent: 20,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(122),
      ),
      itemBuilder: (context, index) {
        final participant = _joinedParticipants[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundImage: participant.user?.avatar != null
                ? NetworkImage(AppCredentials.fixurl(participant.user!.avatar))
                : null,
            child: participant.user?.avatar == null
                ? Text(
                    (participant.user?.fullName ?? 'U')
                        .substring(0, 1)
                        .toUpperCase(),
                  )
                : null,
          ),
          title: Text(
            participant.user?.fullName ?? 'Unknown',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(participant.user?.email ?? ''),
          onTap: () {},
          trailing: _isEventCreator
              ? PopupMenuButton<String>(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  icon: Icon(
                    Icons.more_vert,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                  ),
                  onSelected: (value) {
                    showDialog(
                      context: context,
                      builder: (context) => MemberConfirmationDialog(
                        confirmBtnText: "Remove",
                        onCancel: () {
                          Navigator.pop(context);
                        },
                        onConfirm: () {
                          Navigator.pop(context);
                        },
                        title: "Give a reason for removing the  member",
                      ),
                    );
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'remove',
                      child: Text(
                        'Remove Member',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }

  Widget _buildRequestedList() {
    if (_requestedParticipants.isEmpty) {
      return Center(
        child: Text(
          'No pending requests',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _requestedParticipants.length,
      separatorBuilder: (context, index) => Divider(
        indent: 20,
        endIndent: 20,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(122),
      ),
      itemBuilder: (context, index) {
        final participant = _requestedParticipants[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundImage: participant.user?.avatar != null
                ? NetworkImage(AppCredentials.fixurl(participant.user!.avatar))
                : null,
            child: participant.user?.avatar == null
                ? Text(
                    (participant.user?.fullName ?? 'U')
                        .substring(0, 1)
                        .toUpperCase(),
                  )
                : null,
          ),
          title: Text(
            participant.user?.fullName ?? 'Unknown',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(participant.user?.email ?? ''),
          trailing: _isEventCreator
              ? SizedBox(
                  width: 60.w,
                  child: Row(
              spacing: 8.w,
              children: [
                GestureDetector(
                  onTap: () {
                    _showActionDialog(
                      context,
                      'You have accepted ${participant.user?.fullName ?? 'user\'s'} event join request.',
                      true,
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
                    _showActionDialog(
                      context,
                      'You have rejected ${participant.user?.fullName ?? 'user\'s'} event join request.',
                      false,
                    );
                  },
                  child: Assets.icons.decline.svg(width: 22.w, height: 22.h),
                ),
              ],
            ),
          )
              : null,
        );
      },
    );
  }

  void _showActionDialog(BuildContext context, String content, bool accept) {
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
            child: AnimatedDialogContent(content: content, accept: accept),
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
