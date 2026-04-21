import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Container(
              color: const Color(0xFF0F172A),
            ),
          ),
          // Back arrow
          Positioned(
            left: 16,
            top: 60,
            child: GestureDetector(
              onTap: () => context.go('/dashboard'),
              child: const Text(
                '←',
                style: TextStyle(
                  color: Color(0xFFF8FAFC),
                  fontSize: 22,
                ),
              ),
            ),
          ),
          Positioned(
            left: 100,
            top: 62,
            child: Text(
              'Profile',
              style: TextStyle(
                color: Color(0xFFF8FAFC),
                fontSize: 20,
              ),
            ),
          ),
          Positioned(
            left: 147,
            top: 120,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Color(0xFF1E293B),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '👤',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 40,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 95,
            top: 232,
            child: Text(
              'John Doe',
              style: TextStyle(
                color: Color(0xFFF8FAFC),
                fontSize: 20,
              ),
            ),
          ),
          Positioned(
            left: 95,
            top: 260,
            child: Text(
              'john@email.com',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
              ),
            ),
          ),
          Positioned(
            left: 95,
            top: 284,
            child: Text(
              'Member since Jan 2026',
              style: TextStyle(
                color: Color(0xFF475569),
                fontSize: 11,
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 330,
            child: Text(
              'STATS',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10,
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 356,
            child: Container(
              width: 108,
              height: 80,
              decoration: BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '142',
                    style: TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Completed',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 141,
            top: 356,
            child: Container(
              width: 108,
              height: 80,
              decoration: BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '8',
                    style: TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pending',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 258,
            top: 356,
            child: Container(
              width: 108,
              height: 80,
              decoration: BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '12',
                    style: TextStyle(
                      color: Color(0xFF22C55E),
                      fontSize: 24,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Day streak',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 464,
            child: Text(
              'SETTINGS',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 10,
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 490,
            child: Container(
              width: 342,
              height: 52,
              decoration: BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '🔔  Notifications',
                      style: TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Text(
                      '›',
                      style: TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 550,
            child: Container(
              width: 342,
              height: 52,
              decoration: BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '🌙  Dark Mode',
                  style: TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 610,
            child: Container(
              width: 342,
              height: 52,
              decoration: BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '📊  Export Data',
                      style: TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Text(
                      '›',
                      style: TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 710,
            child: GestureDetector(
              onTap: () => context.go('/login'),
              child: Container(
                width: 342,
                height: 52,
                decoration: BoxDecoration(
                  color: Color(0xFF1C1917),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 15,
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