import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeightCard extends StatelessWidget {
  final String value;
  final List<FlSpot> chartData;

  const WeightCard({
    super.key,
    required this.value,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F0F0F),
            Color.fromARGB(0, 35, 35, 35),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Weight : $value",
              style: const TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 12),
          Expanded(
            child: LineChart(
              LineChartData(
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData,
                    isCurved: true,
                    barWidth: 4,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00F260), Color(0xFF0575E6)],
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00F260).withOpacity(0.4),
                          const Color(0xFF0575E6).withOpacity(0.2),
                        ],
                      ),
                    ),
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
