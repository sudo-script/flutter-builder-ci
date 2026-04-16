import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

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
    _subscribe();
  }

  Future<void> _fetchNotes() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      final data = await Supabase.instance.client
          .from('notes')
          .select('*, note_tags(tag_id, tags(id,name,color))')
          .eq('user_id', user.id)
          .not('deleted_at', 'is', null)
          .order('deleted_at', ascending: false);
      if (!mounted) return;
      setState(() {
        _notes = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load trash: $e')));
    }
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

  @override
  void dispose() {
    Supabase.instance.client.removeChannel(_channel);
    super.dispose();
  }

  Future<void> _restoreNote(String id) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      await Supabase.instance.client
          .from('notes')
          .update({'deleted_at': null})
          .eq('id', id)
          .eq('user_id', user.id);
      _fetchNotes();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Note restored')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore failed: $e')));
    }
  }

  Future<void> _deleteNote(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete note permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      await Supabase.instance.client
          .from('notes')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id);
      _fetchNotes();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Note permanently deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')));
    }
  }

  Future<void> _emptyTrash() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Empty Trash?'),
        content: const Text('All notes in trash will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Empty'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      await Supabase.instance.client
          .from('notes')
          .delete()
          .eq('user_id', user.id)
          .not('deleted_at', 'is', null);
      _fetchNotes();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trash emptied')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to empty trash: $e')));
    }
  }

  int _daysSinceDeleted(String isoDate) {
    final deleted = DateTime.parse(isoDate);
    return DateTime.now().difference(deleted).inDays;
  }

  int _daysRemaining(String isoDate) {
    final days = _daysSinceDeleted(isoDate);
    return 30 - days;
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
              backgroundColor: Colors.redAccent,
            ),
            child: const Text(
              'Empty Trash',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 56,
              color: const Color(0xFFFFFFFF),
              child: const Center(
                child: Text(
                  '⚠️  Notes are permanently deleted after 30 days',
                  style: TextStyle(color: Color(0xFF92400E), fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _notes.isEmpty
                ? Column(
                    children: [
                      const Icon(
                        Icons.delete_outline,
                        size: 96,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your trash is empty',
                        style: TextStyle(
                            color: Color(0xFF6B7280), fontSize: 18),
                      ),
                    ],
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _notes.length,
                    itemBuilder: (ctx, index) {
                      final note = _notes[index];
                      final deletedAt = note['deleted_at'] as String;
                      final daysAgo = _daysSinceDeleted(deletedAt);
                      final daysLeft = _daysRemaining(deletedAt);
                      return Dismissible(
                        key: ValueKey(note['id']),
                        background: Container(
                          color: Colors.green,
                          alignment: Alignment.centerLeft,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: const [
                              Icon(Icons.restore, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Restore',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const [
                              Text('Delete',
                                  style: TextStyle(color: Colors.white)),
                              SizedBox(width: 8),
                              Icon(Icons.delete, color: Colors.white),
                            ],
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            final res = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text(
                                    'Delete note permanently?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            return res == true;
                          }
                          return true;
                        },
                        onDismissed: (direction) {
                          if (direction == DismissDirection.endToStart) {
                            _deleteNote(note['id'] as String);
                          } else {
                            _restoreNote(note['id'] as String);
                          }
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  note['title'] ?? 'Untitled',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF6B7280)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  (note['plain_text'] as String? ?? '')
                                      .replaceAll('\n', ' ')
                                      .substring(0, 50)
                                      .replaceAll(RegExp(r'\s+'), ' '),
                                  style: const TextStyle(
                                      color: Color(0xFF9CA3AF)),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Deleted $daysAgo days ago',
                                      style: const TextStyle(
                                          color: Color(0xFFEF4444),
                                          fontSize: 12),
                                    ),
                                    Text(
                                      '$daysLeft days left',
                                      style: TextStyle(
                                          color: daysLeft <= 5
                                              ? const Color(0xFFEF4444)
                                              : const Color(0xFF404040),
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 16),
            const Text(
              '← Swipe to restore    Swipe to delete →',
              style: TextStyle(
                  color: Color(0xFFD1D5DB), fontSize: 12),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ));
  }
}