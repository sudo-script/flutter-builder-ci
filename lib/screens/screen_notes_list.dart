import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> _pinnedNotes = [];
  List<Map<String, dynamic>> _recentNotes = [];
  List<Map<String, dynamic>> _tags = [];
  late final RealtimeChannel _channel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTags();
    _fetchNotes();
    _subscribeRealtime();
    _searchCtrl.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _fetchNotes();
    });
    setState(() {});
  }

  Future<void> _fetchTags() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final data = await Supabase.instance.client
          .from('tags')
          .select('id,name,color')
          .eq('user_id', userId);
      setState(() {
        _tags = List<Map<String, dynamic>>.from(data);
      });
    } catch (_) {}
  }

  Future<void> _fetchNotes() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      var query = Supabase.instance.client
          .from('notes')
          .select('*, note_tags(tag_id, tags(id,name,color))')
          .eq('user_id', userId)
          .isFilter('deleted_at', null)
          .isFilter('is_archived', false)
          .order('created_at', ascending: false);
      if (_searchCtrl.text.isNotEmpty) {
        query = query.textSearch('fts', _searchCtrl.text, config: 'english');
      }
      final data = await query;
      final notesData = List<Map<String, dynamic>>.from(data);
      setState(() {
        _notes = notesData;
        _pinnedNotes = notesData.where((n) => n['is_pinned'] == true).toList();
        _recentNotes = notesData.where((n) => n['is_pinned'] != true).toList();
      });
    } catch (_) {}
    setState(() {
      _isLoading = false;
    });
  }

  void _subscribeRealtime() {
    _channel = Supabase.instance.client.channel('public:notes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notes',
          callback: (payload) {
            _fetchNotes();
          },
        )
        .subscribe();
  }

  Future<void> _archiveNote(String id) async {
    try {
      await Supabase.instance.client
          .from('notes')
          .update({'is_archived': true})
          .eq('id', id);
      _fetchNotes();
    } catch (_) {}
  }

  Future<void> _deleteNote(String id) async {
    try {
      await Supabase.instance.client
          .from('notes')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', id);
      _fetchNotes();
    } catch (_) {}
  }

  Future<void> _pinNote(String id, bool pin) async {
    try {
      await Supabase.instance.client
          .from('notes')
          .update({'is_pinned': pin})
          .eq('id', id);
      _fetchNotes();
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    _debounce?.cancel();
    Supabase.instance.client.removeChannel(_channel);
    super.dispose();
  }

  Color _parseColor(String? hex) {
    if (hex == null) return Colors.grey;
    final cleaned = hex.replaceFirst('#', '0xFF');
    return Color(int.parse(cleaned));
  }

  Widget _buildNoteCard(Map<String, dynamic> note) {
    final bgColor = _parseColor(note['color']);
    return Dismissible(
      key: ValueKey(note['id']),
      direction: DismissDirection.horizontal,
      background: Container(
        color: Colors.blue,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.archive, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete note?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
          return confirm ?? false;
        }
        return true;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          _archiveNote(note['id']);
        } else {
          _deleteNote(note['id']);
        }
      },
      child: InkWell(
        onLongPress: () => _showNoteOptions(note),
        onTap: () => context.go('/note_editor', extra: note['id']),
        child: Card(
          color: bgColor,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note['title'] ?? '',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (note['plain_text'] != null) ...[
                  SizedBox(height: 4),
                  Text(
                    note['plain_text'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
                SizedBox(height: 8),
                Text(
                  note['created_at'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
  }

  void _showNoteOptions(Map<String, dynamic> note) {
    final isPinned = note['is_pinned'] ?? false;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(isPinned ? Icons.push_pin : Icons.push_pin_outlined),
              title: Text(isPinned ? 'Unpin' : 'Pin'),
              onTap: () {
                Navigator.pop(ctx);
                _pinNote(note['id'], !isPinned);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archive'),
              onTap: () {
                Navigator.pop(ctx);
                _archiveNote(note['id']);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(ctx);
                _deleteNote(note['id']);
              },
            ),
          ],
        ),
      );
  }

  Widget _buildTagChips() {
    return SizedBox(
      height: 50,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _tags.map((t) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text(t['name'] ?? ''),
                selected: false,
                onSelected: (_) => context.go('/tag_manager'),
              ),
            );
          }).toList(),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text('My Notes'),
              background: Center(child: Icon(Icons.note, size: 80, color: Colors.white)),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => context.go('/settings'),
              ),
            ],
          ),
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search notes…',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() {});
                                  _fetchNotes();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildTagChips(),
                  ],
                ),
              ),
            ),
          if (_pinnedNotes.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final note = _pinnedNotes[index];
                  return _buildNoteCard(note);
                },
                childCount: _pinnedNotes.length,
              ),
            ),
          if (_pinnedNotes.isNotEmpty && _recentNotes.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Text(
                  'RECENT',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ),
          if (_recentNotes.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final note = _recentNotes[index];
                  return _buildNoteCard(note);
                },
                childCount: _recentNotes.length,
              ),
            ),
          if (!_isLoading && _notes.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.note_add, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      const Text(
                        'Tap + to create your first note',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/note_editor'),
        child: const Icon(Icons.add),
      );
  }
}