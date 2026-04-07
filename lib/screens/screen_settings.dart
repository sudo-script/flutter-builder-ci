import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _client = Supabase.instance.client;

  bool   _darkMode    = false;
  String _defaultColor = '#ffffff';
  int    _fontSize    = 16;
  String _sortBy      = 'Updated';
  bool   _signing     = false;

  static const _colorPalette = [
    '#ffffff','#fef3c7','#dbeafe','#dcfce7',
    '#fce7f3','#ede9fe','#fee2e2','#f3f4f6',
  ];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode     = prefs.getBool('darkMode')     ?? false;
      _defaultColor = prefs.getString('defaultColor') ?? '#ffffff';
      _fontSize     = prefs.getInt('fontSize')      ?? 16;
      _sortBy       = prefs.getString('sortBy')     ?? 'Updated';
    });
  }

  Future<void> _setPref<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool)   prefs.setBool(key, value);
    if (value is String) prefs.setString(key, value);
    if (value is int)    prefs.setInt(key, value);
  }

  Future<void> _signOut() async {
    final ok = await showDialog<bool>(context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will be returned to the login screen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.red))),
        ]));
    if (ok != true) return;
    setState(() => _signing = true);
    try {
      await _client.auth.signOut();
      if (mounted) context.go('/auth');
    } catch (e) {
      if (mounted) {
        setState(() => _signing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign out failed: $e')));
      }
    }
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 0, 6),
    child: Text(text, style: TextStyle(
      fontSize: 10, fontWeight: FontWeight.bold,
      color: Colors.grey.shade500, letterSpacing: 1.2)));

  Widget _tile({required String title, Widget? trailing, VoidCallback? onTap, Color? textColor}) =>
    ListTile(
      title: Text(title, style: TextStyle(fontSize: 15, color: textColor)),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20));

  Widget _divider() => const Divider(height: 1, indent: 20);

  @override
  Widget build(BuildContext context) {
    final user  = _client.auth.currentUser;
    final email = user?.email ?? '';
    final initials = email.isNotEmpty ? email[0].toUpperCase() : '?';
    final memberSince = user?.createdAt != null
      ? DateTime.tryParse(user!.createdAt)?.year.toString() ?? ''
      : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0),
      body: ListView(children: [
        // Account
        _sectionLabel('ACCOUNT'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFe5e7eb))),
          child: Row(children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF6366f1),
              child: Text(initials,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(email, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              if (memberSince.isNotEmpty)
                Text('Member since $memberSince',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF9ca3af))),
            ])),
          ])),
        const SizedBox(height: 8),

        // Preferences
        _sectionLabel('PREFERENCES'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFe5e7eb))),
          child: Column(children: [
            _tile(
              title: 'Dark Mode',
              trailing: Switch(
                value: _darkMode,
                onChanged: (v) {
                  setState(() => _darkMode = v);
                  _setPref('darkMode', v);
                },
                activeColor: const Color(0xFF6366f1))),
            _divider(),
            _tile(
              title: 'Default note colour',
              trailing: GestureDetector(
                onTap: () => showDialog(context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Default colour'),
                    content: Wrap(spacing: 10, runSpacing: 10, children: _colorPalette.map((c) {
                      final color = Color(int.parse(c.replaceFirst('#', '0xFF')));
                      return GestureDetector(
                        onTap: () {
                          setState(() => _defaultColor = c);
                          _setPref('defaultColor', c);
                          Navigator.pop(ctx);
                        },
                        child: Container(width: 40, height: 40,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle,
                            border: Border.all(
                              color: _defaultColor == c ? Colors.black54 : Colors.grey.shade300,
                              width: _defaultColor == c ? 3 : 1))));
                    }).toList()),
                    actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))])),
                child: Container(width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: Color(int.parse(_defaultColor.replaceFirst('#', '0xFF'))),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300))))),
            _divider(),
            _tile(
              title: 'Editor font size',
              trailing: DropdownButton<int>(
                value: _fontSize,
                underline: const SizedBox(),
                items: [12, 14, 16, 18, 20].map((s) =>
                  DropdownMenuItem(value: s, child: Text('$s'))).toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _fontSize = v);
                  _setPref('fontSize', v);
                })),
            _divider(),
            _tile(
              title: 'Sort notes by',
              trailing: DropdownButton<String>(
                value: _sortBy,
                underline: const SizedBox(),
                items: ['Updated', 'Created', 'Title'].map((s) =>
                  DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _sortBy = v);
                  _setPref('sortBy', v);
                })),
          ])),
        const SizedBox(height: 8),

        // Storage
        _sectionLabel('STORAGE'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFe5e7eb))),
          child: _tile(
            title: 'Cloud backup',
            trailing: TextButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!'))),
              child: const Text('Off', style: TextStyle(color: Color(0xFF9ca3af)))))),
        const SizedBox(height: 8),

        // About
        _sectionLabel('ABOUT'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFe5e7eb))),
          child: _tile(
            title: 'Version',
            trailing: const Text('1.0.0', style: TextStyle(color: Color(0xFF9ca3af))))),
        const SizedBox(height: 24),

        // Sign out
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: _signing ? null : _signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFfee2e2),
                foregroundColor: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _signing
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                : const Text('Sign Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))))),
        const SizedBox(height: 40),
      ]),
    );
  }
}
