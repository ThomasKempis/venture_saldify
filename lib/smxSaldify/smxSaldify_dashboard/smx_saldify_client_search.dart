import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';

class SmxSaldiFyClientSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final String hintText;

  const SmxSaldiFyClientSearchField({
    super.key,
    required this.controller,
    required this.query,
    required this.onChanged,
    this.hintText = 'Buscar por nombre, correo o telefono',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: const TextStyle(
        color: SmxColors.textDark,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: SmxColors.textMuted.withValues(alpha: .8)),
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                tooltip: 'Limpiar busqueda',
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: SmxColors.whiteAlpha(.94),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

class SmxSaldiFyClientSearchEmpty extends StatelessWidget {
  const SmxSaldiFyClientSearchEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        'No se encontraron clientes.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: SmxColors.textMuted,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String smxNormalizeClientSearch(String value) {
  const accents = 'áéíóúüñ';
  const plain = 'aeiouun';
  var normalized = value.toLowerCase();
  for (var index = 0; index < accents.length; index++) {
    normalized = normalized.replaceAll(accents[index], plain[index]);
  }
  return normalized.replaceAll(RegExp(r'[^a-z0-9]'), '');
}

List<int> smxVisibleClientIndexes({
  required int rowCount,
  required bool showAll,
  required String searchQuery,
  required String Function(int index) searchableTextAt,
  int collapsedLimit = 5,
}) {
  if (!showAll) {
    return List<int>.generate(
      rowCount.clamp(0, collapsedLimit).toInt(),
      (index) => index,
    );
  }

  final normalizedQuery = smxNormalizeClientSearch(searchQuery);
  if (normalizedQuery.isEmpty) {
    return List<int>.generate(rowCount, (index) => index);
  }

  return [
    for (var index = 0; index < rowCount; index++)
      if (smxNormalizeClientSearch(
        searchableTextAt(index),
      ).contains(normalizedQuery))
        index,
  ];
}
