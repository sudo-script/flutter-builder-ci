import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String _email;
  late String _memberSince;
  bool _darkMode = false;
  String _defaultColor = '#ffffff';
  int _fontSize = 16;
  String _sortBy = 'Updated';
  bool _backupEnabled = false;

  final List<int> _fontSizeOptions = [12, 14, 16, 18, 20];
  final List<String> _sortByOptions = ['Updated', 'Created', 'Title'];
  final List<String> _colorPalette = [
    '#ffffff',
    '#fef3c7',
    '#dbeafe',
    '#dcfce7',
    '#fce7f3',
    '#ede9fe',
    '#fee2e2',
    '#f3f4f6',
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadUserInfo();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _defaultColor = prefs.getString('defaultColor') ?? '#ffffff';
      _fontSize = prefs.getInt('fontSize') ?? 16;
      _sortBy = prefs.getString('sortBy') ?? 'Updated';
      _backupEnabled = prefs.getBool('backupEnabled') ?? false;
    });
  }

  Future<void> _loadUserInfo() async {
    final user = Supabase.instance.client.auth.currentUser;
    setState(() {
      _email = user?.email ?? 'No Email';
      final createdAt = user?.createdAt;
      _memberSince = createdAt != null ? createdAt.year.toString() : 'Unknown';
    });
  }

  Future<void> _setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() {
      _darkMode = value;
    });
  }

  Future<void> _setDefaultColor(String color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultColor', color);
    setState(() {
      _defaultColor = color;
    });
  }

  Future<void> _setFontSize(int size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fontSize', size);
    setState(() {
      _fontSize = size;
    });
  }

  Future<void> _setSortBy(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sortBy', value);
    setState(() {
      _sortBy = value;
    });
  }

  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await Supabase.instance.client.auth.signOut();
      context.go('/auth');
    }
  }

  void _showColorPicker() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Default Note Color'),
        content: Wrap(
          spacing: 8,
          children: _colorPalette.map((c) {
            return GestureDetector(
              onTap: () {
                _setDefaultColor(c);
                Navigator.pop(ctx);
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Color(int.parse(c.replaceFirst('#', '0xFF'))),
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: _defaultColor == c ? 3 : 1,
                    color: _defaultColor == c
                        ? Colors.black87
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            SizedBox(height: 54),
            const Text(
              'Settings',
              style: TextStyle(fontSize: 22, color: Color(0xFF111827)),
            ),
            SizedBox(height: 4),
            Text(
              'ACCOUNT',
              style: TextStyle(fontSize: 10, color: Color(0xFF6b7280)),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF6366F1),
                    child: Text(
                      _email.isNotEmpty ? _email[0].toUpperCase() : '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _email,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Text(
                          'Free plan · Member since $_memberSince',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Color(0xFFE5E7EB),
              height: 1,
            ),
            SizedBox(height: 8),
            Text(
              'PREFERENCES',
              style: TextStyle(fontSize: 10, color: Color(0xFF6b7280)),
            ),
            SizedBox(height: 8),
            // Dark Mode
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Dark Mode',
                    style: TextStyle(fontSize: 15, color: Color(0xFF111827)),
                  ),
                  Switch(
                    value: _darkMode,
                    onChanged: _setDarkMode,
                  ),
                ],
              ),
            ),
            const Divider(
              color: Color(0xFFE5E7EB),
              height: 1,
            ),
            // Default Note Color
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.white,
              child: InkWell(
                onTap: _showColorPicker,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Default note color',
                      style: TextStyle(fontSize: 15, color: Color(0xFF111827)),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Color(
                            int.parse(_defaultColor.replaceFirst('#', '0xFF'))),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(
              color: Color(0xFFE5E7EB),
              height: 1,
            ),
            // Editor Font Size
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Editor font size',
                    style: TextStyle(fontSize: 15, color: Color(0xFF111827)),
                  ),
                  DropdownButton<int>(
                    value: _fontSize,
                    items: _fontSizeOptions
                        .map((size) => DropdownMenuItem<int>(
                              value: size,
                              child: Text(size.toString()),
                            ))
                        .toList(),
                    onChanged: _setFontSize,
                  ),
                ],
              ),
            ),
            const Divider(
              color: Color(0xFFE5E7EB),
              height: 1,
            ),
            // Sort Notes By
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sort notes by',
                    style: TextStyle(fontSize: 15, color: Color(0xFF111827)),
                  ),
                  DropdownButton<String>(
                    value: _sortBy,
                    items: _sortByOptions
                        .map((option) => DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            ))
                        .toList(),
                    onChanged: _setSortBy,
                  ),
                ],
              ),
            ),
            const Divider(
              color: Color(0xFFE5E7EB),
              height: 1,
            ),
            // Storage
            Text(
              'STORAGE',
              style: TextStyle(fontSize: 10, color: Color(0xFF6b7280)),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'iCloud / Google Drive backup',
                    style: TextStyle(fontSize: 15, color: Color(0xFF111827)),
                  ),
                  Switch(
                    value: _backupEnabled,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coming Soon')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(
              color: Color(0xFFE5E7EB),
              height: 1,
            ),
            // About
            Text(
              'ABOUT',
              style: TextStyle(fontSize: 10, color: Color(0xFF6b7280)),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Version',
                    style: TextStyle(fontSize: 15, color: Color(0xFF111827)),
                  ),
                  Text(
                    '1.0.0',
                    style: TextStyle(fontSize: 15, color: Color(0xFF6b7280)),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Color(0xFFE5E7EB),
              height: 1,
            ),
            SizedBox(height: 16),
            // Sign Out
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(200, 52),
                ),
                onPressed: _handleSignOut,
                child: const Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
  }
}