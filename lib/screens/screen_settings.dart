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
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = _prefs.getBool('darkMode') ?? false;
      _defaultColor = _prefs.getString('defaultColor') ?? '#ffffff';
      _fontSize = _prefs.getInt('fontSize') ?? 16;
      _sortBy = _prefs.getString('sortBy') ?? 'Updated';
    });
  }

  Future<void> _toggleDarkMode(bool val) async {
    setState(() {
      _darkMode = val;
    });
    await _prefs.setBool('darkMode', val);
  }

  Future<void> _pickDefaultColor() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Default Note Color'),
        content: Wrap(
          spacing: 8,
          children: _palette
              .map((c) => GestureDetector(
                    onTap: () => Navigator.pop(ctx, c),
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
                  ))
              .toList(),
        ),
      ),
    );
    if (selected != null && selected != _defaultColor) {
      setState(() {
        _defaultColor = selected;
      });
      await _prefs.setString('defaultColor', selected);
    }
  }

  Future<void> _pickFontSize(int? val) async {
    if (val == null) return;
    setState(() {
      _fontSize = val;
    });
    await _prefs.setInt('fontSize', val);
  }

  Future<void> _pickSortBy(String? val) async {
    if (val == null) return;
    setState(() {
      _sortBy = val;
    });
    await _prefs.setString('sortBy', val);
  }

  final List<String> _palette = const [
    '#ffffff',
    '#fef3c7',
    '#dbeafe',
    '#dcfce7',
    '#fce7f3',
    '#ede9fe',
    '#fee2e2',
    '#f3f4f6',
  ];

  final List<int> _fontSizeOptions = const [12, 14, 16, 18, 20];
  final List<String> _sortOptions = const ['Updated', 'Created', 'Title'];

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _signOut() async {
    final should = await showDialog<bool>(
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
    if (should == true) {
      try {
        await Supabase.instance.client.auth.signOut();
      } catch (_) {}
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? 'user@gmail.com';
    final firstLetter = email.isNotEmpty ? email[0].toUpperCase() : 'U';

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 54),
            Text(
              'Settings',
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 22,
              ),
            ),
            SizedBox(height: 16),
            // Account Section
            Container(
              width: double.infinity,
              color: const Color(0xFFFFFFFF),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF6366F1),
                    child: Text(
                      firstLetter,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          email,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 4),
                        const Text(
                          'Free plan · Member since Jan 2024',
                          style: TextStyle(
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
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            SizedBox(height: 8),
            // Preferences Title
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'PREFERENCES',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            // Dark Mode Switch
            Container(
              width: double.infinity,
              color: const Color(0xFFFFFFFF),
              child: ListTile(
                title: const Text(
                  'Dark Mode',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                  ),
                ),
                trailing: Switch(
                  value: _darkMode,
                  onChanged: _toggleDarkMode,
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            // Default Note Color
            Container(
              width: double.infinity,
              color: const Color(0xFFFFFFFF),
              child: ListTile(
                title: const Text(
                  'Default note color',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                  ),
                ),
                trailing: GestureDetector(
                  onTap: _pickDefaultColor,
                  child: CircleAvatar(
                    backgroundColor: Color(int.parse(_defaultColor.replaceFirst('#', '0xFF'))),
                    radius: 12,
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            // Editor Font Size
            Container(
              width: double.infinity,
              color: const Color(0xFFFFFFFF),
              child: ListTile(
                title: const Text(
                  'Editor font size',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                  ),
                ),
                trailing: DropdownButton<int>(
                  value: _fontSize,
                  icon: const Icon(Icons.arrow_drop_down),
                  underline: Container(),
                  items: _fontSizeOptions
                      .map(
                        (val) => DropdownMenuItem(
                          value: val,
                          child: Text(val.toString()),
                        ),
                      )
                      .toList(),
                  onChanged: _pickFontSize,
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            // Sort Notes By
            Container(
              width: double.infinity,
              color: const Color(0xFFFFFFFF),
              child: ListTile(
                title: const Text(
                  'Sort notes by',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                  ),
                ),
                trailing: DropdownButton<String>(
                  value: _sortBy,
                  icon: const Icon(Icons.arrow_drop_down),
                  underline: Container(),
                  items: _sortOptions
                      .map(
                        (opt) => DropdownMenuItem(
                          value: opt,
                          child: Text(opt),
                        ),
                      )
                      .toList(),
                  onChanged: _pickSortBy,
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            // Storage Section
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'STORAGE',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              color: const Color(0xFFFFFFFF),
              child: ListTile(
                title: const Text(
                  'iCloud / Google Drive backup',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                  ),
                ),
                trailing: Text(
                  'Off',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 13,
                  ),
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming Soon')),
                  );
                },
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            // About Section
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'ABOUT',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              color: const Color(0xFFFFFFFF),
              child: ListTile(
                title: const Text(
                  'Version',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                  ),
                ),
                trailing: const Text(
                  '1.0.0',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            SizedBox(height: 16),
            // Sign Out button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _signOut,
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
  }
}