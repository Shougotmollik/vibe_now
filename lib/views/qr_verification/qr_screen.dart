import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:vibe_now/core/constant/qrcontext_enum.dart';
import 'package:vibe_now/core/routes/route_names.dart';
import 'package:vibe_now/model/chat.dart';
import 'package:vibe_now/views/chat/chat_inbox_screen.dart';
import 'package:vibe_now/views/community/community_welcome_screen.dart';
import 'package:vibe_now/views/event/event_checkin_screen.dart';

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
        // Navigator.pop(context, code);
        // Navigator.pop(context, code);
        context.pushNamed(
          RouteNames.chatInboxScreen,
          extra: Chat(
            avatars: ['https://randomuser.me/api/portraits/women/12.jpg'],
            name: 'Sammy Smith',
            message: 'Sent you a wave!',
            time: '10:30 AM',
            type: ChatType.wave,
          ),
        );
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
    String instructionText;
    switch (widget.qrContext) {
      case QRContext.chats:
        instructionText = "Scan a chat QR code to connect";
        break;
      case QRContext.community:
        instructionText = "Scan a community QR code to join";
        break;
      case QRContext.event:
        instructionText = "Scan event QR code to check in";
        break;
    }

    return Scaffold(
      appBar: AppBar(title: Text('Scan ${widget.qrContext.name}')),
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
