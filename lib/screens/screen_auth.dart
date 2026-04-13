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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid email address')));
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 6 characters')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client
          .auth.signInWithPassword(email: email, password: password);
      setState(() => _isLoading = false);
      context.go('/notes_list');
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid email address')));
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password must be at least 6 characters')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client
          .auth.signUp(email: email, password: password);
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign up successful. Please sign in.')));
      setState(() => _isSignInMode = true);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    const double canvasWidth = 390;
    const double canvasHeight = 844;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        width: canvasWidth,
        height: canvasHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Header background
            Positioned(
              left: 0,
              top: 0,
              width: 390,
              height: 220,
              child: Container(color: const Color(0xFF1A1A2E)),
            ),
            // Title
            Positioned(
              left: 80,
              top: 72,
              child: const Text(
                'Notes',
                style: TextStyle(color: Color(0xFF6366F1), fontSize: 40),
              ),
            ),
            // Subtitle
            Positioned(
              left: 80,
              top: 126,
              child: const Text(
                'Your thoughts, organized',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
              ),
            ),
            // Tagline
            Positioned(
              left: 80,
              top: 158,
              child: const Text(
                'Simple · Private · Synced',
                style: TextStyle(color: Color(0xFF4B5563), fontSize: 12),
              ),
            ),
            // Email input container
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
                    hintText: 'Email address',
                    hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                  ),
                ),
              ),
            ),
            // Password input container
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
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                  ),
                ),
              ),
            ),
            // Sign In / Create Account button
            Positioned(
              left: 30,
              top: _isSignInMode ? 384 : 490,
              width: 330,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  minimumSize: const Size(330, 52),
                ),
                onPressed: _isLoading
                    ? null
                    : () {
                        if (_isSignInMode) {
                          _signIn();
                        } else {
                          _signUp();
                        }
                      },
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isSignInMode ? 'Sign In' : 'Create account',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
            // Divider line
            Positioned(
              left: 60,
              top: 456,
              width: 270,
              child: const Divider(
                color: Color(0xFFE5E7EB),
                thickness: 1,
              ),
            ),
            // 'or' text
            Positioned(
              left: 150,
              top: 466,
              child: const Text(
                'or',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
              ),
            ),
            // Terms text
            Positioned(
              left: 80,
              top: 570,
              child: const Text(
                'By continuing, you agree to our Terms',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
              ),
            ),
            // Toggle mode TextButton
            Positioned(
              left: 260,
              top: 580,
              child: TextButton(
                onPressed: () => setState(() => _isSignInMode = !_isSignInMode),
                child: Text(
                  _isSignInMode ? 'Create account' : 'Sign In',
                  style: const TextStyle(color: Color(0xFF6366F1)),
                ),
              ),
            ),
          ],
        ),
      );
  }
}