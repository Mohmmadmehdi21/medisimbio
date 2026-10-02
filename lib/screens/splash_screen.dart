import 'dart:async';
import 'package:flutter/material.dart';
import 'package:medisimbio_ui/screens/auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _timer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();

    // Auto navigate after 2.5 seconds
    _timer = Timer(const Duration(milliseconds: 2500), _navigateToNextScreen);
  }

  void _navigateToNextScreen() {
    if (_navigated || !mounted) return;
    _navigated = true;
    _timer?.cancel();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthWrapper(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F8),
      body: GestureDetector(
        onTap: _navigateToNextScreen,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Topographic Wave Decor Background matching reference image 1.1
            const Positioned.fill(
              child: CustomPaint(
                painter: SplashWaveBackgroundPainter(),
              ),
            ),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const Spacer(flex: 3),

                        // Logo Image from assets
                        Image.asset(
                          'assets/images/splash_screen_logo.png',
                          width: 130,
                          height: 100,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const SizedBox(
                              width: 80,
                              height: 72,
                              child: CustomPaint(
                                painter: CaduceusEmblemPainter(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        // Brand Title: "Medisimbiõ"
                        const Text(
                          'Medisimbiõ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 45,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            color: Color(0xFF087F73),
                            fontFamily: 'serif',
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Subtitle: "MEDICAL SYMBIOSIS"
                        const Text(
                          'MEDICAL SYMBIOSIS',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 4.9,
                            color: Color(0xFF087F73),
                          ),
                        ),

                        const Spacer(flex: 4),

                        // Tagline: "Connecting\nHealthcare\nAround You"
                        const Text(
                          'Connecting\nHealthcare\nAround You',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 27,
                            height: 1.25,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF087F73),
                          ),
                        ),

                        const Spacer(flex: 4),

                        // 4 Indicator Dots at Bottom (1st active pill, 3 inactive circles)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 20,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFF087F73),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFC0E0DA),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFC0E0DA),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFC0E0DA),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CADUCEUS LOGO EMBLEM PAINTER (FALLBACK)
// ============================================================================

class CaduceusEmblemPainter extends CustomPainter {
  const CaduceusEmblemPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final tealPaint = Paint()
      ..color = const Color(0xFF087F73)
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final linePaint = Paint()
      ..color = const Color(0xFF087F73)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final double width = size.width;
    final double height = size.height;
    final double centerX = width / 2;

    // Central Vertical Staff
    canvas.drawLine(
      Offset(centerX, height * 0.22),
      Offset(centerX, height * 0.90),
      linePaint,
    );

    // Top Sphere / Ball on staff
    canvas.drawCircle(Offset(centerX, height * 0.16), width * 0.07, tealPaint);

    // Symmetrical Wings at Top
    final wingPath = Path();
    // Left Wing
    wingPath.moveTo(centerX - 3, height * 0.28);
    wingPath.cubicTo(
      centerX - width * 0.35,
      height * 0.10,
      centerX - width * 0.48,
      height * 0.40,
      centerX - 6,
      height * 0.46,
    );
    wingPath.cubicTo(
      centerX - width * 0.30,
      height * 0.35,
      centerX - width * 0.20,
      height * 0.22,
      centerX - 3,
      height * 0.28,
    );

    // Right Wing
    wingPath.moveTo(centerX + 3, height * 0.28);
    wingPath.cubicTo(
      centerX + width * 0.35,
      height * 0.10,
      centerX + width * 0.48,
      height * 0.40,
      centerX + 6,
      height * 0.46,
    );
    wingPath.cubicTo(
      centerX + width * 0.30,
      height * 0.35,
      centerX + width * 0.20,
      height * 0.22,
      centerX + 3,
      height * 0.28,
    );

    canvas.drawPath(wingPath, tealPaint);

    // Entwined Serpents (Double helical loop)
    final snakePaint = Paint()
      ..color = const Color(0xFF087F73)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;

    final snakePath1 = Path();
    snakePath1.moveTo(centerX, height * 0.85);
    snakePath1.quadraticBezierTo(
      centerX - width * 0.22,
      height * 0.70,
      centerX,
      height * 0.56,
    );
    snakePath1.quadraticBezierTo(
      centerX + width * 0.22,
      height * 0.42,
      centerX,
      height * 0.32,
    );

    final snakePath2 = Path();
    snakePath2.moveTo(centerX, height * 0.85);
    snakePath2.quadraticBezierTo(
      centerX + width * 0.22,
      height * 0.70,
      centerX,
      height * 0.56,
    );
    snakePath2.quadraticBezierTo(
      centerX - width * 0.22,
      height * 0.42,
      centerX,
      height * 0.32,
    );

    canvas.drawPath(snakePath1, snakePaint);
    canvas.drawPath(snakePath2, snakePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// TOPOGRAPHIC WAVY BACKGROUND PAINTER
// ============================================================================

class SplashWaveBackgroundPainter extends CustomPainter {
  const SplashWaveBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Mint contour wave lines
    final mintPaint = Paint()
      ..color = const Color(0xFFBCE3DC).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final lightMintPaint = Paint()
      ..color = const Color(0xFFD6EFEA).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Golden wave lines top right
    final goldPaint = Paint()
      ..color = const Color(0xFFE09A3A).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // 1. TOP-LEFT MINT WAVES
    for (int i = 0; i < 4; i++) {
      final path = Path();
      final double offset = i * 16.0;
      path.moveTo(0, height * 0.08 + offset);
      path.cubicTo(
        width * 0.15,
        height * 0.04 + offset,
        width * 0.25,
        height * 0.18 + offset,
        width * 0.40,
        height * 0.12 + offset,
      );
      path.cubicTo(
        width * 0.50,
        height * 0.08 + offset,
        width * 0.35,
        0,
        width * 0.20,
        0,
      );
      canvas.drawPath(path, i % 2 == 0 ? mintPaint : lightMintPaint);
    }

    // 2. TOP-RIGHT GOLD WAVES
    for (int i = 0; i < 3; i++) {
      final path = Path();
      final double offset = i * 14.0;
      path.moveTo(width * 0.65, offset);
      path.cubicTo(
        width * 0.75,
        height * 0.08 + offset,
        width * 0.85,
        height * 0.04 + offset,
        width,
        height * 0.14 + offset,
      );
      canvas.drawPath(path, goldPaint);
    }

    // 3. BOTTOM-LEFT MINT CONTOUR WAVES
    for (int i = 0; i < 5; i++) {
      final path = Path();
      final double offset = i * 18.0;
      path.moveTo(0, height * 0.75 + offset);
      path.cubicTo(
        width * 0.20,
        height * 0.70 + offset,
        width * 0.25,
        height * 0.88 + offset,
        width * 0.45,
        height * 0.82 + offset,
      );
      path.cubicTo(
        width * 0.60,
        height * 0.76 + offset,
        width * 0.30,
        height,
        width * 0.10,
        height,
      );
      canvas.drawPath(path, i % 2 == 0 ? mintPaint : lightMintPaint);
    }

    // 4. BOTTOM-RIGHT MINT CONTOUR WAVES
    for (int i = 0; i < 5; i++) {
      final path = Path();
      final double offset = i * 18.0;
      path.moveTo(width * 0.40, height + offset);
      path.cubicTo(
        width * 0.55,
        height * 0.82 + offset,
        width * 0.75,
        height * 0.90 + offset,
        width,
        height * 0.72 + offset,
      );
      canvas.drawPath(path, i % 2 == 0 ? mintPaint : lightMintPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
