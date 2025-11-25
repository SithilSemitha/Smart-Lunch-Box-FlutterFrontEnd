import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MealHistory extends StatelessWidget {
  final List<Map<String, dynamic>> plans;

  const MealHistory({super.key, required this.plans});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Meal History",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          plans.isEmpty
              ? const Text("No meal history yet",
                  style: TextStyle(color: Colors.white54))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: plans.length > 10 ? 10 : plans.length,
                  itemBuilder: (context, index) {
                    final plan = plans[index];

                    String formattedTime = plan["timestamp"] ?? "";
                    try {
                      DateTime dt = DateTime.parse(plan["timestamp"]);
                      formattedTime =
                          DateFormat("dd/MM/yyyy HH:mm").format(dt.toLocal());
                    } catch (_) {}

                    IconData icon;
                    Color iconColor;

                    switch (plan["type"]) {
                      case "Breakfast":
                        icon = Icons.wb_sunny;
                        iconColor = Colors.orange;
                        break;
                      case "Lunch":
                        icon = Icons.restaurant;
                        iconColor = Colors.green;
                        break;
                      case "Dinner":
                        icon = Icons.nightlight;
                        iconColor = Colors.blue;
                        break;
                      default:
                        icon = Icons.fastfood;
                        iconColor = Colors.grey;
                    }

                    return Card(
                      color: const Color(0xFF2A2A2A),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: Icon(icon, color: iconColor, size: 30),
                        title: Text(plan["type"],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          "Temp: ${plan["temperature"]}°C | Weight: ${plan["weight"]}kg\n$formattedTime",
                          style:
                              const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
