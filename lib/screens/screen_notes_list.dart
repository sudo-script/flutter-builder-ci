import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';
  List<Map<String, dynamic>> _allNotes = [];
  List<Map<String, dynamic>> _pinnedNotes = [];
  List<Map<String, dynamic>> _recentNotes = [];
  List<Map<String, dynamic>> _tags = [];
  final Set<String> _selectedTagIds = {};
  late final RealtimeChannel _channel;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _subscribeRealtime();
  }

  void _loadInitialData() async {
    await _fetchTags();
    await _fetchNotes();
  }

  Future<void> _fetchTags() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final data = await Supabase.instance.client
        .from('tags')
        .select('id,name,color')
        .eq('user_id', userId);
    _tags = List<Map<String, dynamic>>.from(data);
    setState(() {});
  }

  Future<void> _fetchNotes() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    var query = Supabase.instance.client
        .from('notes')
        .select('*,note_tags(tag_id, tags(id,name,color))')
        .eq('user_id', userId)
        .eq('is_archived', false)
        .isFilter('deleted_at', null)
        .order('is_pinned', ascending: false)
        .order('created_at', ascending: false);

    if (_searchQuery.isNotEmpty) {
      query = query
          .textSearch('fts', _searchQuery, config: 'english')
          .ilike('title', '%${_searchQuery}%');
    }

    try {
      final data = await query;
      _allNotes = List<Map<String, dynamic>>.from(data);
      _applyFilters();
    } catch (_) {
      // ignore errors
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = _allNotes.where((note) {
      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        final title = (note['title'] as String?)?.toLowerCase() ?? '';
        final plain = (note['plain_text'] as String?)?.toLowerCase() ?? '';
        matchesSearch = title.contains(_searchQuery.toLowerCase()) ||
            plain.contains(_searchQuery.toLowerCase());
      }
      bool matchesTags = true;
      if (_selectedTagIds.isNotEmpty) {
        final noteTags = (note['note_tags'] as List<dynamic>?) ?? [];
        matchesTags = noteTags
            .where((t) => _selectedTagIds.contains(t['tag_id']))
            .isNotEmpty;
      }
      return matchesSearch && matchesTags;
    }).toList();

    _pinnedNotes = filtered
        .where((note) => note['is_pinned'] == true)
        .toList();
    _recentNotes = filtered
        .where((note) => note['is_pinned'] == false)
        .toList();
    setState(() {});
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      _searchQuery = value;
      await _fetchNotes();
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
        }).subscribe();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    Supabase.instance.client.removeChannel(_channel);
    super.dispose();
  }

  Color _colorFromHex(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  Future<void> _softDelete(String id) async {
    await Supabase.instance.client
        .from('notes')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }

  Future<void> _archiveNote(String id) async {
    await Supabase.instance.client
        .from('notes')
        .update({'is_archived': true})
        .eq('id', id);
  }

  Future<void> _togglePin(String id, bool isPinned) async {
    await Supabase.instance.client
        .from('notes')
        .update({'is_pinned': !isPinned})
        .eq('id', id);
  }

  void _showNoteOptions(BuildContext context, Map<String, dynamic> note) {
    final id = note['id'] as String;
    final isPinned = note['is_pinned'] as bool? ?? false;
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(isPinned ? Icons.star : Icons.star_border),
                  title: Text(isPinned ? 'Unpin note' : 'Pin note'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _togglePin(id, isPinned);
                    _fetchNotes();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.archive),
                  title: const Text('Archive note'),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _archiveNote(id);
                    _fetchNotes();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete note', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final confirm = await showDialog<bool>(
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
                            ));
                    if (confirm == true) {
                      await _softDelete(id);
                      _fetchNotes();
                    }
                  },
                ),
              ],
            ),
          );
        });
  }

  Widget _buildNoteCard(Map<String, dynamic> note) {
    final id = note['id'] as String;
    final title = note['title'] as String? ?? '';
    final plain = note['plain_text'] as String? ?? '';
    final colorHex = note['color'] as String? ?? '#ffffff';
    final isPinned = note['is_pinned'] as bool? ?? false;
    final subtitle =
        plain.length > 50 ? plain.substring(0, 50) + '...' : plain;
    final bgColor = _colorFromHex(colorHex);

    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          final confirm = await showDialog<bool>(
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
                  ));
          return confirm == true;
        }
        return true;
      },
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          await _softDelete(id);
          _fetchNotes();
        } else {
          await _archiveNote(id);
          _fetchNotes();
        }
      },
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      background: Container(
        color: const Color(0xFF3B82F6),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.archive, color: Colors.white),
      ),
      child: GestureDetector(
        onLongPress: () => _showNoteOptions(context, note),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          color: bgColor,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(subtitle,
                    style:
                        const TextStyle(fontSize: 14, color: Colors.black87)),
                SizedBox(height: 8),
                Text(
                  '${note['created_at'] ?? ''}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      );
  }

  Widget _buildTagChips() {
    return Wrap(
      spacing: 8,
      children: _tags.map((tag) {
        final id = tag['id'] as String? ?? '';
        final name = tag['name'] as String? ?? '';
        final colorHex = tag['color'] as String? ?? '#ffffff';
        final isSelected = _selectedTagIds.contains(id);
        return FilterChip(
          label: Text(name),
          selected: isSelected,
          selectedColor:
              _colorFromHex(colorHex).withOpacity(0.5),
          backgroundColor: _colorFromHex(colorHex).withOpacity(0.2),
          onSelected: (v) {
            setState(() {
              if (v) {
                _selectedTagIds.add(id);
              } else {
                _selectedTagIds.remove(id);
              }
              _applyFilters();
            });
          },
        );
      }).toList();
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> notes) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          SizedBox(height: 8),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final note = notes[index];
                return _buildNoteCard(note);
              },
              childCount: notes.length,
            ),
          ),
        ],
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
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text('My Notes',
                  style: TextStyle(color: Colors.white)),
            ),
            actions: [
              IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => context.go('/settings')),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: '🔍 Search notes…',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _buildTagChips(),
            ),
          ),
          if (_pinnedNotes.isEmpty && _recentNotes.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 100),
                child: Column(
                  children: [
                    const Icon(Icons.add, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    const Text('Tap + to create your first note',
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              ),
            )
          else ...[
            if (_pinnedNotes.isNotEmpty) _buildSection('PINNED', _pinnedNotes),
            if (_recentNotes.isNotEmpty) _buildSection('RECENT', _recentNotes),
          ],
        ].whereType<Widget>().toList(), // ensure widget list
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => context.go('/note_editor'),
      );
  }
}