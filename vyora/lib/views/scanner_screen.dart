import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../controllers/visitor_controller.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'visitor_details_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _scanner = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );
  late final AnimationController _laser = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  // True while a code is being checked, so the same scan is not handled twice.
  bool _isHandling = false;
  bool _torchOn = false;
  String? _errorMessage;

  @override
  void dispose() {
    _laser.dispose();
    _scanner.dispose();
    super.dispose();
  }

  Future<void> _toggleTorch() async {
    try {
      await _scanner.toggleTorch();
      if (mounted) setState(() => _torchOn = !_torchOn);
    } catch (_) {
      // Some devices have no flashlight.
      if (mounted) {
        setState(() => _errorMessage = 'Flashlight is not available on this device.');
      }
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isHandling || capture.barcodes.isEmpty) return;
    _handleCode(capture.barcodes.first.rawValue);
  }

  Future<void> _pickImage() async {
    if (_isHandling) return;
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final result = await _scanner.analyzeImage(picked.path);
    if (!mounted) return;
    if (result == null || result.barcodes.isEmpty) {
      setState(() => _errorMessage = 'No QR code found in that image.');
      return;
    }
    _handleCode(result.barcodes.first.rawValue);
  }

  Future<void> _handleCode(String? value) async {
    _isHandling = true;
    setState(() => _errorMessage = null);

    // Visitor ids are letters, numbers, "-" and "_". Anything else is not our QR.
    final id = value?.trim() ?? '';
    if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(id)) {
      _showError('Invalid QR code. This is not a VYORA visitor pass.');
      return;
    }

    try {
      final visitor = await context.read<VisitorController>().findVisitor(id);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VisitorDetailsScreen(visitorId: visitor.id),
        ),
      );
      _isHandling = false;
    } on AppException catch (e) {
      _showError(e.notFound ? 'Visitor not found for this QR code.' : e.message);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() => _errorMessage = message);
    // Wait a moment before accepting another scan, so the same bad code
    // that is still in front of the camera does not trigger it again.
    Future.delayed(const Duration(seconds: 2), () => _isHandling = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        leading: Padding(
          padding: const EdgeInsets.all(6),
          child: IconButton.filledTonal(
            style: IconButton.styleFrom(backgroundColor: Colors.black54),
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          'Scan visitor pass',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(6),
            child: IconButton.filledTonal(
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
              tooltip: 'Flashlight',
              icon: Icon(
                _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                color: _torchOn ? AppColors.goldLight : Colors.white,
              ),
              onPressed: _toggleTorch,
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _scanner, onDetect: _onDetect),
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _laser,
              builder: (context, _) => CustomPaint(
                painter: _ScanFramePainter(progress: _laser.value),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _BottomPanel(
                  errorMessage: _errorMessage,
                  onUpload: _pickImage,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({required this.errorMessage, required this.onUpload});

  final String? errorMessage;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: (hasError ? Colors.redAccent : AppColors.gold).withValues(
            alpha: .5,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            hasError ? errorMessage! : 'Point the camera at a visitor QR code',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: hasError ? Colors.redAccent.shade100 : Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Upload QR from gallery'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.goldLight,
                side: const BorderSide(color: AppColors.gold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dark overlay with a square cut-out, gold corners and a moving line.
class _ScanFramePainter extends CustomPainter {
  _ScanFramePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.width * .7;
    final frame = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * .4),
      width: side,
      height: side,
    );
    final rounded = RRect.fromRectAndRadius(frame, const Radius.circular(24));

    final overlay = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()..addRRect(rounded),
    );
    canvas.drawPath(overlay, Paint()..color = Colors.black54);

    final corner = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    const length = 30.0;

    // top-left, top-right, bottom-left, bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(frame.left, frame.top + length)
        ..lineTo(frame.left, frame.top)
        ..lineTo(frame.left + length, frame.top),
      corner,
    );
    canvas.drawPath(
      Path()
        ..moveTo(frame.right - length, frame.top)
        ..lineTo(frame.right, frame.top)
        ..lineTo(frame.right, frame.top + length),
      corner,
    );
    canvas.drawPath(
      Path()
        ..moveTo(frame.left, frame.bottom - length)
        ..lineTo(frame.left, frame.bottom)
        ..lineTo(frame.left + length, frame.bottom),
      corner,
    );
    canvas.drawPath(
      Path()
        ..moveTo(frame.right - length, frame.bottom)
        ..lineTo(frame.right, frame.bottom)
        ..lineTo(frame.right, frame.bottom - length),
      corner,
    );

    final y = frame.top + 12 + (frame.height - 24) * progress;
    canvas.drawLine(
      Offset(frame.left + 14, y),
      Offset(frame.right - 14, y),
      Paint()
        ..color = AppColors.goldLight
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanFramePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
