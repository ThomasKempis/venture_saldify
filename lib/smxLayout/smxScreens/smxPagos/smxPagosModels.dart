class SmxPagosViewModel {
  final String clientName;
  final double credito;
  final double disponible;
  final double saldo;
  final String formSubtitle;
  final String keyPrefix;

  const SmxPagosViewModel({
    required this.clientName,
    required this.credito,
    required this.disponible,
    required this.saldo,
    required this.formSubtitle,
    this.keyPrefix = 'pago',
  });
}
