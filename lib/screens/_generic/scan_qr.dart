import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wallet/components/buttons/icon.dart';
import 'package:wallet/logger.dart';
import 'package:wallet/styling.dart';

class QRScreen extends StatefulWidget {
  const QRScreen({super.key});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool popped = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: _buildQrView(context)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  'Scan a QR code',
                  style: GTextStyles.mulishBoldAlert,
                ),
                const SizedBox(height: 12),
                SafeArea(
                  top: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: GIconButton(
                          onPressed: () async {
                            cameraController.toggleTorch();
                          },
                          icon: LucideIcons.flashlight,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: GIconButton(
                          icon: LucideIcons.x,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: GIconButton(
                          icon: LucideIcons.switchCamera,
                          onPressed: () async {
                            cameraController.switchCamera();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    return MobileScanner(
      controller: cameraController,
      onDetect: (barcodes) {
        if (barcodes.barcodes.isEmpty) return;

        for (final code in barcodes.barcodes) {
          if (code.rawValue == null) {
            logger.e('Failed to scan Barcode');
          } else {
            if (popped) return;
            setState(() {
              popped = true;
            });
            Navigator.of(context).pop(code.rawValue);
          }
        }
      },
    );
  }
}