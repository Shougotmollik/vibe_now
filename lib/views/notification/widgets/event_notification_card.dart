// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:go_router/go_router.dart';
// import 'package:vibe_now/core/routes/route_names.dart';
// import 'package:vibe_now/design_system/tokens/colors.dart';
// import 'package:vibe_now/gen/assets.gen.dart';
// import 'package:vibe_now/model/community_notification.dart';
// import 'package:vibe_now/views/notification/widgets/animated_dialog_content.dart';

// class EventNotificationCard extends StatefulWidget {
//   final NotificationModel notification;

//   const EventNotificationCard({super.key, required this.notification});

//   @override
//   State<EventNotificationCard> createState() => _EventNotificationCardState();
// }

// class _EventNotificationCardState extends State<EventNotificationCard> {
//   bool _isTapped = false;

//   void _handleTap() {
//     setState(() {
//       _isTapped = true;
//     });

//     Future.delayed(const Duration(milliseconds: 200), () {
//       setState(() {
//         _isTapped = false;
//       });

//       context.pushNamed(RouteNames.eventScreen);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: _handleTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
//         decoration: BoxDecoration(
//           border: Border(
//             bottom: BorderSide(color: const Color(0xffEAEAEA), width: 1.w),
//           ),
//           gradient: _isTapped
//               ? LinearGradient(
//                   colors: [
//                     const Color(0xff8663F6).withValues(alpha: 0.15),
//                     const Color(0xffC470F5).withValues(alpha: 0.15),
//                     const Color(0xff57C2FF).withValues(alpha: 0.15),
//                   ],
//                   stops: [0.16, 0.54, 0.92],
//                   transform: GradientRotation(pi - 0.7),
//                 )
//               : null,
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(50.r),
//               child: Image.network(
//                 widget.notification.userImage,
//                 width: 48.w,
//                 height: 48.w,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) {
//                   return Container(
//                     width: 48.w,
//                     height: 48.w,
//                     color: Colors.grey[300],
//                     child: Icon(Icons.person, color: Colors.grey[600]),
//                   );
//                 },
//               ),
//             ),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   _buildNameSection(),
//                   SizedBox(height: 8.h),
//                   _buildDistanceRow(),
//                   if (widget.notification.type == NotificationType.event)
//                     ..._buildEventDetails(),
//                   if (widget.notification.type == NotificationType.request)
//                     ..._buildRequestButtons(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNameSection() {
//     String displayName = widget.notification.userName;

//     // For interest notifications, append the interest description
//     if (widget.notification.type == NotificationType.interest &&
//         widget.notification.interestDescription != null) {
//       displayName += ' ${widget.notification.interestDescription}';
//     }
//     // For event notifications, show the event name instead
//     else if (widget.notification.type == NotificationType.event &&
//         widget.notification.eventName != null) {
//       displayName = widget.notification.eventName!;
//     }

//     return Text(
//       displayName,
//       style: TextStyle(
//         fontSize: 14.sp,
//         fontWeight: FontWeight.w500,
//         color: const Color(0xff303030),
//       ),
//     );
//   }

//   Widget _buildDistanceRow() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Assets.icons.location.svg(
//           width: 16.w,
//           height: 16.h,
//           color: const Color(0xff707070),
//         ),
//         SizedBox(width: 5.w),
//         Text(
//           widget.notification.distance,
//           style: TextStyle(
//             fontSize: 12.sp,
//             fontWeight: FontWeight.w400,
//             color: const Color(0xff707070),
//           ),
//         ),
//       ],
//     );
//   }

//   List<Widget> _buildEventDetails() {
//     if (widget.notification.eventTime == null) return [];

//     return [
//       SizedBox(height: 4.h),
//       Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Assets.icons.calendarColor.svg(
//             width: 16.w,
//             height: 16.h,
//             color: const Color(0xff707070),
//           ),
//           SizedBox(width: 5.w),
//           Text(
//             widget.notification.eventTime!,
//             style: TextStyle(
//               fontSize: 12.sp,
//               fontWeight: FontWeight.w400,
//               color: const Color(0xff707070),
//             ),
//           ),
//         ],
//       ),
//     ];
//   }

//   List<Widget> _buildRequestButtons() {
//     return [
//       SizedBox(height: 12.h),
//       Row(
//         spacing: 8.w,
//         children: [
//           _buildActionButton('Accept', true, () {
//             showDialog(
//               context: context,
//               barrierDismissible: true,
//               builder: (context) {
//                 return Center(
//                   child: Dialog(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20.r),
//                     ),
//                     elevation: 0,
//                     backgroundColor: Colors.transparent,
//                     child: AnimatedDialogContent(
//                       content:
//                           'You have accepted ${widget.notification.userName}\'s event request.',
//                     ),
//                   ),
//                 );
//               },
//             );
//             // Handle accept action
//             print('Accept tapped for ${widget.notification.id}');
//           }),
//           SizedBox(width: 12.w),
//           _buildActionButton('Decline', false, () {
//             showDialog(
//               context: context,
//               barrierDismissible: true,
//               builder: (context) {
//                 return Center(
//                   child: Dialog(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20.r),
//                     ),
//                     elevation: 0,
//                     backgroundColor: Colors.transparent,
//                     child: AnimatedDialogContent(
//                       content:
//                           'You have declined ${widget.notification.userName}\'s event request.',
//                     ),
//                   ),
//                 );
//               },
//             );
//             // Handle decline action
//             print('Decline tapped for ${widget.notification.id}');
//           }),
//         ],
//       ),
//     ];
//   }

//   Widget _buildActionButton(String label, bool isPrimary, VoidCallback onTap) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: 8.h),
//           decoration: BoxDecoration(
//             gradient: isPrimary ? AppColors.primaryGradientRotated : null,
//             color: isPrimary ? null : Colors.transparent,
//             borderRadius: BorderRadius.circular(25.r),
//             border: isPrimary
//                 ? null
//                 : Border.all(color: const Color(0xffE0E0E0), width: 1.w),
//           ),
//           child: Text(
//             label,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w500,
//               color: isPrimary ? Colors.white : const Color(0xff707070),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
