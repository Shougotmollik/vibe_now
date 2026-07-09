import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:vibe_now/controller/community_controller.dart';
import 'package:vibe_now/design_system/components/buttons/primary_button.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/gen/assets.gen.dart';
import 'package:vibe_now/localization/app_localizations.dart';

class CommunityWelcomeScreen extends StatefulWidget {
  const CommunityWelcomeScreen({super.key, this.qrCode});
  final String? qrCode;

  @override
  State<CommunityWelcomeScreen> createState() => _CommunityWelcomeScreenState();
}

class _CommunityWelcomeScreenState extends State<CommunityWelcomeScreen> {
  final CommunityController _controller = Get.find<CommunityController>();

  @override
  void initState() {
    super.initState();
    if (widget.qrCode != null) {
      _controller.communityQrcodeJoin(qrcode: widget.qrCode!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.onSurface,
            size: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        final community = _controller.qrCommunityDetails.value;

        if (_controller.isQrJoining.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final String title = community?.title ?? 'the community';

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 150.h,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Lottie.asset(
                      'assets/lottie/Confetti - Full Screen.json',
                      width: double.infinity,
                      repeat: true,
                      fit: BoxFit.cover,
                    ),
                    const Text("🥳", style: TextStyle(fontSize: 80)),
                  ],
                ),
              ),

              Text(
                "${loc.translate('welcomeTo')}\n$title!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "${loc.translate('youreOfficialMember')}\n${loc.translate('feelFreeToSayHi')}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),

              SizedBox(height: 24.h),

              _buildFeaturesCard(context: context, loc: loc),
              const SizedBox(height: 24),

              _buildTrustNote(context: context, loc: loc),
              const SizedBox(height: 48),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFeaturesCard({required BuildContext context, required loc}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildListTile(
            context: context,
            icon: Assets.icons.chatting,
            title: loc.translate('chats'),
          ),
          _buildListTile(
            context: context,
            icon: Assets.icons.calendarColor,
            title: loc.translate('meetups'),
          ),
          _buildListTile(
            context: context,
            icon: Assets.icons.communityColor,
            title: loc.translate('members'),
          ),
          const SizedBox(height: 24),

          PrimaryButton.text(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            text: loc.translate('enterCommunity'),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required SvgGenImage icon,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: icon.svg(
              height: 24,
              width: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustNote({required BuildContext context, required loc}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Assets.icons.shieldColor.svg(width: 24.h, height: 24.h),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: loc.translate('pendingMeetupsNote') + ' ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14.sp,
                    ),
                  ),
                  TextSpan(
                    text: loc.translate('trustEcosystem'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
