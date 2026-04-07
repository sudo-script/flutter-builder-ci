import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NoteEditorScreen extends StatefulWidget {
  final String? noteId;
  const NoteEditorScreen({Key? key, this.noteId}) : super(key: key);

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final String? _noteId;
  bool _isExisting = false;

  final TextEditingController _titleController = TextEditingController();
  late QuillController _quillController;
  String _backgroundColor = '#ffffff';
  bool _isPinned = false;
  DateTime? _reminderAt;
  final List<String> _selectedTagIds = [];
  List<Map<String, dynamic>> _allTags = [];
  final ImagePicker _picker = ImagePicker();
  FlutterLocalNotificationsPlugin? _flutterLocalNotificationsPlugin;

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _audioFilePath;
  RecorderController? _recorderController;
  PlayerController? _playerController;

  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _noteId = widget.noteId;
    _quillController = QuillController.basic();
    _initNotifications();
    _fetchAllTags();
    if (_noteId != null) {
      _isExisting = true;
      _loadNote();
      _subscribeRealtime();
    }
  }

  Future<void> _initNotifications() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initSettings = InitializationSettings(android: androidSettings);
    await _flutterLocalNotificationsPlugin?.initialize(initSettings);
  }

  void _subscribeRealtime() {
    _channel = Supabase.instance.client.channel('public:notes')
      .on(PostgresChangeEvent.all, (payload, refs) {
        if (payload?.new_?['id'] == _noteId ||
            payload?.old_?['id'] == _noteId) {
          _loadNote();
        }
      }, null).subscribe();
  }

  Future<void> _loadNote() async {
    try {
      final data = await Supabase.instance.client
          .from('notes')
          .select('*, note_tags(tag_id, tags(id, name, color))')
          .eq('id', _noteId)
          .single();
      final note = data as Map<String, dynamic>;
      setState(() {
        _titleController.text = note['title'] ?? '';
        final content = note['content'] as String?;
        if (content != null && content.isNotEmpty) {
          _quillController = QuillController(
            document: Document.fromJson(jsonDecode(content)),
            selection: const TextSelection.collapsed(offset: 0),
          );
        } else {
          _quillController = QuillController.basic();
        }
        _backgroundColor = note['color'] ?? '#ffffff';
        _isPinned = note['is_pinned'] ?? false;
        final ts = note['reminder_at'];
        _reminderAt = ts != null ? DateTime.parse(ts) : null;
        final tags = note['note_tags'] as List<dynamic>?;
        _selectedTagIds.clear();
        tags?.forEach((t) {
          final tagId = t['tag_id'] as String?;
          if (tagId != null) _selectedTagIds.add(tagId);
        });
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _fetchAllTags() async {
    try {
      final data = await Supabase.instance.client
          .from('tags')
          .select('id, name, color')
          .order('created_at', ascending: true);
      setState(() {
        _allTags = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _recorderController?.dispose();
    _playerController?.dispose();
    if (_channel != null) {
      Supabase.instance.client.removeChannel(_channel!);
    }
    super.dispose();
  }

  int _wordCount(String text) {
    if (text.trim().isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final file = File(picked.path);
    final bytes = await file.readAsBytes();
    final path = 'note-images/${const Uuid().v4()}.jpg';
    try {
      await Supabase.instance.client.storage
          .from('note-images')
          .uploadBinary(path, bytes,
              fileOptions: const FileOptions(contentType: 'image/jpeg'));
      final url = Supabase.instance.client.storage
          .from('note-images')
          .getPublicUrl(path);
      final delta = Delta()
        ..insert({'image': url})
        ..insert('\n');
      _quillController.document.compose(
          delta, _quillController.selection, ChangeSource.LOCAL);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _pickReminder() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderAt ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderAt ?? now),
    );
    if (time == null) return;
    final selected = DateTime(
        date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      _reminderAt = selected;
    });
    await _scheduleNotification(selected);
  }

  Future<void> _scheduleNotification(DateTime at) async {
    if (_flutterLocalNotificationsPlugin == null) return;
    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminder',
      channelDescription: 'Notification channel for note reminders',
    );
    final details = NotificationDetails(android: androidDetails);
    await _flutterLocalNotificationsPlugin!
        .zonedSchedule(
          0,
          'Note Reminder',
          _titleController.text,
          at,
          details,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        )
        .then((value) => null)
        .catchError((e) => null);
  }

  Future<void> _toggleRecording() async {
    if (!_isRecording) {
      await _startRecording();
    } else {
      await _stopRecording();
    }
  }

  Future<void> _startRecording() async {
    _recorderController ??= RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
    final appDocDir = await getApplicationDocumentsDirectory();
    final path =
        '${appDocDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorderController!.record(path: path);
    setState(() {
      _isRecording = true;
      _audioFilePath = path;
    });
  }

  Future<void> _stopRecording() async {
    final filePath = await _recorderController!.stop();
    setState(() {
      _isRecording = false;
      _audioFilePath = filePath;
    });
    await _uploadAudio(filePath);
  }

  Future<void> _uploadAudio(String path) async {
    try {
      final file = File(path);
      final bytes = await file.readAsBytes();
      final uploadPath = 'note-audio/${const Uuid().v4()}.m4a';
      await Supabase.instance.client.storage
          .from('note-audio')
          .uploadBinary(uploadPath, bytes,
              fileOptions: const FileOptions(contentType: 'audio/m4a'));
      final url = Supabase.instance.client.storage
          .from('note-audio')
          .getPublicUrl(uploadPath);
      await Supabase.instance.client
          .from('attachments')
          .insert({
            'note_id': _noteId,
            'url': url,
            'type': 'audio',
            'size_kb': await file.length() ~/ 1024
          })
          
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final contentJson = jsonEncode(_quillController.document.toDelta().toJson());
    final plainText = _quillController.document.toPlainText();
    final color = _backgroundColor;
    final isPinned = _isPinned;
    final reminderAtStr = _reminderAt?.toIso8601String();

    try {
      if (_isExisting && _noteId != null) {
        await Supabase.instance.client
            .from('notes')
            .update({
              'title': title,
              'content': contentJson,
              'plain_text': plainText,
              'color': color,
              'is_pinned': isPinned,
              'reminder_at': reminderAtStr
            })
            .eq('id', _noteId)
            
        await Supabase.instance.client
            .from('note_tags')
            .delete()
            .eq('note_id', _noteId)
            
        for (var tagId in _selectedTagIds) {
          await Supabase.instance.client
              .from('note_tags')
              .insert({'note_id': _noteId, 'tag_id': tagId})
              
        }
      } else {
        final create = await Supabase.instance.client
            .from('notes')
            .insert({
              'title': title,
              'content': contentJson,
              'plain_text': plainText,
              'color': color,
              'is_pinned': isPinned,
              'reminder_at': reminderAtStr,
              'user_id':
                  Supabase.instance.client.auth.currentUser?.id?.toString()
            })
            
        final inserted = create.data[0] as Map<String, dynamic>;
        final newId = inserted['id'];
        for (var tagId in _selectedTagIds) {
          await Supabase.instance.client
              .from('note_tags')
              .insert({'note_id': newId, 'tag_id': tagId})
              
        }
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _pickTag() async {
    final selected = await showModalBottomSheet<String>(
        context: context,
        builder: (context) {
          return ListView.builder(
            itemCount: _allTags.length,
            itemBuilder: (context, index) {
              final tag = _allTags[index];
              final id = tag['id'] as String;
              return ListTile(
                title: Text(tag['name'] as String),
                leading: CircleAvatar(
                  backgroundColor: Color(
                      int.parse('${tag['color']}'.replaceFirst('#', '0xFF'))),
                ),
                onTap: () => Navigator.pop(context, id),
              );
            },
          );
        });
    if (selected != null && !_selectedTagIds.contains(selected)) {
      setState(() {
        _selectedTagIds.add(selected);
      });
    }
  }

  Widget _buildTagChip(Map<String, dynamic> tag) {
    final id = tag['id'] as String;
    final isSelected = _selectedTagIds.contains(id);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(tag['name'] as String),
        selected: isSelected,
        onSelected: (v) {
          setState(() {
            if (v) {
              _selectedTagIds.add(id);
            } else {
              _selectedTagIds.remove(id);
            }
          });
        },
        backgroundColor:
            Color(int.parse('${tag['color']}'.replaceFirst('#', '0xFF')))
                .withOpacity(0.2),
        selectedColor:
            Color(int.parse('${tag['color']}').toInt()).withOpacity(0.5),
      ),
  }

  @override
  Widget build(BuildContext context) {
    final plainText = _quillController.document.toPlainText();
    final wordCount = _wordCount(plainText);

    return Scaffold(
      backgroundColor: Color(int.parse(_backgroundColor.replaceFirst('#', '0xFF'))),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              height: 60,
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () async {
                      await _saveNote();
                      context.go('/notes_list');
                    },
                  ),
                  IconButton(
                    icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
                    onPressed: () {
                      setState(() {
                        _isPinned = !_isPinned;
                      });
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                          hintText: 'Title',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                    ),
                  ),
                  TextButton(
                    onPressed: _saveNote,
                    child: const Text('Save',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            // Color picker
            Container(
              height: 60,
              color: Colors.grey[200],
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 8,
                itemBuilder: (_, index) {
                  final col = _palette[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _backgroundColor = col;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      decoration: BoxDecoration(
                        color: Color(int.parse(col.replaceFirst('#', '0xFF'))),
                        shape: BoxShape.circle,
                        border: Border.all(
                            width: _backgroundColor == col ? 3 : 1,
                            color: _backgroundColor == col
                                ? Colors.black87
                                : Colors.grey.shade300),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Editor
            Expanded(
              child: Column(
                children: [
                  QuillToolbar.basic(controller: _quillController),
                  Expanded(
                    child: QuillEditor.basic(
                        controller: _quillController,
                        readOnly: false),
                  ),
                ],
              ),
            ),
            // Tags and actions
            Container(
              height: 80,
              color: Colors.grey[200],
              child: Column(
                children: [
                  // Tag chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _allTags
                          .map((t) => _buildTagChip(t))
                          .toList()
                            ..add(
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: ElevatedButton.icon(
                                  onPressed: _pickTag,
                                  icon: const Icon(Icons.add),
                                  label: const Text('+ Tag'),
                                ),
                              ),
                            ),
                    ),
                  ),
                  // Bottom toolbar
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.image),
                        onPressed: _pickImage,
                      ),
                      IconButton(
                        icon: const Icon(Icons.alarm),
                        onPressed: _pickReminder,
                      ),
                      IconButton(
                        icon: Icon(_isRecording
                            ? Icons.stop
                            : (_isPlaying ? Icons.pause : Icons.mic)),
                        onPressed: _toggleRecording,
                      ),
                      const Spacer(),
                      Text('$wordCount words',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
  }

  final List<String> _palette = [
    '#ffffff',
    '#fef3c7',
    '#dbeafe',
    '#dcfce7',
    '#fce7f3',
    '#ede9fe',
    '#fee2e2',
    '#f3f4f6'
  ];
}