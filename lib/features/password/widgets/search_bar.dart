import 'package:flutter/material.dart';

class PasswordSearchBar extends StatelessWidget {
  final Function(String) onSearch;

  const PasswordSearchBar({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        onChanged: onSearch,
        decoration: InputDecoration(
          hintText: 'Cari password...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant,
        ),
      ),
    );
  }
}
