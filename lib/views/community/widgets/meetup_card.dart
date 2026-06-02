import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vibe_now/controller/meetup_controller.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/meetup.dart';
import 'package:vibe_now/services/local_storage.dart';
import 'package:vibe_now/views/common/meetup_join_dialog.dart';
import 'package:vibe_now/views/community/meetup_details_screen.dart';

class MeetupCard extends StatefulWidget {
  const MeetupCard({super.key, required this.meetup});

  @override
  State<MeetupCard> createState() => _MeetupCardState();

  final Meetup meetup;
}

class _MeetupCardState extends State<MeetupCard> {
  final MeetupController _meetupController = Get.find<MeetupController>();
  String? _currentUserId;
  bool _isLoadingJoin = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    final userId = await LocalStorage.user_id.get();
    if (mounted) {
      setState(() {
        _currentUserId = userId;
      });
    }
  }

  bool get isMyMeetup =>
      widget.meetup.createdBy?.id != null &&
      _currentUserId != null &&
      widget.meetup.createdBy!.id == _currentUserId;

  Future<void> _joinMeetup() async {
    if (_isLoadingJoin) return;

    setState(() => _isLoadingJoin = true);

    final success = await _meetupController.joinMeetup(
      meetupId: '${widget.meetup.id}',
    );

    if (success && mounted) {
      widget.meetup.isJoined = true;
      setState(() => _isLoadingJoin = false);
      showDialog(
        context: context,
        builder: (context) => MeetupSentDialog(
          onWithDrawTap: () => Navigator.pop(context),
        ),
      );
    } else {
      setState(() => _isLoadingJoin = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final meetup = widget.meetup;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.h),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  meetup.coverImage != null
                      ? AppCredentials.fixurl(meetup.coverImage!)
                      : '',
                  height: 200.h,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200.h,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Center(child: Icon(Icons.image, size: 48)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            meetup.title ?? '',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Assets.icons.location.svg(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  meetup.address ?? '',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Assets.icons.calender3.svg(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: 4.w),
              Text(
                '${meetup.meetupDate ?? ''}, ${meetup.meetupTime ?? ''}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          PrimaryButton.text(
            onPressed: () {
              if (isMyMeetup || meetup.isJoined == true) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MeetupDetailsScreen(meetupId: '${meetup.id}'),
                  ),
                );
              } else {
                _joinMeetup();
              }
            },
            isLoading: _isLoadingJoin,
            isEnabled: !_isLoadingJoin,
            text: (isMyMeetup || meetup.isJoined == true)
                ? "View Details"
                : "Join",
            gradient: AppColors.primaryGradientRotated,
            radius: 12.r,
          ),
        ],
      ),
    );
  }
}
