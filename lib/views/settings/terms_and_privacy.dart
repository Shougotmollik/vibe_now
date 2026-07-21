import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibe_now/controller/settings_controller.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';

class TermsAndPrivacy extends StatefulWidget {
  const TermsAndPrivacy({super.key});

  @override
  State<TermsAndPrivacy> createState() => _TermsAndPrivacyState();
}

class _TermsAndPrivacyState extends State<TermsAndPrivacy> {
  final SettingsController settingsController = Get.find<SettingsController>();

  @override
  void initState() {
    super.initState();
    settingsController.getPrivacyPolicy();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: CustomAppBar(
                title: loc.translate('termsAndPrivacy'),
                canBack: true,
              ),
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: Obx(() {
                final content = settingsController.privacyPolicyContent.value;

                if (settingsController.isLoading.value && content.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (content.isEmpty) {
                  return Center(
                    child: Text(
                      'Unable to load privacy policy.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  );
                }

                final headingColor = Theme.of(context).colorScheme.onSurface;
                final String headingHex = _colorToCssHex(headingColor);
                final String linkHex = _colorToCssHex(
                  Theme.of(context).colorScheme.primary,
                );

                final h1Size = 22.sp;
                final h2Size = 20.sp;
                final h3Size = 18.sp;
                final h4Size = 17.sp;
                final h5Size = 16.sp;
                final h6Size = 15.sp;

                return RefreshIndicator(
                  onRefresh: () => settingsController.getPrivacyPolicy(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16.w),
                    child: HtmlWidget(
                      content,
                      textStyle: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.8),
                        height: 1.6,
                      ),
                      onTapUrl: (url) async {
                        final uri = Uri.tryParse(url);
                        if (uri != null && await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                          return true;
                        }
                        return false;
                      },
                      customStylesBuilder: (element) {
                        switch (element.localName) {
                          case 'h1':
                            return {
                              'font-size': '${h1Size.toStringAsFixed(0)}px',
                              'font-weight': 'bold',
                              'color': headingHex,
                              'margin': '24px 0 12px 0',
                            };
                          case 'h2':
                            return {
                              'font-size': '${h2Size.toStringAsFixed(0)}px',
                              'font-weight': 'bold',
                              'color': headingHex,
                              'margin': '20px 0 10px 0',
                            };
                          case 'h3':
                            return {
                              'font-size': '${h3Size.toStringAsFixed(0)}px',
                              'font-weight': '600',
                              'color': headingHex,
                              'margin': '16px 0 8px 0',
                            };
                          case 'h4':
                            return {
                              'font-size': '${h4Size.toStringAsFixed(0)}px',
                              'font-weight': '600',
                              'color': headingHex,
                              'margin': '14px 0 6px 0',
                            };
                          case 'h5':
                            return {
                              'font-size': '${h5Size.toStringAsFixed(0)}px',
                              'font-weight': '500',
                              'color': headingHex,
                              'margin': '12px 0 4px 0',
                            };
                          case 'h6':
                            return {
                              'font-size': '${h6Size.toStringAsFixed(0)}px',
                              'font-weight': '500',
                              'color': headingHex,
                              'margin': '10px 0 4px 0',
                            };
                          case 'p':
                            return {
                              'margin': '0 0 12px 0',
                              'line-height': '1.6',
                            };
                          case 'ul':
                          case 'ol':
                            return {
                              'margin': '0 0 12px 0',
                              'padding-left': '24px',
                            };
                          case 'li':
                            return {
                              'margin': '0 0 4px 0',
                              'line-height': '1.6',
                            };
                          case 'a':
                            return {
                              'color': linkHex,
                              'text-decoration': 'underline',
                            };
                          default:
                            return null;
                        }
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  static String _colorToCssHex(Color color) {
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b';
  }
}
