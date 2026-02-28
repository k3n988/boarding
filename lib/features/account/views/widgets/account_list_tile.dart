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
            // Changed icon color to solid black
            Icon(icon, color: Colors.black, size: 24), 
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  // Changed text color to solid black (unless destructive)
                  color: isDestructive ? Colors.red : Colors.black, 
                ),
              ),
            ),
            if (trailingText != null && trailingText!.isNotEmpty)
              Text(
                trailingText!,
                style: const TextStyle(
                  color: Colors.black54, // Kept slightly faded for visual hierarchy, but black-based
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(width: 8),
            // Changed chevron to solid black
            const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.black), 
          ],
        ),
      ),
    );
  }
}