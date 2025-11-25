import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../widgets/glass_card2.dart';
import '../widgets/weight_chart.dart';
import '../widgets/meal_pie_chart.dart';
import '../widgets/report_button.dart';
import '../widgets/quick_stats.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  final mealHistoryRef = FirebaseDatabase.instance.ref("mealPlans/history");
  List<Map<String, dynamic>> mealData = [];

  @override
  void initState() {
    super.initState();
    mealHistoryRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        final List<Map<String, dynamic>> list = [];
        data.forEach((key, value) {
          final map = Map<String, dynamic>.from(value);
          map['key'] = key;
          list.add(map);
        });
        setState(() => mealData = list.reversed.toList());
      } else {
        setState(() => mealData = []);
      }
    });
  }

  List<Map<String, dynamic>> filterMeals(DateTime start, DateTime end) {
    return mealData.where((m) {
      try {
        DateTime dt = DateTime.parse(m['timestamp']);
        return dt.isAfter(start.subtract(const Duration(seconds: 1))) &&
            dt.isBefore(end.add(const Duration(seconds: 1)));
      } catch (_) {
        return false;
      }
    }).toList();
  }

  Map<String, int> mealTypeDistribution(List<Map<String, dynamic>> meals) {
    Map<String, int> map = {};
    for (var m in meals) {
      String type = m['type'] ?? "Unknown";
      map[type] = (map[type] ?? 0) + 1;
    }
    return map;
  }

  Future<void> generatePdf(String period) async {
    DateTime now = DateTime.now();
    DateTime start;
    DateTime end = now;

    switch (period) {
      case 'Daily':
        start = DateTime(now.year, now.month, now.day);
        break;
      case 'Weekly':
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        break;
      case 'Monthly':
        start = DateTime(now.year, now.month, 1);
        break;
      default:
        start = DateTime(now.year, now.month, now.day);
    }

    final filteredData = filterMeals(start, end);
    final totalWeight = filteredData.fold(
      0.0,
      (sum, m) => sum + (double.tryParse(m['weight'].toString()) ?? 0),
    );
    final avgWeight = filteredData.isEmpty
        ? 0
        : totalWeight / filteredData.length;
    final mealDistribution = mealTypeDistribution(filteredData);

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Text(
            "$period Meal Report",
            style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            "From ${DateFormat('yyyy-MM-dd').format(start)} to ${DateFormat('yyyy-MM-dd').format(end)}",
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            "Summary",
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.Bullet(text: "Total Meals: ${filteredData.length}"),
          pw.Bullet(text: "Average Weight: ${avgWeight.toStringAsFixed(2)} kg"),
          pw.Bullet(
            text: "Total Weight Recorded: ${totalWeight.toStringAsFixed(2)} kg",
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            "Meal Type Distribution",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          ...mealDistribution.entries.map(
            (e) => pw.Bullet(text: "${e.key}: ${e.value} meals"),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            "Meal Details",
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.ListView.builder(
            itemCount: filteredData.length,
            itemBuilder: (context, index) {
              final m = filteredData[index];
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 5),
                child: pw.Text(
                  "${m['type']} | Temp: ${m['temperature']}°C | Weight: ${m['weight']}kg | ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(m['timestamp']))}",
                ),
              );
            },
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mealDistribution = mealTypeDistribution(mealData);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 7, 9, 22),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 6, 8, 19),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.greenAccent, Colors.blueAccent],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.analytics, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              "Analysis Dashboard",
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuickStats(mealData: mealData, filterMeals: filterMeals),
            const SizedBox(height: 8),
            WeightChart(mealData: mealData),
            MealPieChart(distribution: mealDistribution),
            GlassCard2(
              title: "Generate Reports",
              child: Column(
                children: [
                  ReportButton(
                    label: "Daily Report",
                    subtitle: "Last 24 hours analysis",
                    icon: Icons.today,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                    ),
                    onPressed: () => generatePdf("Daily"),
                  ),
                  const SizedBox(height: 12),
                  ReportButton(
                    label: "Weekly Report",
                    subtitle: "7 days comprehensive data",
                    icon: Icons.calendar_view_week,
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 241, 202, 44),
                        Color.fromARGB(255, 170, 124, 5),
                      ],
                    ),
                    onPressed: () => generatePdf("Weekly"),
                  ),
                  const SizedBox(height: 12),
                  ReportButton(
                    label: "Monthly Report",
                    subtitle: "Complete month overview",
                    icon: Icons.calendar_month,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6BCB77), Color(0xFF4D96FF)],
                    ),
                    onPressed: () => generatePdf("Monthly"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
