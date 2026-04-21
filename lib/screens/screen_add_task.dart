import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});
  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _dueDate;
  String _category = 'Work';
  String _priority = 'Low';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (!mounted || picked == null) return;
    setState(() => _dueDate = picked);
  }

  void _create() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a task name')));
      return;
    }
    if (!mounted) return;
    context.go('/dashboard');
  }

  Widget _buildChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1E3A5F) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: selected ? const Color(0xFF93C5FD) : const Color(0xFF64748B), fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }

  Widget _buildPriority(String label, Color color, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100, height: 38,
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.2) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: selected ? Border.all(color: color, width: 1.5) : null,
        ),
        child: Center(child: Text(label, style: TextStyle(color: selected ? color : const Color(0xFF64748B), fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.normal))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Row(
                children: [
                  GestureDetector(onTap: () => context.go('/dashboard'), child: const Text('\u2190', style: TextStyle(color: Color(0xFFF8FAFC), fontSize: 22))),
                  SizedBox(width: 60),
                  const Text('New Task', style: TextStyle(color: Color(0xFFF8FAFC), fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 32),
              const Text('Task name', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'What do you need to do?', hintStyle: const TextStyle(color: Color(0xFF475569)),
                  filled: true, fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 20),
              const Text('Notes', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              SizedBox(height: 6),
              TextField(
                controller: _notesCtrl, maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Add details or context...', hintStyle: const TextStyle(color: Color(0xFF475569)),
                  filled: true, fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              SizedBox(height: 20),
              const Text('Due date', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              SizedBox(height: 6),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  width: double.infinity, height: 50,
                  decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _dueDate == null ? '\ud83d\udcc5  Pick a date' : '${_dueDate!.month}/${_dueDate!.day}/${_dueDate!.year}',
                    style: const TextStyle(color: Color(0xFF475569), fontSize: 14),
                  ),
                ),
              ),
              SizedBox(height: 20),
              const Text('Category', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              SizedBox(height: 6),
              Row(
                children: [
                  _buildChip('\ud83d\udcbc Work', _category == 'Work', () => setState(() => _category = 'Work')),
                  SizedBox(width: 10),
                  _buildChip('\ud83c\udfe0 Personal', _category == 'Personal', () => setState(() => _category = 'Personal')),
                  SizedBox(width: 10),
                  _buildChip('\ud83d\udcda Study', _category == 'Study', () => setState(() => _category = 'Study')),
                ],
              ),
              SizedBox(height: 20),
              const Text('Priority', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              SizedBox(height: 6),
              Row(
                children: [
                  _buildPriority('Low', const Color(0xFF4ADE80), _priority == 'Low', () => setState(() => _priority = 'Low')),
                  SizedBox(width: 10),
                  _buildPriority('Medium', const Color(0xFFF59E0B), _priority == 'Medium', () => setState(() => _priority = 'Medium')),
                  SizedBox(width: 10),
                  _buildPriority('High', const Color(0xFFEF4444), _priority == 'High', () => setState(() => _priority = 'High')),
                ],
              ),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton(
                  onPressed: _create,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: const Text('Create Task', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity, height: 48,
                child: TextButton(
                  onPressed: () => context.go('/dashboard'),
                  child: const Text('Cancel', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
