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
  late final RealtimeChannel _channel;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
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

  @override
  void dispose() {
    Supabase.instance.client.removeChannel(_channel);
    super.dispose();
  }

  Future<void> _fetchNotes() async {
    try {
      final data = await Supabase.instance.client
          .from('notes')
          .select('*, note_tags(tag_id, tags(id,name,color))')
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
          .not('deleted_at', 'is', null)
          .order('deleted_at', ascending: true);
      setState(() {
        _notes = List<Map<String, dynamic>>.from(data);
      });
    } catch (_) {
      // Handle error if needed
    }
  }

  Future<void> _restoreNote(String id) async {
    try {
      await Supabase.instance.client
          .from('notes')
          .update({'deleted_at': null})
          .eq('id', id)
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note restored')),
      );
      _fetchNotes();
    } catch (_) {}
  }

  Future<void> _hardDeleteNote(String id) async {
    try {
      // Delete from note_tags first
      await Supabase.instance.client
          .from('note_tags')
          .delete()
          .eq('note_id', id)
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id);
      // Delete from notes
      await Supabase.instance.client
          .from('notes')
          .delete()
          .eq('id', id)
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id);
      _fetchNotes();
    } catch (_) {}
  }

  Future<void> _emptyTrash() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Empty Trash'),
        content: const Text('Are you sure you want to permanently delete all notes in Trash?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(_, true),
            child: const Text('Delete All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final ids = _notes.map((n) => n['id'] as String).toList();
      if (ids.isNotEmpty) {
        await Supabase.instance.client
            .from('note_tags')
            .delete()
            .eq('note_id', ids[0]); // To trigger cascading delete; supabase handles foreign keys
        await Supabase.instance.client
            .from('notes')
            .delete()
            .in_('id', ids)
            .eq('user_id', Supabase.instance.client.auth.currentUser!.id);
      }
      _fetchNotes();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('All notes permanently deleted')));
    } catch (_) {}
  }

  String _formatDeletedAgo(DateTime deletedAt) {
    final diff = DateTime.now().difference(deletedAt);
    final daysAgo = diff.inDays;
    return 'Deleted $daysAgo days ago';
  }

  String _formatRemainingDays(DateTime deletedAt) {
    final diff = DateTime.now().difference(deletedAt);
    final remaining = 30 - diff.inDays;
    if (remaining <= 5 && remaining >= 0) {
      return 'Remaining ${remaining} days';
    }
    return '';
  }

  Widget _buildNoteCard(Map<String, dynamic> note) {
    final deletedAtStr = note['deleted_at'] as String?;
    if (deletedAtStr == null) return SizedBox.shrink();
    final deletedAt = DateTime.parse(deletedAtStr);
    final title = note['title'] as String? ?? '';
    final preview = (note['plain_text'] as String? ?? '').length > 100
        ? (note['plain_text'] as String).substring(0, 100) + '…'
        : (note['plain_text'] as String? ?? '');

    return Dismissible(
      key: ValueKey(note['id']),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Delete Note'),
              content: const Text('Are you sure you want to permanently delete this note?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(_, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(_, true),
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
        }
        return true;
      },
      direction: DismissDirection.horizontal,
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restore, color: Colors.white),
            SizedBox(width: 8),
            Text('Restore', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Delete', style: TextStyle(color: Colors.white)),
            SizedBox(width: 8),
            Icon(Icons.delete, color: Colors.white),
          ],
        ),
      ),
      onDismissed: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await _restoreNote(note['id'] as String);
        } else if (direction == DismissDirection.endToStart) {
          await _hardDeleteNote(note['id'] as String);
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
              SizedBox(height: 4),
              Text(preview,
                  style: const TextStyle(fontSize: 14, color: Colors.black54)),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDeletedAgo(deletedAt),
                      style: const TextStyle(fontSize: 12, color: Colors.black45)),
                  Text(
                    _formatRemainingDays(deletedAt),
                    style: TextStyle(
                        fontSize: 12,
                        color: _formatRemainingDays(deletedAt).contains('Remaining')
                            ? Colors.red
                            : Colors.green),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/notes_list'),
        ),
        title: const Text('Trash'),
        actions: [
          TextButton(
            onPressed: _emptyTrash,
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Empty Trash'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_notes.isEmpty) ...[
              SizedBox(height: 100),
              const Icon(Icons.delete_forever, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              const Text('Trash is empty',
                  style: TextStyle(fontSize: 18, color: Colors.black54)),
              SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '← Swipe to restore    Swipe to delete →',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFd1d5db), fontSize: 12),
                ),
              ),
            ] else ...[
              SizedBox(height: 16),
              ..._notes.map((note) => _buildNoteCard(note)).toList(),
            ],
            SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '← Swipe to restore    Swipe to delete →',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFd1d5db), fontSize: 12),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
  }
}