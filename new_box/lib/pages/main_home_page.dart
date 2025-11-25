import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

import '../widgets/temperature_circle.dart';
import '../widgets/weight_card.dart';
import '../widgets/upcoming_alarm.dart';
import '../widgets/meal_history.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref(
    "readings/latest",
  );
  final DatabaseReference mealHistoryRef = FirebaseDatabase.instance.ref(
    "mealPlans/history",
  );
  final DatabaseReference alarmRef = FirebaseDatabase.instance.ref(
    "mealPlans/alarm",
  );

  String temperature = "0";
  String weight = "0";
  String timestamp = "";
  List<FlSpot> weightData = [];
  double xValue = 0;

  final Map<String, Map<String, dynamic>> mealPlansMap = {};
  List<Map<String, dynamic>> get mealPlans =>
      mealPlansMap.values.toList().reversed.toList();

  String? upcomingMealType;
  String? upcomingMealTime;

  @override
  void initState() {
    super.initState();

    // Latest readings
    dbRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          temperature = data["temperature"]?.toString() ?? "0";
          weight = data["weight"]?.toString() ?? "0";
          timestamp = data["timestamp"] ?? "";

          weightData.add(FlSpot(xValue, double.tryParse(weight) ?? 0));
          xValue += 1;
          if (weightData.length > 20) weightData.removeAt(0);
        });
      }
    });

    // Meal history incremental updates
    mealHistoryRef.onChildAdded.listen((event) {
      if (event.snapshot.value != null) {
        final value = Map<String, dynamic>.from(event.snapshot.value as Map);
        mealPlansMap[event.snapshot.key!] = {
          ...value,
          "key": event.snapshot.key,
        };
        setState(() {});
      }
    });

    mealHistoryRef.onChildChanged.listen((event) {
      if (event.snapshot.value != null) {
        final value = Map<String, dynamic>.from(event.snapshot.value as Map);
        mealPlansMap[event.snapshot.key!] = {
          ...value,
          "key": event.snapshot.key,
        };
        setState(() {});
      }
    });

    mealHistoryRef.onChildRemoved.listen((event) {
      if (mealPlansMap.containsKey(event.snapshot.key)) {
        mealPlansMap.remove(event.snapshot.key);
        setState(() {});
      }
    });

    // Upcoming alarm listener
    alarmRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          upcomingMealType = data["type"];
          upcomingMealTime = data["time"];
        });
      } else {
        setState(() {
          upcomingMealType = null;
          upcomingMealTime = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        title: const Text("Smart Lunchbox V1.0"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TemperatureCircle(value: temperature),
            const SizedBox(height: 10),
            const Text(
              "Temperature",
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),
            WeightCard(value: weight, chartData: weightData),

            const SizedBox(height: 10),
            Text(
              "Last Update: $timestamp",
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),

            const SizedBox(height: 30),
            UpcomingAlarm(type: upcomingMealType, time: upcomingMealTime),

            const SizedBox(height: 20),
            MealHistory(plans: mealPlans),
          ],
        ),
      ),
    );
  }
}
