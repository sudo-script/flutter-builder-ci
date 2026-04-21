import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Map<String, dynamic>> _pending = [
    {'title': 'Design landing page mockups', 'due': 'Due today', 'cat': 'Work', 'done': false},
    {'title': 'Buy groceries', 'due': 'Due today', 'cat': 'Personal', 'done': false},
    {'title': 'Prepare sprint review slides', 'due': 'Due tomorrow', 'cat': 'Work', 'done': false},
  ];
  final List<Map<String, dynamic>> _completed = [
    {'title': 'Reply to client emails', 'done': true},
    {'title': 'Morning standup meeting', 'done': true},
  ];

  void _toggleTask(int index) {
    setState(() {
      final task = _pending.removeAt(index);
      task['done'] = true;
      _completed.insert(0, task);
    });
  }

  Widget _buildTaskCard(String title, String subtitle, bool done, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: done ? const Color(0xFF1E293B).withValues(alpha: 0.6) : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? const Color(0xFF22C55E).withValues(alpha: 0.7) : Colors.transparent,
                  border: done ? null : Border.all(color: const Color(0xFFF59E0B), width: 2),
                ),
                child: done ? Center(child: Text('\u2713', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold))) : null,
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 15, color: done ? const Color(0xFF64748B).withValues(alpha: 0.7) : const Color(0xFFE2E8F0))),
                    if (subtitle.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String icon, String label, bool active) {
    final color = active ? const Color(0xFF3B82F6) : const Color(0xFF64748B);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(icon, style: TextStyle(fontSize: 20, color: color)),
        SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 9, color: color, fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _pending.length + _completed.length;
    final done = _completed.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Good morning \ud83d\udc4b', style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8))),
                        SizedBox(height: 4),
                        const Text("Today's Plan", style: TextStyle(fontSize: 26, color: Color(0xFFF8FAFC), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/profile'),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Color(0xFF1E293B), shape: BoxShape.circle),
                      child: Center(child: Text('\ud83d\udc64', style: TextStyle(fontSize: 18))),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF1E3A5F), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('\ud83d\udcc5  April 21, 2026', style: TextStyle(fontSize: 13, color: Color(0xFF93C5FD), fontWeight: FontWeight.w600)),
                          SizedBox(height: 8),
                          Text('${_pending.length} tasks remaining', style: const TextStyle(fontSize: 20, color: Color(0xFFDBEAFE), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Container(
                      width: 72, height: 48,
                      decoration: BoxDecoration(color: const Color(0xFF3B82F6), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$done/$total', style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                          const Text('done', style: TextStyle(fontSize: 10, color: Color(0xFF93C5FD))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  if (_pending.isNotEmpty) ...[
                    const Text('PENDING', style: TextStyle(fontSize: 11, color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    ..._pending.asMap().entries.map((e) => _buildTaskCard(
                      e.value['title'] as String,
                      '${e.value['due']} \u00b7 ${e.value['cat']}',
                      false,
                      onTap: () => _toggleTask(e.key),
                    )),
                    SizedBox(height: 20),
                  ],
                  if (_completed.isNotEmpty) ...[
                    const Text('COMPLETED', style: TextStyle(fontSize: 11, color: Color(0xFF22C55E), fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    ..._completed.map((t) => _buildTaskCard(t['title'] as String, '', true)),
                  ],
                ],
              ),
            ),
            Container(
              height: 60,
              color: const Color(0xFF1E293B),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem('\ud83c\udfe0', 'Today', true),
                  _buildNavItem('\ud83d\udcc5', 'Calendar', false),
                  _buildNavItem('\u2699\ufe0f', 'Settings', false),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add_task'),
        backgroundColor: const Color(0xFF3B82F6),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
