import 'package:flutter/material.dart';

// path: views/widgets → ../../data/models/
import '../../data/models/payment_model.dart';

class PaymentMethodSelector extends StatelessWidget {
  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onChanged;

  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: PaymentMethod.all.map((pm) {
        final isSelected = pm.type == selected.type;
        return GestureDetector(
          onTap: () => onChanged(pm),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? Colors.black87 : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? Colors.black87 : Colors.grey.shade200,
                width: isSelected ? 0 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.15)
                        : _bgColor(pm.type),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      _icon(pm.type),
                      color: isSelected ? Colors.white : _iconColor(pm.type),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Label + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pm.label,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pm.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white70 : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                // Radio dot
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.white : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.black87,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── UI helpers (icon / color) live here, NOT in payment_model.dart ─────────

  IconData _icon(PaymentMethodType t) {
    switch (t) {
      case PaymentMethodType.gcash:        return Icons.g_mobiledata_rounded;
      case PaymentMethodType.maya:         return Icons.account_balance_wallet_rounded;
      case PaymentMethodType.bankTransfer: return Icons.account_balance_rounded;
      case PaymentMethodType.cash:         return Icons.payments_rounded;
    }
  }

  Color _bgColor(PaymentMethodType t) {
    switch (t) {
      case PaymentMethodType.gcash:        return const Color(0xFFE8F4FD);
      case PaymentMethodType.maya:         return const Color(0xFFE8FAF0);
      case PaymentMethodType.bankTransfer: return const Color(0xFFFFF3E0);
      case PaymentMethodType.cash:         return const Color(0xFFF3E5F5);
    }
  }

  Color _iconColor(PaymentMethodType t) {
    switch (t) {
      case PaymentMethodType.gcash:        return const Color(0xFF007AFF);
      case PaymentMethodType.maya:         return const Color(0xFF00C853);
      case PaymentMethodType.bankTransfer: return const Color(0xFFFF8F00);
      case PaymentMethodType.cash:         return const Color(0xFF7B1FA2);
    }
  }
}