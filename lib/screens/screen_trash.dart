import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  late final RealtimeChannel _channel;
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
    _subscribe();
  }

  @override
  void dispose() {
    Supabase.instance.client.removeChannel(_channel);
    super.dispose();
  }

  void _subscribe() {
    _channel = Supabase.instance.client
        .channel('public:notes')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'notes',
            callback: (payload) => _fetchNotes())
        .subscribe();
  }

  Future<void> _fetchNotes() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      final list = await Supabase.instance.client
          .from('notes')
          .select('id, title, plain_text, deleted_at, updated_at, user_id')
          .eq('user_id', userId)
          .isFilter('deleted_at', null)
          .order('deleted_at', ascending: false);
      setState(() {
        _notes = List<Map<String, dynamic>>.from(list);
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _notes = [];
      });
    }
  }

  Future<void> _restoreNote(String noteId) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      await Supabase.instance.client
          .from('notes')
          .update({'deleted_at': null})
          .eq('id', noteId)
          .eq('user_id', userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note restored')),
      );
      await _fetchNotes();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error restoring note'));
    }
  }

  Future<void> _deleteNotePermanently(String noteId) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      await Supabase.instance.client
          .from('note_tags')
          .delete()
          .eq('note_id', noteId)
          .eq('user_id', userId);
      await Supabase.instance.client
          .from('notes')
          .delete()
          .eq('id', noteId)
          .eq('user_id', userId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note permanently deleted')),
      );
      await _fetchNotes();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting note'));
    }
  }

  Future<void> _emptyTrash() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Empty Trash'),
        content:
            const Text('All deleted notes will be permanently removed.'),
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
    if (confirm != true) return;
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      await Supabase.instance.client
          .from('notes')
          .delete()
          .eq('user_id', userId)
          .not('deleted_at', 'is', null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trash emptied')),
      );
      await _fetchNotes();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error emptying trash'));
    }
  }

  int _daysAgo(DateTime deletedAt) =>
      DateTime.now().difference(deletedAt).inDays;
  int _daysLeft(int daysAgo) => 30 - daysAgo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 56,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go('/notes_list'),
                  ),
                  Expanded(
                    child: Text(
                      'Trash',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: _emptyTrash,
                    child: const Text(
                      'Empty Trash',
                      style: TextStyle(color: Color(0xFFEF4444)),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 40,
              width: double.infinity,
              color: const Color(0xFFFFFBEB),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: const Text(
                '⚠️  Notes are permanently deleted after 30 days',
                style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
              ),
            ),
            SizedBox(height: 8),
            _isLoading
                ? Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  )
                : _notes.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Column(
                          children: [
                            const Icon(Icons.delete_outline,
                                size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            const Text(
                              'Trash is empty',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _notes.length,
                        separatorBuilder: (ctx, idx) => const Divider(
                          height: 1,
                          color: Color(0xFFE5E7EB),
                        ),
                        itemBuilder: (ctx, idx) {
                          final note = _notes[idx];
                          final deletedAt =
                              DateTime.parse(note['deleted_at'] as String);
                          final daysAgo = _daysAgo(deletedAt);
                          final daysLeft = _daysLeft(daysAgo);
                          return Dismissible(
                            key: ValueKey(note['id'] as String),
                            confirmDismiss: (direction) async {
                              if (direction ==
                                      DismissDirection.endToStart ||
                                  direction == DismissDirection.startToEnd) {
                                if (direction ==
                                    DismissDirection.endToStart) {
                                  final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                            title: const Text(
                                                'Delete permanently?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ));
                                  return ok == true;
                                }
                                return true;
                              }
                              return false;
                            },
                            background: Container(
                              color: Colors.blue,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.restore, color: Colors.white),
                                  SizedBox(width: 6),
                                  Text('Restore',
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            secondaryBackground: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.delete, color: Colors.white),
                                  SizedBox(width: 6),
                                  Text('Delete',
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            onDismissed: (direction) async {
                              if (direction == DismissDirection.endToStart) {
                                await _deleteNotePermanently(
                                    note['id'] as String);
                              } else {
                                await _restoreNote(note['id'] as String);
                              }
                            },
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              color: const Color(0xFFF9FAFB),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      note['title'] as String,
                                      style: const TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      note['plain_text'] as String,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Color(0xFF9CA3AF),
                                          fontSize: 12),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Deleted $daysAgo days ago · $daysLeft days left',
                                      style: const TextStyle(
                                          color: Color(0xFFEF4444),
                                          fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '← Swipe to restore    Swipe to delete →',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFFD1D5DB)),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      );
  }
}