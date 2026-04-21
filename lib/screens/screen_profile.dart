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
      body: Stack(fit: StackFit.expand, children: [
        Positioned(
          left: 0,
          top: 0,
          width: 390,
          height: 844,
          child: Container(color: const Color(0xFF0f172a)),
        ),
        Positioned(
          left: 16,
          top: 60,
          width: 40,
          height: 28,
          child: GestureDetector(
            onTap: () => context.go('/dashboard'),
            child: Text(
              '←',
              style: const TextStyle(
                color: Color(0xFFf8fafc),
                fontSize: 22,
              ),
            ),
          ),
        ),
        Positioned(
          left: 100,
          top: 62,
          width: 190,
          height: 28,
          child: const Text(
            'Profile',
            style: TextStyle(
              color: Color(0xFFf8fafc),
              fontSize: 20,
            ),
          ),
        ),
        Positioned(
          left: 147,
          top: 120,
          width: 96,
          height: 96,
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF1e293b),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: 147,
          top: 140,
          width: 96,
          height: 56,
          child: Center(
            child: Text(
              '👤',
              style: TextStyle(
                color: Color(0xFF94a3b8),
                fontSize: 40,
              ),
            ),
          ),
        ),
        Positioned(
          left: 95,
          top: 232,
          width: 200,
          height: 24,
          child: const Text(
            'John Doe',
            style: TextStyle(
              color: Color(0xFFf8fafc),
              fontSize: 20,
            ),
          ),
        ),
        Positioned(
          left: 95,
          top: 260,
          width: 200,
          height: 18,
          child: const Text(
            'john@email.com',
            style: TextStyle(
              color: Color(0xFF64748b),
              fontSize: 13,
            ),
          ),
        ),
        Positioned(
          left: 95,
          top: 284,
          width: 200,
          height: 16,
          child: const Text(
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
          width: 200,
          height: 18,
          child: const Text(
            'STATS',
            style: TextStyle(
              color: Color(0xFF64748b),
              fontSize: 10,
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
              color: Color(0xFF1e293b),
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
            decoration: BoxDecoration(
              color: Color(0xFF1e293b),
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
            decoration: BoxDecoration(
              color: Color(0xFF1e293b),
              borderRadius: BorderRadius.all(Radius.circular(14)),
            ),
          ),
        ),
        Positioned(
          left: 24,
          top: 370,
          width: 108,
          height: 28,
          child: const Text(
            '142',
            style: TextStyle(
              color: Color(0xFF3b82f6),
              fontSize: 24,
            ),
          ),
        ),
        Positioned(
          left: 141,
          top: 370,
          width: 108,
          height: 28,
          child: const Text(
            '8',
            style: TextStyle(
              color: Color(0xFFf59e0b),
              fontSize: 24,
            ),
          ),
        ),
        Positioned(
          left: 258,
          top: 370,
          width: 108,
          height: 28,
          child: const Text(
            '12',
            style: TextStyle(
              color: Color(0xFF22c55e),
              fontSize: 24,
            ),
          ),
        ),
        Positioned(
          left: 24,
          top: 402,
          width: 108,
          height: 16,
          child: const Text(
            'Completed',
            style: TextStyle(
              color: Color(0xFF64748b),
              fontSize: 11,
            ),
          ),
        ),
        Positioned(
          left: 141,
          top: 402,
          width: 108,
          height: 16,
          child: const Text(
            'Pending',
            style: TextStyle(
              color: Color(0xFF64748b),
              fontSize: 11,
            ),
          ),
        ),
        Positioned(
          left: 258,
          top: 402,
          width: 108,
          height: 16,
          child: const Text(
            'Day streak',
            style: TextStyle(
              color: Color(0xFF64748b),
              fontSize: 11,
            ),
          ),
        ),
        Positioned(
          left: 24,
          top: 464,
          width: 200,
          height: 18,
          child: const Text(
            'SETTINGS',
            style: TextStyle(
              color: Color(0xFF64748b),
              fontSize: 10,
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
              color: Color(0xFF1e293b),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        Positioned(
          left: 44,
          top: 506,
          width: 200,
          height: 20,
          child: const Text(
            '🔔  Notifications',
            style: TextStyle(
              color: Color(0xFFe2e8f0),
              fontSize: 15,
            ),
          ),
        ),
        Positioned(
          left: 330,
          top: 506,
          width: 30,
          height: 20,
          child: const Text(
            '›',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 18,
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
              color: Color(0xFF1e293b),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        Positioned(
          left: 44,
          top: 566,
          width: 200,
          height: 20,
          child: const Text(
            '🌙  Dark Mode',
            style: TextStyle(
              color: Color(0xFFe2e8f0),
              fontSize: 15,
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
              color: Color(0xFF1e293b),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        Positioned(
          left: 44,
          top: 626,
          width: 200,
          height: 20,
          child: const Text(
            '📊  Export Data',
            style: TextStyle(
              color: Color(0xFFe2e8f0),
              fontSize: 15,
            ),
          ),
        ),
        Positioned(
          left: 330,
          top: 626,
          width: 30,
          height: 20,
          child: const Text(
            '›',
            style: TextStyle(
              color: Color(0xFF475569),
              fontSize: 18,
            ),
          ),
        ),
        Positioned(
          left: 24,
          top: 710,
          width: 342,
          height: 52,
          child: GestureDetector(
            onTap: () => context.go('/login'),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF1c1917),
                borderRadius: BorderRadius.all(Radius.circular(14)),
              ),
            ),
          ),
        ),
        Positioned(
          left: 24,
          top: 726,
          width: 342,
          height: 22,
          child: const Text(
            'Sign Out',
            style: TextStyle(
              color: Color(0xFFef4444),
              fontSize: 15,
            ),
          ),
        ),
      ]));
  }
}