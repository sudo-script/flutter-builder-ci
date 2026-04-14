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
  final TextEditingController _renameController = TextEditingController();
  late final RealtimeChannel _channel;
  String _editingTagId = '';
  String _selectedColor = '#6366f1';
  final List<Tag> _tags = [];

  @override
  void initState() {
    super.initState();
    _fetchTags();
    _subscribe();
  }

  Future<void> _fetchTags() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final tagsData = await Supabase.instance.client
          .from('tags')
          .select('id, name, color')
          .eq('user_id', userId)
          .order('name', ascending: true)
          .range(0, 99);
      final List<Tag> fetchedTags = [];
      for (var tagData in tagsData as List) {
        final tagId = tagData['id'] as String;
        final noteTagList = await Supabase.instance.client
            .from('note_tags')
            .select('*')
            .eq('tag_id', tagId) as List;
        final noteCount = noteTagList.length;
        fetchedTags.add(Tag(
            id: tagId,
            name: tagData['name'] as String,
            color: tagData['color'] as String,
            noteCount: noteCount));
      }
      setState(() {
        _tags
          ..clear()
          ..addAll(fetchedTags);
      });
    } catch (e) {
      // Handle error
    }
  }

  void _subscribe() {
    _channel = Supabase.instance.client.channel('public:tags').onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'tags',
        callback: (payload) {
      _fetchTags();
    }).subscribe();
  }

  @override
  void dispose() {
    Supabase.instance.client.removeChannel(_channel);
    _newTagController.dispose();
    _renameController.dispose();
    super.dispose();
  }

  Future<void> _addTag() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final name = _newTagController.text.trim();
    if (name.isEmpty) return;
    try {
      await Supabase.instance.client
          .from('tags')
          .insert({'user_id': userId, 'name': name, 'color': _selectedColor});
      _newTagController.clear();
      _selectedColor = '#6366f1';
      _fetchTags();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _renameTag(Tag tag) async {
    final newName = _renameController.text.trim();
    if (newName.isEmpty) return;
    try {
      await Supabase.instance.client
          .from('tags')
          .update({'name': newName})
          .eq('id', tag.id);
      _editingTagId = '';
      _fetchTags();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _updateColor(Tag tag, String color) async {
    try {
      await Supabase.instance.client
          .from('tags')
          .update({'color': color})
          .eq('id', tag.id);
      _fetchTags();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _deleteTag(Tag tag) async {
    try {
      if (tag.noteCount > 0) {
        final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text('Delete Tag'),
                  content: Text(
                      'This tag is assigned to ${tag.noteCount} notes. Are you sure you want to delete it?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete')),
                  ],
                ));
        if (confirm != true) return;
      }
      await Supabase.instance.client
          .from('tags')
          .delete()
          .eq('id', tag.id);
      _fetchTags();
    } catch (e) {
      // Handle error
    }
  }

  void _showColorPicker({String? tagId, bool isNew = true}) {
    final colors = const [
      '#ffffff',
      '#fef3c7',
      '#dbeafe',
      '#dcfce7',
      '#fce7f3',
      '#ede9fe',
      '#fee2e2',
      '#f3f4f6'
    ];
    showModalBottomSheet(
        context: context,
        builder: (_) => Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: colors.map((c) {
                  return GestureDetector(
                    onTap: () {
                      if (isNew) {
                        setState(() {
                          _selectedColor = c;
                        });
                      } else if (tagId != null) {
                        final tag =
                            _tags.firstWhere((t) => t.id == tagId);
                        _updateColor(tag, c);
                      }
                      Navigator.pop(context);
                    },
                    child: CircleAvatar(
                      backgroundColor: Color(int.parse(c.replaceFirst('#', '0xFF'))),
                      radius: 20,
                    ),
                  );
                }).toList(),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/notes_list')),
        title: const Text('Tags'),
        actions: [
          TextButton(
              onPressed: () => context.go('/notes_list'),
              child: const Text('Done', style: TextStyle(color: Colors.white)))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showColorPicker(isNew: true),
                    child: CircleAvatar(
                      backgroundColor:
                          Color(int.parse(_selectedColor.replaceFirst('#', '0xFF'))),
                      radius: 15,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _newTagController,
                      decoration: const InputDecoration(
                          hintText: 'New tag name…',
                          border: OutlineInputBorder()),
                    ),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _addTag,
                    child: const Text('+'),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text('YOUR TAGS',
                      style: TextStyle(
                          color: Color(0xff6b7280),
                          fontSize: 10))),
              SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _tags.length,
                itemBuilder: (context, index) {
                  final tag = _tags[index];
                  return Dismissible(
                    key: ValueKey(tag.id),
                    direction: DismissDirection.horizontal,
                    background: Container(
                      color: Colors.blue[200],
                      alignment: Alignment.centerLeft,
                      padding:
                          const EdgeInsets.only(left: 20),
                      child: Column(
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
                      color: Colors.red[200],
                      alignment: Alignment.centerRight,
                      padding:
                          const EdgeInsets.only(right: 20),
                      child: Column(
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
                      if (direction == DismissDirection.endToStart &&
                          tag.noteCount > 0) {
                        final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                                  title: const Text('Delete tag?'),
                                  content: Text(
                                      'This tag is used in ${tag.noteCount} notes. Delete?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Cancel')),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Delete')),
                                  ],
                                ));
                        return confirm == true;
                      }
                      return true;
                    },
                    onDismissed: (direction) {
                      if (direction == DismissDirection.endToStart) {
                        _deleteTag(tag);
                      } else {
                        // Archive can be implemented if needed
                      }
                    },
                    child: InkWell(
                      onDoubleTap: () {
                        setState(() {
                          _editingTagId = tag.id;
                          _renameController.text = tag.name;
                        });
                      },
                      child: ListTile(
                        leading: GestureDetector(
                          onTap: () =>
                              _showColorPicker(tagId: tag.id, isNew: false),
                          child: CircleAvatar(
                            backgroundColor: Color(
                                int.parse(tag.color.replaceFirst('#', '0xFF'))),
                            radius: 15,
                          ),
                        ),
                        title: _editingTagId == tag.id
                            ? TextField(
                                controller: _renameController,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder()),
                                onSubmitted: (_) => _renameTag(tag),
                              )
                            : Text(tag.name),
                        subtitle: Text('${tag.noteCount} notes'),
                        trailing: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.grey),
                          onPressed: () => _deleteTag(tag),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
  }
}

class Tag {
  final String id;
  final String name;
  final String color;
  final int noteCount;
  Tag(
      {required this.id,
      required this.name,
      required this.color,
      required this.noteCount});
}