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

  void _signIn() {
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient rectangle
          Positioned(
            left: 0,
            top: 0,
            width: 390,
            height: 844,
            child: Container(color: const Color(0xFF0F172A)),
          ),
          // Top header rectangle
          Positioned(
            left: 0,
            top: 0,
            width: 390,
            height: 320,
            child: Container(color: const Color(0xFF1E293B)),
          ),
          // Blue circle
          Positioned(
            left: 115,
            top: 40,
            width: 80,
            height: 80,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),
          // Check mark
          Positioned(
            left: 155,
            top: 88,
            width: 80,
            height: 64,
            child: const Text(
              '✓',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 44,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // TaskFlow title
          Positioned(
            left: 95,
            top: 180,
            width: 200,
            height: 36,
            child: const Text(
              'TaskFlow',
              style: TextStyle(
                color: Color(0xFFF8FAFC),
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Subtitle
          Positioned(
            left: 95,
            top: 220,
            width: 200,
            height: 20,
            child: const Text(
              'Plan your day. Get it done.',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
              ),
            ),
          ),
          // Email label
          Positioned(
            left: 32,
            top: 360,
            width: 200,
            height: 18,
            child: const Text(
              'Email',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
              ),
            ),
          ),
          // Email input field
          Positioned(
            left: 32,
            top: 382,
            width: 326,
            height: 50,
            child: TextField(
              controller: _emailController,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintText: 'you@email.com',
                hintStyle: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Password label
          Positioned(
            left: 32,
            top: 450,
            width: 200,
            height: 18,
            child: const Text(
              'Password',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
              ),
            ),
          ),
          // Password input field
          Positioned(
            left: 32,
            top: 472,
            width: 326,
            height: 50,
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintText: '••••••••',
                hintStyle: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide.none,
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
            child: ElevatedButton(
              onPressed: _signIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
            child: const Divider(
              color: Color(0xFF334155),
              thickness: 1,
            ),
          ),
          // "or" text
          Positioned(
            left: 155,
            top: 650,
            width: 80,
            height: 18,
            child: const Text(
              'or',
              style: TextStyle(
                color: Color(0xFF475569),
                fontSize: 12,
              ),
            ),
          ),
          // Create Account button placeholder
          Positioned(
            left: 32,
            top: 684,
            width: 326,
            height: 52,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
              ),
              child: const Text(
                'Create Account',
                style: TextStyle(
                  color: Color(0xFF93C5FD),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Terms text
          Positioned(
            left: 70,
            top: 780,
            width: 250,
            height: 16,
            child: const Text(
              'By continuing, you agree to our Terms',
              style: TextStyle(
                color: Color(0xFF475569),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ));
  }
}