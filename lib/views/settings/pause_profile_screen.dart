import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/settings/delete_reason_screen.dart';

class PauseProfileScreen extends StatelessWidget {
  const PauseProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              CustomAppBar(title: "Pause"),

              SizedBox(height: 14.h),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xffE0E0E0), width: 1.5),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    _buildOptionTile(
                      title: "Pause Account",
                      onTap: () {
                        context.pushNamed(RouteNames.reasonScreen);
                      },
                    ),
                    Divider(height: 1.h, color: Colors.black12),
                    _buildOptionTile(
                      title: "Delete Account",
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              contentPadding: EdgeInsets.all(16.w),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8.w),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Assets.icons.delete.svg(
                                        width: 32.w,
                                        height: 32.w,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 16.h),

                                  Text(
                                    "Delete Confirmation",
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),

                                  SizedBox(height: 8.h),

                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                    ),
                                    child: Text(
                                      "You can delete your account, but please note the process may take some time to complete. Once deleted, it cannot be undone later.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Color(0xff908F90),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 24.h),

                                  // Buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  _buildDeleteDialog(context),
                                            );

                                            // Navigator.pop(context);
                                          },
                                          child: Text(
                                            "Delete",
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteDialog(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      contentPadding: EdgeInsets.all(16.w),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Confirm your password to delete your account",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),

          SizedBox(height: 36.h),

          TextField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Enter your password",
              hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
            ),
          ),

          SizedBox(height: 18.h),

          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    context.pushNamed(RouteNames.reasonScreen);
                    context.pop();
                    context.pop();
                  },
                  child: Text(
                    "Delete",
                    style: TextStyle(fontSize: 16.sp, color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({required String title, VoidCallback? onTap}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 20.h),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.translucent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                color: Color(0xff2A2A2A),
                fontWeight: FontWeight.w400,
              ),
            ),

            Icon(Icons.arrow_forward_ios, size: 20.h, color: Color(0xFFCFCFCF)),
          ],
        ),
      ),
    );
  }
}
