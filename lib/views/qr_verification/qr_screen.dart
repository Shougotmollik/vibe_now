import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:vibe_now/core/constant/api_constant.dart';
import 'package:vibe_now/core/constant/qrcontext_enum.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/localization/app_localizations.dart';
import 'package:vibe_now/model/chat.dart';
import 'package:vibe_now/model/scan_result.dart';
import 'package:vibe_now/services/custom_http.dart';
import 'package:vibe_now/views/chat/chat_inbox_screen.dart';
import 'package:vibe_now/views/community/community_welcome_screen.dart';
import 'package:vibe_now/views/event/event_checkin_screen.dart';
import 'package:vibe_now/views/qr_verification/scan_success_screen.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key, required this.qrContext});

  final QRContext qrContext;

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _hasRedirected = false;

  void _navigateToSuccess(String code) {
    if (_hasRedirected || !mounted) return;

    setState(() => _hasRedirected = true);
    controller?.pauseCamera();

    switch (widget.qrContext) {
      case QRContext.chats:
        _handleChatScan(code);
        break;
      case QRContext.community:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CommunityWelcomeScreen(qrCode: code),
          ),
        );
        break;

      case QRContext.event:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EventCheckinScreen(qrCode: code),
          ),
        ).then((_) {
          // If they come back, reset the camera
          if (mounted) {
            setState(() => _hasRedirected = false);
            controller?.resumeCamera();
          }
        });
        break;
    }
  }

  Future<void> _handleChatScan(String qrCode) async {
    final result = await CustomHttp.post(
      endpoint: ApiConstant.scanWaveMeetupQR,
      body: {'qr_code_value': qrCode},
    );

    if (result.ok && result.data != null && mounted) {
      final scanResult = ScanResult.fromJson(result.data['data'] as Map<String, dynamic>? ?? {});
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ScanSuccessScreen(scanResult: scanResult),
        ),
      );
    } else if (mounted) {
      setState(() => _hasRedirected = false);
      controller?.resumeCamera();
    }
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) controller!.pauseCamera();
    controller!.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null) {
        _navigateToSuccess(scanData.code!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    String instructionText;
    switch (widget.qrContext) {
      case QRContext.chats:
        instructionText = loc.translate('scanChatQR');
        break;
      case QRContext.community:
        instructionText = loc.translate('scanCommunityQR');
        break;
      case QRContext.event:
        instructionText = loc.translate('scanEventQR');
        break;
    }

    return Scaffold(
      appBar: AppBar(title: Text('${loc.translate('scanName')} ${widget.qrContext.name}')),
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.greenAccent,
              borderRadius: 20,
              borderLength: 40,
              borderWidth: 10,
              cutOutSize: 280,
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  instructionText,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// // --- Success Screen ---
// class SuccessScreen extends StatelessWidget {
//   final String data;
//   const SuccessScreen({super.key, required this.data});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.check_circle_outline,
//               color: Colors.green,
//               size: 120,
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               "Success!",
//               style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Text("Data: $data"),
//             const SizedBox(height: 40),
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("Go Back"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
