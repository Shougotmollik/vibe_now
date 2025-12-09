import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/src/presentation/views/event/create_event_screen.dart';
import 'package:vibe_now/src/presentation/views/event/create_post_screen.dart';
import 'package:vibe_now/src/presentation/views/event/event_details_screen.dart';
import 'package:vibe_now/src/presentation/views/qr_verification/qr_verification_screen.dart';
import 'package:vibe_now/src/presentation/views/settings/settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      builder: (context, child) => MaterialApp(
        title: 'Flutter Demo',
        theme: AppTheme.light(),
        home: SettingsScreen(),
      ),
    );
  }
}
