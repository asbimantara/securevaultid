import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import '../../data/models/password_model.dart';

class ExportService {
  static Future<String> exportToPdf(List<Password> passwords) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('SecureVault ID - Daftar Password'),
          ),
          pw.Table.fromTextArray(
            context: context,
            data: <List<String>>[
              ['Judul', 'Username', 'Password', 'Website', 'Kategori'],
              ...passwords.map(
                (p) => [
                  p.title,
                  p.username,
                  p.password,
                  p.website ?? '-',
                  p.category,
                ],
              ),
            ],
          ),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/passwords_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  static Future<String> exportToCsv(List<Password> passwords) async {
    final csvData = [
      [
        'Judul',
        'Username',
        'Password',
        'Website',
        'Kategori',
        'Dibuat',
        'Diubah'
      ],
      ...passwords.map(
        (p) => [
          p.title,
          p.username,
          p.password,
          p.website ?? '',
          p.category,
          p.createdAt.toIso8601String(),
          p.lastModified?.toIso8601String() ?? '',
        ],
      ),
    ];

    final csvString = const ListToCsvConverter().convert(csvData);
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
      '${directory.path}/passwords_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    await file.writeAsString(csvString);
    return file.path;
  }
}
