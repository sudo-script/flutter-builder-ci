import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  late final SupabaseClient _client;

  final List<String> _palette = [
    '#ffffff',
    '#fef3c7',
    '#dbeafe',
    '#dcfce7',
    '#fce7f3',
    '#ede9fe',
    '#fee2e2',
    '#f3f4f6'
  ];

  final List<int> _fontSizes = [12, 14, 16, 18, 20];
  final List<String> _sortOptions = ['Updated', 'Created', 'Title'];

  @override
  void initState() {
    super.initState();
    _client = Supabase.instance.client;
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = _prefs.getBool('darkMode') ?? false;
      _defaultColor = _prefs.getString('defaultColor') ?? _palette[0];
      _fontSize = _prefs.getInt('fontSize') ?? 16;
      _sortBy = _prefs.getString('sortBy') ?? 'Updated';
    });
  }

  Future<void> _setDarkMode(bool value) async {
    await _prefs.setBool('darkMode', value);
    setState(() {
      _darkMode = value;
    });
  }

  Future<void> _setDefaultColor(String color) async {
    await _prefs.setString('defaultColor', color);
    setState(() {
      _defaultColor = color;
    });
  }

  Future<void> _setFontSize(int size) async {
    await _prefs.setInt('fontSize', size);
    setState(() {
      _fontSize = size;
    });
  }

  Future<void> _setSortBy(String value) async {
    await _prefs.setString('sortBy', value);
    setState(() {
      _sortBy = value;
    });
  }

  Future<void> _signOut() async {
    try {
      await _client.auth.signOut();
      if (!mounted) return;
      context.go('/auth');
    } catch (e) {
      // Handle error if needed
    }
  }

  Future<void> _showColorPicker() async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Default Color'),
        content: Wrap(
          spacing: 8,
          children: _palette.map((c) {
            final color = Color(int.parse(c.replaceFirst('#', '0xFF')));
            return GestureDetector(
              onTap: () {
                _setDefaultColor(c);
                Navigator.of(context).pop();
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
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
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _client.auth.currentUser;
    final email = user?.email ?? 'N/A';
    final displayName = user?.userMetadata['name'] ?? 'U';
    final memberSince = 'Jan 2024';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              const Text(
                'ACCOUNT',
                style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
              ),
              SizedBox(height: 8),
              Card(
                color: Colors.white,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF6366F1),
                    child: Text(
                      displayName.substring(0, 1),
                      style: const TextStyle(fontSize: 22, color: Colors.white),
                    ),
                  ),
                  title: Text(email, style: const TextStyle(fontSize: 15)),
                  subtitle: const Text(
                    'Free plan · Member since Jan 2024',
                    style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              const Divider(color: Color(0xFFE5E7EB), height: 1),
              SizedBox(height: 16),
              const Text(
                'PREFERENCES',
                style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
              ),
              SizedBox(height: 8),
              Card(
                color: Colors.white,
                child: SwitchListTile(
                  title: const Text('Dark Mode', style: TextStyle(fontSize: 15)),
                  value: _darkMode,
                  onChanged: _setDarkMode,
                ),
              ),
              SizedBox(height: 16),
              Card(
                color: Colors.white,
                child: ListTile(
                  title:
                      const Text('Default note color', style: TextStyle(fontSize: 15)),
                  trailing: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Color(int.parse(_defaultColor.replaceFirst('#', '0xFF'))),
                      shape: BoxShape.circle,
                    ),
                  ),
                  onTap: _showColorPicker,
                ),
              ),
              SizedBox(height: 16),
              Card(
                color: Colors.white,
                child: ListTile(
                  title: const Text('Editor font size', style: TextStyle(fontSize: 15)),
                  trailing: DropdownButton<int>(
                    value: _fontSize,
                    items: _fontSizes
                        .map((size) => DropdownMenuItem<int>(
                              value: size,
                              child: Text(
                                size.toString(),
                                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 15),
                              ),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) _setFontSize(v);
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                color: Colors.white,
                child: ListTile(
                  title: const Text('Sort notes by', style: TextStyle(fontSize: 15)),
                  trailing: DropdownButton<String>(
                    value: _sortBy,
                    items: _sortOptions
                        .map((opt) => DropdownMenuItem<String>(
                              value: opt,
                              child: Text(opt,
                                  style: const TextStyle(
                                      color: Color(0xFF6B7280), fontSize: 13)),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) _setSortBy(v);
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              const Divider(color: Color(0xFFE5E7EB), height: 1),
              SizedBox(height: 16),
              const Text(
                'STORAGE',
                style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
              ),
              SizedBox(height: 8),
              Card(
                color: Colors.white,
                child: ListTile(
                  title: const Text('iCloud / Google Drive backup',
                      style: TextStyle(fontSize: 15)),
                  trailing: const Text('Off',
                      style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Coming Soon'),
                    ));
                  },
                ),
              ),
              SizedBox(height: 16),
              const Divider(color: Color(0xFFE5E7EB), height: 1),
              const SizedSizedBox(height: 16),

              const Text(
                'ABOUT',
                style: TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
              ),
              SizedBox(height: 8),
              Card(
                color: Colors.white,
                child: ListTile(
                  title: const Text('Version', style: TextStyle(fontSize: 15)),
                  trailing: const Text('1.0.0',
                      style: TextStyle(fontSize: 15, color: Color(0xFF6B7280))),
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: SizedBox(
                  width: 358,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Confirm Sign Out'),
                          content: const Text('Are you sure you want to sign out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Sign Out'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await _signOut();
                      }
                    },
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
      );
  }
}