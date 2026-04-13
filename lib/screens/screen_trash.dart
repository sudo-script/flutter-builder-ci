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
  bool _isLoading = true;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _fetchTrashNotes();
    _subscribeRealtime();
  }

  @override
  void dispose() {
    if (_channel != null) {
      Supabase.instance.client.removeChannel(_channel!);
    }
    super.dispose();
  }

  Future<void> _fetchTrashNotes() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await Supabase.instance.client
          .from('notes')
          .select('*, note_tags(tag_id, tags(id,name,color))')
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
          .isFilter('deleted_at', null)
          .order('deleted_at', ascending: false)
          .limit(100)
          
      setState(() {
        _notes = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      // Handle error if necessary
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _subscribeRealtime() {
    _channel = Supabase.instance.client
        .channel('public:notes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notes',
          callback: (payload) {
            _fetchTrashNotes();
          },
        )
        .subscribe();
  }

  Future<void> _restoreNote(String id) async {
    try {
      await Supabase.instance.client
          .from('notes')
          .update({'deleted_at': null})
          .eq('id', id)
          
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Note restored')),
      );
    } catch (_) {
      // Handle error
    }
  }

  Future<void> _deleteNote(String id) async {
    try {
      await Supabase.instance.client.from('notes').delete().eq('id', id)
    } catch (_) {
      // Handle error
    }
  }

  Future<void> _emptyTrash() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Empty Trash'),
        content: const Text('Are you sure you want to permanently delete all notes?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      try {
        // Hard delete all notes where deleted_at IS NOT NULL
        await Supabase.instance.client
            .from('notes')
            .delete()
            .isFilter('deleted_at', null)
            
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Trash emptied')),
        );
        _fetchTrashNotes();
      } catch (_) {
        // Handle error
      }
    }
  }

  Widget _buildNoteCard(Map<String, dynamic> note) {
    final id = note['id'] as String;
    final title = note['title'] as String? ?? 'Untitled';
    final preview = note['plain_text'] as String? ?? '';
    final deletedAtStr = note['deleted_at'] as String?;
    final deletedAt = deletedAtStr != null ? DateTime.parse(deletedAtStr) : null;
    final now = DateTime.now();
    final daysDeleted = deletedAt != null ? now.difference(deletedAt).inDays : 0;
    final daysLeft = 30 - daysDeleted;
    final daysLeftText = '$daysLeft days left';
    final daysLeftStyle = TextStyle(
      color: daysLeft <= 5 ? Colors.red : Colors.black87,
      fontWeight: FontWeight.bold,
    );

    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          final res = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete note'),
              content: const Text('Are you sure you want to permanently delete this note?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
              ],
            ),
          );
          return res == true;
        }
        return true;
      },
      onDismissed: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await _restoreNote(id);
        } else if (direction == DismissDirection.endToStart) {
          await _deleteNote(id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Note permanently deleted')),
        }
        _fetchTrashNotes();
      },
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Icon(Icons.restore, color: Colors.white),
            SizedBox(width: 8),
            Text('Restore', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Delete', style: TextStyle(color: Colors.white, fontSize: 16)),
            SizedBox(width: 8),
            const Icon(Icons.delete, color: Colors.white),
          ],
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                preview.length > 80 ? '${preview.substring(0, 80)}…' : preview,
                style: TextStyle(color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Deleted $daysDeleted days ago',
                    style: const TextStyle(color: Colors.red),
                  ),
                  Text(
                    daysLeftText,
                    style: daysLeftStyle,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
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
            onPressed: _emptyTrash,
            child: const Text(
              'Empty Trash',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : (_notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.delete_outline, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      const Text('Trash is empty',
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                      SizedBox(height: 32),
                      const Text(
                        '← Swipe to restore    Swipe to delete →',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 16),
                      ..._notes.map((n) => _buildNoteCard(n)).toList(),
                      SizedBox(height: 32),
                      const Text(
                        '← Swipe to restore    Swipe to delete →',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      SizedBox(height: 32),
                    ],
                  ),
                )),
  }
}