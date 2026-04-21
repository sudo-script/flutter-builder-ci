import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedCategory = 'Work';
  String _selectedPriority = 'Low';

  @override
  void dispose() {
    _taskNameController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  String get _formattedDueDate {
    if (_selectedDate == null) return '📅  Pick a date';
    return '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}';
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date != null) {
      if (!mounted) return;
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _submitTask() async {
    try {
      await Supabase.instance.client
          .from('tasks')
          .insert([
            {
              'name': _taskNameController.text,
              'description': _detailsController.text,
              'due_date': _selectedDate?.toIso8601String(),
              'category': _selectedCategory,
              'priority': _selectedPriority,
              'created_at': DateTime.now().toIso8601String();
            }
          ])
          .single();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error creating task')));
      }
      return;
    }
    if (!mounted) return;
    context.go('/dashboard');
  }

  void _navigateBack() {
    if (!mounted) return;
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Rect
          Positioned(
            left: 0,
            top: 0,
            width: 390,
            height: 844,
            child: Container(
              color: Color(0xFF0f172a),
            ),
          ),
          // Back arrow
          Positioned(
            left: 16,
            top: 60,
            width: 40,
            height: 28,
            child: Text(
              "←",
              style:
                  TextStyle(fontSize: 22, color: Color(0xFFf8fafc)),
            ),
          ),
          // Title
          Positioned(
            left: 100,
            top: 62,
            width: 190,
            height: 28,
            child: Text(
              "New Task",
              style:
                  TextStyle(fontSize: 20, color: Color(0xFFf8fafc)),
            ),
          ),
          // Task name label
          Positioned(
            left: 24,
            top: 120,
            width: 200,
            height: 18,
            child: Text(
              "Task name",
              style: TextStyle(
                  fontSize: 12, color: Color(0xFF94a3b8)),
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
                color: Color(0xFF1e293b),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          Positioned(
            left: 24 + 12,
            top: 142 + 12,
            width: 342 - 24,
            height: 50 - 24,
            child: TextField(
              controller: _taskNameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '',
                hintStyle:
                    TextStyle(color: Color(0xFF475569)),
                border: InputBorder.none,
              ),
            ),
          ),
          // Task name subtext
          Positioned(
            left: 40,
            top: 158,
            width: 300,
            height: 20,
            child: Text(
              "What do you need to do?",
              style:
                  TextStyle(fontSize: 14, color: Color(0xFF475569)),
            ),
          ),
          // Notes label
          Positioned(
            left: 24,
            top: 216,
            width: 200,
            height: 18,
            child: Text(
              "Notes",
              style: TextStyle(
                  fontSize: 12, color: Color(0xFF94a3b8)),
            ),
          ),
          // Notes input background
          Positioned(
            left: 24,
            top: 238,
            width: 342,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF1e293b),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          Positioned(
            left: 24 + 12,
            top: 238 + 12,
            width: 342 - 24,
            height: 100 - 24,
            child: TextField(
              controller: _detailsController,
              maxLines: null,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '',
                hintStyle:
                    TextStyle(color: Color(0xFF475569)),
                border: InputBorder.none,
              ),
            ),
          ),
          // Notes subtext
          Positioned(
            left: 40,
            top: 254,
            width: 300,
            height: 20,
            child: Text(
              "Add details or context...",
              style:
                  TextStyle(fontSize: 14, color: Color(0xFF475569)),
            ),
          ),
          // Due date label
          Positioned(
            left: 24,
            top: 362,
            width: 200,
            height: 18,
            child: Text(
              "Due date",
              style: TextStyle(
                  fontSize: 12, color: Color(0xFF94a3b8)),
            ),
          ),
          // Due date picker background
          Positioned(
            left: 24,
            top: 384,
            width: 342,
            height: 50,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF1e293b),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          Positioned(
            left: 24 + 12,
            top: 384 + 12,
            width: 342 - 24,
            height: 50 - 24,
            child: GestureDetector(
              onTap: _selectDate,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _formattedDueDate,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF475569)),
                ),
              ),
            ),
          ),
          // Category label
          Positioned(
            left: 24,
            top: 458,
            width: 200,
            height: 18,
            child: Text(
              "Category",
              style: TextStyle(
                  fontSize: 12, color: Color(0xFF94a3b8)),
            ),
          ),
          // Work category
          Positioned(
            left: 24,
            top: 480,
            width: 106,
            height: 40,
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedCategory = 'Work');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1e3a5f),
                  borderRadius: BorderRadius.circular(20),
                  border: _selectedCategory == 'Work'
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                ),
                alignment: Alignment.center,
                child: const Text(
                  "💼 Work",
                  style:
                      TextStyle(fontSize: 13, color: Color(0xFF93c5fd)),
                ),
              ),
            ),
          ),
          // Personal category
          Positioned(
            left: 142,
            top: 480,
            width: 120,
            height: 40,
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedCategory = 'Personal');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(20),
                  border: _selectedCategory == 'Personal'
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                ),
                alignment: Alignment.center,
                child: const Text(
                  "🏠 Personal",
                  style: TextStyle(
                      fontSize: 13, color: Color(0xFF64748b)),
                ),
              ),
            ),
          ),
          // Study category
          Positioned(
            left: 274,
            top: 480,
            width: 92,
            height: 40,
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedCategory = 'Study');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(20),
                  border: _selectedCategory == 'Study'
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                ),
                alignment: Alignment.center,
                child: const Text(
                  "📚 Study",
                  style:
                      TextStyle(fontSize: 13, color: Color(0xFF64748b)),
                ),
              ),
            ),
          ),
          // Priority label
          Positioned(
            left: 24,
            top: 548,
            width: 200,
            height: 18,
            child: Text(
              "Priority",
              style:
                  TextStyle(fontSize: 12, color: Color(0xFF94a3b8)),
            ),
          ),
          // Low priority
          Positioned(
            left: 24,
            top: 572,
            width: 100,
            height: 38,
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedPriority = 'Low');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF14532d),
                  borderRadius: BorderRadius.circular(10),
                  border: _selectedPriority == 'Low'
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Low",
                  style:
                      TextStyle(fontSize: 13, color: Color(0xFF4ade80)),
                ),
              ),
            ),
          ),
          // Medium priority
          Positioned(
            left: 136,
            top: 572,
            width: 100,
            height: 38,
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedPriority = 'Medium');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(10),
                  border: _selectedPriority == 'Medium'
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Medium",
                  style: TextStyle(
                      fontSize: 13, color: Color(0xFF64748b)),
                ),
              ),
            ),
          ),
          // High priority
          Positioned(
            left: 248,
            top: 572,
            width: 100,
            height: 38,
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedPriority = 'High');
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(10),
                  border: _selectedPriority == 'High'
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                ),
                alignment: Alignment.center,
                child: const Text(
                  "High",
                  style: TextStyle(
                      fontSize: 13, color: Color(0xFF64748b)),
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
            child: ElevatedButton(
              onPressed: null,
              child: Text(
                'Create Task',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          // Cancel text
          Positioned(
            left: 24,
            top: 728,
            width: 342,
            height: 48,
            child: GestureDetector(
              // will override on tap
              child: Text(
                'Cancel',
                style:
                    TextStyle(fontSize: 14, color: Color(0xFF94a3b8)),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _navigateBack,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF94a3b8)),
              ),
            ),
            ElevatedButton(
              onPressed: _submitTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3b82f6),
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Create Task',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ));
  }
}