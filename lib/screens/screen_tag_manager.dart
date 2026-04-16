import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TagManagerScreen extends StatefulWidget {
  const TagManagerScreen({super.key});

  @override
  State<TagManagerScreen> createState() => _TagManagerScreenState();
}

class _TagManagerScreenState extends State<TagManagerScreen> {
  final TextEditingController _newTagController = TextEditingController();
  final TextEditingController _renameController = TextEditingController();

  late final RealtimeChannel _channel;

  String _selectedColor = '#6366f1';

  final List<String> _palette = [
    '#ffffff',
    '#fef3c7',
    '#dbeafe',
    '#dcfce7',
    '#fce7f3',
    '#ede9fe',
    '#fee2e2',
    '#f3f4f6',
  ];

  List<Map<String, dynamic>> _tags = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTags();
    _subscribeRealtime();
  }

  Future<void> _fetchTags() async {
    try {
      final uid = Supabase.instance.client.auth.currentUser!.id;
      final data = await Supabase.instance.client
          .from('tags')
          .select('id, name, color, note_tags(id)')
          .eq('user_id', uid)
          .order('created_at', ascending: false);
      if (!mounted) return;
      setState(() {
        _tags = data
            .map((e) => {
                  'id': e['id'],
                  'name': e['name'],
                  'color': e['color'],
                  'note_count': e['note_tags']?.length ?? 0,
                })
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _subscribeRealtime() {
    _channel = Supabase.instance.client.channel('public:tags').onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'tags',
        callback: (payload) {
      _fetchTags();
    }).subscribe();
  }

  Future<void> _addTag() async {
    final name = _newTagController.text.trim();
    if (name.isEmpty) return;
    final uid = Supabase.instance.client.auth.currentUser!.id;
    try {
      await Supabase.instance.client.from('tags').insert({
        'name': name,
        'color': _selectedColor,
        'user_id': uid,
      });
      _newTagController.clear();
      _fetchTags();
    } catch (e) {
      // ignore
    }
  }

  Future<void> _deleteTag(String id) async {
    try {
      await Supabase.instance.client
          .from('note_tags')
          .delete()
          .eq('tag_id', id);
      await Supabase.instance.client
          .from('tags')
          .delete()
          .eq('id', id);
      _fetchTags();
    } catch (e) {
      // ignore
    }
  }

  Future<void> _archiveTag(String id) async {
    try {
      await Supabase.instance.client
          .from('tags')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', id);
      _fetchTags();
    } catch (e) {
      // ignore
    }
  }

  Future<void> _renameTag(Map<String, dynamic> tag) async {
    _renameController.text = tag['name'];
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Tag'),
        content: TextField(
          controller: _renameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Tag name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save')),
        ],
      ),
    );
    if (result == true) {
      try {
        await Supabase.instance.client
            .from('tags')
            .update({'name': _renameController.text})
            .eq('id', tag['id']);
        _fetchTags();
      } catch (e) {
        // ignore
      }
    }
  }

  Future<void> _changeTagColor(String id, String color) async {
    try {
      await Supabase.instance.client
          .from('tags')
          .update({'color': color})
          .eq('id', id);
      _fetchTags();
    } catch (e) {
      // ignore
    }
  }

  void _openColorPicker() {
    showModalBottomSheet(
        context: context,
        builder: (ctx) => Wrap(
              spacing: 8,
              children: _palette.map((c) {
                final hex = c.replaceFirst('#', '0xFF');
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = c;
                    });
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Color(int.parse(hex)),
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: (_selectedColor == c ? 3 : 1),
                        color: (_selectedColor == c
                            ? Colors.black87
                            : Colors.grey.shade300),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ));
  }

  @override
  void dispose() {
    Supabase.instance.client.removeChannel(_channel);
    _newTagController.dispose();
    _renameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/notes_list'),
        ),
        title: const Text('Tags',
            style: TextStyle(fontSize: 20, color: Color(0xFF111827))),
        actions: [
          TextButton(
            onPressed: () => context.go('/notes_list'),
            child: const Text('Done',
                style: TextStyle(fontSize: 15, color: Color(0xFF6366F1))),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _openColorPicker,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Color(int.parse(
                              _selectedColor.replaceFirst('#', '0xFF'))),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _newTagController,
                        decoration: const InputDecoration(
                          hintText: 'New tag name…',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: _addTag,
                      color: const Color(0xFF6366F1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(thickness: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 8),
              const Text('YOUR TAGS',
                  style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 10,
                      fontWeight: FontWeight.w400)),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _tags.length,
                      itemBuilder: (ctx, i) {
                        final tag = _tags[i];
                        return Dismissible(
                          key: Key(tag['id'].toString()),
                          direction: DismissDirection.horizontal,
                          background: Container(
                            color: Colors.blue,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.archive, color: Colors.white),
                                Text('Archive',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 11)),
                              ],
                            ),
                          ),
                          secondaryBackground: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delete, color: Colors.white),
                                Text('Delete',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 11)),
                              ],
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction ==
                                DismissDirection.endToStart) {
                              return await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                        title: const Text('Delete tag?'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, false),
                                              child:
                                                  const Text('Cancel')),
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx, true),
                                              child:
                                                  const Text('Delete')),
                                        ],
                                      ));
                            }
                            return true;
                          },
                          onDismissed: (direction) {
                            if (direction ==
                                DismissDirection.endToStart) {
                              _deleteTag(tag['id'].toString());
                            } else {
                              _archiveTag(tag['id'].toString());
                            }
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Color(int.parse(
                                  tag['color'].replaceFirst('#', '0xFF'))),
                            ),
                            title: GestureDetector(
                              onDoubleTap: () => _renameTag(tag),
                              child: Text(tag['name'],
                                  style:
                                      const TextStyle(fontSize: 15, color: Color(0xFF111827))),
                            ),
                            subtitle: Text('${tag['note_count']} notes',
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF9CA3AF))),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.circle, size: 12),
                                  color: Color(int.parse(
                                      tag['color'].replaceFirst('#', '0xFF'))),
                                  onPressed: () =>
                                      _changeTagColor(tag['id'].toString(), tag['color']),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.close,
                                    color: Color(0xFFD1D5DB), size: 16),
                              ],
                            ),
                          ),
                        );
                      }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ));
  }
}