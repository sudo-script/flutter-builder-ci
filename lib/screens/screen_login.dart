import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: 0.0, top: 0.0,
              child: Container(
                width: 390.0, height: 844.0,
                decoration: BoxDecoration(color: const Color(0xFF0F172A)),
              ),
            ),
            Positioned(
              left: 0.0, top: 0.0,
              child: Container(
                width: 390.0, height: 320.0,
                decoration: BoxDecoration(color: const Color(0xFF1E293B)),
              ),
            ),
            Positioned(
              left: 155.0, top: 80.0,
              child: Container(
                width: 80.0, height: 80.0,
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF3B82F6)),
              ),
            ),
            Positioned(
              left: 155.0, top: 88.0,
              child: SizedBox(
                width: 80.0,
                child: Text(
                  '✓',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 44.0, color: const Color(0xFFFFFFFF), fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Positioned(
              left: 95.0, top: 180.0,
              child: SizedBox(
                width: 200.0,
                child: Text(
                  'TaskFlow',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30.0, color: const Color(0xFFF8FAFC), fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Positioned(
              left: 95.0, top: 220.0,
              child: SizedBox(
                width: 200.0,
                child: Text(
                  'Plan your day. Get it done.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.0, color: const Color(0xFF64748B)),
                ),
              ),
            ),
            Positioned(
              left: 32.0, top: 360.0,
              child: SizedBox(
                width: 200.0,
                child: Text(
                  'Email',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 12.0, color: const Color(0xFF94A3B8)),
                ),
              ),
            ),
            Positioned(
              left: 32.0, top: 382.0,
              child: Container(
                width: 326.0, height: 50.0,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0), color: const Color(0xFF1E293B)),
              ),
            ),
            Positioned(
              left: 48.0, top: 398.0,
              child: SizedBox(
                width: 200.0,
                child: Text(
                  'you@email.com',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 14.0, color: const Color(0xFF475569)),
                ),
              ),
            ),
            Positioned(
              left: 32.0, top: 450.0,
              child: SizedBox(
                width: 200.0,
                child: Text(
                  'Password',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 12.0, color: const Color(0xFF94A3B8)),
                ),
              ),
            ),
            Positioned(
              left: 32.0, top: 472.0,
              child: Container(
                width: 326.0, height: 50.0,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0), color: const Color(0xFF1E293B)),
              ),
            ),
            Positioned(
              left: 48.0, top: 488.0,
              child: SizedBox(
                width: 200.0,
                child: Text(
                  '••••••••',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 14.0, color: const Color(0xFF475569)),
                ),
              ),
            ),
            Positioned(
              left: 32.0, top: 556.0,
              child: Container(
                width: 326.0, height: 52.0,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.0), color: const Color(0xFF3B82F6)),
              ),
            ),
            Positioned(
              left: 32.0, top: 570.0,
              child: SizedBox(
                width: 326.0,
                child: Text(
                  'Sign In',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.0, color: const Color(0xFFFFFFFF), fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Positioned(
              left: 80.0, top: 640.0,
              child: SizedBox(
                width: 230.0, height: 1.0,
                child: CustomPaint(
                  painter: _LinePainter(color: const Color(0xFF334155), strokeWidth: 1.0),
                ),
              ),
            ),
            Positioned(
              left: 155.0, top: 650.0,
              child: SizedBox(
                width: 80.0,
                child: Text(
                  'or',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.0, color: const Color(0xFF475569)),
                ),
              ),
            ),
            Positioned(
              left: 32.0, top: 684.0,
              child: Container(
                width: 326.0, height: 52.0,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.0), color: Colors.transparent, border: Border.all(color: const Color(0xFF334155), width: 1.5.0)),
              ),
            ),
            Positioned(
              left: 32.0, top: 698.0,
              child: SizedBox(
                width: 326.0,
                child: Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.0, color: const Color(0xFF93C5FD), fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Positioned(
              left: 70.0, top: 780.0,
              child: SizedBox(
                width: 250.0,
                child: Text(
                  'By continuing, you agree to our Terms',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.0, color: const Color(0xFF475569)),
                ),
              ),
            ),
          ],
        ),
    );
  }
}


class _LinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  const _LinePainter({required this.color, required this.strokeWidth});
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      Paint()..color = color..strokeWidth = strokeWidth..strokeCap = StrokeCap.round,
    );
  }
  @override bool shouldRepaint(_LinePainter old) => old.color != color || old.strokeWidth != strokeWidth;
}
