import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// =============================================================
/// GLOBAL SCAFFOLD MESSENGER KEY
/// =============================================================
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// =============================================================
/// SNACK TYPES
/// =============================================================
enum SnackType { success, error, warning, info }

/// =============================================================
/// SNACK ICONS
/// =============================================================
class SnackIcons {
  static const info =
      '<svg id="Layer_1" data-name="Layer 1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><path d="M256.42,512C115.51,512.45.42,397.73,0,256.41-.42,115.46,114.2.47,255.57,0,396.51-.46,511.49,114.14,512,255.57,512.5,396.48,397.82,511.55,256.42,512Zm-28-300c0,21.53,0,43.05,0,64.57,0,16.72,11.5,28.86,27.27,29,16,.14,27.86-12.09,27.87-29q.07-64.29,0-128.57c0-16.94-11.74-29.33-27.6-29.33S228.45,131,228.42,148Q228.38,180,228.41,212ZM224.72,366.1a31.17,31.17,0,1,0,31.07-31.32A31,31,0,0,0,224.72,366.1Z"/></svg>';
  static const success =
      '<svg id="Layer_1" data-name="Layer 1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><path d="M261,0l4.19,2.3c7.27,4,11,11.61,9.79,20.2C274,30.09,268,36.82,260.1,38s-16.25,1.11-24.36,1.85a210.13,210.13,0,0,0-116.8,47.87c-36.56,30-62,67.8-73.07,114C27.89,276.42,44,343.49,95.15,401.3c34,38.43,77,61.82,127.63,69.21,65.79,9.61,124.74-7.12,175.39-50.72,34-29.25,56.68-65.81,68.09-109.24a205.06,205.06,0,0,0,6.85-49.29,51.24,51.24,0,0,1,.72-8.93c2-10.28,10.58-16.47,21.13-15.44a18.8,18.8,0,0,1,17,19c.11,40.8-8.8,79.58-27.71,115.73-35.9,68.65-91.36,113.78-166.48,132.64C182.78,538.1,46.87,458.23,9.39,323.79c-4.21-15.11-5.62-31-8.34-46.52-.25-1.46-.64-2.89-1-4.34v-34c.76-6.07,1.43-12.16,2.31-18.21,7.35-50.32,27.37-94.94,61-133.08,41.11-46.6,92.47-75,154-84.69,7.19-1.13,14.42-2,21.63-3Z"/><path d="M239.72,301.28c1.22-1.81,2.11-3.71,3.5-5.11Q355.3,184.24,467.42,72.37c6-6,12.55-9.81,21.4-7.36a19.25,19.25,0,0,1,10,30.43a45.87,45.87,0,0,1-3.73,4Q374.69,219.65,254.29,339.84c-6.34,6.34-13.36,10.23-22.32,6.91a25.27,25.27,0,0,1-9.31-6.37q-47.22-50.91-94.19-102.08c-4.37-4.73-7.33-9.9-6.75-16.53.71-8,4.86-13.83,12.38-16.62,7.9-2.94,15.19-1.2,21,4.93,8.15,8.56,16.07,17.34,24.08,26q28.44,30.87,56.88,61.73C236.85,298.68,237.73,299.4,239.72,301.28Z"/></svg>';
  static const warning =
      '<svg id="Layer_1" data-name="Layer 1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><path d="M256.28,487.86q-100,0-199.91,0c-28.29,0-50.51-18.33-55.48-46.07-2.33-13,.27-25.35,6.85-36.91q39.07-68.57,78-137.22Q146.39,160.9,207,54.13c9.3-16.41,22.69-26.81,41.54-29.43,22.76-3.17,43.74,7.1,55.31,27.21,15.17,26.36,30.06,52.89,45.08,79.34q77.28,136.16,154.61,272.28c8.13,14.31,10.76,29.2,6,45.1-7.07,23.72-28.33,39.19-53.92,39.21Q356,487.9,256.28,487.86Zm34.77-303.43c.3-14.86-1-25.25-4.95-35.76-3.16-8.44-8.85-14.13-17.8-16.24-17.16-4-34.22,6.2-37.67,23.94-1.7,8.75-1.29,18.07-.8,27.07,1.63,29.88,3.61,59.74,5.68,89.59,1,14.54,1,29.26,6.18,43.22,3.21,8.6,9,12.78,17.87,12.72s15.54-4.11,17.54-12.92a275.58,275.58,0,0,0,5.21-34.21C285.46,249.39,288.17,216.9,291.05,184.43ZM228.28,385.87c-.08,17.58,13.16,30.66,31.08,30.7,17.52.05,30.76-12.79,30.8-29.86,0-17.79-13.48-31.76-30.86-31.89S228.36,368.38,228.28,385.87Z"/></svg>';
}

/// =============================================================
/// SNACK CONFIG
/// =============================================================
class SnackConfig {
  final Color primaryColor;
  final Color backgroundColor;
  final Color textColor;
  final String svg;

  const SnackConfig({
    required this.primaryColor,
    required this.backgroundColor,
    required this.textColor,
    required this.svg,
  });
}

/// =============================================================
/// SNACK THEME
/// =============================================================
class SnackTheme {
  static const double iconSize = 22;

  static final Map<SnackType, SnackConfig> configs = {
    SnackType.success: SnackConfig(
      primaryColor: Color(0xFF2E7D32),
      backgroundColor: Color(0xFFE8F5E9),
      textColor: Color(0xFF1B5E20),
      svg: SnackIcons.success,
    ),
    SnackType.error: SnackConfig(
      primaryColor: Color(0xFFD32F2F),
      backgroundColor: Color(0xFFFFEBEE),
      textColor: Color(0xFFB71C1C),
      svg: SnackIcons.warning,
    ),
    SnackType.warning: SnackConfig(
      primaryColor: Color(0xFFF57C00),
      backgroundColor: Color(0xFFFFF3E0),
      textColor: Color(0xFFE65100),
      svg: SnackIcons.warning,
    ),
    SnackType.info: SnackConfig(
      primaryColor: Color(0xFF1976D2),
      backgroundColor: Color(0xFFE3F2FD),
      textColor: Color(0xFF0D47A1),
      svg: SnackIcons.info,
    ),
  };

  static SvgPicture icon(SnackType type) {
    final config = configs[type]!;
    return SvgPicture.string(
      config.svg,
      colorFilter: ColorFilter.mode(config.primaryColor, BlendMode.srcIn),
      width: iconSize,
      height: iconSize,
    );
  }
}

/// =============================================================
/// CUSTOM SNACKBAR WIDGET
/// =============================================================
class CustomSnackbar extends StatefulWidget {
  final String message;
  final SnackType type;
  final int duration;
  final VoidCallback onClose;

  const CustomSnackbar({
    super.key,
    required this.message,
    required this.type,
    required this.duration,
    required this.onClose,
  });

  @override
  State<CustomSnackbar> createState() => _CustomSnackbarState();
}

class _CustomSnackbarState extends State<CustomSnackbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = SnackTheme.configs[widget.type]!;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          color: Colors.transparent,
          elevation: 6,
          shadowColor: Colors.black.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: config.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(color: config.primaryColor, width: 4),
              ),
              boxShadow: [
                BoxShadow(
                  color: config.primaryColor.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                /// ICON
                Container(
                  padding: const EdgeInsets.all(4),
                  child: SnackTheme.icon(widget.type),
                ),

                const SizedBox(width: 12),

                /// MESSAGE
                Expanded(
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: config.textColor,
                      letterSpacing: 0.15,
                      height: 1.43,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                /// CLOSE BUTTON WITH PROGRESS
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onClose,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: config.primaryColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 26,
                      height: 26,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 1.0, end: 0.0),
                        duration: Duration(milliseconds: widget.duration),
                        builder: (context, value, child) {
                          return CircularProgressIndicator(
                            value: value,
                            strokeWidth: 2,
                            color: config.primaryColor.withValues(alpha: 0.5),
                            backgroundColor: config.primaryColor.withValues(
                              alpha: 0.1,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// =============================================================
/// Snackbar SERVICE (PUBLIC API)
/// =============================================================
class AppSnackbar {
  static void show({
    required String message,
    SnackType type = SnackType.info,
    int duration = 4000,
  }) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: Duration(milliseconds: duration),
      margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      padding: EdgeInsets.zero,
      content: CustomSnackbar(
        message: message,
        type: type,
        duration: duration,
        onClose: () {
          rootScaffoldMessengerKey.currentState?.hideCurrentSnackBar();
        },
      ),
    );

    rootScaffoldMessengerKey.currentState
      ?..clearSnackBars()
      ..showSnackBar(snackBar);
  }
}

/*   
!!!README

📱 Material Snackbar with Accent Strip

✅ Step 1: Add to main.dart
────────────────────────────
MaterialApp(
  scaffoldMessengerKey: rootScaffoldMessengerKey,
  home: MyHome(),
);

✅ Step 2: Usage Examples
────────────────────────────
// Success (Green)
AppSnackbar.show(
  message: 'Profile updated successfully',
  type: SnackType.success,
);

// Error (Red)
AppSnackbar.show(
  message: 'Failed to connect to server',
  type: SnackType.error,
);

// Warning (Orange)
AppSnackbar.show(
  message: 'Your session will expire in 5 minutes',
  type: SnackType.warning,
);

// Info (Blue)
AppSnackbar.show(
  message: 'You have 3 new notifications',
  type: SnackType.info,
);

// Custom duration
AppSnackbar.show(
  message: 'Changes saved',
  type: SnackType.success,
  duration: 3000,
);

✨ Polish Enhancements
────────────────────────────
• Smooth scale + fade entrance animation
• easeOutBack curve for bouncy effect
• Enhanced elevation and shadows
• Color-matched shadow overlay
• Refined Material ripple effect
• Cross-platform visual consistency
• Optimized for both iOS and Android
*/
