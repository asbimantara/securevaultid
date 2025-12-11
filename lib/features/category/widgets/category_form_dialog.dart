import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/category_model.dart';
import '../../../data/providers/category_provider.dart';
import 'icon_picker_dialog.dart';
import 'color_picker_dialog.dart';

class CategoryFormDialog extends StatefulWidget {
  final Category? category;

  const CategoryFormDialog({
    super.key,
    this.category,
  });

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  late IconData _selectedIcon;
  late Color _selectedColor;
  final List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _descriptionController.text = widget.category!.description ?? '';
      _selectedIcon = widget.category!.icon;
      _selectedColor = widget.category!.color;
      _tags.addAll(widget.category!.tags);
    } else {
      _selectedIcon = Icons.folder;
      _selectedColor = Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
          Text(widget.category == null ? 'Tambah Kategori' : 'Edit Kategori'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kategori',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama kategori tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(_selectedIcon),
                      label: const Text('Pilih Ikon'),
                      onPressed: _pickIcon,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _selectedColor,
                      ),
                      onPressed: _pickColor,
                      child: Text(
                        'Pilih Warna',
                        style: TextStyle(
                          color: _selectedColor.computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  ..._tags.map(
                    (tag) => Chip(
                      label: Text(tag),
                      onDeleted: () {
                        setState(() {
                          _tags.remove(tag);
                        });
                      },
                    ),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.add),
                    label: const Text('Tambah Tag'),
                    onPressed: _addTag,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          child: Text(widget.category == null ? 'Tambah' : 'Simpan'),
        ),
      ],
    );
  }

  Future<void> _pickIcon() async {
    final icon = await showDialog<IconData>(
      context: context,
      builder: (context) => IconPickerDialog(initialIcon: _selectedIcon),
    );

    if (icon != null) {
      setState(() {
        _selectedIcon = icon;
      });
    }
  }

  Future<void> _pickColor() async {
    final color = await showDialog<Color>(
      context: context,
      builder: (context) => ColorPickerDialog(initialColor: _selectedColor),
    );

    if (color != null) {
      setState(() {
        _selectedColor = color;
      });
    }
  }

  Future<void> _addTag() async {
    final tag = await showDialog<String>(
      context: context,
      builder: (context) => _AddTagDialog(),
    );

    if (tag != null && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
    }
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CategoryProvider>();
    final category = widget.category ??
        Category(
          name: _nameController.text,
          iconData: _selectedIcon.codePoint.toString(),
          colorValue: _selectedColor.value,
          description: _descriptionController.text,
          tags: _tags,
        );

    if (widget.category != null) {
      category.name = _nameController.text;
      category.updateIcon(_selectedIcon);
      category.updateColor(_selectedColor);
      category.description = _descriptionController.text;
      category.tags.clear();
      category.tags.addAll(_tags);
      provider.updateCategory(category);
    } else {
      provider.addCategory(category);
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class _AddTagDialog extends StatelessWidget {
  final _controller = TextEditingController();

  _AddTagDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Tag'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Nama Tag',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            Navigator.pop(context, value);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              Navigator.pop(context, _controller.text);
            }
          },
          child: const Text('Tambah'),
        ),
      ],
    );
  }
}
