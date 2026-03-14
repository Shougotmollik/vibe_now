import 'dart:async'; // Required for Timer
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:vibe_now/views/event/event_checkin_screen.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Timer? _demoTimer;
  bool _hasRedirected = false;

  @override
  void initState() {
    super.initState();
    // DEMO REDIRECT
    _demoTimer = Timer(const Duration(seconds: 5), () {
      _navigateToSuccess("Demo Mode: 5 Seconds Elapsed");
    });
  }

  void _navigateToSuccess(String code) {
    if (_hasRedirected || !mounted) return;

    setState(() => _hasRedirected = true);
    _demoTimer?.cancel();
    controller?.pauseCamera();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventCheckinScreen()),
    ).then((_) {
      setState(() => _hasRedirected = false);
      controller?.resumeCamera();
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) controller!.pauseCamera();
    controller!.resumeCamera();
  }

  @override
  void dispose() {
    _demoTimer?.cancel();
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
    return Scaffold(
      appBar: AppBar(title: const Text('Scanning...')),
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
          // Visual countdown for the demo
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
                child: const Text(
                  "Demo: Redirecting in 5 seconds...",
                  style: TextStyle(color: Colors.white),
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
