import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NoteEditorScreen extends StatefulWidget {
  final String? noteId;
  const NoteEditorScreen({super.key, this.noteId});
  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _client      = Supabase.instance.client;
  final _titleCtrl   = TextEditingController();
  final _picker      = ImagePicker();
  final _notifPlugin = FlutterLocalNotificationsPlugin();
  final _uuid        = const Uuid();

  late QuillController _quill;
  bool   _loading   = true;
  bool   _saving    = false;
  String _color     = '#ffffff';
  bool   _isPinned  = false;
  String? _audioPath;
  DateTime? _reminder;
  List<Map<String, dynamic>> _allTags     = [];
  List<Map<String, dynamic>> _noteTags    = [];
  Map<String, dynamic>?      _existingNote;

  static const _palette = [
    '#ffffff','#fef3c7','#dbeafe','#dcfce7',
    '#fce7f3','#ede9fe','#fee2e2','#f3f4f6',
  ];

  @override
  void initState() {
    super.initState();
    _quill = QuillController.basic();
    _init();
  }

  Future<void> _init() async {
    await _fetchAllTags();
    if (widget.noteId != null) await _loadNote();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _fetchAllTags() async {
    try {
      final data = await _client.from('tags')
        .select('id, name, color')
        .eq('user_id', _client.auth.currentUser!.id);
      if (mounted) setState(() => _allTags = List<Map<String, dynamic>>.from(data as List));
    } catch (_) {}
  }

  Future<void> _loadNote() async {
    try {
      final data = await _client.from('notes')
        .select()
        .eq('id', widget.noteId!)
        .single();
      _existingNote = data;
      _titleCtrl.text = data['title'] as String? ?? '';
      _color    = data['color']     as String? ?? '#ffffff';
      _isPinned = data['is_pinned'] == true;
      _audioPath = data['audio_path'] as String?;
      if (data['reminder_at'] != null) {
        _reminder = DateTime.tryParse(data['reminder_at'].toString());
      }
      if (data['content'] != null) {
        try {
          _quill = QuillController(
            document: Document.fromJson(jsonDecode(data['content'] as String)),
            selection: const TextSelection.collapsed(offset: 0));
        } catch (_) {}
      }
      // Load tags for this note
      final tagData = await _client.from('note_tags')
        .select('tag_id, tags(id, name, color)')
        .eq('note_id', widget.noteId!);
      if (mounted) setState(() =>
        _noteTags = (tagData as List).map((e) => e['tags'] as Map<String, dynamic>).toList());
    } catch (_) {}
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final title     = _titleCtrl.text.trim();
    final content   = jsonEncode(_quill.document.toDelta().toJson());
    final plainText = _quill.document.toPlainText().trim();
    final userId    = _client.auth.currentUser!.id;

    try {
      String noteId;
      if (widget.noteId != null) {
        await _client.from('notes').update({
          'title': title.isEmpty ? 'Untitled' : title,
          'content': content,
          'plain_text': plainText,
          'color': _color,
          'is_pinned': _isPinned,
          'reminder_at': _reminder?.toIso8601String(),
          'audio_path': _audioPath,
        }).eq('id', widget.noteId!);
        noteId = widget.noteId!;
      } else {
        final res = await _client.from('notes').insert({
          'title': title.isEmpty ? 'Untitled' : title,
          'content': content,
          'plain_text': plainText,
          'color': _color,
          'is_pinned': _isPinned,
          'user_id': userId,
          'reminder_at': _reminder?.toIso8601String(),
          'audio_path': _audioPath,
        }).select('id').single();
        noteId = res['id'] as String;
      }
      if (_reminder != null) _scheduleReminder(noteId, title, _reminder!);
      if (mounted) context.go('/notes_list');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _scheduleReminder(String id, String title, DateTime when) {
    if (when.isBefore(DateTime.now())) return;
    _notifPlugin.zonedSchedule(
      id.hashCode.abs() % 100000,
      'Reminder: $title', '',
      tz.TZDateTime.from(when, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails('notes_reminder', 'Note Reminders',
          importance: Importance.high, priority: Priority.high),
        iOS: DarwinNotificationDetails()),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;
    try {
      final bytes = await file.readAsBytes();
      final path  = 'images/${_uuid.v4()}.jpg';
      await _client.storage.from('note-images').uploadBinary(path, bytes,
        fileOptions: FileOptions(contentType: 'image/jpeg'));
      final url = _client.storage.from('note-images').getPublicUrl(path);
      final index = _quill.selection.baseOffset;
      _quill.document.insert(index, BlockEmbed.image(url));
      setState(() {});
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')));
    }
  }

  Future<void> _pickReminder() async {
    final now  = DateTime.now();
    final date = await showDatePicker(context: context,
      initialDate: now.add(const Duration(hours: 1)),
      firstDate: now, lastDate: now.add(const Duration(days: 365)));
    if (date == null) return;
    final time = await showTimePicker(context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))));
    if (time == null) return;
    setState(() => _reminder = DateTime(date.year, date.month, date.day, time.hour, time.minute));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reminder set for ${_reminder.toString().substring(0, 16)}')));
  }

  Future<void> _toggleTag(Map<String, dynamic> tag) async {
    final tagId  = tag['id'] as String;
    final noteId = widget.noteId ?? '';
    final has    = _noteTags.any((t) => t['id'] == tagId);
    setState(() {
      if (has) _noteTags.removeWhere((t) => t['id'] == tagId);
      else     _noteTags.add(tag);
    });
    if (noteId.isEmpty) return;
    try {
      if (has) {
        await _client.from('note_tags')
          .delete().eq('note_id', noteId).eq('tag_id', tagId);
      } else {
        await _client.from('note_tags')
          .insert({'note_id': noteId, 'tag_id': tagId});
      }
    } catch (_) {}
  }

  void _showTagPicker() {
    showModalBottomSheet(context: context, isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.5, maxChildSize: 0.9, minChildSize: 0.3, expand: false,
        builder: (_, scrollCtrl) => Column(children: [
          const Padding(padding: EdgeInsets.all(16),
            child: Text('Select Tags', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
          Expanded(child: ListView.builder(
            controller: scrollCtrl, itemCount: _allTags.length,
            itemBuilder: (__, i) {
              final t   = _allTags[i];
              final sel = _noteTags.any((nt) => nt['id'] == t['id']);
              final c   = Color(int.parse((t['color'] as String).replaceFirst('#', '0xFF')));
              return ListTile(
                leading: CircleAvatar(backgroundColor: c, radius: 12),
                title: Text(t['name'] as String),
                trailing: sel ? const Icon(Icons.check, color: Color(0xFF6366f1)) : null,
                onTap: () { _toggleTag(t); Navigator.pop(ctx); });
            })),
          TextButton(onPressed: () => context.go('/tag_manager'),
            child: const Text('Manage Tags →')),
          const SizedBox(height: 16),
        ])));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _quill.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = Color(int.parse(_color.replaceFirst('#', '0xFF')));
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _save),
        title: Text(_isPinned ? '📌 Pinned' : '',
          style: const TextStyle(fontSize: 13, color: Color(0xFF6b7280))),
        actions: [
          IconButton(icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: () => setState(() => _isPinned = !_isPinned)),
          if (_saving)
            const Padding(padding: EdgeInsets.all(14),
              child: SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2)))
          else
            TextButton(onPressed: _save,
              child: const Text('Save', style: TextStyle(
                color: Color(0xFF6366f1), fontWeight: FontWeight.bold, fontSize: 15))),
        ]),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : Column(children: [
            // Color picker
            Container(
              height: 48, color: bg,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _palette.length,
                itemBuilder: (_, i) {
                  final c = _palette[i];
                  final sel = _color == c;
                  return GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: Container(
                      width: 30, height: 30, margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Color(int.parse(c.replaceFirst('#', '0xFF'))),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: sel ? Colors.black54 : Colors.grey.shade300,
                          width: sel ? 3 : 1))));
                })),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _titleCtrl,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                decoration: const InputDecoration(
                  hintText: 'Title', border: InputBorder.none,
                  hintStyle: TextStyle(color: Color(0xFF9ca3af))),
                textCapitalization: TextCapitalization.sentences)),
            const Divider(height: 1),
            // Quill toolbar
            QuillSimpleToolbar(
              controller: _quill,
              configurations: const QuillSimpleToolbarConfigurations()),
            const Divider(height: 1),
            // Editor body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: QuillEditor.basic(
                  controller: _quill,
                  configurations: const QuillEditorConfigurations(
                    placeholder: 'Start typing...')))),
            // Tags row
            if (_noteTags.isNotEmpty || true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: bg,
                child: Row(children: [
                  Expanded(child: Wrap(spacing: 6, children: [
                    ..._noteTags.map((t) {
                      final c = Color(int.parse((t['color'] as String).replaceFirst('#', '0xFF')));
                      return Chip(
                        label: Text(t['name'] as String, style: const TextStyle(fontSize: 11)),
                        backgroundColor: c.withOpacity(0.25),
                        deleteIcon: const Icon(Icons.close, size: 13),
                        onDeleted: () => _toggleTag(t),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.zero);
                    }),
                    ActionChip(
                      label: const Text('+ Tag', style: TextStyle(fontSize: 11)),
                      onPressed: _showTagPicker,
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(color: Color(0xFFd1d5db)),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  ])),
                ])),
            // Bottom toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: bg, border: Border(top: BorderSide(color: Colors.grey.shade200))),
              child: Row(children: [
                _toolBtn(Icons.image_outlined, Colors.blue, _pickImage),
                const SizedBox(width: 8),
                _toolBtn(Icons.alarm_add_outlined, Colors.amber, _pickReminder),
                if (_reminder != null) Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Chip(
                    label: Text('⏰ ${_reminder.toString().substring(0, 16)}',
                      style: const TextStyle(fontSize: 10)),
                    deleteIcon: const Icon(Icons.close, size: 12),
                    onDeleted: () => setState(() => _reminder = null),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)),
                const Spacer(),
                Text('${_quill.document.toPlainText().trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length} words',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF9ca3af))),
              ])),
          ]),
    );
  }

  Widget _toolBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 18)));
  }
}
