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
  String? _email;
  final List<String> _colorOptions = [
    '#ffffff',
    '#fef3c7',
    '#dbeafe',
    '#dcfce7',
    '#fce7f3',
    '#ede9fe',
    '#fee2e2',
    '#f3f4f6',
  ];
  final List<String> _fontSizeOptions = ['12', '14', '16', '18', '20'];
  final List<String> _sortOptions = ['Updated', 'Created', 'Title'];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _fetchUser();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final dark = prefs.getBool('darkMode') ?? false;
    final color = prefs.getString('defaultColor') ?? '#ffffff';
    final size = prefs.getInt('fontSize') ?? 16;
    final sort = prefs.getString('sortBy') ?? 'Updated';
    setState(() {
      _darkMode = dark;
      _defaultColor = color;
      _fontSize = size;
      _sortBy = sort;
    });
  }

  Future<void> _saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() => _darkMode = value);
  }

  Future<void> _saveDefaultColor(String color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('defaultColor', color);
    setState(() => _defaultColor = color);
  }

  Future<void> _saveFontSize(int size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fontSize', size);
    setState(() => _fontSize = size);
  }

  Future<void> _saveSortBy(String sort) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sortBy', sort);
    setState(() => _sortBy = sort);
  }

  Future<void> _fetchUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    setState(() => _email = user?.email);
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Select Default Note Color'),
        content: Wrap(
          spacing: 8,
          children: _colorOptions.map((c) {
            final isSelected = _defaultColor == c;
            return GestureDetector(
              onTap: () {
                _saveDefaultColor(c);
                Navigator.pop(context);
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Color(int.parse(c.replaceFirst('#', '0xFF'))),
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: isSelected ? 3 : 1,
                    color: isSelected ? Colors.black87 : Colors.grey.shade300,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Sign Out'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Supabase.instance.client.auth.signOut();
              context.go('/auth');
            },
            child: const Text('Sign Out'),
          ),
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 54),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 22,
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                'ACCOUNT',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 80,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF6366F1),
                  radius: 24,
                  child: Text(
                    _email?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _email ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const Text(
                        'Free plan · Member since Jan 2024',
                        style: TextStyle(
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
          const Divider(color: Color(0xFFE5E7EB), thickness: 1),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 16, top: 4),
              child: Text(
                'PREFERENCES',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 56,
            color: Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: const Text(
                'Dark Mode',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF111827),
                ),
              ),
              trailing: Switch(
                value: _darkMode,
                onChanged: (v) => _saveDarkMode(v),
              ),
            ),
          ),
          const Divider(color: Color(0xFFE5E7EB), thickness: 1),
          Container(
            width: double.infinity,
            height: 56,
            color: Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: const Text(
                'Default note color',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF111827),
                ),
              ),
              trailing: InkWell(
                onTap: _showColorPicker,
                child: CircleAvatar(
                  backgroundColor: Color(int.parse(_defaultColor.replaceFirst('#', '0xFF'))),
                  radius: 12,
                ),
              ),
            ),
          ),
          const Divider(color: Color(0xFFE5E7EB), thickness: 1),
          Container(
            width: double.infinity,
            height: 56,
            color: Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: const Text(
                'Editor font size',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF111827),
                ),
              ),
              trailing: DropdownButton<int>(
                value: _fontSize,
                items: _fontSizeOptions.map((s) {
                  final v = int.parse(s);
                  return DropdownMenuItem<int>(
                    value: v,
                    child: Text(
                      s,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 15,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) _saveFontSize(v);
                },
              ),
            ),
          ),
          const Divider(color: Color(0xFFE5E7EB), thickness: 1),
          Container(
            width: double.infinity,
            height: 56,
            color: Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: const Text(
                'Sort notes by',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF111827),
                ),
              ),
              trailing: DropdownButton<String>(
                value: _sortBy,
                items: _sortOptions.map((s) {
                  return DropdownMenuItem<String>(
                    value: s,
                    child: Text(
                      s,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 15,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) _saveSortBy(v);
                },
              ),
            ),
          ),
          const Divider(color: Color(0xFFE5E7EB), thickness: 1),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 16, top: 4),
              child: Text(
                'STORAGE',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 56,
            color: Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: const Text(
                'iCloud / Google Drive backup',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF111827),
                ),
              ),
              subtitle: const Text(
                'Off',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF9CA3AF)),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming Soon')),
              ),
            ),
          ),
          const Divider(color: Color(0xFFE5E7EB), thickness: 1),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 16, top: 4),
              child: Text(
                'ABOUT',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 56,
            color: Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              title: const Text(
                'Version',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF111827),
                ),
              ),
              trailing: const Text(
                '1.0.0',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ),
          const Divider(color: Color(0xFFE5E7EB), thickness: 1),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xFFEF4444),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _confirmSignOut,
                child: const Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 30),
        ],
      );
  }
}