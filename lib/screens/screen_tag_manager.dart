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
  final Map<String, TextEditingController> _renameControllers = {};
  final Set<String> _editingTags = {};
  late final RealtimeChannel _channel;

  String _selectedColor = '#ffffff';
  List<Map<String, dynamic>> _tags = [];

  @override
  void initState() {
    super.initState();
    _fetchTags();
    _subscribeRealtime();
  }

  @override
  void dispose() {
    _newTagController.dispose();
    for (var controller in _renameControllers.values) {
      controller.dispose();
    }
    Supabase.instance.client.removeChannel(_channel);
    super.dispose();
  }

  Future<void> _subscribeRealtime() async {
    _channel = Supabase.instance.client.channel('public:tags')
        .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'tags',
      callback: (_) => _fetchTags(),
    )
        .subscribe();
  }

  Future<void> _fetchTags() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      final data = await Supabase.instance.client
          .from('tags')
          .select('id, name, color')
          .eq('user_id', userId);
      List<Map<String, dynamic>> tags = List<Map<String, dynamic>>.from(data);
      for (var tag in tags) {
        final tagId = tag['id'] as String;
        final notesData = await Supabase.instance.client
            .from('note_tags')
            .select('tag_id')
            .eq('tag_id', tagId);
        tag['count'] = notesData.length;
      }
      setState(() {
        _tags = tags;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _addTag() async {
    final name = _newTagController.text.trim();
    if (name.isEmpty) return;
    try {
      await Supabase.instance.client.from('tags').insert({
        'name': name,
        'color': _selectedColor,
        'user_id': Supabase.instance.client.auth.currentUser?.id,
      });
      _newTagController.clear();
      setState(() {
        _selectedColor = '#ffffff';
      });
      await _fetchTags();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _renameTag(String id) async {
    final controller = _renameControllers[id];
    if (controller == null) return;
    final newName = controller.text.trim();
    if (newName.isEmpty) return;
    try {
      await Supabase.instance.client
          .from('tags')
          .update({'name': newName})
          .eq('id', id);
      _editingTags.remove(id);
      _renameControllers.remove(id);
      await _fetchTags();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _changeColor(String id, String color) async {
    try {
      await Supabase.instance.client
          .from('tags')
          .update({'color': color})
          .eq('id', id);
      await _fetchTags();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _deleteTag(String id, int count) async {
    if (count > 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete tag?'),
          content: const Text(
              'This tag is associated with notes. Deleting will remove all associations.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete')),
          ],
        ),
      );
      if (confirm != true) return;
    }
    try {
      await Supabase.instance.client
          .from('note_tags')
          .delete()
          .eq('tag_id', id);
      await Supabase.instance.client
          .from('tags')
          .delete()
          .eq('id', id);
      await _fetchTags();
    } catch (e) {
      // Handle error
    }
  }

  void _showColorPicker(String tagId) {
    final colors = [
      '#ffffff',
      '#fef3c7',
      '#dbeafe',
      '#dcfce7',
      '#fce7f3',
      '#ede9fe',
      '#fee2e2',
      '#f3f4f6',
    ];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 10,
          children: colors
              .map(
                (c) => GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    _changeColor(tagId, c);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(int.parse(c.replaceFirst('#', '0xFF'))),
                      shape: BoxShape.circle,
                      border: Border.all(
                          width: 2,
                          color: Colors.black.withOpacity(0.2)),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with back arrow and Done button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.go('/notes_list'),
                    child: Row(
                      children: const [
                        Icon(Icons.arrow_back),
                        SizedBox(width: 4),
                        Text(
                          'Tags',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/notes_list'),
                    child: const Text('Done'),
                  ),
                ],
              ),
              SizedBox(height: 24),
              // New tag input row
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Show color picker for new tag
                      _showColorPicker('new_tag_dummy');
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(int.parse(_selectedColor.replaceFirst('#', '0xFF'))),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _newTagController,
                      decoration: const InputDecoration(
                        hintText: 'New tag name…',
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addTag,
                    child: const Text('+'),
                  ),
                ],
              ),
              SizedBox(height: 24),
              const Divider(),
              SizedBox(height: 16),
              const Text(
                'YOUR TAGS',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 10),
              ),
              SizedBox(height: 16),
              const Divider(),
              SizedBox(height: 16),
              // List of tags
              ..._tags.map((tag) {
                final id = tag['id'] as String;
                final name = tag['name'] as String;
                final colorHex = tag['color'] as String;
                final count = tag['count'] as int? ?? 0;
                final isEditing = _editingTags.contains(id);
                return Dismissible(
                  key: ValueKey(id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete tag?'),
                        content: Text(
                            'This tag is associated with $count notes. Deleting will remove all associations.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete')),
                        ],
                      ),
                    );
                    return confirm == true;
                  },
                  onDismissed: (dir) {
                    _deleteTag(id, count);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    leading: GestureDetector(
                      onTap: () => _showColorPicker(id),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Color(
                              int.parse(colorHex.replaceFirst('#', '0xFF'))),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.black, width: 1),
                        ),
                      ),
                    ),
                    title: isEditing
                        ? TextField(
                            controller: _renameControllers[id] ??
                                TextEditingController(text: name),
                            onEditingComplete: () => _renameTag(id),
                            decoration:
                                const InputDecoration(border: InputBorder.none),
                          )
                        : GestureDetector(
                            onDoubleTap: () {
                              setState(() {
                                _editingTags.add(id);
                                _renameControllers[id] =
                                    TextEditingController(text: name);
                              });
                            },
                            child: Text(name),
                          ),
                    trailing: Text('$count notes'),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      );
  }
}