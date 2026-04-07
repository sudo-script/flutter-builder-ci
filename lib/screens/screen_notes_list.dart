import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});
  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final _client = Supabase.instance.client;
  final _searchCtrl = TextEditingController();

  List<Map<String, dynamic>> _pinned  = [];
  List<Map<String, dynamic>> _others  = [];
  List<Map<String, dynamic>> _tags    = [];
  List<Map<String, dynamic>> _search  = [];
  String? _selectedTagId;
  String  _query = '';
  bool    _loading = true;
  Timer?  _debounce;
  late final RealtimeChannel _channel;

  @override
  void initState() {
    super.initState();
    _fetchTags();
    _fetchNotes();
    _channel = _client
      .channel('public:notes')
      .onPostgresChanges(
        event: PostgresChangeEvent.all, schema: 'public', table: 'notes',
        callback: (_) => _fetchNotes())
      .subscribe();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    _client.removeChannel(_channel);
    super.dispose();
  }

  String _relativeDate(dynamic raw) {
    if (raw == null) return '';
    final dt = DateTime.tryParse(raw.toString())?.toLocal();
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inHours   < 1)  return '${diff.inMinutes} min ago';
    if (diff.inHours   < 24) return '${diff.inHours} hour${diff.inHours > 1 ? "s" : ""} ago';
    if (diff.inDays    == 1) return 'Yesterday';
    if (diff.inDays    < 7)  return '${diff.inDays} days ago';
    return DateFormat('MMM d').format(dt);
  }

  Future<void> _fetchTags() async {
    try {
      final data = await _client.from('tags')
        .select('id, name, color')
        .eq('user_id', _client.auth.currentUser!.id);
      if (mounted) setState(() => _tags = List<Map<String, dynamic>>.from(data as List));
    } catch (_) {}
  }

  Future<void> _fetchNotes() async {
    try {
      var q = _client.from('notes')
        .select('id, title, plain_text, color, is_pinned, is_archived, created_at, updated_at')
        .eq('user_id', _client.auth.currentUser!.id)
        .eq('is_archived', false)
        .isFilter('deleted_at', null);
      if (_selectedTagId != null) {
        final tagged = await _client.from('note_tags')
          .select('note_id').eq('tag_id', _selectedTagId!);
        final ids = (tagged as List).map((e) => e['note_id']).toList();
        if (ids.isEmpty) {
          if (mounted) setState(() { _pinned = []; _others = []; _loading = false; });
          return;
        }
        q = q.inFilter('id', ids);
      }
      final data = await q.order('is_pinned', ascending: false).order('updated_at', ascending: false);
      final all = List<Map<String, dynamic>>.from(data as List);
      if (mounted) setState(() {
        _pinned  = all.where((n) => n['is_pinned'] == true).toList();
        _others  = all.where((n) => n['is_pinned'] != true).toList();
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _searchNotes(String q) async {
    if (q.trim().isEmpty) { setState(() => _search = []); return; }
    try {
      final data = await _client.from('notes')
        .select('id, title, plain_text, color, is_pinned, updated_at')
        .eq('user_id', _client.auth.currentUser!.id)
        .isFilter('deleted_at', null)
        .textSearch('fts', q, config: 'english');
      if (mounted) setState(() => _search = List<Map<String, dynamic>>.from(data as List));
    } catch (_) {
      try {
        final data = await _client.from('notes')
          .select('id, title, plain_text, color, is_pinned, updated_at')
          .eq('user_id', _client.auth.currentUser!.id)
          .isFilter('deleted_at', null)
          .ilike('title', '%$q%');
        if (mounted) setState(() => _search = List<Map<String, dynamic>>.from(data as List));
      } catch (_) {}
    }
  }

  Future<void> _archiveNote(String id) async {
    try {
      await _client.from('notes').update({'is_archived': true}).eq('id', id);
      _fetchNotes();
    } catch (_) {}
  }

  Future<void> _deleteNote(String id) async {
    final ok = await showDialog<bool>(context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('The note will be moved to Trash.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ]));
    if (ok != true) return;
    try {
      await _client.from('notes')
        .update({'deleted_at': DateTime.now().toIso8601String()}).eq('id', id);
      _fetchNotes();
    } catch (_) {}
  }

  Future<void> _togglePin(String id, bool current) async {
    try {
      await _client.from('notes').update({'is_pinned': !current}).eq('id', id);
      _fetchNotes();
    } catch (_) {}
  }

  Widget _noteCard(Map<String, dynamic> note) {
    final color = note['color'] as String? ?? '#ffffff';
    final bg    = Color(int.parse(color.replaceFirst('#', '0xFF')));
    final isDark = ThemeData.estimateBrightnessForColor(bg) == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final id       = note['id'] as String;
    final isPinned = note['is_pinned'] == true;

    return Dismissible(
      key: ValueKey(id),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: Colors.blue,
        child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.archive, color: Colors.white),
          Text('Archive', style: TextStyle(color: Colors.white, fontSize: 11)),
        ])),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.delete, color: Colors.white),
          Text('Delete', style: TextStyle(color: Colors.white, fontSize: 11)),
        ])),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.endToStart) {
          await _deleteNote(id); return false;
        }
        await _archiveNote(id); return false;
      },
      child: GestureDetector(
        onTap: () => context.go('/note_editor', extra: {'noteId': id}),
        onLongPress: () => _showNoteMenu(note),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(note['title'] as String? ?? 'Untitled',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(note['plain_text'] as String? ?? '',
                style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.7)),
                maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Text(_relativeDate(note['updated_at']),
                style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.5))),
            ])),
            if (isPinned) Icon(Icons.push_pin, size: 16, color: textColor.withOpacity(0.6)),
          ])),
      ),
    );
  }

  void _showNoteMenu(Map<String, dynamic> note) {
    final id = note['id'] as String;
    final isPinned = note['is_pinned'] == true;
    showModalBottomSheet(context: context, builder: (ctx) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: Icon(isPinned ? Icons.push_pin_outlined : Icons.push_pin),
          title: Text(isPinned ? 'Unpin' : 'Pin'),
          onTap: () { Navigator.pop(ctx); _togglePin(id, isPinned); }),
        ListTile(leading: const Icon(Icons.archive_outlined), title: const Text('Archive'),
          onTap: () { Navigator.pop(ctx); _archiveNote(id); }),
        ListTile(leading: const Icon(Icons.delete_outline, color: Colors.red),
          title: const Text('Delete', style: TextStyle(color: Colors.red)),
          onTap: () { Navigator.pop(ctx); _deleteNote(id); }),
      ])));
  }

  @override
  Widget build(BuildContext context) {
    final showSearch = _query.isNotEmpty;
    final displayNotes = showSearch ? _search : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true, floating: false, expandedHeight: 120,
          backgroundColor: Colors.white, elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            title: const Text('My Notes',
              style: TextStyle(color: Color(0xFF111827), fontSize: 22, fontWeight: FontWeight.bold))),
          actions: [
            IconButton(icon: const Icon(Icons.settings_outlined, color: Color(0xFF374151)),
              onPressed: () => context.go('/settings')),
          ]),
        SliverToBoxAdapter(child: Column(children: [
          // Search
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) {
                setState(() => _query = v);
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 300), () => _searchNotes(v));
              },
              decoration: InputDecoration(
                hintText: 'Search notes…',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9ca3af)),
                suffixIcon: _query.isEmpty ? null : IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFF9ca3af)),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() { _query = ''; _search = []; });
                  }),
                filled: true, fillColor: const Color(0xFFf3f4f6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(23), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0)),
            )),
          // Tag filter chips
          if (_tags.isNotEmpty)
            SizedBox(height: 44, child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: const Text('All'), selected: _selectedTagId == null,
                    onSelected: (_) => setState(() { _selectedTagId = null; _fetchNotes(); }),
                    selectedColor: const Color(0xFF6366f1),
                    labelStyle: TextStyle(color: _selectedTagId == null ? Colors.white : null))),
                ..._tags.map((t) {
                  final sel = _selectedTagId == t['id'];
                  final c = Color(int.parse((t['color'] as String).replaceFirst('#', '0xFF')));
                  return Padding(padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(t['name'] as String),
                      selected: sel,
                      onSelected: (_) => setState(() {
                        _selectedTagId = sel ? null : t['id'] as String;
                        _fetchNotes();
                      }),
                      selectedColor: c.withOpacity(0.3),
                      backgroundColor: const Color(0xFFf3f4f6)));
                }),
              ])),
          const SizedBox(height: 8),
        ])),
        if (_loading)
          const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
        else if (showSearch) ...[
          if (_search.isEmpty)
            const SliverFillRemaining(child: Center(
              child: Text('No notes match your search', style: TextStyle(color: Color(0xFF9ca3af)))))
          else
            SliverList(delegate: SliverChildBuilderDelegate(
              (ctx, i) => _noteCard(_search[i]), childCount: _search.length)),
        ] else ...[
          if (_pinned.isNotEmpty) ...[
            const SliverToBoxAdapter(child: Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 0, 4),
              child: Text('📌  PINNED',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6b7280), letterSpacing: 1)))),
            SliverList(delegate: SliverChildBuilderDelegate(
              (ctx, i) => _noteCard(_pinned[i]), childCount: _pinned.length)),
          ],
          if (_others.isNotEmpty) ...[
            const SliverToBoxAdapter(child: Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 0, 4),
              child: Text('RECENT',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6b7280), letterSpacing: 1)))),
            SliverList(delegate: SliverChildBuilderDelegate(
              (ctx, i) => _noteCard(_others[i]), childCount: _others.length)),
          ],
          if (_pinned.isEmpty && _others.isEmpty)
            SliverFillRemaining(child: Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.note_add_outlined, size: 64, color: Color(0xFFd1d5db)),
                const SizedBox(height: 12),
                const Text('Tap + to create your first note',
                  style: TextStyle(color: Color(0xFF9ca3af), fontSize: 15)),
                const SizedBox(height: 8),
                TextButton(onPressed: () => context.go('/tag_manager'),
                  child: const Text('Manage tags →')),
              ]))),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6366f1),
        onPressed: () => context.go('/note_editor', extra: {'noteId': null}),
        child: const Icon(Icons.add, color: Colors.white, size: 28)),
    );
  }
}
