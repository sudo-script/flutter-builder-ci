import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
            left: 20,
            top: 60,
            width: 200,
            height: 28,
            child: Text(
              'Good morning 👋',
              style: TextStyle(fontSize: 14, color: const Color(0xFF94A3B8)),
            ),
          ),
          Positioned(
            left: 334,
            top: 64,
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => context.go('/profile'),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '👤',
                  style: TextStyle(fontSize: 18, color: const Color(0xFF94A3B8)),
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 84,
            width: 260,
            height: 36,
            child: Text(
              "Today's Plan",
              style: TextStyle(fontSize: 26, color: const Color(0xFFF8FAFC)),
            ),
          ),
          Positioned(
            left: 20,
            top: 136,
            width: 350,
            height: 88,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A5F),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            left: 36,
            top: 152,
            width: 200,
            height: 20,
            child: Text(
              '📅  April 21, 2026',
              style: TextStyle(fontSize: 13, color: const Color(0xFF93C5FD)),
            ),
          ),
          Positioned(
            left: 280,
            top: 156,
            width: 72,
            height: 48,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            left: 280,
            top: 164,
            width: 72,
            height: 30,
            child: Text(
              '5/8',
              style: TextStyle(fontSize: 22, color: const Color(0xFFFFFFFF)),
            ),
          ),
          Positioned(
            left: 36,
            top: 178,
            width: 180,
            height: 32,
            child: Text(
              '3 tasks remaining',
              style: TextStyle(fontSize: 20, color: const Color(0xFFDBEAFE)),
            ),
          ),
          Positioned(
            left: 280,
            top: 190,
            width: 72,
            height: 14,
            child: Text(
              'done',
              style: TextStyle(fontSize: 10, color: const Color(0xFF93C5FD)),
            ),
          ),
          Positioned(
            left: 20,
            top: 248,
            width: 200,
            height: 20,
            child: Text(
              'PENDING',
              style: TextStyle(fontSize: 11, color: const Color(0xFFF59E0B)),
            ),
          ),
          Positioned(
            left: 20,
            top: 276,
            width: 350,
            height: 68,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          Positioned(
            left: 76,
            top: 290,
            width: 260,
            height: 20,
            child: Text(
              'Design landing page mockups',
              style: TextStyle(fontSize: 15, color: const Color(0xFFE2E8F0)),
            ),
          ),
          Positioned(
            left: 36,
            top: 296,
            width: 28,
            height: 28,
            child: Container(),
          ),
          Positioned(
            left: 76,
            top: 314,
            width: 200,
            height: 16,
            child: Text(
              'Due today · Work',
              style: TextStyle(fontSize: 11, color: const Color(0xFF64748B)),
            ),
          ),
          Positioned(
            left: 20,
            top: 356,
            width: 350,
            height: 68,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          Positioned(
            left: 76,
            top: 370,
            width: 260,
            height: 20,
            child: Text(
              'Buy groceries',
              style: TextStyle(fontSize: 15, color: const Color(0xFFE2E8F0)),
            ),
          ),
          Positioned(
            left: 36,
            top: 376,
            width: 28,
            height: 28,
            child: Container(),
          ),
          Positioned(
            left: 76,
            top: 394,
            width: 200,
            height: 16,
            child: Text(
              'Due today · Personal',
              style: TextStyle(fontSize: 11, color: const Color(0xFF64748B)),
            ),
          ),
          Positioned(
            left: 20,
            top: 436,
            width: 350,
            height: 68,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          Positioned(
            left: 76,
            top: 450,
            width: 260,
            height: 20,
            child: Text(
              'Prepare sprint review slides',
              style: TextStyle(fontSize: 15, color: const Color(0xFFE2E8F0)),
            ),
          ),
          Positioned(
            left: 36,
            top: 456,
            width: 28,
            height: 28,
            child: Container(),
          ),
          Positioned(
            left: 76,
            top: 474,
            width: 200,
            height: 16,
            child: Text(
              'Due tomorrow · Work',
              style: TextStyle(fontSize: 11, color: const Color(0xFF64748B)),
            ),
          ),
          Positioned(
            left: 20,
            top: 528,
            width: 200,
            height: 20,
            child: Text(
              'COMPLETED',
              style: TextStyle(fontSize: 11, color: const Color(0xFF22C55E)),
            ),
          ),
          Positioned(
            left: 20,
            top: 556,
            width: 350,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.6),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          Positioned(
            left: 36,
            top: 572,
            width: 28,
            height: 28,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withOpacity(0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 76,
            top: 572,
            width: 260,
            height: 20,
            child: Text(
              'Reply to client emails',
              style: TextStyle(fontSize: 15, color: const Color(0xFF64748B).withOpacity(0.7)),
            ),
          ),
          Positioned(
            left: 40,
            top: 578,
            width: 20,
            height: 18,
            child: Text(
              '✓',
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
            ),
          ),
          Positioned(
            left: 20,
            top: 628,
            width: 350,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withOpacity(0.6),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          Positioned(
            left: 36,
            top: 644,
            width: 28,
            height: 28,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withOpacity(0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 76,
            top: 644,
            width: 260,
            height: 20,
            child: Text(
              'Morning standup meeting',
              style: TextStyle(fontSize: 15, color: const Color(0xFF64748B).withOpacity(0.7)),
            ),
          ),
          Positioned(
            left: 40,
            top: 650,
            width: 20,
            height: 18,
            child: Text(
              '✓',
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
            ),
          ),
          Positioned(
            left: 310,
            top: 720,
            width: 56,
            height: 56,
            child: GestureDetector(
              onTap: () => context.go('/add_task'),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '+',
                  style: TextStyle(fontSize: 32, color: const Color(0xFFFFFFFF)),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 784,
            width: 390,
            height: 60,
            child: Container(color: const Color(0xFF1E293B)),
          ),
          Positioned(
            left: 40,
            top: 800,
            width: 60,
            height: 20,
            child: Text(
              '🏠',
              style: TextStyle(fontSize: 20, color: const Color(0xFF3B82F6)),
            ),
          ),
          Positioned(
            left: 165,
            top: 800,
            width: 60,
            height: 20,
            child: Text(
              '📅',
              style: TextStyle(fontSize: 20, color: const Color(0xFF64748B)),
            ),
          ),
          Positioned(
            left: 290,
            top: 800,
            width: 60,
            height: 20,
            child: Text(
              '⚙️',
              style: TextStyle(fontSize: 20, color: const Color(0xFF64748B)),
            ),
          ),
          Positioned(
            left: 40,
            top: 820,
            width: 60,
            height: 14,
            child: Text(
              'Today',
              style: TextStyle(fontSize: 9, color: const Color(0xFF3B82F6)),
            ),
          ),
          Positioned(
            left: 165,
            top: 820,
            width: 60,
            height: 14,
            child: Text(
              'Calendar',
              style: TextStyle(fontSize: 9, color: const Color(0xFF64748B)),
            ),
          ),
          Positioned(
            left: 290,
            top: 820,
            width: 60,
            height: 14,
            child: Text(
              'Settings',
              style: TextStyle(fontSize: 9, color: const Color(0xFF64748B)),
            ),
          ),
        ],
      ));
  }
}