import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class TemperatureCircle extends StatelessWidget {
  final String value;
  const TemperatureCircle({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    double tempVal = double.tryParse(value) ?? 0;
    double percent = (tempVal / 100).clamp(0.0, 1.0);

    return CircularPercentIndicator(
      radius: 95,
      lineWidth: 25,
      animation: true,
      animationDuration: 800,
      percent: percent,
      circularStrokeCap: CircularStrokeCap.round,
      linearGradient: const LinearGradient(
        colors: [Colors.red, Colors.orange, Colors.yellow],
      ),
      backgroundColor: Colors.white10,
      center: Text("$tempVal °C",
          style: const TextStyle(
              fontSize: 23, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}
