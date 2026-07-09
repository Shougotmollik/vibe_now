import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vibe_now/controller/meetup_controller.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/model/meetup.dart';
import 'package:vibe_now/views/common/avatar_stack.dart';
import 'package:vibe_now/views/community/meetup_member_screen.dart';

class MeetupDetailsScreen extends StatefulWidget {
  const MeetupDetailsScreen({super.key, required this.meetupId});

  final String meetupId;

  @override
  State<MeetupDetailsScreen> createState() => _MeetupDetailsScreenState();
}

class _MeetupDetailsScreenState extends State<MeetupDetailsScreen> {
  final MeetupController _meetupController = Get.find<MeetupController>();

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
      _meetupController.getMeetupDetails(meetupId: widget.meetupId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: Obx(() {
        final meetup = _meetupController.meetupDetails.value;

        if (meetup == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 400.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      meetup.coverImage != null
                          ? AppCredentials.fixurl(meetup.coverImage!)
                          : "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 40.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).maybePop(),
                            child: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meetup.title ?? '',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 16.h),
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
                                fontWeight: FontWeight.w400,
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
                            '${meetup.meetupTime ?? ''}, ${meetup.meetupDate ?? ''}',
                            style: TextStyle(
                               fontSize: 12.sp,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Assets.icons.community.svg(
                            width: 16.w,
                            height: 16.h,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${meetup.joinedCount ?? 0}/${meetup.maxAttendees ?? 0} ${loc.translate('attending')}',
                            style: TextStyle(
                               fontSize: 12.sp,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      if (meetup.participants != null && meetup.participants!.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Expanded(
                              child: AvatarStack(
                                imageUrls: meetup.participants!
                                    .map((p) => p.avatar != null
                                        ? AppCredentials.fixurl(p.avatar!)
                                        : '')
                                    .where((url) => url.isNotEmpty)
                                    .toList(),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                     builder: (context) => MeetupMemberScreen(meetupId: widget.meetupId),
                                  ),
                                );
                              },
                              child: Text(loc.translate('viewAll')),
                            ),
                          ],
                        ),
                      ],
                      SizedBox(height: 20.h),
                      Text(
                        loc.translate('description'),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        meetup.description ?? '',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                           fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
