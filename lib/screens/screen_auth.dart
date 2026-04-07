import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  bool _isSignIn = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
  }

  Future<void> _signIn() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (!email.contains('@')) {
      _showError('Invalid email address.');
      return;
    }
    if (password.length < 6) {
      _showError('Password must be at least 6 characters.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      context.go('/notes_list');
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signUp() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (!email.contains('@')) {
      _showError('Invalid email address.');
      return;
    }
    if (password.length < 6) {
      _showError('Password must be at least 6 characters.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      context.go('/notes_list');
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Static background rect
          Positioned(
            left: 0,
            top: 0,
            width: 390,
            height: 220,
            child: Container(color: const Color(0xFF1A1A2E)),
          ),
          // Static texts
          Positioned(
            left: 80,
            top: 72,
            child: const Text(
              'Notes',
              style: TextStyle(fontSize: 40, color: Color(0xFF6366F1)),
            ),
          ),
          Positioned(
            left: 80,
            top: 126,
            child: const Text(
              'Your thoughts, organized',
              style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
            ),
          ),
          Positioned(
            left: 80,
            top: 158,
            child: const Text(
              'Simple · Private · Synced',
              style: TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
            ),
          ),
          // Email input background
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
            ),
          ),
          Positioned(
            left: 52,
            top: 258,
            child: const Text(
              'Email address',
              style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
            ),
          ),
          // Password input background
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
            ),
          ),
          Positioned(
            left: 52,
            top: 326,
            child: const Text(
              'Password',
              style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
            ),
          ),
          // Email TextField
          Positioned(
            left: 30,
            top: 240,
            width: 330,
            child: TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(border: InputBorder.none),
              style: const TextStyle(color: Colors.black),
            ),
          ),
          // Password TextField
          Positioned(
            left: 30,
            top: 308,
            width: 330,
            child: TextField(
              controller: _passwordCtrl,
              obscureText: true,
              decoration: const InputDecoration(border: InputBorder.none),
              style: const TextStyle(color: Colors.black),
            ),
          ),
          // Sign In button
          Positioned(
            left: 30,
            top: 384,
            width: 330,
            height: 52,
            child: _isSignIn
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isLoading ? null : _signIn,
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                  )
                : const SizedBox.shrink(),
          ),
          // Divider line
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
            child: const Text(
              'or',
              style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            ),
          ),
          // Create Account button
          Positioned(
            left: 30,
            top: 490,
            width: 330,
            height: 52,
            child: !_isSignIn
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isLoading ? null : _signUp,
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white),
                          )
                        : const Text(
                            'Create account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                  )
                : const SizedBox.shrink(),
          ),
          // Bottom terms text
          Positioned(
            left: 80,
            top: 570,
            child: const Text(
              'By continuing, you agree to our Terms',
              style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ),
          // Toggle button
          Positioned(
            left: 80,
            top: 598,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _isSignIn = !_isSignIn;
                });
              },
              child: Text(_isSignIn ? 'Create account instead' : 'Back to Sign in',
                  style: const TextStyle(color: Color(0xFF6366F1))),
            ),
          ),
        ],
      ),
  }
}