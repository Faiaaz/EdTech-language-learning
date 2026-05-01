import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/streak_controller.dart';

/// Duolingo-style top bar with language flag + streak / gem / heart counters.
class DuoTopCurrencyBar extends StatelessWidget {
  const DuoTopCurrencyBar({super.key, this.flagEmoji = '🇯🇵'});

  final String flagEmoji;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 44,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            alignment: Alignment.center,
            child: Text(flagEmoji, style: const TextStyle(fontSize: 20)),
          ),
          Row(
            children: [
              Obx(() => _CurrencyPill(
                    icon: Icons.local_fire_department_rounded,
                    color: const Color(0xFFFF6B35),
                    value: StreakController.to.state.value.streakCount,
                  )),
              const SizedBox(width: 14),
              const _CurrencyPill(
                icon: Icons.diamond_rounded,
                color: Color(0xFF60A5FA),
                value: 500,
              ),
              const SizedBox(width: 14),
              const _CurrencyPill(
                icon: Icons.favorite_rounded,
                color: Color(0xFFEF4444),
                value: 5,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrencyPill extends StatelessWidget {
  const _CurrencyPill({
    required this.icon,
    required this.color,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 4),
        Text(
          value.toString(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
