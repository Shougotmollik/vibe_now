import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/src/presentation/views/common/custom_app_bar.dart';
import 'package:vibe_now/src/presentation/views/common/custom_elevated_button.dart';

class BlockedAccountsScreen extends StatelessWidget {
  const BlockedAccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              CustomAppBar(title: "Blocked Accounts"),
              Expanded(
                child: ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return _buildAccountTile(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTile(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Image.network(
          "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400",
          width: 40.w,
          height: 40.h,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        "Jony Gomes",
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
      ),
      trailing: TextButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Are you sure you want to Unblock this person?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff908F90),
                        ),
                      ),

                      SizedBox(height: 20.h),

                      Row(
                        children: [
                          Expanded(
                            child: CustomElevatedButton(
                              onTap: () {},
                              buttonText: "Cancel",
                              btnColor: Color(0xffF2F2F2),
                              textColor: Color(0xFF202020),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: CustomElevatedButton(
                              onTap: () {},
                              buttonText: "Unblock",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: Text(
          "Unblock",
          style: TextStyle(
            fontSize: 14.sp,
            color: Color(0xFF9D9D9D),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
