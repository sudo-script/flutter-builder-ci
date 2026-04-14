import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TagManagerScreen extends StatefulWidget {
  const TagManagerScreen({Key? key}) : super(key: key);

  @override
  State<TagManagerScreen> createState() => _TagManagerScreenState();
}

class _TagManagerScreenState extends State<TagManagerScreen> {
  final TextEditingController _tagNameController = TextEditingController();
  final TextEditingController _renameController = TextEditingController();
  String _newTagColor = '#ffffff';
  String? _editingTagId;
  List<Tag> _tags = [];
  final String _userId = Supabase.instance.client.auth.currentUser!.id;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _fetchTags();
    _subscribe();
  }

  @override
  void dispose() {
    _tagNameController.dispose();
    _renameController.dispose();
    if (_channel != null) {
      Supabase.instance.client.removeChannel(_channel!);
    }
    super.dispose();
  }

  Future<void> _fetchTags() async {
    try {
      final data = await Supabase.instance.client
          .from('tags')
          .select('id, name, color, note_tags(*)')
          .eq('user_id', _userId)
          .order('created_at', ascending: false)
          .range(0, 100);
      final List<Tag> tags = List<Tag>.from(data.map((e) {
        final noteTags = e['note_tags'] as List<dynamic>?;
        return Tag(
          id: e['id'] as String,
          name: e['name'] as String,
          color: e['color'] as String,
          count: noteTags?.length ?? 0,
        );
      }));
      setState(() {
        _tags = tags;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _subscribe() {
    _channel = Supabase.instance.client
        .channel('public:tags')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'tags',
            callback: (payload) {
          _fetchTags();
        })
        .subscribe();
  }

  Future<void> _addTag() async {
    final name = _tagNameController.text.trim();
    if (name.isEmpty) return;
    try {
      await Supabase.instance.client
          .from('tags')
          .insert({
        'user_id': _userId,
        'name': name,
        'color': _newTagColor,
      });
      _tagNameController.clear();
      _newTagColor = '#ffffff';
      _fetchTags();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _renameTag(String id, String newName) async {
    try {
      await Supabase.instance.client
          .from('tags')
          .update({'name': newName})
          .eq('id', id);
      _fetchTags();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _updateTagColor(String id, String color) async {
    try {
      await Supabase.instance.client
          .from('tags')
          .update({'color': color})
          .eq('id', id);
      _fetchTags();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _deleteTag(String id, int count) async {
    bool confirm = true;
    if (count > 0) {
      confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete tag with notes?'),
              content:
                  const Text('This tag is associated with notes. Are you sure?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Delete')),
              ],
            )) ??
        false;
    }
    if (!confirm) return;
    try {
      await Supabase.instance.client
          .from('tags')
          .delete()
          .eq('id', id);
      _fetchTags();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _showColorPicker(
      {required BuildContext context,
      String? currentColor,
      required Function(String) onColorSelected}) async {
    final palette = ['#ffffff', '#fef3c7', '#dbeafe', '#dcfce7',
      '#fce7f3', '#ede9fe', '#fee2e2', '#f3f4f6'];
    await showModalBottomSheet(
        context: context,
        builder: (_) {
          return SizedBox(
            height: 120,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8),
              itemCount: palette.length,
              itemBuilder: (_, i) {
                final colorHex = palette[i];
                final color =
                    Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    onColorSelected(colorHex);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: currentColor == colorHex ? 3 : 1,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  Widget _buildAddTagRow() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _showColorPicker(
              context: context,
              currentColor: _newTagColor,
              onColorSelected: (c) => setState(() => _newTagColor = c)),
          child: CircleAvatar(
            radius: 14,
            backgroundColor: Color(
                int.parse(_newTagColor.replaceFirst('#', '0xFF'))),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _tagNameController,
            decoration: const InputDecoration(
              hintText: 'New tag name…',
              hintStyle: TextStyle(color: Colors.grey),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        SizedBox(width: 8),
        ElevatedButton(
            onPressed: _addTag, child: const Text('+')),
      ],
  }

  Widget _buildTagItem(Tag tag) {
    final isEditing = _editingTagId == tag.id;
    return Dismissible(
      key: ValueKey(tag.id),
      background: Container(
        color: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.archive, color: Colors.white),
            SizedBox(height: 4),
            Text('Archive', style: TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.white),
            SizedBox(height: 4),
            Text('Delete', style: TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
      confirmDismiss: (direction) async =>
          direction == DismissDirection.endToStart
              ? await showDialog<bool>(
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
                  ),
                ) ??
                false
              : true,
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _deleteTag(tag.id, tag.count);
        } else {
          // Archive logic if needed
        }
      },
      child: ListTile(
        leading: GestureDetector(
          onTap: () => _showColorPicker(
              context: context,
              currentColor: tag.color,
              onColorSelected: (c) => _updateTagColor(tag.id, c)),
          child: CircleAvatar(
              backgroundColor:
                  Color(int.parse(tag.color.replaceFirst('#', '0xFF')))),
        ),
        title: isEditing
            ? TextField(
                controller: _renameController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Rename…',
                ),
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    _renameTag(tag.id, val.trim());
                  }
                  setState(() => _editingTagId = null);
                },
              )
            : GestureDetector(
                onDoubleTap: () {
                  setState(() {
                    _editingTagId = tag.id;
                    _renameController.text = tag.name;
                  });
                },
                child: Text(tag.name),
              ),
        trailing: Text('${tag.count} notes',
            style: const TextStyle(color: Colors.grey)),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('← Tags'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/notes_list'),
        ),
        actions: [
          TextButton(
              onPressed: () => context.go('/notes_list'),
              child: const Text('Done'))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddTagRow(),
            SizedBox(height: 24),
            const Text('YOUR TAGS',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 10,
                )),
            SizedBox(height: 12),
            if (_tags.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No tags found.')),
              )
            else
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _tags.length,
                itemBuilder: (_, i) => _buildTagItem(_tags[i]),
              ),
            SizedBox(height: 100),
          ],
        ),
      );
  }
}

class Tag {
  final String id;
  final String name;
  final String color;
  final int count;

  Tag(
      {required this.id,
      required this.name,
      required this.color,
      required this.count});
}