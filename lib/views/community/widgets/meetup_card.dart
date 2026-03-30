import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/event.dart';
import 'package:vibe_now/views/common/meetup_join_dialog.dart';
import 'package:vibe_now/views/common/request_sent_dialog.dart';
import 'package:vibe_now/views/community/meetup_details_screen.dart';
import 'package:vibe_now/views/event/event_details_screen.dart';
import 'package:vibe_now/views/event/widgets/event_animated_dialog.dart';
import 'package:vibe_now/views/notification/widgets/animated_dialog_content.dart';

class MeetupCard extends StatefulWidget {
  const MeetupCard({super.key, required this.event});

  @override
  State<MeetupCard> createState() => _MeetupCardState();

  final Event event;
}

class _MeetupCardState extends State<MeetupCard> {
  late EventStatus? currentStatus;

  bool get isJoined => currentStatus == EventStatus.going;
  bool get isPending => currentStatus == EventStatus.requested;
  bool get cannotJoin => isJoined || isPending;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.event.userStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.h),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
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
                  widget.event.image,
                  height: 200.h,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),

              // GestureDetector(
              //   onTap: () {
              //     setState(() {
              //       widget.event.isFavorite = !widget.event.isFavorite;
              //     });
              //   },
              //   child: Padding(
              //     padding: const EdgeInsets.all(8.0),
              //     child: Container(
              //       decoration: BoxDecoration(
              //         shape: BoxShape.circle,
              //         color: AppColors.primary.withAlpha(200),
              //       ),
              //       padding: const EdgeInsets.all(10),
              //       child: SvgPicture.asset(
              //         widget.event.isFavorite ? wishlistFilled : wishlist,
              //         height: 18.h,
              //         width: 18.w,
              //         color: AppColors.background,
              //       ),
              //     ),
              //   ),
              // ),

              // Positioned(
              //   top: 10.h,
              //   left: 12.w,
              //   child: Container(
              //     padding: const EdgeInsets.all(8),
              //     decoration: BoxDecoration(
              //       color: AppColors.primary.withAlpha(200),
              //       borderRadius: BorderRadius.circular(8.r),
              //     ),
              //     child: Row(
              //       mainAxisSize: MainAxisSize.min,
              //       crossAxisAlignment: CrossAxisAlignment.center,
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       spacing: 4.w,
              //       children: [
              //         SvgPicture.asset(
              //           isPublic ? public : private,
              //           height: 14.h,
              //           width: 14.w,
              //           color: AppColors.background,
              //         ),
              //         Text(
              //           isPublic ? "Public" : "Private",
              //           style: TextStyle(
              //             color: AppColors.background,
              //             fontSize: 12.sp,
              //             fontWeight: FontWeight.w500,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            widget.event.name,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Assets.icons.location.svg(),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  widget.event.location,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Assets.icons.calender3.svg(),
              SizedBox(width: 4.w),
              Text(
                '${widget.event.time}, ${widget.event.date}',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Text(
                widget.event.description,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          PrimaryButton.text(
            onPressed: isJoined
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MeetupDetailsScreen(),
                      ),
                    );
                  }
                : () {
                    showDialog(
                      context: context,
                      builder: (context) => MeetupSentDialog(
                        onWithDrawTap: () {
                          setState(
                            () => currentStatus = EventStatus.interested,
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ).then((_) {
                      setState(() {
                        currentStatus = EventStatus.going;
                      });
                    });
                  },
            text: isJoined ? "View Details" : "Join",
            gradient: AppColors.primaryGradientRotated,
            radius: 12.r,
          ),
          // Row(
          //   children: [
          //     Assets.icons.users.svg(),
          //     SizedBox(width: 4.w),
          //     Text(
          //       '${widget.event.attending}/${widget.event.totalAttending} attending',
          //       style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
          //     ),
          //   ],
          // ),
          // SizedBox(height: 12),
          // // Event Button section
          // widget.event.isMyEvent
          //     ? PrimaryButton.text(
          //         radius: 12.r,
          //         onPressed: () {
          //           context.pushNamed(
          //             RouteNames.eventDetailsScreen,
          //             extra: widget.event,
          //           );
          //         },
          //         text: "View Details",
          //         gradient: AppColors.primaryGradientRotated,
          //       )
          //     : Row(
          //         children: [
          //           Expanded(
          //             child: GestureDetector(
          //               onTap: () {
          //                 // PUBLIC EVENT FLOW
          //                 if (isPublic && !isGoing) {
          //                   setState(() {
          //                     currentStatus = EventStatus.going;
          //                   });

          //                   // showDialog(
          //                   //   context: context,
          //                   //   barrierDismissible: true,
          //                   //   builder: (_) => Dialog(
          //                   //     backgroundColor: Colors.transparent,
          //                   //     child: EventAnimatedDialog(
          //                   //       content:
          //                   //           'You have joined the event successfully. See you there!',
          //                   //     ),
          //                   //   ),
          //                   // );

          //                   showDialog(
          //                     context: context,
          //                     builder: (context) => RequestSentDialog(
          //                       onWithDrawTap: () {
          //                         setState(() {
          //                           currentStatus = EventStatus.interested;
          //                         });
          //                         Navigator.pop(context);
          //                       },
          //                     ),
          //                   );

          //                   return;
          //                 }

          //                 // PRIVATE EVENT FLOW
          //                 if (isPrivate && !isRequested) {
          //                   setState(() {
          //                     currentStatus = EventStatus.requested;
          //                   });

          //                   showDialog(
          //                     context: context,
          //                     builder: (context) => RequestSentDialog(
          //                       onWithDrawTap: () {
          //                         setState(() {
          //                           currentStatus = EventStatus.interested;
          //                         });
          //                         Navigator.pop(context);
          //                       },
          //                     ),
          //                   );
          //                 }
          //               },

          //               child: Container(
          //                 padding: EdgeInsets.all(12.w),
          //                 decoration: BoxDecoration(
          //                   borderRadius: BorderRadius.circular(12.r),
          //                   border: Border.all(color: Colors.grey.shade300),
          //                   gradient: !isActive
          //                       ? AppColors.primaryGradientRotated
          //                       : null,
          //                   color: !isActive ? null : const Color(0xffC4A8FF),
          //                 ),

          //                 child: Center(
          //                   child: Row(
          //                     mainAxisSize: MainAxisSize.min,
          //                     mainAxisAlignment: MainAxisAlignment.center,
          //                     crossAxisAlignment: CrossAxisAlignment.center,
          //                     spacing: 8.w,
          //                     children: [
          //                       isPrivate
          //                           ? SvgPicture.asset(
          //                               isActive ? hourglass : "",
          //                               height: isActive ? 16.h : 0.h,
          //                               width: isActive ? 16.w : 0.w,
          //                               color: AppColors.background,
          //                             )
          //                           : SizedBox(),

          //                       // : SvgPicture.asset(
          //                       //     "",
          //                       //     height: 16.h,
          //                       //     width: 16.w,
          //                       //     color: AppColors.background,
          //                       //   ),
          //                       Text(
          //                         buttonText,
          //                         style: TextStyle(
          //                           color: !isActive
          //                               ? Colors.white
          //                               : Colors.grey.shade100,
          //                           fontSize: 16.sp,
          //                           fontWeight: FontWeight.w600,
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               ),
          //             ),
          //           ),
          //         ],
          //       ),
        ],
      ),
    );
  }
}
