// Pure data — no Flutter/UI imports needed here.

enum PaymentMethodType { gcash, maya, cash, bankTransfer }

class PaymentMethod {
  final PaymentMethodType type;
  final String label;
  final String subtitle;

  const PaymentMethod({
    required this.type,
    required this.label,
    required this.subtitle,
  });

  static const List<PaymentMethod> all = [
    PaymentMethod(
      type:     PaymentMethodType.gcash,
      label:    'GCash',
      subtitle: 'Pay via GCash e-wallet',
    ),
    PaymentMethod(
      type:     PaymentMethodType.maya,
      label:    'Maya',
      subtitle: 'Pay via Maya e-wallet',
    ),
    PaymentMethod(
      type:     PaymentMethodType.bankTransfer,
      label:    'Bank Transfer',
      subtitle: 'BDO, BPI, UnionBank, etc.',
    ),
    PaymentMethod(
      type:     PaymentMethodType.cash,
      label:    'Cash',
      subtitle: 'Pay in person on move-in day',
    ),
  ];
}