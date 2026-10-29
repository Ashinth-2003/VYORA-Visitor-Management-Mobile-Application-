import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../theme/app_theme.dart';

/// QR code on a white tile. The code itself is always black on white,
/// gold or inverted codes are hard for cameras to read.
class QrBox extends StatelessWidget {
  const QrBox({super.key, required this.data, this.size = 180});

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: .3),
            blurRadius: 24,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: data.isEmpty
            ? SizedBox(
                width: size,
                height: size,
                child: const Center(
                  child: Text(
                    'No pass id',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              )
            : QrImageView(
                data: data,
                size: size,
                padding: EdgeInsets.zero,
                backgroundColor: Colors.white,
              ),
      ),
    );
  }
}
