import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToDashboard() {
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background rect
          Positioned(
            left: 0,
            top: 0,
            width: 390,
            height: 844,
            child: Container(
              color: const Color(0xFF0f172a),
            ),
          ),
          // Top overlay rect
          Positioned(
            left: 0,
            top: 0,
            width: 390,
            height: 320,
            child: Container(
              color: const Color(0xFF1e293b),
            ),
          ),
          // Circle
          Positioned(
            left: 155,
            top: 80,
            width: 80,
            height: 80,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF3b82f6),
              ),
            ),
          ),
          // Tick text
          Positioned(
            left: 155,
            top: 88,
            child: Text(
              '✓',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 44,
              ),
            ),
          ),
          // Title
          Positioned(
            left: 95,
            top: 180,
            child: SizedBox(
              width: 200,
              child: Text(
                'TaskFlow',
                style: const TextStyle(
                  color: Color(0xFFf8fafc),
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Subtitle
          Positioned(
            left: 95,
            top: 220,
            child: SizedBox(
              width: 200,
              child: Text(
                'Plan your day. Get it done.',
                style: const TextStyle(
                  color: Color(0xFF64748b),
                  fontSize: 13,
                ),
              ),
            ),
          ),
          // Email label
          Positioned(
            left: 32,
            top: 360,
            child: Text(
              'Email',
              style: const TextStyle(
                color: Color(0xFF94a3b8),
                fontSize: 12,
              ),
            ),
          ),
          // Email input background
          Positioned(
            left: 32,
            top: 382,
            width: 326,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF1e293b),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: TextField(
                controller: _emailController,
                style: const TextStyle(
                  color: Color(0xFF475569),
                ),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'you@email.com',
                  hintStyle: TextStyle(
                    color: Color(0xFF475569),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ),
          // Password label
          Positioned(
            left: 32,
            top: 450,
            child: Text(
              'Password',
              style: const TextStyle(
                color: Color(0xFF94a3b8),
                fontSize: 12,
              ),
            ),
          ),
          // Password input background
          Positioned(
            left: 32,
            top: 472,
            width: 326,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF1e293b),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(
                  color: Color(0xFF475569),
                ),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: TextStyle(
                    color: Color(0xFF475569),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ),
          // Sign In button
          Positioned(
            left: 32,
            top: 556,
            width: 326,
            height: 52,
            child: SizedBox(
              width: 326,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3b82f6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _navigateToDashboard,
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          // Divider line
          Positioned(
            left: 80,
            top: 640,
            width: 230,
            height: 1,
            child: Container(
              color: const Color(0xFF334155),
            ),
          ),
          // Or text
          Positioned(
            left: 155,
            top: 650,
            child: Text(
              'or',
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 12,
              ),
            ),
          ),
          // Create Account text
          Positioned(
            left: 32,
            top: 698,
            child: Text(
              'Create Account',
              style: const TextStyle(
                color: Color(0xFF93c5fd),
                fontSize: 16,
              ),
            ),
          ),
          // Terms text
          Positioned(
            left: 70,
            top: 780,
            child: Text(
              'By continuing, you agree to our Terms',
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ));
  }
}