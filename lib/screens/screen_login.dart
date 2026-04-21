import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
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
    if (!mounted) return;
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full screen dark background
          Positioned(
            left: 0,
            top: 0,
            width: 390,
            height: 844,
            child: Container(
              color: const Color(0xFF0F172A),
            ),
          ),
          // Header rectangle
          Positioned(
            left: 0,
            top: 0,
            width: 390,
            height: 320,
            child: Container(
              color: const Color(0xFF1E293B),
            ),
          ),
          // Circular icon
          Positioned(
            left: 155,
            top: 80,
            width: 80,
            height: 80,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF3B82F6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Check mark text
          Positioned(
            left: 155,
            top: 88,
            width: 80,
            height: 64,
            child: Center(
              child: Text(
                '✓',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                ),
              ),
            ),
          ),
          // App title
          Positioned(
            left: 95,
            top: 180,
            width: 200,
            height: 36,
            child: Text(
              'TaskFlow',
              style: const TextStyle(
                color: Color(0xFFF8FAFC),
                fontSize: 30,
              ),
            ),
          ),
          // Subtitle
          Positioned(
            left: 95,
            top: 220,
            width: 200,
            height: 20,
            child: Text(
              'Plan your day. Get it done.',
              style: const TextStyle(
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
            child: Text(
              'Email',
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
              ),
            ),
          ),
          // Email input container
          Positioned(
            left: 32,
            top: 382,
            width: 326,
            height: 50,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: TextField(
                controller: _emailController,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'you@email.com',
                  hintStyle: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            child: Text(
              'Password',
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
              ),
            ),
          ),
          // Password input container
          Positioned(
            left: 32,
            top: 472,
            width: 326,
            height: 50,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            child: GestureDetector(
              onTap: _signIn,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
                child: Center(
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
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
            width: 80,
            height: 18,
            child: Center(
              child: Text(
                'or',
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 12,
                ),
              ),
            ),
          ),
          // Create Account (non-interactive)
          Positioned(
            left: 32,
            top: 698,
            width: 326,
            height: 24,
            child: Center(
              child: Text(
                'Create Account',
                style: const TextStyle(
                  color: Color(0xFF93C5FD),
                  fontSize: 16,
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
            child: Center(
              child: Text(
                'By continuing, you agree to our Terms',
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ));
  }
}