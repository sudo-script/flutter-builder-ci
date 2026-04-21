import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _goToDashboard() {
    context.go('/dashboard');
  }

  void _goToLogin() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 0,
            top: 0,
            width: 390,
            height: 844,
            child: Container(color: const Color(0xFF0F172A)),
          ),
          Positioned(
            left: 16,
            top: 60,
            child: GestureDetector(
              onTap: _goToDashboard,
              child: const Text(
                '←',
                style: TextStyle(
                  fontSize: 22,
                  color: Color(0xFFF8FAFC),
                ),
              ),
            ),
          ),
          Positioned(
            left: 100,
            top: 62,
            child: const Text(
              'Profile',
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFFF8FAFC),
              ),
            ),
          ),
          Positioned(
            left: 147 - 48,
            top: 120 - 48,
            width: 96,
            height: 96,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          Positioned(
            left: 147 - 48,
            top: 140 - 28,
            child: const Text(
              '👤',
              style: TextStyle(
                fontSize: 40,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
          Positioned(
            left: 95,
            top: 232,
            child: const Text(
              'John Doe',
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFFF8FAFC),
              ),
            ),
          ),
          Positioned(
            left: 95,
            top: 260,
            child: const Text(
              'john@email.com',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Positioned(
            left: 95,
            top: 284,
            child: const Text(
              'Member since Jan 2026',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF475569),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 330,
            child: const Text(
              'STATS',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 356,
            width: 108,
            height: 80,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
            ),
          ),
          Positioned(
            left: 141,
            top: 356,
            width: 108,
            height: 80,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
            ),
          ),
          Positioned(
            left: 258,
            top: 356,
            width: 108,
            height: 80,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 370,
            child: const Text(
              '142',
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),
          Positioned(
            left: 141,
            top: 370,
            child: const Text(
              '8',
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFF59E0F6),
              ),
            ),
          ),
          Positioned(
            left: 258,
            top: 370,
            child: const Text(
              '12',
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFF22C55E),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 402,
            child: const Text(
              'Completed',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Positioned(
            left: 141,
            top: 402,
            child: const Text(
              'Pending',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Positioned(
            left: 258,
            top: 402,
            child: const Text(
              'Day streak',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 464,
            child: const Text(
              'SETTINGS',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 490,
            width: 342,
            height: 52,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          Positioned(
            left: 44,
            top: 506,
            child: const Text(
              '🔔  Notifications',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFFE2E8F0),
              ),
            ),
          ),
          Positioned(
            right: 0, // Use right for 330 based on total width
            top: 506,
            child: const Text(
              '›',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF475569),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 550,
            width: 342,
            height: 52,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          Positioned(
            left: 44,
            top: 566,
            child: const Text(
              '🌙  Dark Mode',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFFE2E8F0),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 610,
            width: 342,
            height: 52,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          Positioned(
            left: 44,
            top: 626,
            child: const Text(
              '📊  Export Data',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFFE2E8F0),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 626,
            child: const Text(
              '›',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF475569),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 710,
            width: 342,
            height: 52,
            child: GestureDetector(
              onTap: _goToLogin,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1C1917),
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 0),
                    child: Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFEF4444),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ));
  }
}