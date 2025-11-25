import 'package:flutter/material.dart';

class MealTypeSelector extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeSelected;

  const MealTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final mealTypes = [
      {"type": "Breakfast", "icon": Icons.breakfast_dining, "color": const Color(0xFFFFD93D)},
      {"type": "Lunch", "icon": Icons.lunch_dining, "color": const Color(0xFFFF6B6B)},
      {"type": "Dinner", "icon": Icons.dinner_dining, "color": const Color(0xFF6BCB77)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.orangeAccent, Colors.redAccent],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Select Meal Type",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: mealTypes.map((meal) {
            final isSelected = selectedType == meal["type"];
            return Expanded(
              child: GestureDetector(
                onTap: () => onTypeSelected(meal["type"] as String),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              (meal["color"] as Color).withOpacity(0.8),
                              (meal["color"] as Color).withOpacity(0.5),
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
                      color: isSelected
                          ? (meal["color"] as Color)
                          : Colors.white.withOpacity(0.1),
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (meal["color"] as Color).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        meal["icon"] as IconData,
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        meal["type"] as String,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
