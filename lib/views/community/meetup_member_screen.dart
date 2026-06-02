import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vibe_now/controller/meetup_controller.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/model/meetup.dart';
import 'package:vibe_now/utils.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';

class MeetupMemberScreen extends StatefulWidget {
  const MeetupMemberScreen({super.key, required this.meetupId});

  final String meetupId;

  @override
  State<MeetupMemberScreen> createState() => _MeetupMemberScreenState();
}

class _MeetupMemberScreenState extends State<MeetupMemberScreen> {
  final MeetupController _controller = Get.find<MeetupController>();

  final List<_TabConfig> _tabs = const [
    _TabConfig(label: 'Participants', apiTab: 'joined'),
    _TabConfig(label: 'Invited', apiTab: 'invited'),
  ];

  String _selectedTab = 'joined';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchMembers());
  }

  void _fetchMembers() {
    _controller.getMeetupMembers(meetupId: widget.meetupId, tab: _selectedTab);
  }

  String get _emptyMessage {
    switch (_selectedTab) {
      case 'joined':
        return 'No participants yet';
      case 'invited':
        return 'No invited members yet';
      default:
        return 'No members found';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomAppBar(title: "Meetup Members"),
            ),
            const SizedBox(height: 16),
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
                if (_controller.isMeetupMembersLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final members = _controller.meetupMembers;
                if (members.isEmpty) {
                  return Center(
                    child: Text(
                      _emptyMessage,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: members.length,
                  separatorBuilder: (context, index) => Divider(
                    indent: 20,
                    endIndent: 20,
                    color: Theme.of(context).dividerColor,
                  ),
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final hasAvatar =
                        member.avatar != null && member.avatar!.isNotEmpty;
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundImage: hasAvatar
                            ? NetworkImage(
                                AppCredentials.fixurl(member.avatar!),
                              )
                            : null,
                        child: !hasAvatar
                            ? const Icon(Icons.person, size: 28)
                            : null,
                      ),
                      title: Text(
                        member.fullName ?? 'Unknown',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        _selectedTab == 'joined' && member.joinedAt != null
                            ? 'Joined ${timeAgo(DateTime.parse(member.joinedAt!))}'
                            : _selectedTab == 'invited' &&
                                  member.joinedAt != null
                            ? 'Invited ${timeAgo(DateTime.parse(member.joinedAt!))}'
                            : '',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabTrigger(_TabConfig tab) {
    bool isActive = _selectedTab == tab.apiTab;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedTab = tab.apiTab);
        _fetchMembers();
      },
      child: Container(
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
          tab.label,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _TabConfig {
  final String label;
  final String apiTab;

  const _TabConfig({required this.label, required this.apiTab});
}
