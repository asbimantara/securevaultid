import 'package:flutter/material.dart';
import '../../data/models/password_model.dart';
import '../../data/providers/password_provider.dart';
import './widgets/password_generator_dialog.dart';
import './widgets/password_strength_indicator.dart';
import './widgets/tag_editor_dialog.dart';
import '../../core/services/expiration_service.dart';

class PasswordFormScreen extends StatefulWidget {
  final Password? password; // null untuk tambah baru, isi untuk edit

  const PasswordFormScreen({super.key, this.password});

  @override
  State<PasswordFormScreen> createState() => _PasswordFormScreenState();
}

class _PasswordFormScreenState extends State<PasswordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _websiteController = TextEditingController();
  bool _obscurePassword = true;
  String? _selectedCategory;
  List<String> _tags = [];
  bool _isFavorite = false;
  DateTime? _expirationDate;

  @override
  void initState() {
    super.initState();
    if (widget.password != null) {
      _titleController.text = widget.password!.title;
      _usernameController.text = widget.password!.username;
      _passwordController.text = widget.password!.password;
      _websiteController.text = widget.password?.website ?? '';
      _tags = List.from(widget.password!.tags);
      _isFavorite = widget.password!.isFavorite;
    }
  }

  Future<void> _showPasswordGenerator() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const PasswordGeneratorDialog(),
    );

    if (result != null) {
      setState(() {
        _passwordController.text = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.password == null ? 'Tambah Password' : 'Edit Password'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Judul tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Username tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.auto_fix_high),
                      onPressed: _showPasswordGenerator,
                      tooltip: 'Generate Password',
                    ),
                    IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ],
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password tidak boleh kosong';
                }
                return null;
              },
            ),
            if (_passwordController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              PasswordStrengthIndicator(
                password: _passwordController.text,
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Website (Opsional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.web),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'sosial_media',
                  child: Text('Sosial Media'),
                ),
                DropdownMenuItem(
                  value: 'email',
                  child: Text('Email'),
                ),
                DropdownMenuItem(
                  value: 'bank',
                  child: Text('Bank'),
                ),
              ],
              onChanged: (value) {
                _selectedCategory = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Pilih kategori';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.tag),
                    label: Text(_tags.isEmpty
                        ? 'Tambah Tag'
                        : 'Tags (${_tags.length})'),
                    onPressed: () async {
                      final result = await showDialog<List<String>>(
                        context: context,
                        builder: (context) => TagEditorDialog(
                          initialTags: _tags,
                          onTagsUpdated: (tags) => Navigator.pop(context, tags),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          _tags = result;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : null,
                  ),
                  onPressed: () {
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(_expirationDate == null
                  ? 'Set Tanggal Kedaluwarsa'
                  : 'Kedaluwarsa: ${_formatDate(_expirationDate!)}'),
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _expirationDate ??
                      DateTime.now().add(const Duration(days: 90)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                );
                if (date != null) {
                  setState(() {
                    _expirationDate = date;
                  });
                }
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final password = Password(
                    title: _titleController.text,
                    username: _usernameController.text,
                    password: _passwordController.text,
                    website: _websiteController.text,
                    category: _selectedCategory!,
                    createdAt: DateTime.now(),
                    lastModified: DateTime.now(),
                    tags: _tags,
                    isFavorite: _isFavorite,
                    expirationDate: _expirationDate,
                  );

                  if (widget.password == null) {
                    context.read<PasswordProvider>().addPassword(password);
                  } else {
                    password.key = widget.password!.key;
                    context.read<PasswordProvider>().updatePassword(password);
                  }

                  if (_expirationDate != null) {
                    ExpirationService.scheduleExpirationReminder(password);
                  }

                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _websiteController.dispose();
    super.dispose();
  }
}
