import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedCategory = 'Work';
  String _selectedPriority = 'Low';

  @override
  void dispose() {
    _taskNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background rectangle
          Positioned(
            left: 0,
            top: 0,
            width: 390,
            height: 844,
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
              child: Text(
                '←',
                style: const TextStyle(
                  color: Color(0xFFFCFCFC),
                  fontSize: 22,
                ),
              ),
            ),
          ),
          // Title
          Positioned(
            left: 100,
            top: 62,
            child: Text(
              'New Task',
              style: const TextStyle(
                color: Color(0xFFFCFCFC),
                fontSize: 20,
              ),
            ),
          ),
          // Task name label
          Positioned(
            left: 24,
            top: 120,
            child: Text(
              'Task name',
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
              ),
            ),
          ),
          // Task name input background
          Positioned(
            left: 24,
            top: 142,
            width: 342,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Task name field
          Positioned(
            left: 40,
            top: 158,
            width: 300,
            height: 20,
            child: TextField(
              controller: _taskNameController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'What do you need to do?',
                hintStyle: TextStyle(color: Color(0xFF475569)),
                border: InputBorder.none,
              ),
            ),
          ),
          // Notes label
          Positioned(
            left: 24,
            top: 216,
            child: Text(
              'Notes',
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
              ),
            ),
          ),
          // Notes background
          Positioned(
            left: 24,
            top: 238,
            width: 342,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Notes field
          Positioned(
            left: 40,
            top: 254,
            width: 300,
            height: 80,
            child: TextField(
              controller: _notesController,
              maxLines: null,
              expands: true,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Add details or context...',
                hintStyle: TextStyle(color: Color(0xFF475569)),
                border: InputBorder.none,
              ),
            ),
          ),
          // Due date label
          Positioned(
            left: 24,
            top: 292,
            child: Text(
              'Due date',
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
              ),
            ),
          ),
          // Due date picker
          Positioned(
            left: 24,
            top: 384,
            width: 342,
            height: 50,
            child: GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (!mounted) return;
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _selectedDate == null
                        ? '📅  Pick a date'
                        : '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}',
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Category label
          Positioned(
            left: 24,
            top: 458,
            child: Text(
              'Category',
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
              ),
            ),
          ),
          // Work category button
          Positioned(
            left: 24,
            top: 480,
            width: 106,
            height: 40,
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = 'Work'),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A5F),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '💼 Work',
                    style: const TextStyle(
                      color: Color(0xFF93C5FD),
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Personal category button
          Positioned(
            left: 142,
            top: 480,
            width: 120,
            height: 40,
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = 'Personal'),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '🏠 Personal',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Study category button
          Positioned(
            left: 274,
            top: 480,
            width: 92,
            height: 40,
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = 'Study'),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '📚 Study',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Priority label
          Positioned(
            left: 24,
            top: 548,
            child: Text(
              'Priority',
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
              ),
            ),
          ),
          // Low priority button
          Positioned(
            left: 24,
            top: 572,
            width: 100,
            height: 38,
            child: GestureDetector(
              onTap: () => setState(() => _selectedPriority = 'Low'),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedPriority == 'Low'
                      ? const Color(0xFF4ADE80)
                      : const Color(0xFF14532D),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Low',
                    style: const TextStyle(
                      color: Color(0xFF4ADE80),
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Medium priority button
          Positioned(
            left: 136,
            top: 572,
            width: 100,
            height: 38,
            child: GestureDetector(
              onTap: () => setState(() => _selectedPriority = 'Medium'),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedPriority == 'Medium'
                      ? const Color(0xFF64748B)
                      : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Medium',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // High priority button
          Positioned(
            left: 248,
            top: 572,
            width: 100,
            height: 38,
            child: GestureDetector(
              onTap: () => setState(() => _selectedPriority = 'High'),
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedPriority == 'High'
                      ? const Color(0xFF64748B)
                      : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'High',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Create Task button
          Positioned(
            left: 24,
            top: 660,
            width: 342,
            height: 54,
            child: GestureDetector(
              onTap: () {
                // Here you would normally handle create logic
                context.go('/dashboard');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    'Create Task',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Cancel button
          Positioned(
            left: 24,
            top: 728,
            width: 342,
            height: 48,
            child: GestureDetector(
              onTap: () {
                context.go('/dashboard');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    'Cancel',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
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