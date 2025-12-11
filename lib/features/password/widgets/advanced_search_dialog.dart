import 'package:flutter/material.dart';

class AdvancedSearchDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;

  const AdvancedSearchDialog({
    super.key,
    required this.onApplyFilters,
  });

  @override
  State<AdvancedSearchDialog> createState() => _AdvancedSearchDialogState();
}

class _AdvancedSearchDialogState extends State<AdvancedSearchDialog> {
  final _searchController = TextEditingController();
  String _selectedCategory = '';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _onlyFavorites = false;
  bool _hasWebsite = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Lanjutan'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Kata Kunci',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              value: _selectedCategory.isEmpty ? null : _selectedCategory,
              items: [
                const DropdownMenuItem(
                  value: '',
                  child: Text('Semua Kategori'),
                ),
                ...['Sosial Media', 'Email', 'Bank', 'Kerja', 'Lainnya'].map(
                  (category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value ?? '';
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_startDate == null
                        ? 'Dari Tanggal'
                        : _formatDate(_startDate!)),
                    onPressed: () => _selectDate(true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_endDate == null
                        ? 'Sampai Tanggal'
                        : _formatDate(_endDate!)),
                    onPressed: () => _selectDate(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Hanya Favorit'),
              value: _onlyFavorites,
              onChanged: (value) {
                setState(() {
                  _onlyFavorites = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Memiliki Website'),
              value: _hasWebsite,
              onChanged: (value) {
                setState(() {
                  _hasWebsite = value;
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
            widget.onApplyFilters({
              'query': _searchController.text,
              'category': _selectedCategory,
              'startDate': _startDate,
              'endDate': _endDate,
              'onlyFavorites': _onlyFavorites,
              'hasWebsite': _hasWebsite,
            });
            Navigator.pop(context);
          },
          child: const Text('Terapkan'),
        ),
      ],
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
