enum SmxSaldiFyInvitaAction { copiarLink, whatsApp }

class SmxSaldiFyInvitacionGenerada {
  final String codigo;
  final String codigoFormato;
  final String link;
  final String telefono;

  const SmxSaldiFyInvitacionGenerada({
    required this.codigo,
    required this.codigoFormato,
    required this.link,
    this.telefono = '',
  });
}
