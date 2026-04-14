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
  bool _isSignIn = true;
  bool _loading = false;

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email.')));
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters.')));
      return;
    }
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
      context.go('/notes_list');
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email.')));
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters.')));
      return;
    }
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.auth.signUp(email: email, password: password);
      context.go('/notes_list');
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background dark rect
          Positioned(
            left: 0,
            top: 0,
            width: 390,
            height: 220,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Color(0xFF1A1A2E)),
            ),
          ),
          // "Notes" title
          Positioned(
            left: 80,
            top: 72,
            child: Text('Notes',
                style: TextStyle(
                    color: Color(0xFF6366F1),
                    fontSize: 40,
                    fontWeight: FontWeight.bold))),
          // Subtitle
          Positioned(
            left: 80,
            top: 126,
            child: Text('Your thoughts, organized',
                style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 14))),
          // Tagline
          Positioned(
            left: 80,
            top: 158,
            child: Text('Simple · Private · Synced',
                style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 12))),
          // Email input background
          Positioned(
            left: 30,
            top: 240,
            width: 330,
            height: 52,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email address',
                    hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          // Password input background
          Positioned(
            left: 30,
            top: 308,
            width: 330,
            height: 52,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
          // Sign In / Create Account button
          Positioned(
            left: 30,
            top: _isSignIn ? 384 : 490,
            width: 330,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSignIn ? _signIn : _signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_isSignIn ? 14 : 14),
                ),
              ),
              child: Text(
                _isSignIn ? 'Sign In' : 'Create account',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          // Divider line
          Positioned(
            left: 60,
            top: 456,
            width: 270,
            height: 1,
            child: Divider(
              color: Color(0xFFE5E7EB),
              thickness: 1,
            ),
          ),
          // "or"
          Positioned(
            left: 150,
            top: 466,
            child: Text('or',
                style: TextStyle(
                    color: Color(0xFF9CA3AF), fontSize: 12))),
          // Terms
          Positioned(
            left: 80,
            top: 570,
            child: Text('By continuing, you agree to our Terms',
                style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11))),
          // Toggle button
          Positioned(
            left: 80,
            top: 620,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _isSignIn = !_isSignIn;
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              child: Text(
                _isSignIn
                    ? "Don't have an account? Sign Up"
                    : "Already have an account? Sign In",
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          if (_loading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      );
  }
}