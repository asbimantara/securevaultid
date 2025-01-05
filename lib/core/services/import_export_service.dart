import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../data/models/password_model.dart';

class ImportExportService {
  static Future<List<Password>?> importFromCsv(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final List<List<dynamic>> rowsAsListOfValues =
            const CsvToListConverter().convert(content);

        // Skip header row
        rowsAsListOfValues.removeAt(0);

        return rowsAsListOfValues.map((row) {
          return Password(
            title: row[0].toString(),
            username: row[1].toString(),
            password: row[2].toString(),
            website: row[3].toString().isEmpty ? null : row[3].toString(),
            category: row[4].toString(),
            createdAt: DateTime.now(),
            lastModified: DateTime.now(),
          );
        }).toList();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing CSV: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    return null;
  }

  static Future<List<Password>?> importFromJson(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final List<dynamic> jsonList = json.decode(content);

        return jsonList
            .map((json) => Password(
                  title: json['title'],
                  username: json['username'],
                  password: json['password'],
                  website: json['website'],
                  category: json['category'],
                  createdAt: DateTime.parse(json['createdAt']),
                  lastModified: json['lastModified'] != null
                      ? DateTime.parse(json['lastModified'])
                      : null,
                  tags: List<String>.from(json['tags'] ?? []),
                  isFavorite: json['isFavorite'] ?? false,
                ))
            .toList();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing JSON: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    return null;
  }
}
