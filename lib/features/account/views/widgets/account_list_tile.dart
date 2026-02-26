import 'package:flutter/material.dart';

class AccountListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final bool isDestructive;
  final VoidCallback? onTap;

  const AccountListTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailingText,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[700], size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.red : Colors.black87,
                ),
              ),
            ),
            if (trailingText != null && trailingText!.isNotEmpty)
              Text(
                trailingText!,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
