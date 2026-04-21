import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
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
            child: Container(
              color: const Color(0xFF0F172A),
            ),
          ),
          Positioned(
            left: 16,
            top: 60,
            child: GestureDetector(
              onTap: () {
                context.go('/dashboard');
              },
              child: Text(
                '←',
                style: const TextStyle(
                  fontSize: 22,
                  color: Color(0xFFF8FAFC),
                ),
              ),
            ),
          ),
          Positioned(
            left: 100,
            top: 62,
            child: Text(
              'Profile',
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFFF8FAFC),
              ),
            ),
          ),
          Positioned(
            left: 99,
            top: 120,
            width: 96,
            height: 96,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          Positioned(
            left: 147,
            top: 140,
            child: Text(
              '👤',
              style: const TextStyle(
                fontSize: 40,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
          Positioned(
            left: 95,
            top: 232,
            child: Text(
              'John Doe',
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFFF8FAFC),
              ),
            ),
          ),
          Positioned(
            left: 95,
            top: 260,
            child: Text(
              'john@email.com',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Positioned(
            left: 95,
            top: 284,
            child: Text(
              'Member since Jan 2026',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF475569),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 330,
            child: Text(
              'STATS',
              style: const TextStyle(
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
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          Positioned(
            left: 141,
            top: 356,
            width: 108,
            height: 80,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          Positioned(
            left: 258,
            top: 356,
            width: 108,
            height: 80,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 370,
            child: Text(
              '142',
              style: const TextStyle(
                fontSize: 24,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),
          Positioned(
            left: 141,
            top: 370,
            child: Text(
              '8',
              style: const TextStyle(
                fontSize: 24,
                color: Color(0xFFF59E0B),
              ),
            ),
          ),
          Positioned(
            left: 258,
            top: 370,
            child: Text(
              '12',
              style: const TextStyle(
                fontSize: 24,
                color: Color(0xFF22C55E),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 402,
            child: Text(
              'Completed',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Positioned(
            left: 141,
            top: 402,
            child: Text(
              'Pending',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Positioned(
            left: 258,
            top: 402,
            child: Text(
              'Day streak',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 464,
            child: Text(
              'SETTINGS',
              style: const TextStyle(
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
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SizedBox(width: 20),
                  Text(
                    '🔔  Notifications',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFFE2E8F0),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {},
                    child: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF475569),
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 20),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 550,
            width: 342,
            height: 52,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SizedBox(width: 20),
                  Text(
                    '🌙  Dark Mode',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFFE2E8F0),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 610,
            width: 342,
            height: 52,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  SizedBox(width: 20),
                  Text(
                    '📊  Export Data',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFFE2E8F0),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {},
                    child: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF475569),
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 20),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 710,
            width: 342,
            height: 52,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C1917),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  'Sign Out',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 726,
            child: GestureDetector(
              onTap: () {
                context.go('/login');
              },
              child: Text(
                'Sign Out',
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
          ),
        ],
      ));
  }
}