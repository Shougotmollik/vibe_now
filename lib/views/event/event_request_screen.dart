import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:vibe_now/controller/event_controller.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/model/event.dart';
import 'package:vibe_now/views/common/cancel_button.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';

class EventRequestScreen extends StatefulWidget {
  const EventRequestScreen({super.key, required this.event});
  final Event event;

  @override
  State<EventRequestScreen> createState() => _EventRequestScreenState();
}

class _EventRequestScreenState extends State<EventRequestScreen> {
  final EventController _eventController = Get.find<EventController>();
  bool _isWithdrawing = false;

  Event get _event => widget.event;

  Future<void> _withdrawRequest() async {
    if (_isWithdrawing) return;

    setState(() => _isWithdrawing = true);

    final success = await _eventController.eventJoinWithdraw(
      id: _event.id ?? 0,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
    }

    setState(() => _isWithdrawing = false);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                SafeArea(
                  child: CustomAppBar(
                    title: "Event Request Sent",
                    canBack: true,
                  ),
                ),
                SizedBox(height: 100.h),
                Image.asset(
                  "assets/images/celebration.png",
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 10.h),
                Text(
                  _event.title ?? "",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 10.h),

                _buildEventInfoCard(
                  context,
                  icon: Assets.icons.location,
                  location: _event.address ?? "",
                ),
                SizedBox(height: 8.h),
                _buildEventInfoCard(
                  context,
                  icon: Assets.icons.colorClock,
                  location: "${_event.eventDate} ${_event.eventTime}",
                ),
                Spacer(),
                Text(
                  "Your request has been sent!",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                SizedBox(height: 12.h),
                PrimaryButton.text(
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => EventAccessGrandScreen(),
                    //   ),
                    // );
                    Navigator.of(context).pop();
                  },
                  text: "OK",
                ),
                SizedBox(height: 12.h),
                CancelButton(
                  onTap: _isWithdrawing ? null : () => _withdrawRequest(),
                  btnText: _isWithdrawing ? "Withdrawing..." : "Withdraw Request",
                ),

                SizedBox(height: 48.h),
              ],
            ),
          ),
          IgnorePointer(
            child: Lottie.asset(
              'assets/lottie/Confetti - Full Screen.json',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventInfoCard(
    BuildContext context, {
    required SvgGenImage icon,
    required String location,
  }) {
    return IntrinsicWidth(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          icon.svg(
            width: 16.w,
            height: 16.h,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),

          SizedBox(width: 6.w),

          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 250.w),
            child: Text(
              location,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
