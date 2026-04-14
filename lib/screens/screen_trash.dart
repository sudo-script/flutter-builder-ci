import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class TrashScreen extends StatefulWidget {
  const TrashScreen({Key? key}) : super(key: key);

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  List<Map<String, dynamic>> _notes = [];
  late final RealtimeChannel _channel;
  final _userId = Supabase.instance.client.auth.currentUser!.id;
  @override
  void initState() {
    super.initState();
    _fetchNotes();
    _subscribe();
  }

  Future<void> _fetchNotes() async {
    try {
      final data = await Supabase.instance.client
          .from('notes')
          .select('*')
          .eq('user_id', _userId)
          .not('deleted_at', 'is', null)
          .order('deleted_at', ascending: false);
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
    })
        .subscribe();
  }

  @override
  void dispose() {
    Supabase.instance.client.removeChannel(_channel);
    super.dispose();
  }

  Future<void> _confirmEmptyTrash() async {
    final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Empty Trash?'),
            content:
                const Text('This will permanently delete all trashed notes.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Delete',
                      style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;
    if (shouldDelete) await _emptyTrash();
  }

  Future<void> _emptyTrash() async {
    try {
      await Supabase.instance.client
          .from('notes')
          .delete()
          .eq('user_id', _userId)
          .not('deleted_at', 'is', null);
      _fetchNotes();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Trash emptied.')));
    } catch (_) {}
  }

  Future<void> _restoreNote(String id) async {
    try {
      await Supabase.instance.client
          .from('notes')
          .update({'deleted_at': null})
          .eq('id', id);
      _fetchNotes();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Note restored.')));
    } catch (_) {}
  }

  Future<void> _deleteNotePermanently(String id) async {
    try {
      await Supabase.instance.client
          .from('note_tags')
          .delete()
          .eq('note_id', id);
      await Supabase.instance.client
          .from('attachments')
          .delete()
          .eq('note_id', id);
      await Supabase.instance.client
          .from('notes')
          .delete()
          .eq('id', id);
      _fetchNotes();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Note deleted.')));
    } catch (_) {}
  }

  Future<bool> _confirmDelete(String id) async {
    final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete permanently?'),
            content: const Text('This action cannot be undone.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Delete',
                      style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;
    if (confirm) await _deleteNotePermanently(id);
    return confirm;
  }

  Widget _buildNoteCard(Map<String, dynamic> note) {
    final deletedAt = DateTime.parse(note['deleted_at']);
    final now = DateTime.now();
    final daysAgo = now.difference(deletedAt).inDays;
    final daysLeft = 30 - daysAgo;
    final countdown = daysLeft <= 5
        ? Text('Deleted $daysAgo days ago • $daysLeft days left',
            style:
                const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
        : Text('Deleted $daysAgo days ago • $daysLeft days left');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Dismissible(
        key: ValueKey(note['id']),
        direction: DismissDirection.horizontal,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            return await _confirmDelete(note['id']);
          }
          // restore
          _restoreNote(note['id']);
          return false;
        },
        background: Container(
          color: Colors.green.shade100,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.restore, color: Colors.white),
              SizedBox(width: 8),
              Text('Restore',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
            ],
          ),
        ),
        secondaryBackground: Container(
          color: Colors.red.shade100,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Delete',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(width: 8),
              Icon(Icons.delete, color: Colors.white)
            ],
          ),
        ),
        child: Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note['title'] ?? '',
                  style: const TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  note['plain_text'] != null &&
                          note['plain_text'].toString().length > 100
                      ? note['plain_text']
                              .toString()
                              .substring(0, 100) +
                          '…'
                      : note['plain_text'] ?? '',
                  style: const TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                countdown,
              ],
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.go('/notes_list'),
                    ),
                    const Text('Trash',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: _confirmEmptyTrash,
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.transparent)),
                      child: const Text('Empty Trash',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Warning banner
                Container(
                  width: double.infinity,
                  height: 40,
                  color: const Color(0xfffffbeb),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: const Text('⚠️  Notes are permanently deleted after 30 days',
                      style: TextStyle(color: Color(0xff92400e), fontSize: 12)),
                ),
                SizedBox(height: 12),
                // List of notes
                _notes.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 80),
                        child: Column(
                          children: [
                            Icon(Icons.delete_outline,
                                size: 80, color: Color(0xff9ca3af)),
                            SizedBox(height: 16),
                            Text('Trash is empty',
                                style: TextStyle(
                                    color: Color(0xff9ca3af),
                                    fontSize: 16))
                          ],
                        ),
                      )
                    : Column(
                        children: _notes
                            .map((note) => _buildNoteCard(note))
                            .toList(),
                      ),
                SizedBox(height: 20),
                const Text('← Swipe to restore    Swipe to delete →',
                    style: TextStyle(color: Color(0xffd1d5db), fontSize: 12)),
              ],
            ),
          ),
        ),
      );
  }
}