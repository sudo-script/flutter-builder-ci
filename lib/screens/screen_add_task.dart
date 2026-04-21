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
  DateTime? _dueDate;
  String _category = 'Work';
  String _priority = 'Low';

  @override
  void dispose() {
    _taskNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _pickDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      if (!mounted) return;
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _handleCreate() {
    final taskName = _taskNameController.text.trim();
    final notes = _notesController.text.trim();
    if (taskName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter task name')),
      );
      return;
    }
    debugPrint(
        'Creating task: $taskName\nNotes: $notes\nDue: $_dueDate\nCategory: $_category\nPriority: $_priority');
    context.go('/dashboard');
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
            child: Container(color: const Color(0xFF0f172a)),
          ),
          Positioned(
            left: 16,
            top: 60,
            child: GestureDetector(
              onTap: () => context.go('/dashboard'),
              child: const Text(
                '←',
                style: TextStyle(color: Color(0xFFf8fafc), fontSize: 22),
              ),
            ),
          ),
          Positioned(
            left: 100,
            top: 62,
            child: const Text(
              'New Task',
              style: TextStyle(color: Color(0xFFf8fafc), fontSize: 20),
            ),
          ),
          Positioned(
            left: 24,
            top: 120,
            child: Text(
              'Task name',
              style: TextStyle(color: Color(0xFF94a3b8), fontSize: 12),
            ),
          ),
          Positioned(
            left: 24,
            top: 142,
            width: 342,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1e293b),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _taskNameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'What do you need to do?',
                    hintStyle: TextStyle(color: Color(0xFF475569)),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 216,
            child: Text(
              'Notes',
              style: TextStyle(color: Color(0xFF94a3b8), fontSize: 12),
            ),
          ),
          Positioned(
            left: 24,
            top: 238,
            width: 342,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1e293b),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _notesController,
                  maxLines: null,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Add details or context...',
                    hintStyle: TextStyle(color: Color(0xFF475569)),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 362,
            child: Text(
              'Due date',
              style: TextStyle(color: Color(0xFF94a3b8), fontSize: 12),
            ),
          ),
          Positioned(
            left: 24,
            top: 384,
            width: 342,
            height: 50,
            child: GestureDetector(
              onTap: _pickDueDate,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _dueDate == null
                        ? '📅  Pick a date'
                        : '${_dueDate!.month}/${_dueDate!.day}/${_dueDate!.year}',
                    style: const TextStyle(
                        color: Color(0xFF475569), fontSize: 14),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 458,
            child: Text(
              'Category',
              style: TextStyle(color: Color(0xFF94a3b8), fontSize: 12),
            ),
          ),
          Positioned(
            left: 24,
            top: 480,
            width: 106,
            height: 40,
            child: GestureDetector(
              onTap: () {
                if (!mounted) return;
                setState(() => _category = 'Work');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _category == 'Work'
                      ? const Color(0xFF1e3a5f)
                      : const Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '💼 Work',
                    style:
                        TextStyle(color: Color(0xFF93c5fd), fontSize: 13),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 142,
            top: 480,
            width: 120,
            height: 40,
            child: GestureDetector(
              onTap: () {
                if (!mounted) return;
                setState(() => _category = 'Personal');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _category == 'Personal'
                      ? const Color(0xFF1e3a5f)
                      : const Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '🏠 Personal',
                    style:
                        TextStyle(color: Color(0xFF64748b), fontSize: 13),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 274,
            top: 480,
            width: 92,
            height: 40,
            child: GestureDetector(
              onTap: () {
                if (!mounted) return;
                setState(() => _category = 'Study');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _category == 'Study'
                      ? const Color(0xFF1e3a5f)
                      : const Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '📚 Study',
                    style:
                        TextStyle(color: Color(0xFF64748b), fontSize: 13),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 548,
            child: Text(
              'Priority',
              style: TextStyle(color: Color(0xFF94a3b8), fontSize: 12),
            ),
          ),
          Positioned(
            left: 24,
            top: 572,
            width: 100,
            height: 38,
            child: GestureDetector(
              onTap: () {
                if (!mounted) return;
                setState(() => _priority = 'Low');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _priority == 'Low'
                      ? const Color(0xFF14532d)
                      : const Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Low',
                    style: TextStyle(color: Color(0xFF4ade80), fontSize: 13),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 136,
            top: 572,
            width: 100,
            height: 38,
            child: GestureDetector(
              onTap: () {
                if (!mounted) return;
                setState(() => _priority = 'Medium');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _priority == 'Medium'
                      ? const Color(0xFF1e293b)
                      : const Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Medium',
                    style: TextStyle(color: Color(0xFF64748b), fontSize: 13),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 248,
            top: 572,
            width: 100,
            height: 38,
            child: GestureDetector(
              onTap: () {
                if (!mounted) return;
                setState(() => _priority = 'High');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _priority == 'High'
                      ? const Color(0xFF1e293b)
                      : const Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'High',
                    style: TextStyle(color: Color(0xFF64748b), fontSize: 13),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 660,
            width: 342,
            height: 54,
            child: GestureDetector(
              onTap: _handleCreate,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF3b82f6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    'Create Task',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 728,
            width: 342,
            height: 48,
            child: GestureDetector(
              onTap: () => context.go('/dashboard'),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF94a3b8), fontSize: 14),
                  ),
                ),
              ),
            ),
          ),
        ],
      ));
  }
}