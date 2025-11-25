import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../widgets/glass_card3.dart';
import '../../widgets/info_card1.dart';
import '../../widgets/duration_button.dart';
import '../../widgets/start_button.dart';
import '../../widgets/countdown_card.dart';

class HeatControlPage extends StatefulWidget {
  const HeatControlPage({super.key});

  @override
  State<HeatControlPage> createState() => _HeatControlPageState();
}

class _HeatControlPageState extends State<HeatControlPage>
    with SingleTickerProviderStateMixin {
  final db = FirebaseDatabase.instance.ref();

  int selectedDuration = 0;
  bool isCounting = false;
  int remaining = 0;
  Timer? timer;

  late AnimationController fireController;
  late Animation<double> fireGlow;

  @override
  void initState() {
    super.initState();

    fireController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    fireGlow = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: fireController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    timer?.cancel();
    fireController.dispose();
    super.dispose();
  }

  void startHeatNow() {
    if (selectedDuration == 0) return;

    setState(() {
      remaining = selectedDuration;
      isCounting = true;
    });

    db.child("heat").update({"active": true, "duration": selectedDuration});

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => remaining--);

      if (remaining <= 0) {
        timer?.cancel();
        setState(() => isCounting = false);
        db.child("heat").update({"active": false});

        Future.delayed(const Duration(milliseconds: 300), () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => CountdownCard.showFinishedDialog(ctx),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 5, 6, 15),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 6, 9, 20),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.whatshot, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              "Heating Control",
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
            const InfoCard1(),
            const SizedBox(height: 24),
            GlassCard3(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Select Duration",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: DurationButton(
                          label: "30s",
                          seconds: 30,
                          selected: selectedDuration,
                          onTap: (sec) =>
                              setState(() => selectedDuration = sec),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DurationButton(
                          label: "1 min",
                          seconds: 60,
                          selected: selectedDuration,
                          onTap: (sec) =>
                              setState(() => selectedDuration = sec),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DurationButton(
                          label: "2 min",
                          seconds: 120,
                          selected: selectedDuration,
                          onTap: (sec) =>
                              setState(() => selectedDuration = sec),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (!isCounting)
              StartButton(enabled: selectedDuration > 0, onTap: startHeatNow),
            const SizedBox(height: 24),
            if (isCounting)
              CountdownCard(
                remaining: remaining,
                total: selectedDuration,
                fireController: fireController,
                fireGlow: fireGlow,
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
