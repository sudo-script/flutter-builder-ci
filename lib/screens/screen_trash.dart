import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});
  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final _client = Supabase.instance.client;
  List<Map<String, dynamic>> _notes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchTrash();
  }

  Future<void> _fetchTrash() async {
    try {
      final data = await _client.from('notes')
        .select('id, title, plain_text, deleted_at, color')
        .eq('user_id', _client.auth.currentUser!.id)
        .not('deleted_at', 'is', null)
        .order('deleted_at', ascending: false);
      if (mounted) setState(() { _notes = List<Map<String, dynamic>>.from(data as List); _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  int _daysLeft(dynamic raw) {
    if (raw == null) return 30;
    final dt = DateTime.tryParse(raw.toString());
    if (dt == null) return 30;
    return (30 - DateTime.now().difference(dt).inDays).clamp(0, 30);
  }

  String _deletedAgo(dynamic raw) {
    if (raw == null) return '';
    final dt = DateTime.tryParse(raw.toString())?.toLocal();
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt).inDays;
    if (diff == 0) return 'Deleted today';
    if (diff == 1) return 'Deleted yesterday';
    return 'Deleted $diff days ago';
  }

  Future<void> _restore(String id) async {
    try {
      await _client.from('notes').update({'deleted_at': null}).eq('id', id);
      setState(() => _notes.removeWhere((n) => n['id'] == id));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note restored ✓')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')));
    }
  }

  Future<void> _deletePermanent(String id) async {
    final ok = await showDialog<bool>(context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete permanently?'),
        content: const Text('This note will be gone forever and cannot be recovered.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Forever', style: TextStyle(color: Colors.red))),
        ]));
    if (ok != true) return;
    try {
      await _client.from('note_tags').delete().eq('note_id', id);
      await _client.from('attachments').delete().eq('note_id', id);
      await _client.from('notes').delete().eq('id', id);
      setState(() => _notes.removeWhere((n) => n['id'] == id));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')));
    }
  }

  Future<void> _emptyTrash() async {
    final ok = await showDialog<bool>(context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Empty Trash?'),
        content: Text('${_notes.length} note${_notes.length != 1 ? "s" : ""} will be permanently deleted. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Empty Trash', style: TextStyle(color: Colors.red))),
        ]));
    if (ok != true) return;
    try {
      final ids = _notes.map((n) => n['id'] as String).toList();
      for (final id in ids) {
        await _client.from('note_tags').delete().eq('note_id', id);
        await _client.from('attachments').delete().eq('note_id', id);
      }
      await _client.from('notes')
        .delete()
        .eq('user_id', _client.auth.currentUser!.id)
        .not('deleted_at', 'is', null);
      if (mounted) setState(() => _notes = []);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trash', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/notes_list')),
        actions: [
          if (_notes.isNotEmpty)
            TextButton(
              onPressed: _emptyTrash,
              child: const Text('Empty Trash', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        ]),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : Column(children: [
            if (_notes.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A))),
                child: const Text(
                  '⚠️  Notes are permanently deleted after 30 days.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF92400e)))),
            Expanded(child: _notes.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.delete_outline, size: 72, color: Color(0xFFd1d5db)),
                  const SizedBox(height: 12),
                  const Text('Trash is empty', style: TextStyle(color: Color(0xFF9ca3af), fontSize: 15)),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 100),
                  itemCount: _notes.length,
                  itemBuilder: (ctx, i) {
                    final note    = _notes[i];
                    final id      = note['id'] as String;
                    final left    = _daysLeft(note['deleted_at']);
                    final urgent  = left <= 5;
                    return Dismissible(
                      key: ValueKey(id),
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        color: Colors.green,
                        child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.restore, color: Colors.white),
                          Text('Restore', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ])),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.delete_forever, color: Colors.white),
                          Text('Delete', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ])),
                      confirmDismiss: (dir) async {
                        if (dir == DismissDirection.startToEnd) { await _restore(id); return false; }
                        await _deletePermanent(id); return false;
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFf9fafb),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFe5e7eb))),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(note['title'] as String? ?? 'Untitled',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF6b7280)),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(note['plain_text'] as String? ?? '',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF9ca3af)),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 6),
                          Row(children: [
                            Text(_deletedAgo(note['deleted_at']),
                              style: const TextStyle(fontSize: 11, color: Color(0xFF9ca3af))),
                            const Spacer(),
                            Text('$left day${left != 1 ? "s" : ""} left',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                color: urgent ? Colors.red : const Color(0xFFf59e0b))),
                          ]),
                        ])));
                  })),
            Container(
              padding: const EdgeInsets.all(12),
              child: const Text(
                '← Swipe right to restore   ·   Swipe left to delete forever →',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Color(0xFFd1d5db)))),
          ]),
    );
  }
}
