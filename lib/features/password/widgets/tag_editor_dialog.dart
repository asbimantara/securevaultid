import 'package:flutter/material.dart';

class TagEditorDialog extends StatefulWidget {
  final List<String> initialTags;
  final Function(List<String>) onTagsUpdated;

  const TagEditorDialog({
    super.key,
    required this.initialTags,
    required this.onTagsUpdated,
  });

  @override
  State<TagEditorDialog> createState() => _TagEditorDialogState();
}

class _TagEditorDialogState extends State<TagEditorDialog> {
  late List<String> _tags;
  final _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.initialTags);
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Tag'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tagController,
                  decoration: const InputDecoration(
                    hintText: 'Tambah tag baru',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: _addTag,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _addTag(_tagController.text),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: _tags.map((tag) {
              return Chip(
                label: Text(tag),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removeTag(tag),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onTagsUpdated(_tags);
            Navigator.pop(context);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }
}
