import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';
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
  final _titleController = TextEditingController();
  late QuillController _quillController;
  late final RecorderController _recCtrl;
  late final PlayerController _playCtrl;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _audioUrl;
  String _noteColor = '#ffffff';
  bool _isPinned = false;
  DateTime? _reminderAt;
  List<Tag> _allTags = []; // all available tags
  List<String> _selectedTagIds = [];
  late final FlutterLocalNotificationsPlugin _notificationPlugin;
  late final RealtimeChannel _channel;
  Timer? _debounce;

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
    _notificationPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
    _loadNote();
    _subscribeRealtime();
  }

  void _initializeNotifications() async {
    const android = AndroidInitializationSettings('app_icon');
    const ios = DarwinInitializationSettings();
    final settings = InitializationSettings(android: android, iOS: ios);
    await _notificationPlugin.initialize(settings);
  }

  Future<void> _loadNote() async {
    if (widget.noteId == null) {
      _quillController = QuillController.basic();
      return;
    }
    try {
      final noteData = await Supabase.instance.client
          .from('notes')
          .select('*')
          .eq('id', widget.noteId!)
          .single();
      if (noteData == null) return;
      final title = noteData['title'] as String? ?? '';
      final contentJson = noteData['content'] as String? ?? '';
      final color = noteData['color'] as String? ?? '#ffffff';
      final isPinned = noteData['is_pinned'] as bool? ?? false;
      final reminderStr = noteData['reminder_at'] as String?;
      final audioUrl = noteData['audio_path'] as String?;
      _reminderAt =
          reminderStr != null ? DateTime.parse(reminderStr) : null;
      _audioUrl = audioUrl;
      _noteColor = color;
      _isPinned = isPinned;
      _titleController.text = title;
      final doc = contentJson.isNotEmpty
          ? Document.fromJson(jsonDecode(contentJson))
          : Document();
      _quillController = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (e) {
      // handle error
    }
    // Load tags
    try {
      final tagData = await Supabase.instance.client
          .from('note_tags')
          .select('tag_id, tags(id,name,color)')
          .eq('note_id', widget.noteId!);
      if (tagData != null && tagData is List) {
        for (var item in tagData) {
          final tagInfo = item['tags'];
          if (tagInfo != null) {
            _selectedTagIds.add(item['tag_id'] as String);
            _allTags.add(Tag(
                id: tagInfo['id'] as String,
                name: tagInfo['name'] as String,
                color: tagInfo['color'] as String));
          }
        }
      }
    } catch (e) {
      // handle
    }

    setState(() {});
  }

  void _subscribeRealtime() {
    _channel = Supabase.instance.client
        .channel('public:notes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notes',
          callback: (payload) => _loadNote(),
        )
        .subscribe();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _recCtrl.dispose();
    _playCtrl.dispose();
    _debounce?.cancel();
    if (mounted) {
      Supabase.instance.client.removeChannel(_channel);
    }
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final contentJson =
        jsonEncode(_quillController.document.toDelta().toJson());
    final plainText = _quillController.document.toPlainText();
    final colorHex = _noteColor;
    final isPinned = _isPinned;
    final reminderAtStr = _reminderAt?.toIso8601String();
    final audioUrl = _audioUrl ?? '';

    final notePayload = {
      'title': title,
      'content': contentJson,
      'plain_text': plainText,
      'color': colorHex,
      'is_pinned': isPinned,
      'reminder_at': reminderAtStr,
      'audio_path': audioUrl,
      'user_id': Supabase.instance.client.auth.currentUser?.id
    };

    try {
      if (widget.noteId != null) {
        await Supabase.instance.client
            .from('notes')
            .update(notePayload)
            .eq('id', widget.noteId!);
      } else {
        final result = await Supabase.instance.client
            .from('notes')
            .insert(notePayload)
            .select('id');
        if (result != null && result is List && result.isNotEmpty) {
          _localNoteId = result.first['id'] as String?;
        }
      }
    } catch (e) {
      // handle error
    }

    // Sync tags (simplified)
    // TODO: sync _selectedTagIds with note_tags table

    // Confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note saved')));
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final path = 'uploads/${const Uuid().v4()}.jpg';
    try {
      await Supabase.instance.client.storage
          .from('note-images')
          .uploadBinary(path, bytes,
              fileOptions: FileOptions(contentType: 'image/jpeg'));
      final url = Supabase.instance.client.storage.from('note-images').getPublicUrl(path);
      if (url != null) {
        final idx = _quillController.selection.baseOffset;
        _quillController.document.insert(idx, BlockEmbed.image(url));
      }
    } catch (e) {
      // handle error
    }
  }

  Future<void> _pickReminder() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderAt ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderAt ?? DateTime.now()),
    );
    if (time == null) return;
    final reminder = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      _reminderAt = reminder;
    });
    await _scheduleNotification(reminder);
  }

  Future<void> _scheduleNotification(DateTime dateTime) async {
    final dz = tz.local;
    final tzAt = tz.TZDateTime.from(dateTime, dz);
    final androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Note reminders',
      importance: Importance.max,
      priority: Priority.high,
      scheduledPublishTime: tzAt,
    );
    final iOSDetails = DarwinNotificationDetails();
    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    ));
    await _notificationPlugin.zonedSchedule(
      dateTime.millisecondsSinceEpoch ~/ 1000,
      'Reminder',
      _titleController.text,
      tzAt,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  }

  Future<void> _startRecording() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final path =
        '${appDocDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recCtrl.record(path: path);
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recCtrl.stop();
    setState(() {
      _isRecording = false;
    });
    final file = File(path);
    final bytes = await file.readAsBytes();
    final uploadPath = 'uploads/${const Uuid().v4()}.m4a';
    try {
      await Supabase.instance.client.storage
          .from('note-audio')
          .uploadBinary(uploadPath, bytes, fileOptions: FileOptions(contentType: 'audio/m4a'));
      final url = Supabase.instance.client.storage.from('note-audio').getPublicUrl(uploadPath);
      if (url != null) {
        _audioUrl = url;
        // Optionally insert into attachments table
        await Supabase.instance.client.from('attachments').insert({
          'note_id': widget.noteId,
          'url': url,
          'type': 'audio',
          'size_kb': bytes.length ~/ 1024,
        });
      }
    } catch (e) {
      // handle
    }
  }

  void _togglePlay() async {
    if (_isPlaying) {
      await _playCtrl.pausePlayer();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _playCtrl.preparePlayer(path: _audioUrl!, shouldExtractWaveform: true);
      await _playCtrl.startPlayer();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  List<Color> get _paletteColors => const [
        Color(0xFFFFFFFF),
        Color(0xFFFEF3C7),
        Color(0xFFDBEAFE),
        Color(0xFFDCFCE7),
        Color(0xFFFCE7F3),
        Color(0xFFEDE9FE),
        Color(0xFFfee2e2),
        Color(0xFFF3F4F6),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 0,
            top: 54,
            width: 390,
            height: 56,
            child: Container(
              color: Colors.white,
            ),
          ),
          Positioned(
            left: 316,
            top: 65,
            width: 58,
            height: 32,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 68,
            width: 300,
            height: 30,
            child: Text(
              '←',
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 22,
              ),
            ),
          ),
          Positioned(
            left: 327,
            top: 75,
            width: 300,
            height: 22,
            child: Text(
              'Save',
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 14,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 110,
            width: 390,
            height: 48,
            child: Container(
              color: const Color(0xFFF9FAFB),
            ),
          ),
          Positioned(
            left: 20,
            top: 122,
            width: 28,
            height: 28,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            left: 56,
            top: 122,
            width: 28,
            height: 28,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFef3c7),
              ),
            ),
          ),
          Positioned(
            left: 92,
            top: 122,
            width: 28,
            height: 28,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFDBEAFE),
              ),
            ),
          ),
          Positioned(
            left: 128,
            top: 122,
            width: 28,
            height: 28,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFD CFCE7),
              ),
            ),
          ),
          Positioned(
            left: 164,
            top: 122,
            width: 28,
            height: 28,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFCE7F3),
              ),
            ),
          ),
          Positioned(
            left: 200,
            top: 122,
            width: 28,
            height: 28,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFEDE9FE),
              ),
            ),
          ),
          Positioned(
            left: 236,
            top: 122,
            width: 28,
            height: 28,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFfee2e2),
              ),
            ),
          ),
          Positioned(
            left: 272,
            top: 122,
            width: 28,
            height: 28,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF3F4F6),
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 174,
            width: 358,
            height: 32,
            child: Text(
              'Meeting with design team',
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 24,
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 210,
            width: 358,
            height: 1,
            child: Container(
              color: const Color(0xFFE5E7EB),
            ),
          ),
          Positioned(
            left: 0,
            top: 218,
            width: 390,
            height: 44,
            child: Container(
              color: const Color(0xFFF9FAFB),
            ),
          ),
          Positioned(
            left: 20,
            top: 232,
            width: 300,
            height: 23,
            child: Text(
              'B',
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 15,
              ),
            ),
          ),
          Positioned(
            left: 48,
            top: 232,
            width: 300,
            height: 23,
            child: Text(
              'I',
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 15,
              ),
            ),
          ),
          Positioned(
            left: 72,
            top: 232,
            width: 300,
            height: 23,
            child: Text(
              'U̲',
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 15,
              ),
            ),
          ),
          Positioned(
            left: 98,
            top: 232,
            width: 300,
            height: 21,
            child: Text(
              'H1',
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 13,
              ),
            ),
          ),
          Positioned(
            left: 128,
            top: 232,
            width: 300,
            height: 21,
            child: Text(
              'H2',
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 13,
              ),
            ),
          ),
          Positioned(
            left: 156,
            top: 232,
            width: 300,
            height: 24,
            child: Text(
              '≡',
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 16,
              ),
            ),
          ),
          Positioned(
            left: 180,
            top: 232,
            width: 300,
            height: 23,
            child: Text(
              '☑',
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 15,
              ),
            ),
          ),
          Positioned(
            left: 206,
            top: 232,
            width: 300,
            height: 23,
            child: Text(
              '⌁',
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 15,
              ),
            ),
          ),
          Positioned(
            left: 230,
            top: 232,
            width: 300,
            height: 21,
            child: Text(
              '🔗',
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 13,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 262,
            width: 390,
            height: 380,
            child: Container(
              color: const Color(0xFFFFFFFF),
            ),
          ),
          Positioned(
            left: 16,
            top: 278,
            width: 358,
            height: 23,
            child: Text(
              'Discussed the new design system and component',
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 15,
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 302,
            width: 358,
            height: 23,
            child: Text(
              'library. Key decisions:',
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 15,
              ),
            ),
          ),
          Positioned(
            left: 28,
            top: 330,
            width: 340,
            height: 22,
            child: const Text(
              '• Use Material 3 tokens for color',
              style: TextStyle(
                color: Color(0xFF374151),
                fontSize: 14,
              ),
            ),
          ),
          Positioned(
            left: 28,
            top: 354,
            width: 340,
            height: 22,
            child: const Text(
              '• Typography scale: 11 / 14 / 16 / 22 / 28',
              style: TextStyle(
                color: Color(0xFF374151),
                fontSize: 14,
              ),
            ),
          ),
          Positioned(
            left: 28,
            top: 378,
            width: 340,
            height: 22,
            child: const Text(
              '☑  Review Figma components by Friday',
              style: TextStyle(
                color: Color(0xFF374151),
                fontSize: 14,
              ),
            ),
          ),
          Positioned(
            left: 28,
            top: 402,
            width: 340,
            height: 22,
            child: const Text(
              '☐  Share with dev team',
              style: TextStyle(
                color: Color(0xFF374151),
                fontSize: 14,
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 432,
            width: 358,
            height: 22,
            child: const Text(
              'Next steps: Schedule follow-up for Q1 sprint',
              style: TextStyle(
                color: Color(0xFF374151),
                fontSize: 14,
              ),
            ),
          ),
          Positioned(
            left: 310,
            top: 630,
            width: 300,
            height: 19,
            child: Text(
              '${_quillController.document.toPlainText().split(RegExp(r'\\s+')).where((s) => s.isNotEmpty).length} words',
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 11,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 648,
            width: 390,
            height: 48,
            child: Container(
              color: const Color(0xFFF9FAFB),
            ),
          ),
          Positioned(
            left: 16,
            top: 658,
            width: 68,
            height: 28,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          Positioned(
            left: 92,
            top: 658,
            width: 68,
            height: 28,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFDbeafe),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          Positioned(
            left: 168,
            top: 658,
            width: 78,
            height: 28,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          Positioned(
            left: 26,
            top: 667,
            width: 300,
            height: 20,
            child: const Text(
              'Work',
              style: TextStyle(
                color: Color(0xFF6366F1),
                fontSize: 12,
              ),
            ),
          ),
          Positioned(
            left: 102,
            top: 667,
            width: 300,
            height: 20,
            child: const Text(
              'Design',
              style: TextStyle(
                color: Color(0xFF3B82F6),
                fontSize: 12,
              ),
            ),
          ),
          Positioned(
            left: 178,
            top: 667,
            width: 300,
            height: 20,
            child: const Text(
              '+ Add tag',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 704,
            width: 390,
            height: 56,
            child: Container(
              color: const Color(0xFFF9FAFB),
            ),
          ),
          Positioned(
            left: 20,
            top: 714,
            width: 40,
            height: 40,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFfee2e2),
              ),
            ),
          ),
          Positioned(
            left: 70,
            top: 714,
            width: 40,
            height: 40,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFdbeafe),
              ),
            ),
          ),
          Positioned(
            left: 120,
            top: 714,
            width: 40,
            height: 40,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFef3c7),
              ),
            ),
          ),
          Positioned(
            left: 320,
            top: 726,
            width: 300,
            height: 24,
            child: const Text(
              '•••',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 16,
              ),
            ),
          ),
          Positioned(
            left: 31,
            top: 727,
            width: 300,
            height: 24,
            child: const Text(
              '🎙',
              style: TextStyle(
                color: Color(0xFFef4444),
                fontSize: 16,
              ),
            ),
          ),
          Positioned(
            left: 81,
            top: 727,
            width: 300,
            height: 24,
            child: const Text(
              '🖼',
              style: TextStyle(
                color: Color(0xFF3b82f6),
                fontSize: 16,
              ),
            ),
          ),
          Positioned(
            left: 131,
            top: 727,
            width: 300,
            height: 24,
            child: const Text(
              '🔔',
              style: TextStyle(
                color: Color(0xFFf59e0b),
                fontSize: 16,
              ),
            ),
          ),
          // App bar controls
          Positioned(
            left: 0,
            top: 0,
            width: 390,
            height: 54,
            child: GestureDetector(
              onTap: () async {
                await _saveNote();
                if (mounted) context.go('/notes_list');
              },
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Icon(Icons.arrow_back),
                ),
              ),
            ),
          ),
          Positioned(
            left: 316,
            top: 65,
            width: 58,
            height: 32,
            child: Align(
              alignment: Alignment.center,
              child: IconButton(
                icon: Icon(
                  _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                ),
                onPressed: () {
                  setState(() => _isPinned = !_isPinned);
                },
              ),
            ),
          ),
          Positioned(
            left: 327,
            top: 75,
            width: 300,
            height: 22,
            child: Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: _saveNote,
                child: const Text('Save'),
              ),
            ),
          ),
          // Title input
          Positioned(
            left: 16,
            top: 220,
            width: 358,
            height: 24,
            child: TextField(
              controller: _titleController,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
          // Color Picker
          Positioned(
            left: 16,
            top: 250,
            width: 358,
            height: 32,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_paletteColors.length, (i) {
                  final c = _paletteColors[i];
                  return GestureDetector(
                    onTap: () => setState(() => _noteColor = '#${c.value.toRadixString(16).substring(2)}'),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: _paletteColors[i].toHex() == _paletteColors.first.toHex() ? 2 : 1,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          // Rich text editor
          Positioned(
            left: 0,
            top: 282,
            width: 390,
            height: 356,
            child: Column(
              children: [
                QuillSimpleToolbar(
                  controller: _quillController,
                  configurations: const QuillSimpleToolbarConfigurations(),
                ),
                Expanded(
                  child: QuillEditor.basic(
                    controller: _quillController,
                    configurations: const QuillEditorConfigurations(placeholder: 'Start typing…'),
                  ),
                ),
              ],
            ),
          ),
          // Tags row
          Positioned(
            left: 0,
            top: 638,
            width: 390,
            height: 28,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ..._selectedTagIds.map((tagId) {
                    final tag = _allTags.firstWhere((t) => t.id == tagId,
                        orElse: () => Tag(id: tagId, name: 'Tag', color: '#ffffff'));
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Chip(
                        label: Text(tag.name),
                        backgroundColor: Color(int.parse(tag.color.replaceFirst('#', '0xFF')))
                            .withOpacity(0.2),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () {
                          setState(() {
                            _selectedTagIds.remove(tagId);
                          });
                        },
                      ),
                    );
                  }).toList(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InputChip(
                      label: const Text('+ Add tag'),
                      onPressed: () => _showTagPicker(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom toolbar
          Positioned(
            left: 0,
            bottom: 0,
            width: 390,
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                ),
                if (_audioUrl != null)
                  IconButton(
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: _togglePlay,
                  ),
              ],
            ),
          ),
          // Word count
          Positioned(
            right: 8,
            bottom: 8,
            child: Text(
              '${_quillController.document.toPlainText().split(RegExp(r'\\s+')).where((s) => s.isNotEmpty).length} words',
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ));
  }

  void _showTagPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        shrinkWrap: true,
        children: _allTags.map((tag) {
          final selected = _selectedTagIds.contains(tag.id);
          return ListTile(
            title: Text(tag.name),
            trailing: selected ? const Icon(Icons.check) : null,
            onTap: () {
              setState(() {
                if (selected) {
                  _selectedTagIds.remove(tag.id);
                } else {
                  _selectedTagIds.add(tag.id);
                }
              });
            },
          );
        }).toList(),
      ));
  }
}

class Tag {
  final String id;
  final String name;
  final String color;
  Tag({required this.id, required this.name, required this.color});
}

extension ColorHex on Color {
  String toHex() => '#${value.toRadixString(16).substring(2).padLeft(6, '0')}';
}