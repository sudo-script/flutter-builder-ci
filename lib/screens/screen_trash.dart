import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({Key? key}) : super(key: key);

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  List<Map<String, dynamic>> _notes = [];
  String? _userId;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _userId = Supabase.instance.client.auth.currentUser?.id;
    _fetchNotes();
    _subscribe();
  }

  @override
  void dispose() {
    if (_channel != null) {
      Supabase.instance.client.removeChannel(_channel!);
    }
    super.dispose();
  }

  Future<void> _fetchNotes() async {
    if (_userId == null) return;
    try {
      final data =
          await Supabase.instance.client
              .from('notes')
              .select('*, note_tags(tag_id, tags(id, name, color))')
              .eq('user_id', _userId!)
              .not('deleted_at', 'is', null)
              .order('updated_at', ascending: false);
      setState(() {
        _notes = List<Map<String, dynamic>>.from(data);
      });
    } catch (_) {}
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
          },
        )
        .subscribe();
  }

  Future<void> _restoreNote(String id) async {
    if (_userId == null) return;
    try {
      await Supabase.instance.client
          .from('notes')
          .update({'deleted_at': null})
          .eq('id', id)
          .eq('user_id', _userId!)
          .single();
      await _fetchNotes();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note restored')),
      );
    } catch (_) {}
  }

  Future<void> _deleteNotePermanently(String id) async {
    if (_userId == null) return;
    try {
      await Supabase.instance.client
          .from('note_tags')
          .delete()
          .eq('note_id', id)
          .eq('user_id', _userId!)
          .single();
      await Supabase.instance.client
          .from('notes')
          .delete()
          .eq('id', id)
          .eq('user_id', _userId!)
          .single();
      await _fetchNotes();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note deleted')),
      );
    } catch (_) {}
  }

  Future<void> _emptyTrash() async {
    if (_userId == null) return;
    try {
      await Supabase.instance.client
          .from('note_tags')
          .delete()
          .eq('user_id', _userId!)
          .single();
      await Supabase.instance.client
          .from('notes')
          .delete()
          .eq('user_id', _userId!)
          .not('deleted_at', 'is', null)
          .single();
      await _fetchNotes();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trash emptied')),
      );
    } catch (_) {}
  }

  String _formatDate(String iso) {
    final dt = DateTime.parse(iso);
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  int _daysSinceDeleted(String iso) {
    final dt = DateTime.parse(iso);
    return DateTime.now().difference(dt).inDays;
  }

  int _daysRemaining(String iso) {
    return 30 - _daysSinceDeleted(iso);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/notes_list'),
        ),
        actions: [
          TextButton(
            onPressed: () => showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Empty Trash'),
                content:
                    const Text('Are you sure you want to permanently delete all notes?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(ctx).pop();
                      await _emptyTrash();
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ),
            child: const Text(
              'Empty Trash',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 54),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.yellow.shade50,
              child: const Text(
                '⚠️  Notes are permanently deleted after 30 days',
                style: const TextStyle(
                  color: Color(0xFF92400E),
                  fontSize: 12,
                ),
              ),
            ),
            SizedBox(height: 16),
            if (_notes.isEmpty) _buildEmptyState() else _buildNotesList(),
            SizedBox(height: 16),
            const Text(
              '← Swipe to restore    Swipe to delete →',
              style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 12),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
          ],
        ),
      );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(32),
          child: Icon(Icons.delete_outline, size: 80, color: Colors.grey),
        ),
        const Text(
          'Trash is empty',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ],
  }

  Widget _buildNotesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        final deletedAt = note['deleted_at'] as String;
        final daysRemaining = _daysRemaining(deletedAt);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Dismissible(
            key: ValueKey(note['id']),
            direction: DismissDirection.horizontal,
            background: Container(
              color: Colors.blue,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.archive, color: Colors.white),
                  SizedBox(height: 2),
                  Text(
                    'Archive',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.delete, color: Colors.white),
                  SizedBox(height: 2),
                  Text(
                    'Delete',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
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
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  );
              }
              return true;
            },
            onDismissed: (direction) {
              if (direction == DismissDirection.endToStart) {
                _deleteNotePermanently(note['id'] as String);
              } else {
                _restoreNote(note['id'] as String);
              }
            },
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      note['plain_text'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Deleted ${_daysSinceDeleted(deletedAt)} days ago',
                      style: const TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
                    ),
                    Text(
                      'Days remaining: $daysRemaining',
                      style: TextStyle(
                        fontSize: 11,
                        color: daysRemaining <= 5 ? const Color(0xFFEF4444) : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
  }
}