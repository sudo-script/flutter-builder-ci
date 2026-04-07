import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TagManagerScreen extends StatefulWidget {
  const TagManagerScreen({super.key});
  @override
  State<TagManagerScreen> createState() => _TagManagerScreenState();
}

class _TagManagerScreenState extends State<TagManagerScreen> {
  final _client   = Supabase.instance.client;
  final _nameCtrl = TextEditingController();

  List<Map<String, dynamic>> _tags   = [];
  Map<String, int>           _counts = {};
  bool   _loading      = true;
  String _newColor     = '#6366f1';
  String? _renamingId;
  final _renameCtrl = TextEditingController();

  static const _palette = [
    '#6366f1','#10b981','#f59e0b','#ec4899',
    '#3b82f6','#ef4444','#8b5cf6','#14b8a6',
  ];

  @override
  void initState() {
    super.initState();
    _fetchTags();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _renameCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchTags() async {
    try {
      final userId = _client.auth.currentUser!.id;
      final data = await _client.from('tags')
        .select('id, name, color')
        .eq('user_id', userId)
        .order('name');
      final tags = List<Map<String, dynamic>>.from(data as List);

      // Fetch counts per tag
      final Map<String, int> counts = {};
      for (final t in tags) {
        final rows = await _client
          .from('note_tags')
          .select('note_id')
          .eq('tag_id', t['id'] as String);
        counts[t['id'] as String] = (rows as List).length;
      }
      if (mounted) setState(() { _tags = tags; _counts = counts; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addTag() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    if (_tags.any((t) => (t['name'] as String).toLowerCase() == name.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A tag with that name already exists.')));
      return;
    }
    try {
      final res = await _client.from('tags').insert({
        'user_id': _client.auth.currentUser!.id,
        'name': name,
        'color': _newColor,
      }).select().single();
      _nameCtrl.clear();
      setState(() { _tags.insert(0, res); _counts[res['id'] as String] = 0; });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create tag: $e')));
    }
  }

  Future<void> _renameTag(String id, String newName) async {
    final name = newName.trim();
    if (name.isEmpty) return;
    try {
      await _client.from('tags').update({'name': name}).eq('id', id);
      setState(() {
        final i = _tags.indexWhere((t) => t['id'] == id);
        if (i >= 0) _tags[i] = {..._tags[i], 'name': name};
        _renamingId = null;
      });
    } catch (_) {}
  }

  Future<void> _changeColor(String id, String color) async {
    try {
      await _client.from('tags').update({'color': color}).eq('id', id);
      setState(() {
        final i = _tags.indexWhere((t) => t['id'] == id);
        if (i >= 0) _tags[i] = {..._tags[i], 'color': color};
      });
    } catch (_) {}
  }

  Future<void> _deleteTag(String id) async {
    final count = _counts[id] ?? 0;
    final ok = await showDialog<bool>(context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete tag?'),
        content: Text(count > 0
          ? 'This tag is used on $count note${count > 1 ? "s" : ""}. Removing it will not delete those notes.'
          : 'This tag will be permanently deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ]));
    if (ok != true) return;
    try {
      await _client.from('note_tags').delete().eq('tag_id', id);
      await _client.from('tags').delete().eq('id', id);
      setState(() { _tags.removeWhere((t) => t['id'] == id); _counts.remove(id); });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')));
    }
  }

  void _showColorPicker(String tagId) {
    showModalBottomSheet(context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Pick a colour', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Wrap(spacing: 12, runSpacing: 12, children: _palette.map((c) {
            final color = Color(int.parse(c.replaceFirst('#', '0xFF')));
            return GestureDetector(
              onTap: () { _changeColor(tagId, c); Navigator.pop(ctx); },
              child: Container(width: 44, height: 44,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6, offset: const Offset(0, 3))])));
          }).toList()),
          const SizedBox(height: 16),
        ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(onPressed: () => context.go('/notes_list'),
            child: const Text('Done', style: TextStyle(color: Color(0xFF6366f1), fontWeight: FontWeight.bold))),
        ]),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : Column(children: [
            // Add tag row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(children: [
                GestureDetector(
                  onTap: () => showModalBottomSheet(context: context,
                    builder: (ctx) => Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Text('New tag colour', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 16),
                        Wrap(spacing: 12, runSpacing: 12, children: _palette.map((c) {
                          final color = Color(int.parse(c.replaceFirst('#', '0xFF')));
                          return GestureDetector(
                            onTap: () { setState(() => _newColor = c); Navigator.pop(ctx); },
                            child: Container(width: 44, height: 44,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle,
                                border: Border.all(
                                  color: _newColor == c ? Colors.black54 : Colors.transparent,
                                  width: 3))));
                        }).toList()),
                        const SizedBox(height: 16),
                      ]))),
                  child: Container(width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Color(int.parse(_newColor.replaceFirst('#', '0xFF'))),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300))),
                ),
                const SizedBox(width: 10),
                Expanded(child: TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'New tag name…',
                    filled: true, fillColor: const Color(0xFFf3f4f6),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                  textCapitalization: TextCapitalization.words,
                  onSubmitted: (_) => _addTag())),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTag,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366f1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                  child: const Icon(Icons.add, color: Colors.white)),
              ])),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 0, 4),
              child: Align(alignment: Alignment.centerLeft,
                child: Text('YOUR TAGS',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500, letterSpacing: 1.2)))),
            // Tag list
            Expanded(child: _tags.isEmpty
              ? const Center(child: Text('No tags yet — create one above.',
                  style: TextStyle(color: Color(0xFF9ca3af))))
              : ListView.separated(
                  itemCount: _tags.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 20),
                  itemBuilder: (ctx, i) {
                    final t     = _tags[i];
                    final id    = t['id']    as String;
                    final name  = t['name']  as String;
                    final color = Color(int.parse((t['color'] as String).replaceFirst('#', '0xFF')));
                    final count = _counts[id] ?? 0;
                    final isRenaming = _renamingId == id;

                    return Dismissible(
                      key: ValueKey(id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) async { await _deleteTag(id); return false; },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white)),
                      child: ListTile(
                        leading: GestureDetector(
                          onTap: () => _showColorPicker(id),
                          child: CircleAvatar(backgroundColor: color, radius: 16,
                            child: const Icon(Icons.color_lens, color: Colors.white, size: 14))),
                        title: isRenaming
                          ? TextField(
                              controller: _renameCtrl,
                              autofocus: true,
                              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                              onSubmitted: (v) => _renameTag(id, v),
                              onEditingComplete: () => _renameTag(id, _renameCtrl.text))
                          : GestureDetector(
                              onDoubleTap: () => setState(() {
                                _renamingId = id;
                                _renameCtrl.text = name;
                              }),
                              child: Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                        subtitle: Text('$count note${count != 1 ? "s" : ""}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        trailing: isRenaming
                          ? IconButton(icon: const Icon(Icons.check, color: Color(0xFF6366f1)),
                              onPressed: () => _renameTag(id, _renameCtrl.text))
                          : IconButton(icon: Icon(Icons.close, color: Colors.grey.shade400, size: 18),
                              onPressed: () => _deleteTag(id))));
                  })),
          ]),
    );
  }
}
