class SmxSaldiFyCreditoPlanMock {
  final int id;
  final String title;
  final String plan;
  final String subtitle;
  final String footerTitle;
  final String imageAsset;
  final bool hasPorcentajeMinimo;

  const SmxSaldiFyCreditoPlanMock({
    required this.id,
    required this.title,
    required this.plan,
    required this.subtitle,
    required this.footerTitle,
    required this.imageAsset,
    this.hasPorcentajeMinimo = false,
  });
}

const smxSaldiFyCreditoPlanesMock = [
  SmxSaldiFyCreditoPlanMock(
    id: 1,
    title: 'Paga y libera credito',
    plan: 'Fondo',
    subtitle: 'Cada pago aumenta el disponible.',
    footerTitle: 'Pago de 500 -> disponible sube 500',
    imageAsset: 'assets/images/saldify_plan_revolvente.png',
  ),
  SmxSaldiFyCreditoPlanMock(
    id: 2,
    title: 'Paga completo en el corte',
    plan: 'Débito',
    subtitle: 'El credito se libera al liquidar todo.',
    footerTitle: 'Debe 1,000 -> paga 1,000 para comprar',
    imageAsset: 'assets/images/saldify_plan_pago_completo.png',
  ),
  SmxSaldiFyCreditoPlanMock(
    id: 3,
    title: 'Libera con pago minimo',
    plan: 'Crédito',
    subtitle: 'Requiere un porcentaje minimo.',
    footerTitle: 'Minimo % -> libera credito al pagar',
    imageAsset: 'assets/images/saldify_plan_minimo.png',
    hasPorcentajeMinimo: true,
  ),
];

SmxSaldiFyCreditoPlanMock smxSaldiFyCreditoPlanById(int id) {
  return smxSaldiFyCreditoPlanesMock.firstWhere(
    (plan) => plan.id == id,
    orElse: () => smxSaldiFyCreditoPlanesMock.first,
  );
}
