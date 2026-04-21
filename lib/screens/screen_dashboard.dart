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
          // Background rect
          Positioned(
            left: 0,
            top: 0,
            width: 390,
            height: 844,
            child: Container(
              color: const Color(0xFF0F172A),
            ),
          ),
          // Good morning text
          Positioned(
            left: 20,
            top: 60,
            width: 200,
            height: 28,
            child: Text(
              'Good morning 👋',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
          // Profile avatar circle
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
                child: Center(
                  child: Text(
                    '👤',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Today's Plan text
          Positioned(
            left: 20,
            top: 84,
            width: 260,
            height: 36,
            child: Text(
              "Today's Plan",
              style: const TextStyle(
                fontSize: 26,
                color: Color(0xFFF8FAFC),
              ),
            ),
          ),
          // Date rect
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
          // Date text
          Positioned(
            left: 36,
            top: 152,
            width: 200,
            height: 20,
            child: Text(
              '📅  April 21, 2026',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF93C5FD),
              ),
            ),
          ),
          // Progress card
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
              child: Center(
                child: Text(
                  '5/8',
                  style: const TextStyle(
                    fontSize: 22,
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ),
          ),
          // Tasks remaining text
          Positioned(
            left: 36,
            top: 178,
            width: 180,
            height: 32,
            child: Text(
              '3 tasks remaining',
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFFDBEAFE),
              ),
            ),
          ),
          // Done text
          Positioned(
            left: 280,
            top: 190,
            width: 72,
            height: 14,
            child: Text(
              'done',
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF93C5FD),
              ),
            ),
          ),
          // Pending label
          Positioned(
            left: 20,
            top: 248,
            width: 200,
            height: 20,
            child: Text(
              'PENDING',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFFF59E0B),
              ),
            ),
          ),
          // Pending card
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
          // Task title
          Positioned(
            left: 76,
            top: 290,
            width: 260,
            height: 20,
            child: Text(
              'Design landing page mockups',
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFFE2E8F0),
              ),
            ),
          ),
          // Circle transparent
          Positioned(
            left: 36,
            top: 296,
            width: 28,
            height: 28,
            child: Container(
              color: Colors.transparent,
            ),
          ),
          // Due info
          Positioned(
            left: 76,
            top: 314,
            width: 200,
            height: 16,
            child: Text(
              'Due today · Work',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          // Buy groceries card
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
          // Task title
          Positioned(
            left: 76,
            top: 370,
            width: 260,
            height: 20,
            child: Text(
              'Buy groceries',
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFFE2E8F0),
              ),
            ),
          ),
          // Circle transparent
          Positioned(
            left: 36,
            top: 376,
            width: 28,
            height: 28,
            child: Container(
              color: Colors.transparent,
            ),
          ),
          // Due info
          Positioned(
            left: 76,
            top: 394,
            width: 200,
            height: 16,
            child: Text(
              'Due today · Personal',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          // Prepare slides card
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
          // Task title
          Positioned(
            left: 76,
            top: 450,
            width: 260,
            height: 20,
            child: Text(
              'Prepare sprint review slides',
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFFE2E8F0),
              ),
            ),
          ),
          // Circle transparent
          Positioned(
            left: 36,
            top: 456,
            width: 28,
            height: 28,
            child: Container(
              color: Colors.transparent,
            ),
          ),
          // Due info
          Positioned(
            left: 76,
            top: 474,
            width: 200,
            height: 16,
            child: Text(
              'Due tomorrow · Work',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          // Completed label
          Positioned(
            left: 20,
            top: 528,
            width: 200,
            height: 20,
            child: Text(
              'COMPLETED',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF22C55E),
              ),
            ),
          ),
          // Completed card
          Positioned(
            left: 20,
            top: 556,
            width: 350,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0x991E293B),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          // Circle green
          Positioned(
            left: 36,
            top: 572,
            width: 28,
            height: 28,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xB222C55E),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Task title
          Positioned(
            left: 76,
            top: 572,
            width: 260,
            height: 20,
            child: Text(
              'Reply to client emails',
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xB264748B),
              ),
            ),
          ),
          // Check icon
          Positioned(
            left: 40,
            top: 578,
            width: 20,
            height: 18,
            child: Text(
              '✓',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xE6FFFFFF),
              ),
            ),
          ),
          // Morning meeting card
          Positioned(
            left: 20,
            top: 628,
            width: 350,
            height: 60,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0x991E293B),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          // Circle green
          Positioned(
            left: 36,
            top: 644,
            width: 28,
            height: 28,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xB222C55E),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Meeting title
          Positioned(
            left: 76,
            top: 644,
            width: 260,
            height: 20,
            child: Text(
              'Morning standup meeting',
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xB264748B),
              ),
            ),
          ),
          // Check icon
          Positioned(
            left: 40,
            top: 650,
            width: 20,
            height: 18,
            child: Text(
              '✓',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xE6FFFFFF),
              ),
            ),
          ),
          // Floating action button
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
                child: Center(
                  child: Text(
                    '+',
                    style: const TextStyle(
                      fontSize: 32,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Bottom navigation bar
          Positioned(
            left: 0,
            top: 784,
            width: 390,
            height: 60,
            child: Container(
              color: const Color(0xFF1E293B),
            ),
          ),
          // Home icon
          Positioned(
            left: 40,
            top: 800,
            width: 60,
            height: 20,
            child: Text(
              '🏠',
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),
          // Calendar icon
          Positioned(
            left: 165,
            top: 800,
            width: 60,
            height: 20,
            child: Text(
              '📅',
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          // Settings icon
          Positioned(
            left: 290,
            top: 800,
            width: 60,
            height: 20,
            child: Text(
              '⚙️',
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          // Bottom labels
          Positioned(
            left: 40,
            top: 820,
            width: 60,
            height: 14,
            child: Text(
              'Today',
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF3B82F6),
              ),
            ),
          ),
          Positioned(
            left: 165,
            top: 820,
            width: 60,
            height: 14,
            child: Text(
              'Calendar',
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Positioned(
            left: 290,
            top: 820,
            width: 60,
            height: 14,
            child: Text(
              'Settings',
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ],
      ));
  }
}