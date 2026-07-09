import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vibe_now/controller/vibe_controller.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/design_system/tokens/tokens.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/model/vibe_model.dart';
import 'package:vibe_now/views/common/custom_app_bar.dart';
import 'package:vibe_now/views/home/widgets/wave_animated_dialog.dart';
import 'package:vibe_now/views/vibe/my_vibe_screen.dart';
import 'package:vibe_now/views/vibe/widgets/vibe_shimmer_loading.dart';

class UserVibeScreen extends StatefulWidget {
  const UserVibeScreen({super.key});

  @override
  State<UserVibeScreen> createState() => _UserVibeScreenState();
}

class _UserVibeScreenState extends State<UserVibeScreen> {
  final VibeController _vibeController = Get.put(VibeController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _vibeController.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _vibeController.getVibes(),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar(title: loc.translate('allVibes')),
                SizedBox(height: 20.h),
                Obx(() {
                  if (_vibeController.isVibesLoading.value) {
                    return const OwnVibeShimmer();
                  }
                  if (_vibeController.ownVibe.value == null) {
                    return const SizedBox.shrink();
                  }
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyVibeScreen(
                                vibe: _vibeController.ownVibe.value,
                              )),
                    ),
                    child: VibeCard(vibe: _vibeController.ownVibe.value!),
                  );
                }),
                SizedBox(height: 12.h),
                Text(
                  loc.translate('otherVibes'),
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 12.h),
                Obx(() {
                  if (_vibeController.isVibesLoading.value &&
                      _vibeController.othersVibe.isEmpty) {
                    return Column(
                      spacing: 12.h,
                      children: List.generate(4, (index) => const OtherVibeShimmer()),
                    );
                  }
                  if (_vibeController.othersVibe.isEmpty) {
                    return Center(child: Text(loc.translate('noOtherVibes')));
                  }
                  return Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _vibeController.othersVibe.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final vibe = _vibeController.othersVibe[index];
                          return UserVibeCard(vibe: vibe);
                        },
                      ),
                      if (_vibeController.isMoreLoading.value)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: const OtherVibeShimmer(),
                        ),
                    ],
                  );
                }),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UserVibeCard extends StatefulWidget {
  final Vibe vibe;
  const UserVibeCard({super.key, required this.vibe});

  @override
  State<UserVibeCard> createState() => _UserVibeCardState();
}

class _UserVibeCardState extends State<UserVibeCard> {
  bool _isSending = false;
  late bool _hasWaved;
  late String? _waveStatus;

  @override
  void initState() {
    super.initState();
    _hasWaved = widget.vibe.hasSentWave;
    _waveStatus = widget.vibe.waveStatus;
  }

  bool get _showWaveButton =>
      _waveStatus == null || _waveStatus == 'pending';

  Future<void> _sendWave() async {
    if (_isSending || widget.vibe.id == null) return;
    setState(() => _isSending = true);

    final ok = await Get.find<VibeController>().sendWave(
      vibeId: widget.vibe.id!,
    );

    if (!mounted) return;

    if (ok) {
      setState(() {
        _hasWaved = true;
        _waveStatus = 'pending';
      });
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Center(
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: WaveAnimatedDialog(
                content:
                    "${AppLocalizations.of(context).translate('waveSent')} ${widget.vibe.createdBy?.fullName ?? "User"}",
              ),
            ),
          );
        },
      );
    }

    setState(() => _isSending = false);
  }

  String _formatRemainingTime(DateTime? endsAt) {
    final loc = AppLocalizations.of(context);
    if (endsAt == null) return '';
    final remaining = endsAt.difference(DateTime.now());
    if (remaining.isNegative) return loc.translate('expired');

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);

    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    if (minutes > 0) return '${minutes}m';
    return loc.translate('lessThan1m');
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        spacing: 8.w,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50.r),
            child: widget.vibe.createdBy?.avatar != null
                ? Image.network(
                    AppCredentials.fixurl(widget.vibe.createdBy!.avatar),
                    width: 50.w,
                    height: 50.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      "assets/images/profile_picture.jpg",
                      width: 50.w,
                      height: 50.w,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    "assets/images/profile_picture.jpg",
                    width: 50.w,
                    height: 50.w,
                    fit: BoxFit.cover,
                  ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.vibe.createdBy?.fullName ?? "Unknown",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  widget.vibe.title ?? "",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  "${loc.translate('expiresIn')} ${_formatRemainingTime(widget.vibe.endsAt)}",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          if (_showWaveButton)
            GestureDetector(
              onTap: _sendWave,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  gradient: _hasWaved
                      ? AppColors.primaryGradientRotated.withOpacity(0.5)
                      : _isSending
                          ? AppColors.primaryGradientRotated.withOpacity(0.7)
                          : AppColors.primaryGradientRotated,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: _isSending
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _hasWaved ? loc.translate('waved') : loc.translate('wave'),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
