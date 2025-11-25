import 'package:flutter/material.dart';

class DurationButton extends StatelessWidget {
  final String label;
  final int seconds;
  final int selected;
  final Function(int) onTap;

  const DurationButton({
    super.key,
    required this.label,
    required this.seconds,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool active = selected == seconds;

    return GestureDetector(
      onTap: () => onTap(seconds),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(
                  colors: [
                    const Color(0xFFFF6B6B).withOpacity(0.5),
                    const Color(0xFFFF8E53).withOpacity(0.3),
                  ],
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.white.withOpacity(0.02),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active
                ? const Color(0xFFFF6B6B)
                : Colors.white.withOpacity(0.2),
            width: active ? 2 : 1,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              Icons.timer,
              color: active
                  ? const Color(0xFFFF6B6B)
                  : Colors.white.withOpacity(0.5),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: active ? Colors.white : Colors.white.withOpacity(0.6),
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
