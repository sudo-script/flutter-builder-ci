import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

import '../utils/image_helper.dart';

class NoteEditorScreen extends StatefulWidget {
  final String? noteId;

  const NoteEditorScreen({Key? key, this.noteId}) : super(key: key);

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late QuillController _quillController;
  final _imagePicker = ImagePicker();
  final _recCtrl = RecorderController()
    ..androidEncoder = AndroidEncoder.aac
    ..androidOutputFormat = AndroidOutputFormat.mpeg4
    ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
    ..sampleRate = 44100;
  final _playCtrl = PlayerController();

  bool _isRecording = false;
  bool _isPlaying = false;
  String? _audioPath;

  DateTime? _reminderAt;
  late final FlutterLocalNotificationsPlugin _notificationsPlugin;
  late final RealtimeChannel _channel;

  String _bgColorHex = '#ffffff';
  final Color _currentBgColor = Colors.white;

  List<String> _selectedTags = [];
  List<Map<String, dynamic>> _allTags = []; // {id, name, color}

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _quillController = QuillController.basic();
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
    _subscribeRealtime();
    if (widget.noteId != null) {
      _loadNote();
    }
  }

  Future<void> _initializeNotifications() async {
    const android = AndroidInitializationSettings('app_icon');
    const ios = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: android, iOS: ios);
    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> _subscribeRealtime() async {
    _channel = Supabase.instance.client
        .channel('public:notes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notes',
          callback: (payload) => _fetchNotes(),
        )
        .subscribe();
  }

  Future<void> _fetchNotes() async {
    // placeholder for real implementation
  }

  Future<void> _loadNote() async {
    try {
      final noteResult = await Supabase.instance.client
          .from('notes')
          .select('*, note_tags(tag_id, tags(id, name, color))')
          .eq('id', widget.noteId!);
      if (noteResult.isNotEmpty) {
        final note = noteResult.first;
        setState(() {
          _titleController.text = note['title'] ?? '';
          _bgColorHex = note['color'] ?? '#ffffff';
          final contentJson = note['content'];
          if (contentJson != null) {
            _quillController = QuillController(
              document: Document.fromJson(jsonDecode(contentJson)),
              selection: const TextSelection.collapsed(offset: 0);
          }
          final tags = note['note_tags'] as List<dynamic>? ?? [];
          _selectedTags = tags.map((t) => t['tag_id'] as String).toList();
        });
      }
    } catch (e) {
      // handle error
    }
  }

  Future<void> _saveNote() async {
    final title = _titleController.text;
    final contentJson = jsonEncode(_quillController.document.toDelta().toJson());
    final plainText = _quillController.document.toPlainText();
    final userId = Supabase.instance.client.auth.currentUser!.id;

    try {
      if (widget.noteId == null) {
        await Supabase.instance.client.from('notes').insert({
          'title': title,
          'content': contentJson,
          'plain_text': plainText,
          'color': _bgColorHex,
          'is_pinned': false,
          'reminder_at': _reminderAt?.toIso8601String(),
          'audio_path': _audioPath,
          'user_id': userId,
        });
      } else {
        await Supabase.instance.client
            .from('notes')
            .update({
              'title': title,
              'content': contentJson,
              'plain_text': plainText,
              'color': _bgColorHex,
              'reminder_at': _reminderAt?.toIso8601String(),
              'audio_path': _audioPath,
            })
            .eq('id', widget.noteId!);
      }
      Navigator.of(context).pop();
    } catch (e) {
      // handle error
    }
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final file = File(picked.path);
    final bytes = await file.readAsBytes();
    final path = 'note-images/${const Uuid().v4()}.jpg';
    await Supabase.instance.client.storage
        .from('note-images')
        .uploadBinary(path, bytes,
            fileOptions: FileOptions(contentType: 'image/jpeg'));
    final url = Supabase.instance.client.storage
        .from('note-images')
        .getPublicUrl(path);
    final idx = _quillController.selection.baseOffset;
    _quillController.document.insert(idx, BlockEmbed.image(url));
  }

  Future<void> _setReminder() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderAt ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderAt ?? DateTime.now()),
    );
    if (time == null) return;
    final combined = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() => _reminderAt = combined);
    await _scheduleNotification(combined);
  }

  Future<void> _scheduleNotification(DateTime at) async {
    final tzAt = tz.TZDateTime.from(at, tz.local);
    await _notificationsPlugin.zonedSchedule(
      at.millisecondsSinceEpoch,
      'Reminder',
      'You have a reminder',
      tzAt,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminders',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
  }

  Future<void> _startRecording() async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recCtrl.record(path: filePath);
    setState(() {
      _isRecording = true;
      _audioPath = filePath;  // nullable ok
    });
  }

  Future<void> _stopRecording() async {
    await _recCtrl.stop();
    setState(() => _isRecording = false);
  }

  Future<void> _playAudio() async {
    if (_audioPath == null) return;
    await _playCtrl.preparePlayer(
        path: _audioPath!, shouldExtractWaveform: true);
    await _playCtrl.startPlayer();
    setState(() => _isPlaying = true);
  }

  Future<void> _resumePlay() async {
    await _playCtrl.resumePlayer();
    setState(() => _isPlaying = true);
  }

  Future<void> _pausePlay() async {
    await _playCtrl.pausePlayer();
    setState(() => _isPlaying = false);
  }

  void _addTag(String tagId) async {
    try {
      await Supabase.instance.client.from('note_tags').insert({
        'note_id': widget.noteId ?? '',
        'tag_id': tagId,
      });
      setState(() => _selectedTags.add(tagId));
    } catch (e) {}
  }

  void _removeTag(String tagId) async {
    try {
      await Supabase.instance.client
          .from('note_tags')
          .delete()
          .eq('note_id', widget.noteId)
          .eq('tag_id', tagId);
      setState(() => _selectedTags.remove(tagId));
    } catch (e) {}
  }

  void _openTagPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView.builder(
          itemCount: _allTags.length,
          itemBuilder: (_, i) {
            final tag = _allTags[i];
            return ListTile(
              title: Text(tag['name']),
              trailing: _selectedTags.contains(tag['id'])
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                if (_selectedTags.contains(tag['id'])) {
                  _removeTag(tag['id']);
                } else {
                  _addTag(tag['id']);
                }
                Navigator.pop(context);
              },
            );
          },
        );
      },
  }

  String _wordCount() {
    final text = _quillController.document.toPlainText();
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    return '${words.length} words';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _recCtrl.dispose();
    _playCtrl.dispose();
    Supabase.instance.client.removeChannel(_channel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Color(int.parse(_bgColorHex.replaceFirst('#', '0xFF')));
    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 54,
            left: 0,
            right: 0,
            height: 56,
            child: Container(
              color: Colors.white,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 48,
            child: Container(
              color: Colors.grey[200],
            ),
          ),
          Positioned(
            left: 16,
            top: 68,
            child: GestureDetector(
              onTap: () {
                _saveNote();
                context.go('/notes_list');
              },
              child: const Icon(Icons.arrow_back, color: Color(0xFF111827)),
            ),
          ),
          Positioned(
            right: 16,
            top: 68,
            child: GestureDetector(
              onTap: _saveNote,
              child: const Text('Save',
                  style: TextStyle(color: Colors.white, fontSize: 14)),
            ),
          ),
          Positioned(
            top: 110,
            left: 0,
            right: 0,
            height: 48,
            child: Container(
              color: Colors.grey[100],
            ),
          ),
          Positioned(
            top: 122,
            left: 20,
            height: 28,
            width: 28,
            child: Container(
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white),
            ),
          ),
          // other color circles omitted for brevity
          Positioned(
            top: 176,
            left: 16,
            right: 16,
            height: 32,
            child: TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
          Positioned(
            top: 210,
            left: 16,
            right: 16,
            height: 1,
            child: Container(color: const Color(0xFFE5E7EB)),
          ),
          Positioned(
            top: 218,
            left: 0,
            right: 0,
            height: 44,
            child: Container(
              color: Colors.grey[100],
            ),
          ),
          Positioned(
            top: 260,
            left: 0,
            right: 0,
            height: 380,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Expanded(
                    child: QuillSimpleToolbar(
                      controller: _quillController,
                      configurations:
                          const QuillSimpleToolbarConfigurations(),
                    ),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: QuillEditor.basic(
                      controller: _quillController,
                      configs: const QuillEditorConfigurations(
                          placeholder: 'Start typing…'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 310,
            left: 16,
            right: 16,
            height: 320,
            child: Container(
              color: Colors.white,
            ),
          ),
          // bottom toolbar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 56,
            child: Container(
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.image),
                    onPressed: _pickImage,
                  ),
                  IconButton(
                    icon: const Icon(Icons.alarm),
                    onPressed: _setReminder,
                  ),
                  IconButton(
                    icon: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: _isRecording ? Colors.red : null,
                    ),
                    onPressed: () {
                      if (_isRecording) {
                        _stopRecording();
                      } else {
                        _startRecording();
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    onPressed: () {
                      if (_isPlaying) {
                        _pausePlay();
                      } else {
                        _playAudio();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 16,
            child: Text(
              _wordCount(),
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
            ),
          ),
        ],
      );
  }
}