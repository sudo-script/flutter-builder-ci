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
  bool _isLoading = false;
  bool _isSignIn = true;

  void _toggleMode() {
    setState(() {
      _isSignIn = !_isSignIn;
    });
  }

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
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

    setState(() => _isLoading = true);
    try {
      if (_isSignIn) {
        await Supabase.instance.client
            .auth.signInWithPassword(email: email, password: password);
      } else {
        await Supabase.instance.client
            .auth.signUp(email: email, password: password);
      }
      context.go('/notes_list');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(fit: StackFit.expand, children: [
        Positioned(
          left: 0,
          top: 0,
          width: 390,
          height: 220,
          child: Container(
            color: const Color(0xFF1a1a2e),
          ),
        ),
        Positioned(
          left: 80,
          top: 72,
          child: Text(
            'Notes',
            style: TextStyle(
              color: const Color(0xFF6366f1),
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Positioned(
          left: 80,
          top: 126,
          child: Text(
            'Your thoughts, organized',
            style: TextStyle(
              color: const Color(0xFF9ca3af),
              fontSize: 14,
            ),
          ),
        ),
        Positioned(
          left: 80,
          top: 158,
          child: Text(
            'Simple · Private · Synced',
            style: TextStyle(
              color: const Color(0xFF4b5563),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email address',
                  hintStyle: const TextStyle(color: Color(0xFF9ca3af)),
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: Color(0xFF9ca3af)),
                  border: InputBorder.none,
                ),
                obscureText: true,
              ),
            ),
          ),
        ),
        Positioned(
          left: 30,
          top: 384,
          width: 330,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleAuth,
            style: ElevatedButton.styleFrom(
              primary: const Color(0xFF6366f1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: EdgeInsets.zero,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  _isSignIn ? 'Sign In' : 'Create account',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                if (_isLoading)
                  Positioned(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 60,
          top: 456,
          width: 270,
          child: Divider(
            color: Color(0xFFe5e7eb),
            thickness: 1,
          ),
        ),
        Positioned(
          left: 150,
          top: 466,
          child: TextButton(
            onPressed: _toggleMode,
            child: Text(
              'or',
              style: TextStyle(
                color: const Color(0xFF9ca3af),
                fontSize: 12,
              ),
            ),
          ),
        ),
        Positioned(
          left: 30,
          top: 490,
          width: 330,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleAuth,
            style: ElevatedButton.styleFrom(
              primary: const Color(0xFFF8FAFC),
              onPrimary: const Color(0xFF6366f1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: EdgeInsets.zero,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  'Create account',
                  style: const TextStyle(
                    color: Color(0xFF6366f1),
                    fontSize: 16,
                  ),
                ),
                if (_isLoading)
                  Positioned(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Color(0xFF6366f1),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 80,
          top: 570,
          child: Text(
            'By continuing, you agree to our Terms',
            style: const TextStyle(
              color: Color(0xFF6b7280),
              fontSize: 11,
            ),
          ),
        ),
      ]),
  }
}