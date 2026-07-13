import 'package:flutter/material.dart';

import '../../smxSaldify_dashboard/smxSaldiFy_clientes/smxSaldiFy_clientes.dart';
import 'saldify_compras_carrito/smxSaldiFy_compras_carrito.dart';
import 'saldify_compras_manual/smxSaldiFy_compras_manual.dart';

class SmxSaldiFyCompras extends StatelessWidget {
  final SmxSaldiFyClientTapData client;

  const SmxSaldiFyCompras({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    if (client.conCatalogo) {
      return SmxSaldiFyComprasCarrito(client: client);
    }

    return SmxSaldiFyComprasManual(client: client);
  }
}
