import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading   = false;
  bool _isSignUp  = false;
  bool _obscure   = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      if (_isSignUp) {
        await Supabase.instance.client.auth.signUp(email: email, password: password);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created! Check your email to verify.')));
        }
      } else {
        final res = await Supabase.instance.client.auth.signInWithPassword(
          email: email, password: password);
        if (res.user != null && mounted) context.go('/notes_list');
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 72),
              const Text('Notes', style: TextStyle(
                fontSize: 40, fontWeight: FontWeight.bold,
                color: Color(0xFF6366f1), letterSpacing: -1)),
              const SizedBox(height: 8),
              const Text('Your thoughts, organized',
                style: TextStyle(fontSize: 14, color: Color(0xFF9ca3af))),
              const Text('Simple · Private · Synced',
                style: TextStyle(fontSize: 12, color: Color(0xFF4b5563))),
              const SizedBox(height: 52),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Email address',
                  hintStyle: const TextStyle(color: Color(0xFF9ca3af)),
                  filled: true, fillColor: const Color(0xFF1e1e2e),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordCtrl,
                obscureText: _obscure,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: Color(0xFF9ca3af)),
                  filled: true, fillColor: const Color(0xFF1e1e2e),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF6b7280)),
                    onPressed: () => setState(() => _obscure = !_obscure))),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7f1d1d).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8)),
                  child: Text(_error!, style: const TextStyle(color: Color(0xFFfca5a5), fontSize: 13))),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366f1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: _loading
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_isSignUp ? 'Create Account' : 'Sign In',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)))),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(_isSignUp ? 'Already have an account?' : "Don't have an account?",
                  style: const TextStyle(color: Color(0xFF6b7280), fontSize: 13)),
                TextButton(
                  onPressed: () => setState(() { _isSignUp = !_isSignUp; _error = null; }),
                  child: Text(_isSignUp ? 'Sign In' : 'Sign Up',
                    style: const TextStyle(color: Color(0xFF6366f1), fontWeight: FontWeight.bold))),
              ]),
              const SizedBox(height: 32),
              Center(child: Text('By continuing, you agree to our Terms',
                style: const TextStyle(color: Color(0xFF4b5563), fontSize: 11))),
            ],
          ),
        ),
      ),
    );
  }
}
