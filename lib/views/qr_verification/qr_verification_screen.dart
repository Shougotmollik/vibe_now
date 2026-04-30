import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:vibe_now/core/constant/qrcontext_enum.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';
import 'package:vibe_now/views/qr_verification/qr_screen.dart';

class QRVerificationScreen extends StatefulWidget {
  final QRContext qrContext;
  const QRVerificationScreen({super.key, required this.qrContext});

  @override
  State<QRVerificationScreen> createState() => _QRVerificationScreenState();
}

class _QRVerificationScreenState extends State<QRVerificationScreen> {
  bool isQRCodeTab = true;
  String get infoText {
    switch (widget.qrContext) {
      case QRContext.community:
        return 'Scan this QR code to join a community or connect with other members.';
      case QRContext.event:
        return 'Scan this QR code for event access or verification.';
      case QRContext.chats:
        return 'Scan this QR code to create a direct personal connection.';
    }
  }

  String get titleText {
    switch (widget.qrContext) {
      case QRContext.community:
        return 'Join a Community';
      case QRContext.event:
        return 'Event Access & Verification';
      case QRContext.chats:
        return 'Connect with Chats';
    }
  }

  String get subtitleText {
    switch (widget.qrContext) {
      case QRContext.community:
        return 'Let others scan this code to join the community';
      case QRContext.event:
        return 'Present this code for event entry or verification';
      case QRContext.chats:
        return 'Let them scan to connect with you instantly';
    }
  }

  String get scanMessage {
    switch (widget.qrContext) {
      case QRContext.community:
        return 'Scan the QR code to join the community and start connecting.';
      case QRContext.event:
        return 'Scan the QR code to securely access the event.';
      case QRContext.chats:
        return 'Scan the QR code to connect instantly through chat.';
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'QR Verification',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildTabSelector(),
          const SizedBox(height: 24),
          Expanded(child: isQRCodeTab ? _buildQRCodeView() : _buildScanView()),
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
              label: 'QR Code',
              isSelected: isQRCodeTab,
              onTap: () => setState(() => isQRCodeTab = true),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTab(
              icon: Icons.qr_code_scanner,
              label: 'Scan',
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
                child: Image.network(
                  'https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=QRVerificationCode',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This code is unique for this connection',
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
              'Scan Their QR Code',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Align the QR code in the frame',
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
              'Camera permission required',
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
