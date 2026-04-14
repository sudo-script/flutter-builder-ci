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
  bool _darkMode = false;
  String _defaultColor = '#ffffff';
  int _fontSize = 16;
  String _sortBy = 'Updated';

  String _email = '';
  String _memberSince = '';
  static const List<String> _colors = [
    '#ffffff',
    '#fef3c7',
    '#dbeafe',
    '#dcfce7',
    '#fce7f3',
    '#ede9fe',
    '#fee2e2',
    '#f3f4f6',
  ];

  final List<int> _fontSizeOptions = [12, 14, 16, 18, 20];
  final List<String> _sortOptions = ['Updated', 'Created', 'Title'];

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
    });
  }

  Future<void> _loadUserInfo() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final createdAt = user.createdAt;
      String month = 'Jan';
      if (createdAt != null) {
        month = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ][createdAt.month - 1];
      }
      setState(() {
        _email = user.email ?? '';
        _memberSince = '$month ${createdAt?.year ?? ''}';
      });
    }
  }

  Future<void> _saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() {
      _darkMode = value;
    });
  }

  Future<void> _saveDefaultColor(String color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultColor', color);
    setState(() {
      _defaultColor = color;
    });
  }

  Future<void> _saveFontSize(int size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fontSize', size);
    setState(() {
      _fontSize = size;
    });
  }

  Future<void> _saveSortBy(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sortBy', value);
    setState(() {
      _sortBy = value;
    });
  }

  Future<void> _showColorPicker() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Select Default Note Color'),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _colors.map((c) {
              return GestureDetector(
                onTap: () {
                  _saveDefaultColor(c);
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
                      color: _defaultColor == c ? Colors.black87 : Colors.grey.shade300,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
  }

  Future<void> _confirmSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
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
        );
      },
    );
    if (confirm == true) {
      try {
        await Supabase.instance.client.auth.signOut();
        context.go('/auth');
      } catch (e) {
        // Handle error if needed
      }
    }
  }

  Future<void> _backupComingSoon() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming Soon'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 54),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Settings',
                style: const TextStyle(color: Color(0xFF111827), fontSize: 22),
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'ACCOUNT',
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10),
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF6366F1),
                    child: Text(
                      _email.isNotEmpty ? _email[0].toUpperCase() : '',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _email,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          'Free plan · Member since $_memberSince',
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Divider(color: const Color(0xFFE5E7EB)),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'PREFERENCES',
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10),
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  const Text(
                    'Dark Mode',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: _darkMode,
                    onChanged: (val) async {
                      await _saveDarkMode(val);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  const Text(
                    'Default note color',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _showColorPicker,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color:
                            Color(int.parse(_defaultColor.replaceFirst('#', '0xFF'))),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  const Text(
                    'Editor font size',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  DropdownButton<int>(
                    value: _fontSize,
                    items: _fontSizeOptions
                        .map(
                          (size) => DropdownMenuItem<int>(
                            value: size,
                            child: Text(
                              size.toString(),
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 15,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) _saveFontSize(val);
                    },
                    underline: SizedBox(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  const Text(
                    'Sort notes by',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  DropdownButton<String>(
                    value: _sortBy,
                    items: _sortOptions
                        .map(
                          (opt) => DropdownMenuItem<String>(
                            value: opt,
                            child: Text(
                              opt,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) _saveSortBy(val);
                    },
                    underline: SizedBox(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Divider(color: const Color(0xFFE5E7EB)),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'STORAGE',
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10),
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: InkWell(
                onTap: _backupComingSoon,
                child: Row(
                  children: [
                    const Text(
                      'iCloud / Google Drive backup',
                      style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Off',
                      style: TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Divider(color: const Color(0xFFE5E7EB)),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'ABOUT',
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10),
              ),
            ),
            const SizedSizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  const Text(
                    'Version',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    '1.0.0',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Divider(color: const Color(0xFFE5E7EB)),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'SIGN OUT',
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10),
              ),
            ),
            SizedBox(height: 8),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextButton(
                onPressed: _confirmSignOut,
                child: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      );
  }

  @override
  void dispose() {
    super.dispose();
  }
}