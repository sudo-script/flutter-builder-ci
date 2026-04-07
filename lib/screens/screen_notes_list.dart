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
  List<Map<String, dynamic>> _pinnedNotes = [];
  List<Map<String, dynamic>> _recentNotes = [];
  List<Map<String, dynamic>> _allNotes = [];
  List<Map<String, dynamic>> _tags = [];
  Set<String> _selectedTagIds = {};
  bool _loading = false;
  late final RealtimeChannel _channel;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
    _fetchTags();
    _fetchNotes();
    _subscribe();
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    _debounce?.cancel();
    _channel.unsubscribe();
    Supabase.instance.client.removeChannel(_channel);
    super.dispose();
  }

  void _onSearchChanged() {
    final value = _searchCtrl.text;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchQuery = value;
      _fetchNotes();
    });
  }

  String _searchQuery = '';

  Future<void> _fetchTags() async {
    try {
      final data = await Supabase.instance.client
          .from('tags')
          .select('id,name,color')
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id);
      setState(() {
        _tags = List<Map<String, dynamic>>.from(data);
      });
    } catch (_) {}
  }

  Future<void> _fetchNotes() async {
    setState(() {
      _loading = true;
    });
    try {
      var query = Supabase.instance.client
          .from('notes')
          .select('*, note_tags(tag_id, tags(id,name,color))')
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
          .eq('is_archived', false)
          .is('deleted_at', null)
          .order('created_at', ascending: false)
          .range(0, 19);

      if (_searchQuery.isNotEmpty) {
        query = query.textSearch('fts', _searchQuery, config: 'english');
      }

      final data = await query;
      List<Map<String, dynamic>> notesData = List<Map<String, dynamic>>.from(data);

      notesData.forEach((note) {
        // Flatten tags
        if (note['note_tags'] != null) {
          final tags = (note['note_tags'] as List)
              .map((t) => t['tags'] as Map<String, dynamic>)
              .toList();
          note['tags'] = tags;
        } else {
          note['tags'] = [];
        }
      });

      // Filter by selected tags
      if (_selectedTagIds.isNotEmpty) {
        notesData = notesData.where((note) {
          final tags = note['tags'] as List<dynamic>;
          return tags.any((t) => _selectedTagIds.contains(t['id']));
        }).toList();
      }

      setState(() {
        _allNotes = notesData;
        _pinnedNotes = notesData.where((n) => n['is_pinned'] == true).toList();
        _recentNotes = notesData.where((n) => n['is_pinned'] != true).toList();
      });
    } catch (_) {}
    setState(() {
      _loading = false;
    });
  }

  void _subscribe() {
    _channel = Supabase.instance.client
        .channel('public:notes')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'notes',
            callback: (payload) {
      _fetchNotes();
    }).subscribe();
  }

  void _toggleTag(String tagId) {
    setState(() {
      if (_selectedTagIds.contains(tagId)) {
        _selectedTagIds.remove(tagId);
      } else {
        _selectedTagIds.add(tagId);
      }
    });
    _fetchNotes();
  }

  void _pinNote(String id, bool pinned) async {
    try {
      await Supabase.instance.client
          .from('notes')
          .update({'is_pinned': pinned})
          .eq('id', id);
      _fetchNotes();
    } catch (_) {}
  }

  void _archiveNote(String id) async {
    try {
      await Supabase.instance.client
          .from('notes')
          .update({'is_archived': true})
          .eq('id', id);
      _fetchNotes();
    } catch (_) {}
  }

  void _softDeleteNote(String id) async {
    try {
      await Supabase.instance.client
          .from('notes')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', id);
      _fetchNotes();
    } catch (_) {}
  }

  void _hardDeleteNote(String id) async {
    try {
      await Supabase.instance.client
          .from('notes')
          .delete()
          .eq('id', id);
      _fetchNotes();
    } catch (_) {}
  }

  Widget _buildTagsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: _tags.map((tag) {
          final selected = _selectedTagIds.contains(tag['id']);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(tag['name']),
              selected: selected,
              selectedColor: Color(int.parse(tag['color']
                      .replaceFirst('#', '0xFF')))
                  .withOpacity(0.5),
              backgroundColor:
                  Color(int.parse(tag['color'].replaceFirst('#', '0xFF')))
                      .withOpacity(0.2),
              onSelected: (_) => _toggleTag(tag['id']),
            ),
          );
        }).toList(),
      ),
  }

  Widget _buildNoteCard(Map<String, dynamic> note) {
    final color = Color(int.parse(
        note['color'].replaceFirst('#', '0xFF')));
    final title = note['title'] ?? '';
    final snippet = note['plain_text']?.toString() ?? '';
    return Dismissible(
      key: ValueKey(note['id']),
      background: Container(
        color: const Color(0xFF4CAF50),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.archive, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: const Color(0xFFF44336),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete note?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete')),
                  ],
                ),
              ) ??
              false;
        }
        return true;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _softDeleteNote(note['id']);
        } else {
          _archiveNote(note['id']);
        }
      },
      child: GestureDetector(
        onLongPress: () => _showNoteActions(note),
        onTap: () => context.go('/note_editor', extra: note['id']),
        child: Card(
          color: color.withOpacity(0.1),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(snippet,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14)),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        '${DateTime.parse(note['created_at'] ?? DateTime.now().toIso8601String()).month}/${DateTime.parse(note['created_at'] ?? DateTime.now().toIso8601String()).day}/${DateTime.parse(note['created_at'] ?? DateTime.now().toIso8601String()).year}',
                        style: const TextStyle(fontSize: 12)),
                    Chip(
                      avatar: CircleAvatar(
                        backgroundColor:
                            Color(int.parse(note['color'].replaceFirst('#', '0xFF')))
                                .withOpacity(0.7),
                        radius: 4,
                      ),
                      label: const Text('', style: TextStyle(fontSize: 12)),
                      visualDensity: VisualDensity.compact,
                      shape: const StadiumBorder(),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
  }

  void _showNoteActions(Map<String, dynamic> note) async {
    final pinned = note['is_pinned'] == true;
    await showModalBottomSheet(
        context: context,
        builder: (_) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(pinned ? Icons.push_pin : Icons.push_pin_outlined),
                  title: Text(pinned ? 'Unpin' : 'Pin'),
                  onTap: () {
                    Navigator.pop(context);
                    _pinNote(note['id'], !pinned);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.archive_outlined),
                  title: const Text('Archive'),
                  onTap: () {
                    Navigator.pop(context);
                    _archiveNote(note['id']);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Delete'),
                  onTap: () {
                    Navigator.pop(context);
                    _softDeleteNote(note['id']);
                  },
                ),
              ],
            ),
          );
        });
  }

  Widget _buildNotesSection(String header, List<Map<String, dynamic>> notes) {
    return notes.isEmpty
        ? const SizedBox.shrink()
        : SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(header,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: notes.length,
                    itemBuilder: (context, index) =>
                        _buildNoteCard(notes[index]),
                  ),
                ],
              ),
            ),
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/note_editor'),
        child: const Icon(Icons.add),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: Colors.white,
            centerTitle: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('My Notes',
                    style: TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                Spacer(),
                IconButton(
                  icon:
                      const Icon(Icons.settings, color: Color(0xFF374151)),
                  onPressed: () => context.go('/settings'),
                ),
              ],
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: const Image(
                image: AssetImage('assets/images/hero.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: '🔍  Search notes…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchCtrl.clear();
                                _searchQuery = '';
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
                  _buildTagsRow(),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ),
          if (_loading) const SliverToBoxAdapter(child: LinearProgressIndicator()),
          _buildNotesSection('PINNED', _pinnedNotes),
          _buildNotesSection('RECENT', _recentNotes),
          if (_pinnedNotes.isEmpty &&
              _recentNotes.isEmpty &&
              !_loading)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.sticky_note_2, size: 48, color: Color(0xFF9ca3af)),
                    SizedBox(height: 16),
                    Text('Tap + to create your first note',
                        style: TextStyle(fontSize: 16, color: Color(0xFF9ca3af))),
                  ],
                ),
              ),
            ),
        ],
      ),
  }
}