import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../widgets/meal_type_selector.dart';
import '../widgets/time_selector.dart';
import '../widgets/save_button.dart';
import '../widgets/info_card.dart'; // Import the new InfoCard widget
import '../widgets/glass_card.dart';

class MealPlansPage extends StatefulWidget {
  const MealPlansPage({super.key});

  @override
  State<MealPlansPage> createState() => _MealPlansPageState();
}

class _MealPlansPageState extends State<MealPlansPage> {
  final db = FirebaseDatabase.instance.ref();
  String selectedType = "Breakfast";
  TimeOfDay? selectedTime;
  bool saving = false;

  Future<Map<String, dynamic>> _readLatest() async {
    final snap = await db.child("readings/latest").get();
    if (snap.exists) {
      final value = Map<String, dynamic>.from(snap.value as Map);
      return {
        "temperature": value["temperature"]?.toString() ?? "0",
        "weight": value["weight"]?.toString() ?? "0",
        "timestamp":
            value["timestamp"]?.toString() ?? DateTime.now().toIso8601String(),
      };
    } else {
      return {
        "temperature": "0",
        "weight": "0",
        "timestamp": DateTime.now().toIso8601String(),
      };
    }
  }

  Future<void> _saveMealPlan() async {
    if (selectedTime == null) return;
    setState(() => saving = true);
    try {
      final latest = await _readLatest();
      DateTime createdAt;
      try {
        createdAt = DateTime.parse(latest["timestamp"]);
      } catch (_) {
        createdAt = DateTime.now();
      }

      final scheduledDateTime = DateTime(
        createdAt.year,
        createdAt.month,
        createdAt.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      final timeStr =
          "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";

      await db.child("mealPlans/alarm").set({
        "type": selectedType,
        "time": timeStr,
        "scheduled_at": scheduledDateTime.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
      });

      final newScheduled = await db.child("mealPlans/scheduled").push();
      await newScheduled.set({
        "type": selectedType,
        "time": timeStr,
        "scheduled_at": scheduledDateTime.toIso8601String(),
        "created_at": createdAt.toIso8601String(),
        "temperature_snapshot": latest["temperature"],
        "weight_snapshot": latest["weight"],
        "status": "upcoming",
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text("$selectedType meal scheduled at $timeStr")),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text("Error saving meal plan: $e")),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 5, 7, 17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E21),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFFD93D)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.restaurant_menu,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Meal Plans",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoCard(), // Use the InfoCard widget here
            const SizedBox(height: 24),
            GlassCard(
              child: Column(
                children: [
                  MealTypeSelector(
                    selectedType: selectedType,
                    onTypeSelected: (newType) =>
                        setState(() => selectedType = newType),
                  ),
                  const SizedBox(height: 32),
                  TimeSelector(
                    selectedTime: selectedTime,
                    onTimeSelected: (newTime) =>
                        setState(() => selectedTime = newTime),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SaveButton(
              isEnabled: selectedTime != null && !saving,
              onSave: _saveMealPlan,
              isSaving: saving,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
