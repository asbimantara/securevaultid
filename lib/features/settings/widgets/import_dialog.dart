import 'package:flutter/material.dart';
import 'dart:convert';

class ImportDialog extends StatefulWidget {
  const ImportDialog({super.key});

  @override
  State<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {
  final _controller = TextEditingController();
  String? _error;

  void _validateJson() {
    try {
      if (_controller.text.isEmpty) {
        setState(() => _error = 'Data tidak boleh kosong');
        return;
      }

      final data = jsonDecode(_controller.text);
      if (data is! List) {
        setState(() => _error = 'Format data tidak valid');
        return;
      }

      setState(() => _error = null);
      Navigator.pop(context, data);
    } catch (e) {
      setState(() => _error = 'Format JSON tidak valid');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Impor Data'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tempel data JSON hasil ekspor dari aplikasi ini:',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 8,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: 'Tempel data di sini...',
              errorText: _error,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: _validateJson,
          child: const Text('Impor'),
        ),
      ],
    );
  }
}
