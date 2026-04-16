import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({Key? key}) : super(key: key);

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';
  List<Map<String, dynamic>> _pinnedNotes = [];
  List<Map<String, dynamic>> _recentNotes = [];
  List<Map<String, dynamic>> _tags = [];
  late final RealtimeChannel _channel;

  @override
  void initState() {
    super.initState();
    _loadTags();
    _fetchNotes();
    _subscribeRealtime();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    Supabase.instance.client.removeChannel(_channel);
    super.dispose();
  }

  void _subscribeRealtime() {
    _channel = Supabase.instance.client.channel('public:notes')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'notes',
            callback: (payload) => _fetchNotes())
        .subscribe();
  }

  Future<void> _loadTags() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      final tags = await Supabase.instance.client
          .from('tags')
          .select('id,name,color')
          .eq('user_id', userId);
      setState(() {
        _tags = List<Map<String, dynamic>>.from(tags);
      });
    } catch (e) {
      print('Error loading tags: $e');
    }
  }

  Future<void> _fetchNotes() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      List<Map<String, dynamic>> data;
      if (_searchQuery.isNotEmpty) {
        data = await Supabase.instance.client
            .from('notes')
            .select('*')
            .eq('user_id', userId)
            .isFilter('deleted_at', null)
            .eq('is_archived', false)
            
            .order('is_pinned', ascending: false)
            .order('updated_at', ascending: false);
      } else {
        data = await Supabase.instance.client
            .from('notes')
            .select('*')
            .eq('user_id', userId)
            .isFilter('deleted_at', null)
            .eq('is_archived', false)
            .order('is_pinned', ascending: false)
            .order('updated_at', ascending: false);
      }
      setState(() {
        _pinnedNotes = data.where((n) => n['is_pinned'] == true).toList();
        _recentNotes = data.where((n) => n['is_pinned'] != true).toList();
      });
    } catch (e) {
      print('Error fetching notes: $e');
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = value.trim();
      });
      _fetchNotes();
    });
  }

  Future<void> _archiveNote(String id) async {
    try {
      await Supabase.instance.client
          .from('notes')
          .update({'is_archived': true})
          .eq('id', id);
      _fetchNotes();
    } catch (e) {
      print('Archive error: $e');
    }
  }

  Future<void> _deleteNote(String id) async {
    try {
      await Supabase.instance.client
          .from('notes')
          .update(
              {'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', id);
      _fetchNotes();
    } catch (e) {
      print('Delete error: $e');
    }
  }

  Future<void> _togglePin(String id) async {
    try {
      final isPinned =
          _pinnedNotes.any((n) => n['id'] == id);
      await Supabase.instance.client
          .from('notes')
          .update({'is_pinned': !isPinned})
          .eq('id', id);
      _fetchNotes();
    } catch (e) {
      print('Pin toggle error: $e');
    }
  }

  void _showNoteOptions(String id, Color bgColor) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) => Wrap(children: [
              ListTile(
                  title: const Text('Pin'),
                  onTap: () async {
                    await _togglePin(id);
                    Navigator.pop(ctx);
                  }),
              ListTile(
                  title: const Text('Archive'),
                  onTap: () async {
                    await _archiveNote(id);
                    Navigator.pop(ctx);
                  }),
              ListTile(
                  title: const Text('Delete'),
                  onTap: () async {
                    await _deleteNote(id);
                    Navigator.pop(ctx);
                  }),
            ]));
  }

  Widget _buildNoteCard(Map<String, dynamic> note) {
    final id = note['id'] as String;
    final title = note['title'] as String? ?? '';
    final plainText = note['plain_text'] as String? ?? '';
    final colorStr = note['color'] as String? ?? '#ffffff';
    final bgColor =
        Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.horizontal,
      background: Container(
        color: Colors.blue,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.archive, color: Colors.white),
              Text('Archive',
                  style: TextStyle(color: Colors.white, fontSize: 11))
            ]),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete, color: Colors.white),
              Text('Delete',
                  style: TextStyle(color: Colors.white, fontSize: 11))
            ]),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                  title: const Text('Delete note?'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(ctx, false);
                        },
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(ctx, true);
                        },
                        child: const Text('Delete'))
                  ]));
        }
        return true;
      },
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          await _deleteNote(id);
        } else {
          await _archiveNote(id);
        }
      },
      child: GestureDetector(
        onLongPress: () => _showNoteOptions(id, bgColor),
        onTap: () => context.go('/note_editor', extra: {'id': id}),
        child: Card(
          color: bgColor,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 3,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 4),
                  Text(plainText,
                      maxLines: 2, overflow: TextOverflow.ellipsis)
                ]),
          ),
        ),
      ));
  }

  Widget _buildNotesSection(
      String title, List<Map<String, dynamic>> notes) {
    return notes.isEmpty
        ? SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(title,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: notes.length,
                  itemBuilder: (context, index) =>
                      _buildNoteCard(notes[index]))
            ]);
  }

  Widget _buildEmptyState() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.note, size: 100, color: Colors.grey),
              SizedBox(height: 20),
              Text('Tap + to create your first note',
                  style: TextStyle(fontSize: 18, color: Colors.grey))
            ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/note_editor'),
        child: Icon(Icons.add),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
                title: Text('My Notes'),
                background: Container(color: Colors.blueAccent)),
            actions: [
              IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () => context.go('/settings'))
            ],
          ),
          SliverToBoxAdapter(
              child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _searchCtrl,
                          onChanged: (v) => _onSearchChanged(v),
                          decoration: InputDecoration(
                              hintText: '🔍  Search notes…',
                              prefixIcon: Icon(Icons.search),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear),
                                      onPressed: () {
                                        _searchCtrl.clear();
                                        setState(() {
                                          _searchQuery = '';
                                        });
                                        _fetchNotes();
                                      })
                                  : null,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24))),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                            onPressed: () => context.go('/tag_manager'),
                            child: Text('Manage Tags')),
                        SizedBox(height: 16),
                        _pinnedNotes.isEmpty && _recentNotes.isEmpty
                            ? _buildEmptyState()
                            : Column(
                                children: [
                                  _buildNotesSection('PINNED', _pinnedNotes),
                                  _buildNotesSection('RECENT', _recentNotes)
                                ]),
                      ]))),
        ],
      ));
  }
}