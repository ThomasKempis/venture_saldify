class SmxComprasManualViewModel {
  final String clientName;
  final double credito;
  final double disponible;
  final double saldo;
  final String headerLabel;
  final String formTitle;
  final String formSubtitle;
  final String receivedEmptyText;
  final String keyPrefix;

  const SmxComprasManualViewModel({
    required this.clientName,
    required this.credito,
    required this.disponible,
    required this.saldo,
    required this.headerLabel,
    required this.formTitle,
    required this.formSubtitle,
    required this.receivedEmptyText,
    this.keyPrefix = 'compra',
  });
}
