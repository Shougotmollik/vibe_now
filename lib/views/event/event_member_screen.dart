import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:vibe_now/controller/event_controller.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
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
  final selectedStatus = "Participant".obs;
  final isLoading = true.obs;
  final isFetchingTab = false.obs;
  final isEventCreator = false.obs;
  String? _currentUserId;

  // If user is NOT event creator, show all participants by default
  bool get _showAllParticipants => !isEventCreator.value;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _currentUserId = await LocalStorage.user_id.get();

    // Fetch participants based on tab
    await _loadParticipantsByTab(
      selectedStatus.value == "Participant" ? "joined" : "requested",
    );

    final creatorId = _eventController.eventCreator.value?.id;
    isEventCreator.value = creatorId != null && creatorId == _currentUserId;

    isLoading.value = false;
  }

  Future<void> _loadParticipantsByTab(String tab) async {
    isFetchingTab.value = true;
    await _eventController.getEventParticipants(
      eventId: widget.eventId,
      tab: tab,
    );
    isFetchingTab.value = false;
  }

  void _onTabChanged(String tab) {
    selectedStatus.value = tab;
  }

  Future<void> _refreshCurrentTab() async {
    final tab = selectedStatus.value == "Participant" ? "joined" : "requested";
    await _loadParticipantsByTab(tab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          final title = isEventCreator.value
              ? "Manage Request"
              : "Participants";

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomAppBar(title: title),
              ),
              const SizedBox(height: 16),

              // Tabs - show tabs only if user is event creator
              if (!isLoading.value && isEventCreator.value)
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
                child: Obx(() {
                  if (isLoading.value || isFetchingTab.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (_showAllParticipants) {
                    return _buildAllParticipantsList();
                  }
                  return selectedStatus.value == "Participant"
                      ? _buildJoinedList()
                      : _buildRequestedList();
                }),
              ),
            ],
          );
        }),
      ),
    );
  }

  // For non-creator users: show all participants (both joined and requested)
  Widget _buildAllParticipantsList() {
    final joined = _eventController.joinedParticipants;
    final requested = _eventController.requestedParticipants;
    final allParticipants = [...joined, ...requested];

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
          trailing: isEventCreator.value
              ? PopupMenuButton<String>(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  icon: Icon(
                    Icons.more_vert,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(150),
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
                          title:
                              "Accept ${participant.user?.fullName ?? 'user'}?",
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
                        ? AppColors.primary.withAlpha(50)
                        : Colors.orange.withAlpha(50),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    participant.status?.toUpperCase() ?? ''.toUpperCase(),
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
    final participants = _eventController.joinedParticipants;
    if (participants.isEmpty) {
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
      itemCount: participants.length,
      separatorBuilder: (context, index) => Divider(
        indent: 20,
        endIndent: 20,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(122),
      ),
      itemBuilder: (context, index) {
        final participant = participants[index];
        return Skeletonizer(
          enabled: _eventController.isLoading.value,
          child: ListTile(
            leading: CircleAvatar(
              radius: 28,
              backgroundImage: participant.user?.avatar != null
                  ? NetworkImage(
                      AppCredentials.fixurl(participant.user!.avatar),
                    )
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
            trailing: isEventCreator.value
                ? PopupMenuButton<String>(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    icon: Icon(
                      Icons.more_vert,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(150),
                    ),
                    onSelected: (value) {
                      showDialog(
                        context: context,
                        builder: (context) => MemberConfirmationDialog(
                          confirmBtnText: "Remove",
                          onCancel: () {
                            Navigator.pop(context);
                          },
                          onConfirm: () async {
                            // Navigator.pop(context);
                            final success = await _eventController
                                .removeParticipant(
                                  participantId: participant.participantId ?? 0,
                                );

                            if (success) {
                              AppSnackbar.show(
                                message:
                                    "you remove ${participant.user?.fullName} from the event",
                              );
                              Navigator.of(context).pop();
                              _refreshCurrentTab();
                            }
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
          ),
        );
      },
    );
  }

  Widget _buildRequestedList() {
    final participants = _eventController.requestedParticipants;

    if (_eventController.isLoading.value) {
      return Center(child: CircularProgressIndicator());
    }

    if (participants.isEmpty) {
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
      itemCount: participants.length,
      separatorBuilder: (context, index) => Divider(
        indent: 20,
        endIndent: 20,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(122),
      ),
      itemBuilder: (context, index) {
        final participant = participants[index];
        return Skeletonizer(
          enabled: _eventController.isLoading.value,
          child: ListTile(
            leading: CircleAvatar(
              radius: 28,
              backgroundImage: participant.user?.avatar != null
                  ? NetworkImage(
                      AppCredentials.fixurl(participant.user!.avatar),
                    )
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
            trailing: isEventCreator.value
                ? SizedBox(
                    width: 60.w,
                    child: Row(
                      spacing: 8.w,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final success = await _eventController
                                .eventMemberRequest(
                                  participantId: participant.participantId ?? 0,
                                  action: "approve",
                                );

                            if (success && mounted) {
                              _showActionDialog(
                                context,
                                'You have accepted ${participant.user?.fullName ?? 'user\'s'} event join request.',
                                true,
                              );
                              _refreshCurrentTab();
                            }
                          },
                          child: Assets.icons.accept.svg(
                            width: 20.w,
                            height: 20.h,
                            color: AppColors.primary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final success = await _eventController
                                .eventMemberRequest(
                                  participantId: participant.participantId ?? 0,
                                  action: "reject",
                                );
                            if (success && mounted) {
                              _showActionDialog(
                                context,
                                'You have rejected ${participant.user?.fullName ?? 'user\'s'} event join request.',
                                false,
                              );
                              _refreshCurrentTab();
                            }
                          },
                          child: Assets.icons.decline.svg(
                            width: 22.w,
                            height: 22.h,
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
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
    bool isActive = selectedStatus.value == label;
    return GestureDetector(
      onTap: () {
        _onTabChanged(label);
        _loadParticipantsByTab(label == "Participant" ? "joined" : "requested");
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
