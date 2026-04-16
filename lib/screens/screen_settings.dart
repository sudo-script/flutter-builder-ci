import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  User? _user;
  bool _darkMode = false;
  Color _defaultColor = const Color(0xFFFFFFFF);
  int _fontSize = 16;
  String _sortBy = 'Updated';
  bool _isLoading = true;

  final List<String> _colorHexs = const [
    '#ffffff',
    '#fef3c7',
    '#dbeafe',
    '#dcfce7',
    '#fce7f3',
    '#ede9fe',
    '#fee2e2',
    '#f3f4f6'
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      final colorStr = prefs.getString('defaultColor');
      if (colorStr != null) {
        _defaultColor = Color(int.parse(colorStr));
      }
      _fontSize = prefs.getInt('fontSize') ?? 16;
      _sortBy = prefs.getString('sortBy') ?? 'Updated';
    });

    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      setState(() {
        _user = currentUser;
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectColor() async {
    final palette = _colorHexs
        .map((c) => Color(int.parse(c.replaceFirst('#', '0xFF'))))
        .toList();
    await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Pick a color'),
            content: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                children: palette.map((c) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _defaultColor = c;
                      });
                      SharedPreferences.getInstance()
                          .then((p) => p.setString(
                              'defaultColor', '$c'.toString().replaceAll('Color', '').replaceAll('(', '').replaceAll(')', '')));
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: _defaultColor == c ? 3 : 1,
                          color: _defaultColor == c ? Colors.black87 : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        });
  }

  void _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Confirm Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Sign Out')),
            ],
          );
        });
    if (confirmed != true) return;
    try {
      await Supabase.instance.client.auth.signOut();
      if (!mounted) return;
      context.go('/auth');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ));
    }
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 24),
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF6366f1),
              child: Text(
                _user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            SizedBox(height: 8),
            Text(
              _user?.email ?? '',
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            Text(
              'Free plan · Member since ${DateTime.tryParse(_user?.createdAt ?? '')?.year.toString() ?? ''}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 16),
            const Divider(thickness: 1, height: 1, color: Color(0xFFE5E7EB)),
            SizedBox(height: 8),
            const Text('PREFERENCES',
                style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6B7280),
                    letterSpacing: 1)),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text('Dark Mode',
                      style: const TextStyle(fontSize: 15)),
                ),
                Switch(
                  value: _darkMode,
                  onChanged: (value) {
                    setState(() {
                      _darkMode = value;
                    });
                    SharedPreferences.getInstance()
                        .then((p) => p.setBool('darkMode', value));
                  },
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text('Default note color',
                      style: const TextStyle(fontSize: 15)),
                ),
                GestureDetector(
                  onTap: _selectColor,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _defaultColor,
                      shape: BoxShape.circle,
                      border: Border.all(width: 2, color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: Text('Editor font size',
                        style: const TextStyle(fontSize: 15))),
                DropdownButton<int>(
                  value: _fontSize,
                  items: const [12, 14, 16, 18, 20]
                      .map((v) => DropdownMenuItem(
                          value: v, child: Text(v.toString())))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _fontSize = v;
                    });
                    SharedPreferences.getInstance()
                        .then((p) => p.setInt('fontSize', v));
                  },
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: Text('Sort notes by',
                        style: const TextStyle(fontSize: 15))),
                DropdownButton<String>(
                  value: _sortBy,
                  items: const ['Updated', 'Created', 'Title']
                      .map((v) => DropdownMenuItem(
                          value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _sortBy = v;
                    });
                    SharedPreferences.getInstance()
                        .then((p) => p.setString('sortBy', v));
                  },
                ),
              ],
            ),
            const Divider(thickness: 1, height: 1, color: Color(0xFFE5E7EB)),
            Row(
              children: [
                Expanded(
                    child: Text('iCloud / Google Drive backup',
                        style: const TextStyle(fontSize: 15))),
                Text('Off', style: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coming Soon')));
                  },
                ),
              ],
            ),
            const Divider(thickness: 1, height: 1, color: Color(0xFFE5E7EB)),
            Row(
              children: [
                Expanded(
                    child: Text('Version',
                        style: const TextStyle(fontSize: 15))),
                Text('1.0.0', style: const TextStyle(fontSize: 15)),
              ],
            ),
            const Divider(thickness: 1, height: 1, color: Color(0xFFE5E7EB)),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444)),
              onPressed: _confirmSignOut,
              child: const Text('Sign Out',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            SizedBox(height: 40),
          ],
        ),
      ));
  }
}