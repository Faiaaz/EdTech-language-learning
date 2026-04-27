import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/streak_controller.dart';

class StreakPill extends StatelessWidget {
  const StreakPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final streak = StreakController.to.state.value.streakCount;
      final p = StreakController.to.todayProgress.value.clamp(0.0, 1.0);
      final done = p >= 1.0;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: p,
                    strokeWidth: 2.3,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      done ? const Color(0xFFFFE000) : Colors.white,
                    ),
                  ),
                  const Center(
                    child: Icon(Icons.local_fire_department_rounded,
                        size: 14, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$streak',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    });
  }
}

