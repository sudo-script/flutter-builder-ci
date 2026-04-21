import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _taskNameCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();
  DateTime? _dueDate;
  String? _category;
  String? _priority;

  @override
  void dispose() {
    _taskNameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (date != null) {
      if (!mounted) return;
      setState(() {
        _dueDate = date;
      });
    }
  }

  void _selectCategory(String cat) {
    if (!mounted) return;
    setState(() {
      _category = cat;
    });
  }

  void _selectPriority(String prio) {
    if (!mounted) return;
    setState(() {
      _priority = prio;
    });
  }

  Future<void> _createTask() async {
    final name = _taskNameCtrl.text.trim();
    if (name.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter task name')),
      );
      return;
    }
    // Task creation logic would be here
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
          Positioned(
            left: 0,
            top: 0,
            width: 390,
            height: 844,
            child: Container(color: Color(0xFF0f172a)),
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
                style: TextStyle(color: Color(0xFFf8fafc), fontSize: 22),
              ),
            ),
          ),
          Positioned(
            left: 100,
            top: 62,
            width: 190,
            height: 28,
            child: Text(
              'New Task',
              style: TextStyle(color: Color(0xFFf8fafc), fontSize: 20),
            ),
          ),
          Positioned(
            left: 24,
            top: 120,
            width: 200,
            height: 18,
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
                color: Color(0xFF1e293b),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TextField(
                controller: _taskNameCtrl,
                style: TextStyle(color: Color(0xFFf8fafc)),
                decoration: InputDecoration(
                  hintText: 'What do you need to do?',
                  hintStyle: TextStyle(color: Color(0xFF475569)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 216,
            width: 200,
            height: 18,
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
                color: Color(0xFF1e293b),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.all(8),
              child: TextField(
                controller: _notesCtrl,
                style: TextStyle(color: Color(0xFFf8fafc)),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Add details or context...',
                  hintStyle: TextStyle(color: Color(0xFF475569)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 362,
            width: 200,
            height: 18,
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
                  color: Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Color(0xFF475569),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      _dueDate != null
                          ? '${_dueDate!.month}/${_dueDate!.day}/${_dueDate!.year}'
                          : '📅  Pick a date',
                      style:
                          TextStyle(color: Color(0xFF475569), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 458,
            width: 200,
            height: 18,
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
              onTap: () => _selectCategory('Work'),
              child: Container(
                decoration: BoxDecoration(
                  color: _category == 'Work' ? Color(0xFF93c5fd) : Color(0xFF1e3a5f),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  '💼 Work',
                  style: TextStyle(
                    color: _category == 'Work' ? Color(0xFF1e293b) : Color(0xFF93c5fd),
                    fontSize: 13,
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
              onTap: () => _selectCategory('Personal'),
              child: Container(
                decoration: BoxDecoration(
                  color: _category == 'Personal' ? Color(0xFF64748b) : Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  '🏠 Personal',
                  style: TextStyle(
                    color: _category == 'Personal' ? Color(0xFF1e293b) : Color(0xFF64748b),
                    fontSize: 13,
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
              onTap: () => _selectCategory('Study'),
              child: Container(
                decoration: BoxDecoration(
                  color: _category == 'Study' ? Color(0xFF64748b) : Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  '📚 Study',
                  style: TextStyle(
                    color: _category == 'Study' ? Color(0xFF1e293b) : Color(0xFF64748b),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 548,
            width: 200,
            height: 18,
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
              onTap: () => _selectPriority('Low'),
              child: Container(
                decoration: BoxDecoration(
                  color: _priority == 'Low' ? Color(0xFF4ade80) : Color(0xFF14532d),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Low',
                  style: TextStyle(
                    color: _priority == 'Low' ? Color(0xFF14532d) : Color(0xFF4ade80),
                    fontSize: 13,
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
              onTap: () => _selectPriority('Medium'),
              child: Container(
                decoration: BoxDecoration(
                  color: _priority == 'Medium' ? Color(0xFF64748b) : Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Medium',
                  style: TextStyle(
                    color: _priority == 'Medium' ? Color(0xFF1e293b) : Color(0xFF64748b),
                    fontSize: 13,
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
              onTap: () => _selectPriority('High'),
              child: Container(
                decoration: BoxDecoration(
                  color: _priority == 'High' ? Color(0xFF64748b) : Color(0xFF1e293b),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  'High',
                  style: TextStyle(
                    color: _priority == 'High' ? Color(0xFF1e293b) : Color(0xFF64748b),
                    fontSize: 13,
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
              onTap: _createTask,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF3b82f6),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Create Task',
                  style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),
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
                decoration: BoxDecoration(
                  color: Color(0x00000000),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFF94a3b8), fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ));
  }
}