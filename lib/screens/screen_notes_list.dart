import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({Key? key}) : super(key: key);

  @override
  _NotesListScreenState createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';
  List<Map<String, dynamic>> _pinnedNotes = [];
  List<Map<String, dynamic>> _recentNotes = [];
  List<Map<String, dynamic>> _tags = [];
  Set<String> _selectedTagIds = {};
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _fetchTags();
    _fetchNotes();
    _subscribe();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    if (_channel != null) {
      Supabase.instance.client.removeChannel(_channel!);
    }
    super.dispose();
  }

  Future<void> _fetchTags() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final data = await Supabase.instance.client
          .from('tags')
          .select('id, name, color')
          .eq('user_id', userId);
      setState(() => _tags = List<Map<String, dynamic>>.from(data));
    } catch (e) {
      // handle error
    }
  }

  Future<void> _fetchNotes() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final baseQuery = Supabase.instance.client.from('notes').select().eq('user_id', userId).eq('is_archived', false).isFilter('deleted_at', null).order('created_at', ascending: false);
      if (_searchQuery.isNotEmpty) {
        try {
          baseQuery.textSearch('fts', _searchQuery, config: 'english');
        } catch (_) {
          baseQuery.ilike('title', '%${_searchQuery}%');
        }
      }
      // For tags filtering, additional logic can be added.
      final data = await baseQuery;
      final allNotes = List<Map<String, dynamic>>.from(data);
      final pinned = allNotes.where((n) => n['is_pinned'] == true).toList();
      final recent = allNotes.where((n) => n['is_pinned'] != true).toList();
      setState(() {
        _pinnedNotes = pinned;
        _recentNotes = recent;
      });
    } catch (e) {
      // handle error
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = value;
      });
      _fetchNotes();
    });
  }

  void _subscribe() {
    _channel = Supabase.instance.client.channel('public:notes')
        .onPostgresChanges(event: PostgresChangeEvent.all, schema: 'public', table: 'notes', callback: (payload) {
      _fetchNotes();
    }).subscribe();
  }

  Future<void> _softDelete(Map<String, dynamic> note) async {
    try {
      await Supabase.instance.client
          .from('notes')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', note['id']);
      _fetchNotes();
    } catch (e) {
      // handle error
    }
  }

  Future<void> _archiveNote(Map<String, dynamic> note) async {
    try {
      await Supabase.instance.client
          .from('notes')
          .update({'is_archived': true})
          .eq('id', note['id']);
      _fetchNotes();
    } catch (e) {
      // handle error
    }
  }

  Future<void> _togglePin(Map<String, dynamic> note) async {
    try {
      await Supabase.instance.client
          .from('notes')
          .update({'is_pinned': !(note['is_pinned'] == true)})
          .eq('id', note['id']);
      _fetchNotes();
    } catch (e) {
      // handle error
    }
  }

  void _showNoteActions(Map<String, dynamic> note) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(note['is_pinned'] == true ? Icons.push_pin : Icons.push_pin_outlined),
              title: Text(note['is_pinned'] == true ? 'Unpin' : 'Pin'),
              onTap: () {
                Navigator.of(ctx).pop();
                _togglePin(note);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archive'),
              onTap: () {
                Navigator.of(ctx).pop();
                _archiveNote(note);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete'),
              onTap: () async {
                Navigator.of(ctx).pop();
                final confirm = await showDialog<bool>(
                  context: ctx,
                  builder: (ctx1) => AlertDialog(
                    title: const Text('Delete note?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx1).pop(false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.of(ctx1).pop(true), child: const Text('Delete')),
                    ],
                  ),
                );
                if (confirm == true) {
                  _softDelete(note);
                }
              },
            ),
          ],
        ),
      );
  }

  Widget _buildNoteCard(Map<String, dynamic> note) {
    final color = Color(int.parse(note['color'].replaceFirst('#', '0xFF')));
    return Dismissible(
      key: ValueKey(note['id']),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Archive note?'),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Archive')),
              ],
            ),
          );
          return confirm == true;
        }
        if (direction == DismissDirection.endToStart) {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete note?'),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
              ],
            ),
          );
          return confirm == true;
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          _archiveNote(note);
        } else if (direction == DismissDirection.endToStart) {
          _softDelete(note);
        }
      },
      child: Card(
        color: color,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        elevation: 2,
        child: InkWell(
          onTap: () => context.go('/note_editor', extra: {'noteId': note['id']}),
          onLongPress: () => _showNoteActions(note),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note['title'] ?? '',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  note['plain_text'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
  }

  Widget _buildTagChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: _tags.map((tag) {
          final selected = _selectedTagIds.contains(tag['id']);
          return FilterChip(
            label: Text(tag['name']),
            selected: selected,
            onSelected: (val) {
              setState(() {
                if (val) {
                  _selectedTagIds.add(tag['id']);
                } else {
                  _selectedTagIds.remove(tag['id']);
                }
              });
              _fetchNotes();
            },
          );
        }).toList(),
      );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF6B7280)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final allNotesEmpty = _pinnedNotes.isEmpty && _recentNotes.isEmpty;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            title: const Text('My Notes'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => context.go('/settings'),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: Colors.white),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: '🔍 Search notes…',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildTagChips()),
          if (_pinnedNotes.isNotEmpty) ...[
            SliverToBoxAdapter(child: _buildSectionHeader('PINNED')),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, index) => _buildNoteCard(_pinnedNotes[index]),
                childCount: _pinnedNotes.length,
              ),
            ),
          ],
          if (_recentNotes.isNotEmpty) ...[
            SliverToBoxAdapter(child: _buildSectionHeader('RECENT')),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, index) => _buildNoteCard(_recentNotes[index]),
                childCount: _recentNotes.length,
              ),
            ),
          ],
          if (allNotesEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.note_add, size: 64, color: Color(0xFF9CA3AF)),
                    SizedBox(height: 16),
                    Text(
                      'Tap + to create your first note',
                      style: TextStyle(fontSize: 16, color: Color(0xFF9CA3AF)),
                    ),
                  ],
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