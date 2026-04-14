import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loadingSignIn = false;
  bool _loadingSignUp = false;

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
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters.')),
      );
      return;
    }
    setState(() {
      _loadingSignIn = true;
    });
    try {
      final user =
          await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
      if (user != null) {
        context.go('/notes_list');
      } else {
        throw Exception('Authentication failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign In error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _loadingSignIn = false;
      });
    }
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters.')),
      );
      return;
    }
    setState(() {
      _loadingSignUp = true;
    });
    try {
      final user =
          await Supabase.instance.client.auth.signUp(email: email, password: password);
      if (user != null) {
        context.go('/notes_list');
      } else {
        throw Exception('Sign Up failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign Up error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _loadingSignUp = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color _darkBg = Color(0xFF1A1A2E);
    const Color _headerText = Color(0xFF6366F1);
    const Color _subHeaderText = Color(0xFF9CA3AF);
    const Color _infoText = Color(0xFF4B5563);
    const Color _inputBg = Color(0xFFF8FAFC);
    const Color _dividerColor = Color(0xFFE5E7EB);
    const Color _footerText = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Dark header background
          Positioned(
            left: 0,
            top: 0,
            width: 390,
            height: 220,
            child: Container(color: _darkBg),
          ),
          // Header text
          Positioned(
            left: 80,
            top: 72,
            width: 300,
            height: 48,
            child: Text(
              'Notes',
              style: TextStyle(
                color: _headerText,
                fontSize: 40,
                fontWeight: FontWeight.bold,
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
                color: _subHeaderText,
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
                color: _infoText,
                fontSize: 12,
              ),
            ),
          ),
          // Email input background
          Positioned(
            left: 30,
            top: 240,
            width: 330,
            height: 52,
            child: Container(
              color: _inputBg,
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email address',
                  hintStyle: TextStyle(color: _subHeaderText),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              color: _inputBg,
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: TextStyle(color: _subHeaderText),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
          ),
          // Sign In button
          Positioned(
            left: 30,
            top: 384,
            width: 330,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _headerText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _loadingSignIn ? null : _signIn,
              child: _loadingSignIn
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Sign In',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ),
          // Divider
          Positioned(
            left: 60,
            top: 456,
            width: 270,
            height: 1,
            child: Container(color: _dividerColor),
          ),
          // "or" text
          Positioned(
            left: 150,
            top: 466,
            width: 90,
            height: 20,
            child: Text(
              'or',
              style: TextStyle(
                color: _subHeaderText,
                fontSize: 12,
              ),
            ),
          ),
          // Create account button
          Positioned(
            left: 30,
            top: 490,
            width: 330,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _inputBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _loadingSignUp ? null : _signUp,
              child: _loadingSignUp
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.black54, strokeWidth: 2),
                    )
                  : Text(
                      'Create account',
                      style: TextStyle(color: _headerText, fontSize: 16),
                    ),
            ),
          ),
          // Terms text
          Positioned(
            left: 80,
            top: 570,
            width: 300,
            height: 19,
            child: Text(
              'By continuing, you agree to our Terms',
              style: TextStyle(color: _footerText, fontSize: 11),
            ),
          ),
        ],
      );
  }
}