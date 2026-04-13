import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';
import '../utils/image_helper.dart';

class NoteEditorScreen extends StatefulWidget {
  final String? noteId;
  const NoteEditorScreen({Key? key, this.noteId}) : super(key: key);

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  late QuillController _quillController;
  bool _isPinned = false;
  String? _selectedColor = '#ffffff';
  List<String> _selectedTagIds = [];
  List<Map<String, dynamic>> _allTags = [];
  late RealtimeChannel _realtimeChannel;
  final ImagePicker _picker = ImagePicker();

  // Audio
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _audioPath;
  late RecorderController _recCtrl;
  late PlayerController _playCtrl;

  // Notifications
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _initQuill();
    _initAudio();
    _initNotifications();
    _loadNote();
    _subscribeRealtime();
    _fetchAllTags();
  }

  void _initQuill() {
    _quillController = widget.noteId == null
        ? QuillController.basic()
        : QuillController.basic();
  }

  void _initAudio() {
    _recCtrl = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
    _playCtrl = PlayerController();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings ios = DarwinInitializationSettings();
    const InitializationSettings settings =
        InitializationSettings(android: android, iOS: ios);
    await _flutterLocalNotificationsPlugin.initialize(settings);
  }

  Future<void> _loadNote() async {
    if (widget.noteId == null) return;
    try {
      final data = await Supabase.instance.client
          .from('notes')
          .select('*, note_tags(tag_id, tags(id, name, color), reminder_at, audio_path, color, is_pinned, title, content, plain_text')
          .eq('id', widget.noteId!)
          .single()
          .maybeSingle();
      if (data == null) return;
      setState(() {
        _titleController.text = data['title'] ?? '';
        final json = data['content'] ?? '';
        _quillController = json.isEmpty
            ? QuillController.basic()
            : QuillController(
                document: Document.fromJson(jsonDecode(json)),
                selection: const TextSelection.collapsed(offset: 0));
        _selectedColor = data['color'] ?? '#ffffff';
        _isPinned = data['is_pinned'] ?? false;
        _selectedTagIds =
            List<String>.from((data['note_tags'] as List).map((e) => e['tag_id']));
      });
    } catch (e) {
      // handle error
    }
  }

  void _subscribeRealtime() {
    _realtimeChannel = Supabase.instance.client.channel('public:notes')
      ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notes',
          callback: (payload) {
        _loadNote();
      })
      .subscribe();
  }

  Future<void> _fetchAllTags() async {
    try {
      final data = await Supabase.instance.client
          .from('tags')
          .select('id, name, color')
          .order('name', ascending: true);
      setState(() {
        _allTags = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {}
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _recCtrl.dispose();
    _playCtrl.dispose();
    _debounce?.cancel();
    Supabase.instance.client.removeChannel(_realtimeChannel);
    super.dispose();
  }

  Future<void> _autoSaveAndNavigateBack() async {
    await _saveNote();
    context.go('/notes_list');
  }

  Future<void> _saveNote() async {
    final delta = jsonEncode(_quillController.document.toDelta().toJson());
    final plainText = _quillController.document.toPlainText();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      if (widget.noteId == null) {
        await Supabase.instance.client.from('notes').insert({
          'title': _titleController.text,
          'content': delta,
          'plain_text': plainText,
          'color': _selectedColor,
          'is_pinned': _isPinned,
          'reminder_at': null,
          'audio_path': null,
          'user_id': userId,
        });
      } else {
        await Supabase.instance.client
            .from('notes')
            .update({
              'title': _titleController.text,
              'content': delta,
              'plain_text': plainText,
              'color': _selectedColor,
              'is_pinned': _isPinned,
            })
            .eq('id', widget.noteId!);
      }
      await _syncTags();
      await _syncAttachments();
    } catch (e) {
      // handle error
    }
  }

  Future<void> _syncTags() async {
    if (widget.noteId == null) return;
    try {
      final existing = await Supabase.instance.client
          .from('note_tags')
          .select('tag_id')
          .eq('note_id', widget.noteId!)
          .maybeSingle();
      final current = _selectedTagIds;
      // add new
      for (var tagId in current) {
        if (!(existing as List).any((e) => e['tag_id'] == tagId)) {
          await Supabase.instance.client.from('note_tags').insert({
            'note_id': widget.noteId,
            'tag_id': tagId,
          });
        }
      }
      // remove
      for (var tagId in existing.map((e) => e['tag_id'])) {
        if (!current.contains(tagId)) {
          await Supabase.instance.client
              .from('note_tags')
              .delete()
              .eq('note_id', widget.noteId!)
              .eq('tag_id', tagId);
        }
      }
    } catch (e) {}
  }

  Future<void> _syncAttachments() async {
    if (widget.noteId == null || _audioPath == null) return;
    try {
      final bytes = await File(_audioPath!).readAsBytes();
      final path = 'note-audio/${Uuid().v4()}.m4a';
      await Supabase.instance.client.storage
          .from('note-audio')
          .uploadBinary(path, bytes,
              fileOptions:
                  FileOptions(contentType: 'audio/m4a'));
      final url = Supabase.instance.client.storage
          .from('note-audio')
          .getPublicUrl(path);
      await Supabase.instance.client.from('attachments').insert({
        'note_id': widget.noteId,
        'url': url,
        'type': 'audio',
        'size_kb': bytes.length ~/ 1024,
        'user_id': Supabase.instance.client.auth.currentUser?.id,
      });
    } catch (e) {}
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final file = File(picked.path);
    final bytes = await file.readAsBytes();
    final path =
        'note-images/${Uuid().v4()}.${file.path.split('.').last}';
    try {
      await Supabase.instance.client.storage
          .from('note-images')
          .uploadBinary(path, bytes,
              fileOptions: FileOptions(contentType: 'image/jpeg'));
      final url = Supabase.instance.client.storage
          .from('note-images')
          .getPublicUrl(path);
      final idx = _quillController.selection.baseOffset;
      _quillController.document.insert(idx, BlockEmbed.image(url));
    } catch (e) {}
  }

  Future<void> _scheduleReminder() async {
    final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now().add(const Duration(hours: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (date == null) return;
    final time = await showTimePicker(
        context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    final dateTime = DateTime(date.year, date.month, date.day, time.hour,
        time.minute);
    final tzAt = tz.TZDateTime.from(dateTime, tz.local);
    const androidDetails = AndroidNotificationDetails(
        'reminder_channel',
        'Reminders',
        channelDescription: 'Note Reminders',
        importance: Importance.max);
    const iosDetails = DarwinNotificationDetails();
    const platformDetails = NotificationDetails(
        android: androidDetails, iOS: iosDetails);
    await _flutterLocalNotificationsPlugin.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch,
        'Reminder',
        'You have a reminder',
        tzAt,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
    setState(() {
      _selectedColor = '#fce7f3';
    });
  }

  Future<void> _startRecording() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final path =
        '${appDocDir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recCtrl.record(path: path);
    setState(() {
      _isRecording = true;
      _audioPath = path;
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recCtrl.stop();
    setState(() {
      _isRecording = false;
      _audioPath = path;
    });
  }

  Future<void> _playAudio() async {
    if (_audioPath == null) return;
    await _playCtrl.preparePlayer(path: _audioPath!, shouldExtractWaveform: true);
    await _playCtrl.startPlayer();
    setState(() {
      _isPlaying = true;
    });
  }

  Future<void> _pauseAudio() async {
    await _playCtrl.pausePlayer();
    setState(() {
      _isPlaying = false;
    });
  }

  void _selectTag(String tagId) {
    setState(() {
      if (_selectedTagIds.contains(tagId)) {
        _selectedTagIds.remove(tagId);
      } else {
        _selectedTagIds.add(tagId);
      }
    });
  }

  void _pickTag() {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return ListView(
              children: _allTags
                  .map((t) => ListTile(
                        title: Text(t['name'] ?? ''),
                        leading: Icon(Icons.tag),
                        trailing: _selectedTagIds.contains(t['id'])
                            ? const Icon(Icons.check)
                            : null,
                        onTap: () {
                          Navigator.pop(context);
                          _selectTag(t['id']);
                        },
                      ))
                  .toList());
        });
  }

  int _wordCount() {
    final text = _quillController.document.toPlainText();
    return text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Static shapes
            Positioned(
                left: 0,
                top: 54,
                width: 390,
                height: 56,
                child: Container(color: const Color(0xFFFFFFFF))),
            Positioned(
                left: 316,
                top: 65,
                width: 58,
                height: 32,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(color: const Color(0xFF6366F1)))),
            Positioned(
                left: 16,
                top: 68,
                child: GestureDetector(
                    onTap: _autoSaveAndNavigateBack,
                    child: Text('←',
                        style: const TextStyle(
                            fontSize: 22, color: Color(0xFF111827))))),
            Positioned(
                left: 327,
                top: 75,
                child: Text('Save',
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFFFFFFFF)))),
            Positioned(
                left: 0,
                top: 110,
                width: 390,
                height: 48,
                child: Container(color: const Color(0xFFF9FAFB))),
            Positioned(
                left: 20,
                top: 122,
                width: 28,
                height: 28,
                child: ClipOval(
                    child: Container(color: const Color(0xFFFFFFFF)))),
            Positioned(
                left: 56,
                top: 122,
                width: 28,
                height: 28,
                child: ClipOval(
                    child: Container(color: const Color(0xFFFEF3C7)))),
            Positioned(
                left: 92,
                top: 122,
                width: 28,
                height: 28,
                child: ClipOval(
                    child: Container(color: const Color(0xFFDBEAFE)))),
            Positioned(
                left: 128,
                top: 122,
                width: 28,
                height: 28,
                child: ClipOval(
                    child: Container(color: const Color(0xFFDCFCE7)))),
            Positioned(
                left: 164,
                top: 122,
                width: 28,
                height: 28,
                child: ClipOval(
                    child: Container(color: const Color(0xFFFCE7F3)))),
            Positioned(
                left: 200,
                top: 122,
                width: 28,
                height: 28,
                child: ClipOval(
                    child: Container(color: const Color(0xFFEEE9FE)))),
            Positioned(
                left: 236,
                top: 122,
                width: 28,
                height: 28,
                child: ClipOval(
                    child: Container(color: const Color(0xFFFEE2E2)))),
            Positioned(
                left: 272,
                top: 122,
                width: 28,
                height: 28,
                child: ClipOval(
                    child: Container(color: const Color(0xFFF3F4F6)))),
            Positioned(
                left: 16,
                top: 174,
                width: 358,
                height: 32,
                child: TextField(
                  controller: _titleController,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827)),
                  decoration: const InputDecoration(border: InputBorder.none),
                )),
            Positioned(
                left: 16,
                top: 210,
                width: 358,
                child: const Divider(color: Color(0xFFE5E7EB), thickness: 1)),
            Positioned(
                left: 0,
                top: 218,
                width: 390,
                height: 44,
                child: Container(color: const Color(0xFFF9FAFB))),
            Positioned(
                left: 0,
                top: 262,
                width: 390,
                height: 380,
                child: Column(
                    children: [
                      Expanded(child: Column(
                        children: [
                          QuillSimpleToolbar(
                              controller: _quillController,
                              configurations:
                                  const QuillSimpleToolbarConfigurations()),
                          Expanded(
                              child: QuillEditor.basic(
                                  controller: _quillController,
                                  configurations: const QuillEditorConfigurations(
                                      placeholder: 'Start typing…')))
                        ],
                      ))
                    ])),
            Positioned(
                left: 16,
                top: 432,
                width: 358,
                height: 22,
                child: Text('Next steps: Schedule follow-up for Q1 sprint',
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF374151)))),
            Positioned(
                left: 310,
                top: 630,
                child: Text('${_wordCount()} words',
                    style:
                        const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)))),
            Positioned(
                left: 0,
                top: 648,
                width: 390,
                height: 48,
                child: Container(color: const Color(0xFFF9FAFB))),
            Positioned(
                left: 16,
                top: 658,
                width: 68,
                height: 28,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(color: const Color(0xFFEDE9FE)))),
            Positioned(
                left: 92,
                top: 658,
                width: 68,
                height: 28,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(color: const Color(0xFFDBEAFE)))),
            Positioned(
                left: 168,
                top: 658,
                width: 78,
                height: 28,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(color: const Color(0xFFF3F4F6)))),
            Positioned(
                left: 0,
                top: 704,
                width: 390,
                height: 56,
                child: Container(color: const Color(0xFFF9FAFB))),
            Positioned(
                left: 20,
                top: 714,
                width: 40,
                height: 40,
                child: ClipOval(
                    child: Container(color: const Color(0xFFFEE2E2)))),
            Positioned(
                left: 70,
                top: 714,
                width: 40,
                height: 40,
                child: ClipOval(
                    child: Container(color: const Color(0xFFDBEAFE)))),
            Positioned(
                left: 120,
                top: 714,
                width: 40,
                height: 40,
                child: ClipOval(
                    child: Container(color: const Color(0xFFFEF3C7)))),
            Positioned(
                left: 31,
                top: 727,
                child: Icon(
                  Icons.mic,
                  color: const Color(0xFFEF4444),
                  size: 16,
                )),
            Positioned(
                left: 81,
                top: 727,
                child: Icon(
                  Icons.image,
                  color: const Color(0xFF3B82F6),
                  size: 16,
                )),
            Positioned(
                left: 131,
                top: 727,
                child: Icon(
                  Icons.notifications,
                  color: const Color(0xFFF59E0B),
                  size: 16,
                )),
            Positioned(
                left: 320,
                top: 726,
                child: Text('•••',
                    style: const TextStyle(
                        fontSize: 16, color: Color(0xFF9CA3AF)))),
            // Interactive elements
            Positioned(
                left: 16,
                top: 70,
                width: 50,
                height: 30,
                child: IconButton(
                    icon: Icon(_isPinned ? Icons.star : Icons.star_border,
                        color: _isPinned ? Colors.yellow : null),
                    onPressed: () {
                      setState(() {
                        _isPinned = !_isPinned;
                      });
                    })),
            Positioned(
                left: 20,
                top: 172,
                width: 80,
                height: 30,
                child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                        children: [
                          SizedBox(width: 8),
                          ...['#ffffff', '#fef3c7', '#dbeafe', '#dcfce7',
                            '#fce7f3', '#ede9fe', '#fee2e2', '#f3f4f6']
                              .map((c) => GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedColor = c;
                                      });
                                    },
                                    child: Container(
                                        width: 32,
                                        height: 32,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        decoration: BoxDecoration(
                                            color: Color(
                                                int.parse(c.replaceFirst(
                                                    '#', '0xFF'))),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                width: _selectedColor ==
                                                        c
                                                    ? 3
                                                    : 1,
                                                color: _selectedColor ==
                                                        c
                                                    ? Colors.black87
                                                    : Colors.grey.shade300)),
                                    ),
                                  ))
                              .toList()
                        ]))),
            Positioned(
                left: 16,
                top: 432,
                width: 200,
                height: 30,
                child: Wrap(
                    spacing: 6,
                    children: _allTags
                        .map((t) => Chip(
                              label: Text(t['name'] ?? ''),
                              backgroundColor: Color(int.parse(
                                  t['color'].replaceFirst('#', '0xFF')))
                                  .withOpacity(0.2),
                              deleteIcon: const Icon(Icons.close, size: 14),
                              onDeleted: () => _selectTag(t['id']),
                            ))
                        .toList()
                          ..add(Chip(
                              label: const Text('+ Add tag'),
                              backgroundColor: Colors.grey.shade200,
                              onPressed: _pickTag))),
            Positioned(
                left: 0,
                bottom: 0,
                width: 390,
                height: 42,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                        icon: const Icon(Icons.image),
                        onPressed: _pickImage),
                    IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: _scheduleReminder),
                    IconButton(
                        icon: Icon(_isRecording
                            ? Icons.stop
                            : Icons.mic),
                        onPressed: _isRecording
                            ? _stopRecording
                            : _startRecording),
                    IconButton(
                        icon: Icon(_isPlaying
                            ? Icons.pause
                            : Icons.play_arrow),
                        onPressed:
                            _isPlaying ? _pauseAudio : _playAudio)
                  ],
                ))
          ],
        ),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Edit Note',
              style: TextStyle(
                  color: _selectedColor == '#ffffff'
                      ? Colors.black
                      : Colors.white)),
          actions: [
            TextButton(
                onPressed: () async {
                  await _saveNote();
                  context.go('/notes_list');
                },
                child: const Text('Save',
                    style: TextStyle(color: Colors.blue)))
          ],
        ));
  }
}