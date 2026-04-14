import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/image_helper.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({Key? key}) : super(key: key);

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  late final RealtimeChannel _channel;
  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> _tags = [];
  Set<String> _selectedTagIds = {};

  @override
  void initState() {
    super.initState();
    _fetchTags();
    _fetchNotes();
    _channel = Supabase.instance.client
        .channel('public:notes')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'notes',
            callback: (payload) {
          _fetchNotes(_searchCtrl.text);
        })
        .subscribe();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    Supabase.instance.client.removeChannel(_channel);
    super.dispose();
  }

  Future<void> _fetchTags() async {
    try {
      final data = await Supabase.instance.client
          .from('tags')
          .select('id,name,color')
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id);
      setState(() => _tags = List<Map<String, dynamic>>.from(data));
    } catch (e) {
      // handle error if needed
    }
  }

  Future<void> _fetchNotes([String query = '']) async {
    try {
      var qb = Supabase.instance.client
          .from('notes')
          .select('*, note_tags(tag_id, tags(id,name,color))')
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
          .not('deleted_at', 'is', null)
          .not('is_archived', 'is', null);

      if (query.isNotEmpty) {
        qb = qb.textSearch('fts', query, config: 'english');
      }

      final data = await qb
          .order('is_pinned', ascending: false)
          .order('created_at', ascending: false)
          .range(0, 49);
      setState(() => _notes = List<Map<String, dynamic>>.from(data));
    } catch (e) {
      // handle error if needed
    }
  }

  List<Map<String, dynamic>> get _pinnedNotes =>
      _notes.where((n) => n['is_pinned'] == true).toList();

  List<Map<String, dynamic>> get _recentNotes =>
      _notes.where((n) => n['is_pinned'] != true).toList();

  Future<void> _archiveNote(String id) async {
    await Supabase.instance.client
        .from('notes')
        .update({'is_archived': true})
        .eq('id', id);
  }

  Future<void> _deleteNote(String id) async {
    await Supabase.instance.client
        .from('notes')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }

  Future<bool> _confirmDelete() async {
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

  void _showNoteOptions(Map<String, dynamic> note) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          final bool isPinned = note['is_pinned'] == true;
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: Icon(isPinned ? Icons.star : Icons.star_border),
                  title: Text(isPinned ? 'Unpin Note' : 'Pin Note'),
                  onTap: () async {
                    await Supabase.instance.client
                        .from('notes')
                        .update({'is_pinned': !isPinned})
                        .eq('id', note['id']);
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.archive),
                  title: const Text('Archive Note'),
                  onTap: () async {
                    await _archiveNote(note['id']);
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Delete Note'),
                  onTap: () async {
                    final confirm = await _confirmDelete();
                    if (confirm) {
                      await _deleteNote(note['id']);
                    }
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          );
        });
  }

  String _truncatePlainText(String text) {
    if (text.length <= 80) return text;
    return text.substring(0, 80) + '…';
  }

  Widget _buildNoteCard(Map<String, dynamic> note) {
    final color = note['color'] != null
        ? Color(int.parse(note['color'].replaceFirst('#', '0xFF')))
        : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Dismissible(
        key: ValueKey(note['id']),
        background: Container(
          color: Colors.orange,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            children: const [
              Icon(Icons.archive, color: Colors.white),
              Text('Archive',
                  style: TextStyle(color: Colors.white, fontSize: 11)),
            ],
          ),
        ),
        secondaryBackground: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [
              Icon(Icons.delete, color: Colors.white),
              Text('Delete',
                  style: TextStyle(color: Colors.white, fontSize: 11)),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            await _archiveNote(note['id']);
            return false;
          } else {
            return await _confirmDelete();
          }
        },
        onDismissed: (_) {},
        child: InkWell(
          onTap: () =>
              GoRouter.of(context).go('/note_editor', extra: note['id']),
          onLongPress: () => _showNoteOptions(note),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(note['title'] ?? '',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                  _truncatePlainText(note['plain_text'] ?? ''),
                  style:
                      const TextStyle(fontSize: 14, color: Colors.black87),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
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
              background: Image.asset('assets/images/header.jpg',
                  fit: BoxFit.cover),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => GoRouter.of(context).go('/settings'),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: '🔍 Search notes…',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed:
                                  () => _searchCtrl.clear() .._fetchNotes(),
                            )
                          : null,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                    onChanged: (v) {
                      _debounce?.cancel();
                      _debounce = Timer(
                          const Duration(milliseconds: 300), () {
                        _fetchNotes(v);
                      });
                    },
                  ),
                  SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _tags.map((tag) {
                        final bool isSelected =
                            _selectedTagIds.contains(tag['id']);
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FilterChip(
                            label: Text(tag['name']),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedTagIds.add(tag['id']);
                                } else {
                                  _selectedTagIds.remove(tag['id']);
                                }
                              });
                            },
                            backgroundColor: Color(
                                    int.parse(tag['color']
                                            .replaceFirst('#', '0xFF')))
                                .withOpacity(0.2),
                            selectedColor: Color(
                                    int.parse(tag['color']
                                            .replaceFirst('#', '0xFF')))
                                .withOpacity(0.5),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 8),
                  if (_pinnedNotes.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        '📌  PINNED',
                        style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final note = _pinnedNotes[index];
                          return _buildNoteCard(note);
                        },
                        childCount: _pinnedNotes.length,
                      ),
                    ),
                  ],
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'RECENT',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final note = _recentNotes[index];
                        return _buildNoteCard(note);
                      },
                      childCount: _recentNotes.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_notes.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.note_add, size: 64, color: Color(0xFF6B7280)),
                    SizedBox(height: 16),
                    Text('Tap + to create your first note',
                        style: TextStyle(
                            fontSize: 18, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => GoRouter.of(context).go('/note_editor'),
        child: const Icon(Icons.add),
      );
  }
}