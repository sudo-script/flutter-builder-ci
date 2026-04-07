import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TagManagerScreen extends StatefulWidget {
  const TagManagerScreen({Key? key}) : super(key: key);

  @override
  State<TagManagerScreen> createState() => _TagManagerScreenState();
}

class _TagManagerScreenState extends State<TagManagerScreen> {
  final TextEditingController _newTagNameController = TextEditingController();
  final Map<int, TextEditingController> _renameControllers = {};
  int? _editingTagId;
  List<_Tag> _tags = [];
  late final RealtimeChannel _channel;

  @override
  void initState() {
    super.initState();
    _fetchTags();
    _subscribe();
  }

  void _subscribe() {
    _channel = Supabase.instance.client
        .channel('public:tags')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'tags',
          callback: (payload) => _fetchTags(),
        )
        .subscribe();
  }

  Future<void> _fetchTags() async {
    try {
      // Fetch tags for current user
      final data = await Supabase.instance.client
          .from('tags')
          .select('id, name, color')
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
          .order('created_at', ascending: false);

      final tags = List<Map<String, dynamic>>.from(data);
      _tags = tags
          .map((e) => _Tag(
                id: e['id'] as int,
                name: e['name'] as String,
                color: e['color'] as String,
                noteCount: 0,
              ))
          .toList();

      // Count notes per tag
      final notesData = await Supabase.instance.client
          .from('note_tags')
          .select('tag_id')
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id);

      final counts = List<Map<String, dynamic>>.from(notesData);
      for (final ct in counts) {
        final tagId = ct['tag_id'] as int;
        final tag = _tags.firstWhere((t) => t.id == tagId);
        tag.noteCount += 1;
      }

      setState(() {});
    } catch (e) {
      // handle error if needed
    }
  }

  Future<void> _addTag() async {
    final name = _newTagNameController.text.trim();
    if (name.isEmpty) return;
    final color = '#6366f1'; // default color
    try {
      await Supabase.instance.client.from('tags').insert({
        'name': name,
        'color': color,
        'user_id': Supabase.instance.client.auth.currentUser!.id,
      });
      _newTagNameController.clear();
    } catch (e) {
      // handle error
    }
  }

  Future<void> _updateTagName(int id, String newName) async {
    try {
      await Supabase.instance.client
          .from('tags')
          .update({'name': newName})
          .eq('id', id);
    } catch (e) {
      // handle error
    }
  }

  Future<void> _updateTagColor(int id, String newColor) async {
    try {
      await Supabase.instance.client
          .from('tags')
          .update({'color': newColor})
          .eq('id', id);
    } catch (e) {
      // handle error
    }
  }

  Future<void> _deleteTag(_Tag tag) async {
    if (tag.noteCount > 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete tag?'),
          content: const Text(
              'This tag is assigned to notes. Deleting it will remove all assignments.'),
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
    }
    try {
      // Remove tag assignments
      await Supabase.instance.client
          .from('note_tags')
          .delete()
          .eq('tag_id', tag.id);
      // Delete tag
      await Supabase.instance.client
          .from('tags')
          .delete()
          .eq('id', tag.id);
    } catch (e) {
      // handle error
    }
  }

  void _showColorPicker(_Tag tag) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => const _ColorPickerSheet(),
    ).then((selected) {
      if (selected != null) {
        _updateTagColor(tag.id, selected);
      }
    });
  }

  @override
  void dispose() {
    _newTagNameController.dispose();
    _renameControllers
        .values
        .forEach((c) => c.dispose());
    Supabase.instance.client.removeChannel(_channel);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/notes_list'),
        ),
        actions: [
          TextButton(
            onPressed: () => context.go('/notes_list'),
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // New Tag Row
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => _showColorPicker(
                        _Tag(id: 0, name: '', color: '', noteCount: 0)),
                    child: CircleAvatar(
                      backgroundColor: const Color(0xFF6366F1),
                      radius: 14,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _newTagNameController,
                      decoration: const InputDecoration(
                        hintText: 'New tag name…',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _addTag,
                    child: const Text('+'),
                  ),
                ],
              ),
            ),
            const Divider(),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'YOUR TAGS',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _tags.length,
              itemBuilder: (ctx, idx) {
                final tag = _tags[idx];
                return Dismissible(
                  key: ValueKey(tag.id),
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
                          title:
                              const Text('Delete tag?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(ctx, false),
                              child:
                                  const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(ctx, true),
                              child:
                                  const Text('Delete'),
                            ),
                          ],
                        ),
                    }
                    return true;
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      _deleteTag(tag);
                    } else {
                      _editTag(tag);
                    }
                  },
                  child: ListTile(
                    leading: GestureDetector(
                      onTap: () => _showColorPicker(tag),
                      child: CircleAvatar(
                        backgroundColor:
                            Color(int.parse(tag.color.replaceFirst('#', '0xFF'))),
                        radius: 14,
                      ),
                    ),
                    title: _editingTagId == tag.id
                        ? TextField(
                            controller: _renameControllers[tag.id] ??
                                ( _renameControllers[tag.id]
                                    = TextEditingController(text: tag.name)),
                            autofocus: true,
                            onSubmitted: (val) {
                              _updateTagName(tag.id, val);
                              setState(() => _editingTagId = null);
                            },
                          )
                        : GestureDetector(
                            onDoubleTap: () {
                              setState(() => _editingTagId = tag.id);
                            },
                            child: Text(tag.name),
                          ),
                    trailing: Text('${tag.noteCount} notes'),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
  }

  void _editTag(_Tag tag) {
    // Placeholder for archive logic; currently nothing
    // You can implement archive by updating 'deleted_at'
  }
}

class _Tag {
  final int id;
  final String name;
  final String color;
  int noteCount;
  _Tag({
    required this.id,
    required this.name,
    required this.color,
    required this.noteCount,
  });
}
