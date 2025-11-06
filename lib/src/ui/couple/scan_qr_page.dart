import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrPage extends StatefulWidget {
  const ScanQrPage({super.key});

  @override
  State<ScanQrPage> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan invite QR')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            onDetect: (capture) {
              if (_done) return;
              final barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;
              final value = barcodes.first.rawValue;
              if (value == null || value.isEmpty) return;
              _done = true;
              Navigator.of(context).pop(value);
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Point the camera at your partner’s invite QR',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  shadows: const [Shadow(blurRadius: 3, color: Colors.black)],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
