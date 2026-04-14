import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/timezone.dart' as tz;

class NoteEditorScreen extends StatefulWidget {
  final String? noteId;
  const NoteEditorScreen({Key? key, this.noteId}) : super(key: key);

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  // Controllers
  final TextEditingController _titleController = TextEditingController();
  late QuillController _quillController;
  final ImagePicker _picker = ImagePicker();

  // Tag handling
  List<Map<String, dynamic>> _allTags = [];
  List<String> _selectedTagIds = [];

  // Note state
  String _noteColor = '#ffffff';
  bool _isPinned = false;
  DateTime? _reminderAt;
  String? _audioUrl;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _audioLocalPath;

  // Realtime
  late final RealtimeChannel _channel;

  // Notifications
  final FlutterLocalNotificationsPlugin _notificationPlugin =
      FlutterLocalNotificationsPlugin();

  // Recorders
  late RecorderController _recCtrl;
  late PlayerController _playCtrl;

  // Audio recording timer
  Timer? _recordTimer;
  int _recordDurationSeconds = 0;

  @override
  void initState() {
    super.initState();
    _quillController = QuillController.basic();
    _recCtrl = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
    _playCtrl = PlayerController();
    _loadTags();
    if (widget.noteId != null) {
      _loadNote();
    } else {
      _quillController = QuillController.basic();
    }
    _subscribeRealtime();
  }

  Future<void> _loadTags() async {
    try {
      final data = await Supabase.instance.client
          .from('tags')
          .select('id, name, color')
          .order('name', ascending: true);
      setState(() {
        _allTags = List<Map<String, dynamic>>.from(data);
      });
    } catch (_) {}
  }

  Future<void> _loadNote() async {
    try {
      final data = await Supabase.instance.client
          .from('notes')
          .select(
              'title, content, plain_text, color, is_pinned, reminder_at, audio_url')
          .eq('id', widget.noteId!)
          .single();
      setState(() {
        _titleController.text = data['title'] ?? '';
        _noteColor = data['color'] ?? '#ffffff';
        _isPinned = data['is_pinned'] ?? false;
        _reminderAt = data['reminder_at'] != null
            ? DateTime.parse(data['reminder_at'])
            : null;
        _audioUrl = data['audio_url'];
        if (data['content'] != null) {
          _quillController = QuillController(
              document:
                  Document.fromJson(jsonDecode(data['content'])),
              selection:
                  const TextSelection.collapsed(offset: 0));
        }
      });
      // Fetch tags for this note
      final noteTags = await Supabase.instance.client
          .from('note_tags')
          .select('tag_id')
          .eq('note_id', widget.noteId!);
      setState(() {
        _selectedTagIds =
            List<String>.from(noteTags.map((e) => e['tag_id'].toString()));
      });
    } catch (_) {}
  }

  void _subscribeRealtime() {
    _channel = Supabase.instance.client.channel('public:notes')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'notes',
            callback: (payload) {
          if (widget.noteId != null &&
              payload.newRecord['id'] == widget.noteId) {
            _loadNote();
          }
        })
        .subscribe();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _recCtrl.dispose();
    _playCtrl.dispose();
    _notificationPlugin.cancelAll();
    Supabase.instance.client.removeChannel(_channel);
    _recordTimer?.cancel();
    super.dispose();
  }

  Future<void> _autoSave() async {
    await _saveNote();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final contentJson = jsonEncode(_quillController.document.toDelta().toJson());
    final plainText = _quillController.document.toPlainText();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      if (widget.noteId != null) {
        await Supabase.instance.client
            .from('notes')
            .update({
              'title': title,
              'content': contentJson,
              'plain_text': plainText,
              'color': _noteColor,
              'is_pinned': _isPinned,
              'reminder_at': _reminderAt?.toIso8601String(),
              'audio_url': _audioUrl
            })
            .eq('id', widget.noteId!)
            .eq('user_id', userId);
        await _updateNoteTags();
      } else {
        final data = await Supabase.instance.client
            .from('notes')
            .insert({
              'title': title,
              'content': contentJson,
              'plain_text': plainText,
              'color': _noteColor,
              'is_pinned': _isPinned,
              'reminder_at': _reminderAt?.toIso8601String(),
              'audio_url': _audioUrl,
              'user_id': userId
            })
            .single();
        final newNoteId = data['id'] as String;
        await _updateNoteTags();
        // link to new note
      }
    } catch (_) {}
  }

  Future<void> _updateNoteTags() async {
    if (_localNoteId = = null) return;
    final noteId = widget.noteId!;
    // delete existing
    await Supabase.instance.client
        .from('note_tags')
        .delete()
        .eq('note_id', noteId);
    // insert new
    for (var tagId in _selectedTagIds) {
      await Supabase.instance.client
          .from('note_tags')
          .insert({'note_id': noteId, 'tag_id': tagId});
    }
  }

  void _togglePin() {
    setState(() {
      _isPinned = !_isPinned;
    });
  }

  Future<void> _pickImage() async {
    final XFile? imageFile = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (imageFile == null) return;
    final bytes = await imageFile.readAsBytes();
    final uid = Uuid().v4();
    final path = 'uploads/notes/${uid}.jpg';
    await Supabase.instance.client.storage
        .from('note-images')
        .uploadBinary(path, bytes, fileOptions: FileOptions(contentType: 'image/jpeg'));
    final url = Supabase.instance.client.storage
        .from('note-images')
        .getPublicUrl(path);
    final currentIdx = _quillController.selection.baseOffset;
    setState(() {
      _quillController.document
          .insert(currentIdx, BlockEmbed.image(url));
    });
  }

  Future<void> _pickAlarm() async {
    final date = await showDatePicker(
        context: context,
        initialDate: _reminderAt ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (date == null) return;
    final timeOfDay = await showTimePicker(
        context: context, initialTime: TimeOfDay.now());
    if (timeOfDay == null) return;
    final reminderDateTime = DateTime(date.year, date.month, date.day,
        timeOfDay.hour, timeOfDay.minute);
    setState(() {
      _reminderAt = reminderDateTime;
    });
    await _scheduleAlarm(reminderDateTime);
  }

  Future<void> _scheduleAlarm(DateTime reminder) async {
    final androidDetails = AndroidNotificationDetails(
        'note_alarm', 'Note Reminders',
        notificationChannelName: 'note_alarm');
    final iOSDetails = DarwinNotificationDetails();
    final notificationDetails = NotificationDetails(
        android: androidDetails, iOS: iOSDetails);
    final tzAt = tz.TZDateTime.from(reminder, tz.local);
    await _notificationPlugin.zonedSchedule(
        reminder.hashCode,
        _titleController.text,
        'Reminder: ${_titleController.text}',
        tzAt,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> _startRecording() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final filePath = '${appDocDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recCtrl.record(path: filePath);
    setState(() {
      _isRecording = true;
      _audioLocalPath = filePath;
      _recordDurationSeconds = 0;
    });
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _recordDurationSeconds += 1;
      });
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recCtrl.stop();
    _recordTimer?.cancel();
    setState(() {
      _isRecording = false;
    });
    // upload
    final file = File(path!);
    final bytes = await file.readAsBytes();
    final uid = Uuid().v4();
    final uploadPath = 'uploads/audio_${uid}.m4a';
    await Supabase.instance.client.storage
        .from('note-audio')
        .uploadBinary(uploadPath, bytes,
            fileOptions:
                FileOptions(contentType: 'audio/m4a'));
    final url = Supabase.instance.client.storage
        .from('note-audio')
        .getPublicUrl(uploadPath);
    setState(() {
      _audioUrl = url;
    });
  }

  void _showTagPicker() {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return ListView(
            children: _allTags
                .map((t) => CheckboxListTile(
                      title: Text(t['name']),
                      value: _selectedTagIds.contains(t['id'].toString()),
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _selectedTagIds.add(t['id'].toString());
                          } else {
                            _selectedTagIds.remove(t['id'].toString());
                          }
                        });
                        Navigator.pop(ctx);
                      },
                    ))
                .toList(),
          );
        });
  }

  void _back() async {
    await _autoSave();
    context.go('/notes_list');
  }

  @override
  Widget build(BuildContext context) {
    final wordCount = _quillController.document
            .toPlainText()
            .trim()
            .split(RegExp(r'\s+'))
            .where((w) => w.isNotEmpty)
            .length;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Header background
          Positioned(top: 0, left: 0, right: 0, height: 54, child: Container(
              color: _noteColor.hexToColor())),
          // Top bar
          Positioned(
              top: 65,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.black87,
                onPressed: _back,
              )),
          Positioned(
              top: 65,
              right: 16,
              child: TextButton(
                  onPressed: _autoSave,
                  child: const Text('Save', style: TextStyle(color: Colors.white)))),
          // Color picker
          Positioned(
              top: 110,
              left: 0,
              right: 0,
              height: 48,
              child: Container(
                  color: Colors.grey[100],
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 8,
                      itemBuilder: (ctx, idx) {
                        final colorHexes = const [
                          '#ffffff',
                          '#fef3c7',
                          '#dbeafe',
                          '#dcfce7',
                          '#fce7f3',
                          '#ede9fe',
                          '#fee2e2',
                          '#f3f4f6'
                        ];
                        final hex = colorHexes[idx];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _noteColor = hex;
                              });
                            },
                            child: CircleAvatar(
                              backgroundColor: hex.hexToColor(),
                              radius: 12,
                            ),
                          ),
                        );
                      }))),
          // Title field
          Positioned(
              top: 218,
              left: 20,
              right: 20,
              child: TextField(
                  controller: _titleController,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(border: InputBorder.none),
                  onChanged: (_) => _autoSave())),
          // Quill editor
          Positioned(
              top: 262,
              left: 0,
              right: 0,
              bottom: 704,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    QuillSimpleToolbar(
                      controller: _quillController,
                      configurations:
                          const QuillSimpleToolbarConfigurations(),
                    ),
                    Expanded(
                      child: QuillEditor.basic(
                          controller: _quillController,
                          configurations: const QuillEditorConfigurations(
                              placeholder: 'Start typing…')),
                    ),
                  ],
                ),
              )),
          // Tags row
          Positioned(
              bottom: 658,
              left: 0,
              right: 0,
              height: 48,
              child: SizedBox(
                height: 48,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._selectedTagIds
                        .map((id) => _buildTagChip(id))
                        .toList(),
                    ActionChip(
                      label: const Text('+ Add tag'),
                      onPressed: _showTagPicker,
                    )
                  ],
                ),
              )),
          // Bottom bar
          Positioned(
              bottom: 704,
              left: 0,
              right: 0,
              height: 56,
              child: Container(
                  color: Colors.grey[200],
                  child: Row(
                    children: [
                      IconButton(
                          icon: const Icon(Icons.image),
                          onPressed: _pickImage),
                      IconButton(
                          icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                          onPressed: _isRecording
                              ? _stopRecording
                              : _startRecording),
                      IconButton(
                          icon: const Icon(Icons.alarm),
                          onPressed: _pickAlarm),
                      IconButton(
                          icon: Icon(_isPinned ? Icons.star : Icons.star_border),
                          onPressed: _togglePin),
                      const Spacer(),
                      Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Text('$wordCount words',
                              style: const TextStyle(fontSize: 11))),
                    ],
                  ))),
        ],
      );
  }

  Widget _buildTagChip(String tagId) {
    final tag = _allTags.firstWhere((t) => t['id'].toString() == tagId,
        orElse: () => null);
    final tagName = tag?['name'] ?? '';
    final tagColor = tag?['color'] ?? '#000000';
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Chip(
        label: Text(tagName),
        backgroundColor: tagColor.hexToColor().withOpacity(0.2),
        deleteIcon: const Icon(Icons.close, size: 14),
        onDeleted: () {
          setState(() {
            _selectedTagIds.remove(tagId);
          });
        },
      );
  }
}

// Extension to convert hex string to Color
extension HexColor on String {
  Color hexToColor() {
    final hex = replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    } else if (hex.length == 8) {
      return Color(int.parse(hex, radix: 16));
    } else {
      return Colors.transparent;
    }
  }
}