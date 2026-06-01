import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vibe_now/core/helper/app_snackbar.dart';
import 'package:vibe_now/core/routes/routes.dart';

import 'package:get/get.dart';
import 'package:vibe_now/controller/theme_controller.dart';
import 'package:vibe_now/controller_binding.dart';
import 'package:vibe_now/design_system/theme/app_theme.dart';
import 'package:vibe_now/services/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    throw Exception('Error loading .env file: $e');
  }
  // Initialize bindings
  ControllerBinding().dependencies();

  final accessToken = await LocalStorage.access_token.get();
  setupRouter(accessToken != null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return Obx(
          () => MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Vybin',
            scaffoldMessengerKey: rootScaffoldMessengerKey,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeController.themeMode,
            routerConfig: appRouter,
          ),
        );
      },
    );
  }
}
