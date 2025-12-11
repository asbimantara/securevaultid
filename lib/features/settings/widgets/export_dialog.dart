import 'package:flutter/material.dart';
import '../../../core/services/export_service.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/password_provider.dart';

class ExportDialog extends StatelessWidget {
  const ExportDialog({super.key});

  Future<void> _exportToPdf(BuildContext context) async {
    try {
      final passwords = context.read<PasswordProvider>().passwords;
      final filePath = await ExportService.exportToPdf(passwords);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File PDF berhasil disimpan di: $filePath'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengekspor ke PDF'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _exportToCsv(BuildContext context) async {
    try {
      final passwords = context.read<PasswordProvider>().passwords;
      final filePath = await ExportService.exportToCsv(passwords);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File CSV berhasil disimpan di: $filePath'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengekspor ke CSV'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Data'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text('Export ke PDF'),
            onTap: () {
              Navigator.pop(context);
              _exportToPdf(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text('Export ke CSV'),
            onTap: () {
              Navigator.pop(context);
              _exportToCsv(context);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
      ],
    );
  }
}
