import 'package:flutter/material.dart';
import 'package:vibe_now/design_system/tokens/colors.dart';

class QRVerificationScreen extends StatefulWidget {
  const QRVerificationScreen({super.key});

  @override
  State<QRVerificationScreen> createState() => _QRVerificationScreenState();
}

class _QRVerificationScreenState extends State<QRVerificationScreen> {
  bool isQRCodeTab = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'QR Verification',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
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
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black54,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black54,
                fontSize: 15,
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'To join the community chat, simply scan each other\'s QR codes to connect.',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Show Your QR Code',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_2, color: Colors.grey[400], size: 16),
                const SizedBox(width: 6),
                Text(
                  'Let them scan this code',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                width: 220,
                height: 220,
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Share this QR code with your contact both of you need to scan each other\'s codes to unlock messaging.',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Scan Their QR Code',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Align the QR code in the frame',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              height: 320,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(0xffEFF6FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF4DAFFF), width: 3),
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
                        size: 64,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Camera permission required',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner(bool isTop, bool isLeft) {
    return Container(
      width: 40,
      height: 40,
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
          topLeft: isTop && isLeft ? const Radius.circular(12) : Radius.zero,
          topRight: isTop && !isLeft ? const Radius.circular(12) : Radius.zero,
          bottomLeft: !isTop && isLeft
              ? const Radius.circular(12)
              : Radius.zero,
          bottomRight: !isTop && !isLeft
              ? const Radius.circular(12)
              : Radius.zero,
        ),
      ),
    );
  }
}
