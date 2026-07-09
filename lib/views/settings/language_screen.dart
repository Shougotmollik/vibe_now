import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/localization/language_controller.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final LanguageController _langController = Get.find<LanguageController>();

  late int selectedIndex;

  List<LanguageModel> languages = [
    LanguageModel(name: "English", flag: Assets.flags.unitedKingdom, code: 'en'),
    LanguageModel(name: "Deutsch", flag: Assets.flags.germany, code: 'de'),
  ];

  @override
  void initState() {
    super.initState();
    selectedIndex = languages.indexWhere(
      (l) => l.code == _langController.currentLanguageCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              CustomAppBar(title: loc.translate('language')),

              SizedBox(height: 20.h),

              ListView.builder(
                shrinkWrap: true,
                itemCount: languages.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return _buildLanguageTile(languages[index], index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile(LanguageModel lang, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
        _langController.changeLanguage(Locale(lang.code));
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            lang.flag.svg(width: 24.w, height: 24.h, fit: BoxFit.cover),

            SizedBox(width: 12.w),

            Text(
              lang.name,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),

            const Spacer(),

            selectedIndex == index ? _selectedCircle() : _unselectedCircle(),
          ],
        ),
      ),
    );
  }

  Widget _selectedCircle() {
    return Assets.icons.checkboxGradient.svg(
      width: 24.w,
      height: 24.h,
      fit: BoxFit.cover,
    );
  }

  Widget _unselectedCircle() {
    return Container(
      width: 20.w,
      height: 20.h,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
        shape: BoxShape.circle,
      ),
    );
  }
}

class LanguageModel {
  final String name;
  final SvgGenImage flag;
  final String code;

  LanguageModel({required this.name, required this.flag, required this.code});
}
