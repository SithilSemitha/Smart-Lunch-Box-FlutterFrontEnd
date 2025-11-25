import 'package:flutter/material.dart';
import 'stats_card.dart';

class QuickStats extends StatelessWidget {
  final List<Map<String, dynamic>> mealData;
  final List<Map<String, dynamic>> Function(DateTime, DateTime) filterMeals;

  const QuickStats({
    super.key,
    required this.mealData,
    required this.filterMeals,
  });

  @override
  Widget build(BuildContext context) {
    final totalMeals = mealData.length;
    final avgWeight = mealData.isEmpty
        ? 0.0
        : mealData.fold(
                0.0,
                (sum, m) =>
                    sum + (double.tryParse(m['weight'].toString()) ?? 0),
              ) /
              totalMeals;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatsCard(
                label: "Total Meals",
                value: totalMeals.toString(),
                icon: Icons.restaurant,
                color: const Color(0xFF6BCB77),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                label: "Avg Weight",
                value: "${avgWeight.toStringAsFixed(1)}kg",
                icon: Icons.scale,
                color: const Color(0xFF4D96FF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                label: "This Week",
                value: filterMeals(
                  DateTime.now().subtract(
                    Duration(days: DateTime.now().weekday - 1),
                  ),
                  DateTime.now(),
                ).length.toString(),
                icon: Icons.calendar_today,
                color: const Color(0xFFFFD93D),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                label: "This Month",
                value: filterMeals(
                  DateTime(DateTime.now().year, DateTime.now().month, 1),
                  DateTime.now(),
                ).length.toString(),
                icon: Icons.date_range,
                color: const Color(0xFFFF6B6B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
