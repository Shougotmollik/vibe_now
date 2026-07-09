import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:vibe_now/core/constant/credential.dart';
import 'package:vibe_now/core/constant/qrcontext_enum.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/views/qr_verification/qr_screen.dart';

class QRVerificationScreen extends StatefulWidget {
  final QRContext qrContext;
  final bool showQRCodeOnly;
  final bool showScanOnly;
  final String? qrCodeUrl;
  final String? qrCodeValue;

  const QRVerificationScreen({
    super.key,
    required this.qrContext,
    this.showQRCodeOnly = false,
    this.showScanOnly = false,
    this.qrCodeUrl,
    this.qrCodeValue,
  });

  @override
  State<QRVerificationScreen> createState() => _QRVerificationScreenState();
}

class _QRVerificationScreenState extends State<QRVerificationScreen> {
  late bool isQRCodeTab;

  @override
  void initState() {
    super.initState();
    if (widget.showQRCodeOnly) {
      isQRCodeTab = true;
    } else if (widget.showScanOnly) {
      isQRCodeTab = false;
    } else {
      isQRCodeTab = true;
    }
  }
  String get infoText {
    final loc = AppLocalizations.of(context);
    switch (widget.qrContext) {
      case QRContext.community:
        return loc.translate('qrInfoCommunity');
      case QRContext.event:
        return loc.translate('qrInfoEvent');
      case QRContext.chats:
        return loc.translate('qrInfoChats');
    }
  }

  String get titleText {
    final loc = AppLocalizations.of(context);
    switch (widget.qrContext) {
      case QRContext.community:
        return loc.translate('qrTitleCommunity');
      case QRContext.event:
        return loc.translate('qrTitleEvent');
      case QRContext.chats:
        return loc.translate('qrTitleChats');
    }
  }

  String get subtitleText {
    final loc = AppLocalizations.of(context);
    switch (widget.qrContext) {
      case QRContext.community:
        return loc.translate('qrSubtitleCommunity');
      case QRContext.event:
        return loc.translate('qrSubtitleEvent');
      case QRContext.chats:
        return loc.translate('qrSubtitleChats');
    }
  }

  String get scanMessage {
    final loc = AppLocalizations.of(context);
    switch (widget.qrContext) {
      case QRContext.community:
        return loc.translate('qrScanCommunity');
      case QRContext.event:
        return loc.translate('qrScanEvent');
      case QRContext.chats:
        return loc.translate('qrScanChats');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showTabs = !widget.showQRCodeOnly && !widget.showScanOnly;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurface,
            size: 20.sp,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.showScanOnly ? AppLocalizations.of(context).translate('scanEventQR') : AppLocalizations.of(context).translate('qrVerification'),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          if (showTabs) ...[
            const SizedBox(height: 16),
            _buildTabSelector(),
            const SizedBox(height: 24),
          ],
          Expanded(
            child: widget.showQRCodeOnly
                ? _buildQRCodeView()
                : widget.showScanOnly
                    ? _buildScanView()
                    : (isQRCodeTab ? _buildQRCodeView() : _buildScanView()),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildTab(
              icon: Icons.qr_code,
              label: AppLocalizations.of(context).translate('qrTab'),
              isSelected: isQRCodeTab,
              onTap: () => setState(() => isQRCodeTab = true),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTab(
              icon: Icons.qr_code_scanner,
              label: AppLocalizations.of(context).translate('scanTab'),
              isSelected: !isQRCodeTab,
              onTap: () => setState(() => isQRCodeTab = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected
              ? null
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
              size: 20.sp,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCodeView() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.1),
                    Theme.of(
                      context,
                    ).colorScheme.secondaryContainer.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.8),
                    size: 20.sp,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      infoText,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.8),
                        fontSize: 13.sp,
                        height: 1.4.h,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              titleText,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code_2,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                  size: 16.sp,
                ),
                const SizedBox(width: 6),
                Text(
                  subtitleText,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(150),
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                width: 220.w,
                height: 220.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: widget.qrCodeUrl != null
                    ? Image.network(
                        AppCredentials.fixurl(widget.qrCodeUrl),
                        fit: BoxFit.contain,
                      )
                    : widget.qrCodeValue != null
                        ? Center(
                            child: Text(
                              widget.qrCodeValue!,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          )
                        : Image.network(
                            'https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=QRVerificationCode',
                            fit: BoxFit.contain,
                          ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).translate('uniqueQRCode'),
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanView() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.1),
                    Theme.of(
                      context,
                    ).colorScheme.secondaryContainer.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.8),
                    size: 20.sp,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      scanMessage,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.8),
                        fontSize: 13.sp,
                        height: 1.4.h,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context).translate('scanTheirQRCode'),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).translate('alignQRCode'),
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 150),
                fontSize: 14.sp,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QrScreen(qrContext: widget.qrContext),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 320.h,
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF4DAFFF),
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Corner decorations
                      Positioned(
                        top: 0,
                        left: 0,
                        child: _buildCorner(true, true),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: _buildCorner(true, false),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: _buildCorner(false, true),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: _buildCorner(false, false),
                      ),
                      // Camera icon in center
                      Center(
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 64.sp,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).translate('cameraPermissionRequired'),
              style: TextStyle(color: Colors.grey[400], fontSize: 13.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner(bool isTop, bool isLeft) {
    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? BorderSide(color: const Color(0xFF4DAFFF), width: 4)
              : BorderSide.none,
          bottom: !isTop
              ? BorderSide(color: const Color(0xFF4DAFFF), width: 4)
              : BorderSide.none,
          left: isLeft
              ? BorderSide(color: const Color(0xFF4DAFFF), width: 4)
              : BorderSide.none,
          right: !isLeft
              ? BorderSide(color: const Color(0xFF4DAFFF), width: 4)
              : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: isTop && isLeft ? Radius.circular(12.r) : Radius.zero,
          topRight: isTop && !isLeft ? Radius.circular(12.r) : Radius.zero,
          bottomLeft: !isTop && isLeft ? Radius.circular(12.r) : Radius.zero,
          bottomRight: !isTop && !isLeft ? Radius.circular(12.r) : Radius.zero,
        ),
      ),
    );
  }
}
