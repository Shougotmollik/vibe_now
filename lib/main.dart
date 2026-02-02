import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/core/routes/routes.dart';
import 'package:vibe_now/design_system/design_system.dart';
import 'package:vibe_now/views/auth/sign_in_screen.dart';
import 'package:vibe_now/views/auth/sign_up_screen.dart';
import 'package:vibe_now/views/community/community_details_screen.dart';
import 'package:vibe_now/views/community/community_screen.dart';
import 'package:vibe_now/views/community/create_community_screen.dart';
import 'package:vibe_now/views/create_vibe/create_vibe_screen.dart';
import 'package:vibe_now/views/event/create_event_screen.dart';
import 'package:vibe_now/views/event/event_screen.dart';
import 'package:vibe_now/views/event/event_details_screen.dart';
import 'package:vibe_now/views/event/event_or_community_screen.dart';
import 'package:vibe_now/views/home/home_screen.dart';
import 'package:vibe_now/views/main_nav_bar_screen.dart';
import 'package:vibe_now/views/notification/notification_screen.dart';
import 'package:vibe_now/views/subscription/subscription_screen.dart';

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
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Vibe Now',
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          themeMode: ThemeMode.light,
          routerConfig: router,
        );
      },
    );
  }
}
