import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/core/routes/routes.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/src/presentation/views/auth/steps/step_name_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      builder: (context, child) => MaterialApp(
        title: 'Flutter Demo',
        theme: AppTheme.light(),
        // home: MaterialApp.router(
        //   debugShowCheckedModeBanner: false,
        //   routerConfig: router,
        // ),
        home: StepNameScreen(),
      ),
    );
  }
}
