import 'package:flutter/material.dart';
import '../../../core/utils/password_generator.dart';

class PasswordGeneratorDialog extends StatefulWidget {
  final void Function(String) onGenerated;

  const PasswordGeneratorDialog({
    super.key,
    required this.onGenerated,
  });

  @override
  State<PasswordGeneratorDialog> createState() =>
      _PasswordGeneratorDialogState();
}

class _PasswordGeneratorDialogState extends State<PasswordGeneratorDialog> {
  int _length = 12;
  bool _useUppercase = true;
  bool _useLowercase = true;
  bool _useNumbers = true;
  bool _useSpecial = true;
  String _generatedPassword = '';

  void _generatePassword() {
    final password = PasswordGenerator.generate(
      length: _length,
      useUppercase: _useUppercase,
      useLowercase: _useLowercase,
      useNumbers: _useNumbers,
      useSpecial: _useSpecial,
    );
    setState(() => _generatedPassword = password);
  }

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Generate Password'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _generatedPassword,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Panjang: '),
                Expanded(
                  child: Slider(
                    value: _length.toDouble(),
                    min: 8,
                    max: 32,
                    divisions: 24,
                    label: _length.toString(),
                    onChanged: (value) {
                      setState(() {
                        _length = value.round();
                        _generatePassword();
                      });
                    },
                  ),
                ),
                Text(_length.toString()),
              ],
            ),
            CheckboxListTile(
              title: const Text('Huruf Besar (A-Z)'),
              value: _useUppercase,
              onChanged: (value) {
                setState(() {
                  _useUppercase = value!;
                  _generatePassword();
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Huruf Kecil (a-z)'),
              value: _useLowercase,
              onChanged: (value) {
                setState(() {
                  _useLowercase = value!;
                  _generatePassword();
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Angka (0-9)'),
              value: _useNumbers,
              onChanged: (value) {
                setState(() {
                  _useNumbers = value!;
                  _generatePassword();
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Karakter Khusus (!@#\$)'),
              value: _useSpecial,
              onChanged: (value) {
                setState(() {
                  _useSpecial = value!;
                  _generatePassword();
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onGenerated(_generatedPassword);
            Navigator.pop(context);
          },
          child: const Text('Gunakan'),
        ),
      ],
    );
  }
}
