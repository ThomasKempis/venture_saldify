import 'dart:convert';

import 'package:universal_html/html.dart' as html;

import 'models/smxComprasCarritoLocalModels.dart';

class SmxCarritoStorage {
  final int idSysuser11;

  const SmxCarritoStorage(this.idSysuser11);

  String get _key => 'saldify_carritos_$idSysuser11';

  List<SmxCarritoLocal> loadDrafts() {
    final raw = html.window.localStorage[_key];
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final result = list
          .map(
            (value) => SmxCarritoLocal.fromJson(value as Map<String, dynamic>),
          )
          .toList();
      result.sort((a, b) => b.actualizado.compareTo(a.actualizado));
      return result;
    } catch (_) {
      return [];
    }
  }

  void saveDraft(SmxCarritoLocal cart) {
    final drafts = loadDrafts();
    drafts.removeWhere((item) => item.uuid == cart.uuid);
    if (cart.items.isNotEmpty) drafts.add(cart);
    html.window.localStorage[_key] = jsonEncode(
      drafts.map((item) => item.toJson()).toList(),
    );
  }

  void delete(String uuid) {
    final drafts = loadDrafts()..removeWhere((item) => item.uuid == uuid);
    html.window.localStorage[_key] = jsonEncode(
      drafts.map((item) => item.toJson()).toList(),
    );
  }
}
