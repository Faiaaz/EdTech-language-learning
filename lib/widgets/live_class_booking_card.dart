import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LiveClassBookingCard extends StatelessWidget {
  const LiveClassBookingCard({
    super.key,
    this.onTap,
    this.titleKey = 'hiragana_l1_live_lesson',
    this.subtitleKey = 'hiragana_l1_live_lesson_sub',
    this.backgroundColor = const Color(0xFF1E293B),
    this.mutedTextColor = const Color(0xFF94A3B8),
  });

  final VoidCallback? onTap;
  final String titleKey;
  final String subtitleKey;
  final Color backgroundColor;
  final Color mutedTextColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF6366F1),
              Color(0xFFEC4899),
              Color(0xFFFFE000),
              Color(0xFF10B981),
              Color(0xFF3B82F6),
            ],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.video_call_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleKey.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      subtitleKey.tr,
                      style: TextStyle(
                        color: mutedTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: mutedTextColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
