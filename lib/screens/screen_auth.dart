import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSignInMode = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid email')));
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password must be at least 6 characters')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (!mounted) return;
      context.go('/notes_list');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid email')));
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password must be at least 6 characters')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signUp(email: email, password: password);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Sign up successful, please sign in')));
      setState(() => _isSignInMode = true);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 0,
            top: 0,
            width: 390,
            height: 220,
            child: Container(color: const Color(0xFF1A1A2E)),
          ),
          Positioned(
            left: 80,
            top: 72,
            width: 300,
            height: 48,
            child: Text(
              'Notes',
              style: TextStyle(
                color: const Color(0xFF6366F1),
                fontSize: 40,
              ),
            ),
          ),
          Positioned(
            left: 80,
            top: 126,
            width: 300,
            height: 22,
            child: Text(
              'Your thoughts, organized',
              style: TextStyle(
                color: const Color(0xFF9CA3AF),
                fontSize: 14,
              ),
            ),
          ),
          Positioned(
            left: 80,
            top: 158,
            width: 300,
            height: 20,
            child: Text(
              'Simple · Private · Synced',
              style: TextStyle(
                color: const Color(0xFF4B5563),
                fontSize: 12,
              ),
            ),
          ),
          Positioned(
            left: 30,
            top: 240,
            width: 330,
            height: 52,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ),
          Positioned(
            left: 52,
            top: 258,
            width: 300,
            height: 22,
            child: Text(
              'Email address',
              style: TextStyle(
                color: const Color(0xFF9CA3AF),
                fontSize: 14,
              ),
            ),
          ),
          Positioned(
            left: 30,
            top: 308,
            width: 330,
            height: 52,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ),
          Positioned(
            left: 52,
            top: 326,
            width: 300,
            height: 22,
            child: Text(
              'Password',
              style: TextStyle(
                color: const Color(0xFF9CA3AF),
                fontSize: 14,
              ),
            ),
          ),
          if (_isSignInMode)
            Positioned(
              left: 30,
              top: 384,
              width: 330,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _signIn,
                child: const Text(
                  'Sign In',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          if (!_isSignInMode)
            Positioned(
              left: 30,
              top: 490,
              width: 330,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _signUp,
                child: const Text(
                  'Create account',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          Positioned(
            left: 60,
            top: 456,
            width: 270,
            height: 1,
            child: Container(color: const Color(0xFFE5E7EB)),
          ),
          Positioned(
            left: 150,
            top: 466,
            width: 90,
            height: 20,
            child: Text(
              'or',
              style: TextStyle(
                color: const Color(0xFF9CA3AF),
                fontSize: 12,
              ),
            ),
          ),
          Positioned(
            left: 80,
            top: 540,
            width: 230,
            height: 24,
            child: TextButton(
              onPressed: () {
                setState(() => _isSignInMode = !_isSignInMode);
              },
              child: Text(
                _isSignInMode
                    ? "Don't have an account? Sign Up"
                    : "Already have an account? Sign In",
                style: const TextStyle(
                  color: Color(0xFF6366F1),
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Positioned(
            left: 80,
            top: 570,
            width: 300,
            height: 19,
            child: Text(
              'By continuing, you agree to our Terms',
              style: TextStyle(
                color: const Color(0xFF6B7280),
                fontSize: 11,
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ));
  }
}