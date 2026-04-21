import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _signIn() {
    if (!mounted) return;
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              SizedBox(height: 60),
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text('✓', style: TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 24),
              const Text('TaskFlow', style: TextStyle(color: Color(0xFFF8FAFC), fontSize: 30, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              const Text('Plan your day. Get it done.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              SizedBox(height: 48),
              Align(alignment: Alignment.centerLeft, child: const Text('Email', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12))),
              SizedBox(height: 6),
              TextField(
                controller: _emailCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'you@email.com',
                  hintStyle: const TextStyle(color: Color(0xFF475569)),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              SizedBox(height: 20),
              Align(alignment: Alignment.centerLeft, child: const Text('Password', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12))),
              SizedBox(height: 6),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: const TextStyle(color: Color(0xFF475569)),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Sign In', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 24),
              Row(children: [
                Expanded(child: Divider(color: const Color(0xFF334155))),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: const Text('or', style: TextStyle(color: Color(0xFF475569), fontSize: 12))),
                Expanded(child: Divider(color: const Color(0xFF334155))),
              ]),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 52,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF334155), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Create Account', style: TextStyle(color: Color(0xFF93C5FD), fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              SizedBox(height: 40),
              const Text('By continuing, you agree to our Terms', style: TextStyle(color: Color(0xFF475569), fontSize: 11)),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
