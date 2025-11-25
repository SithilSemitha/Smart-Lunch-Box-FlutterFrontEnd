import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  final bool isEnabled;
  final bool isSaving;
  final Function() onSave;

  const SaveButton({
    super.key,
    required this.isEnabled,
    required this.onSave,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onSave : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: isEnabled
                ? const LinearGradient(
                    colors: [Color(0xFF6BCB77), Color(0xFF4D96FF)],
                  )
                : LinearGradient(
                    colors: [
                      Colors.grey.withOpacity(0.3),
                      Colors.grey.withOpacity(0.2),
                    ],
                  ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: const Color(0xFF6BCB77).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: isSaving
              ? const Center(
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: isEnabled
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Save Meal Plan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isEnabled
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
