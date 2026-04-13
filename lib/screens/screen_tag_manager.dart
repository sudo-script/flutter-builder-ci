import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TagManagerScreen extends StatefulWidget {
  const TagManagerScreen({Key? key}) : super(key: key);

  @override
  State<TagManagerScreen> createState() => _TagManagerScreenState();
}

class _TagManagerScreenState extends State<TagManagerScreen> {
  final TextEditingController _newTagController = TextEditingController();
  String _newTagColor = '#6366f1';
  final Map<int, TextEditingController> _renameControllers = {};
  int? _editingTagId;
  late final RealtimeChannel _channel;
  List<Map<String, dynamic>> _tags = [];

  final List<String> _colorOptions = const [
    '#ffffff',
    '#fef3c7',
    '#dbeafe',
    '#dcfce7',
    '#fce7f3',
    '#ede9fe',
    '#fee2e2',
    '#f3f4f6'
  ];

  @override
  void initState() {
    super.initState();
    _loadTags();
    _subscribe();
  }

  @override
  void dispose() {
    _newTagController.dispose();
    _renameControllers.values.forEach((c) => c.dispose());
    Supabase.instance.client.removeChannel(_channel);
    super.dispose();
  }

  void _subscribe() {
    _channel = Supabase.instance.client.channel('public:tags')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tags',
          callback: (payload) {
            _loadTags();
          },
        )
        .subscribe();
  }

  Future<void> _loadTags() async {
    try {
      final userId =
          Supabase.instance.client.auth.currentUser!.id;
      final data = await Supabase.instance.client
          .from('tags')
          .select('id, name, color, note_tags(*, notes(*) )')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      setState(() {
        _tags = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      // handle error
    }
  }

  Future<void> _addTag() async {
    final name = _newTagController.text.trim();
    if (name.isEmpty) return;
    try {
      final userId =
          Supabase.instance.client.auth.currentUser!.id;
      await Supabase.instance.client
          .from('tags')
          .insert({
        'name': name,
        'color': _newTagColor,
        'user_id': userId,
      });
      _newTagController.clear();
      setState(() {
        _newTagColor = '#6366f1';
      });
      _loadTags();
    } catch (e) {
      // handle error
    }
  }

  Future<void> _updateTagName(int id, String newName) async {
    if (newName.trim().isEmpty) return;
    try {
      await Supabase.instance.client
          .from('tags')
          .update({'name': newName.trim()})
          .eq('id', id);
      _loadTags();
    } catch (e) {
      // handle error
    }
  }

  Future<void> _updateTagColor(int id, String color) async {
    try {
      await Supabase.instance.client
          .from('tags')
          .update({'color': color})
          .eq('id', id);
      _loadTags();
    } catch (e) {
      // handle error
    }
  }

  Future<void> _deleteTag(int id, int noteCount) async {
    bool proceed = true;
    if (noteCount > 0) {
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete tag with notes?'),
          content: const Text(
              'This tag has associated notes. Deleting it will also remove those associations.'),
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
      proceed = result ?? false;
    }
    if (!proceed) return;

    try {
      await Supabase.instance.client
          .from('note_tags')
          .delete()
          .eq('tag_id', id);
      await Supabase.instance.client
          .from('tags')
          .delete()
          .eq('id', id);
      _loadTags();
    } catch (e) {
      // handle error
    }
  }

  void _showColorPicker({required Function(String) onColorSelected}) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          children: _colorOptions.map((color) {
            return GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                onColorSelected(color);
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }).toList(),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/notes_list'),
        ),
        title: const Text('Tags'),
        actions: [
          TextButton(
            onPressed: () => context.go('/notes_list'),
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // New tag row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _showColorPicker(
                      onColorSelected: (c) => setState(() => _newTagColor = c),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Color(
                          int.parse(_newTagColor.replaceFirst('#', '0xFF'))),
                      radius: 12,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _newTagController,
                      decoration: const InputDecoration(
                        hintText: 'New tag name…',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _addTag,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 12,
                      ),
                    ),
                    child: const Text(
                      '+',
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            const Text(
              'YOUR TAGS',
              style: TextStyle(
                  color: Color(0xFF6B7280), fontSize: 10, fontWeight: FontWeight.bold),
            ),
            const Divider(color: Color(0xFFE5E7EB)),
            SizedBox(height: 8),
            ..._tags.map((tag) {
              final int id = tag['id'];
              final String name = tag['name'];
              final String color = tag['color'];
              final List<dynamic>? noteTags = tag['note_tags'] as List<dynamic>?;
              final int noteCount = noteTags?.length ?? 0;
              final bool isEditing = _editingTagId == id;
              return Dismissible(
                key: ValueKey(id),
                direction: DismissDirection.horizontal,
                background: Container(
                  color: Colors.blue,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.archive, color: Colors.white),
                      Text(
                        'Archive',
                        style: TextStyle(
                            color: Colors.white, fontSize: 11),
                      )
                    ],
                  ),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete, color: Colors.white),
                      Text(
                        'Delete',
                        style: TextStyle(
                            color: Colors.white, fontSize: 11),
                      )
                    ],
                  ),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete tag?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete')),
                        ],
                      );
                  }
                  return true;
                },
                onDismissed: (direction) {
                  if (direction == DismissDirection.endToStart) {
                    _deleteTag(id, noteCount);
                  } else {
                    _archiveTag(id);
                  }
                },
                child: ListTile(
                  leading: GestureDetector(
                    onTap: () => _showColorPicker(
                      onColorSelected: (c) => _updateTagColor(id, c),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Color(
                          int.parse(color.replaceFirst('#', '0xFF'))),
                      radius: 12,
                    ),
                  ),
                  title: GestureDetector(
                    onDoubleTap: () {
                      if (_editingTagId == id) {
                        _updateTagName(id, _renameControllers[id]!.text);
                        setState(() => _editingTagId = null);
                        _renameControllers[id]?.dispose();
                        _renameControllers.remove(id);
                      } else {
                        _renameControllers[id] = TextEditingController(text: name);
                        setState(() => _editingTagId = id);
                      }
                    },
                    child: isEditing
                        ? TextField(
                            controller: _renameControllers[id],
                            onSubmitted: (_) {
                              _updateTagName(id, _renameControllers[id]!.text);
                              setState(() => _editingTagId = null);
                              _renameControllers[id]?.dispose();
                              _renameControllers.remove(id);
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                          )
                        : Text(
                            name,
                            style: const TextStyle(
                                color: Color(0xFF111827), fontSize: 15),
                          ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (noteCount > 0)
                        Text(
                          '$noteCount notes',
                          style: const TextStyle(
                              color: Color(0xFF9CA3AF), fontSize: 12),
                        ),
                      SizedBox(width: 8),
                      const Icon(Icons.close, color: Color(0xFFD1D5DB), size: 16),
                    ],
                  ),
                ),
              );
            }).toList(),
            SizedBox(height: 16),
          ],
        ),
      );
  }

  void _archiveTag(int id) {
    // Archive logic if needed
    // For now, just delete
    _deleteTag(id, 0);
  }
}