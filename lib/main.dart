import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/core/routes/routes.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/src/presentation/views/auth/sign_in_screen.dart';
import 'package:vibe_now/src/presentation/views/auth/sign_up_screen.dart';
import 'package:vibe_now/src/presentation/views/community/community_details_screen.dart';
import 'package:vibe_now/src/presentation/views/community/community_screen.dart';
import 'package:vibe_now/src/presentation/views/community/create_community_screen.dart';
import 'package:vibe_now/src/presentation/views/create_vibe/create_vibe_screen.dart';
import 'package:vibe_now/src/presentation/views/event/create_event_screen.dart';
import 'package:vibe_now/src/presentation/views/event/event_screen.dart';
import 'package:vibe_now/src/presentation/views/event/event_details_screen.dart';
import 'package:vibe_now/src/presentation/views/event/event_or_community_screen.dart';
import 'package:vibe_now/src/presentation/views/home/home_screen.dart';
import 'package:vibe_now/src/presentation/views/main_nav_bar_screen.dart';
import 'package:vibe_now/src/presentation/views/notification/notification_screen.dart';
import 'package:vibe_now/src/presentation/views/sign_in_screen.dart';
import 'package:vibe_now/src/presentation/views/subscription/subscription_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    throw Exception('Error loading .env file: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Vive Now',
        theme: AppTheme.light(),
        themeMode: ThemeMode.light,
        // home: SignUpScreen(),
        home: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router,
        ),
      ),
    );
  }
}
