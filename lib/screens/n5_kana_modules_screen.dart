import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/models/kana.dart';
import 'package:ez_trainz/screens/kana_chart_screen.dart';
import 'package:ez_trainz/screens/kana_drag_drop_screen.dart';

/// N5 Kana sub-modules: Hiragana and Katakana sections.
/// Each section offers a Chart view and a Drag-and-Drop game.
/// Uses Sakura Pink accent for JLC-specific styling.
class N5KanaModulesScreen extends StatelessWidget {
  const N5KanaModulesScreen({super.key});

  static const _sakura = Color(KanaData.sakuraPink);
  static const _sakuraLight = Color(KanaData.sakuraPinkLight);
  static const _sakuraDark = Color(KanaData.sakuraPinkDark);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _sakuraLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_sakura, _sakuraDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white38, width: 1),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back_ios_rounded,
                              color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('Back',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'N5 Beginner',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Japanese Writing Systems',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Master Hiragana & Katakana characters',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // ── MODULES LIST ────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── HIRAGANA MODULE ─────────────────────────
                    _ModuleSection(
                      title: 'Hiragana',
                      subtitle: 'ひらがな',
                      description:
                          'The foundational Japanese script. 46 basic characters used for native Japanese words.',
                      icon: Icons.brush_rounded,
                      characterCount: 46,
                      onChartTap: () => Get.to(
                        () => KanaChartScreen(
                          title: 'Hiragana',
                          kanaList: KanaData.hiragana,
                        ),
                        transition: Transition.rightToLeftWithFade,
                        duration: const Duration(milliseconds: 300),
                      ),
                      onGameTap: () => Get.to(
                        () => KanaDragDropScreen(
                          title: 'Hiragana',
                          kanaList: KanaData.hiragana,
                        ),
                        transition: Transition.rightToLeftWithFade,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── KATAKANA MODULE ─────────────────────────
                    _ModuleSection(
                      title: 'Katakana',
                      subtitle: 'カタカナ',
                      description:
                          'Used for foreign words, onomatopoeia, and emphasis. 46 basic characters.',
                      icon: Icons.translate_rounded,
                      characterCount: 46,
                      onChartTap: () => Get.to(
                        () => KanaChartScreen(
                          title: 'Katakana',
                          kanaList: KanaData.katakana,
                        ),
                        transition: Transition.rightToLeftWithFade,
                        duration: const Duration(milliseconds: 300),
                      ),
                      onGameTap: () => Get.to(
                        () => KanaDragDropScreen(
                          title: 'Katakana',
                          kanaList: KanaData.katakana,
                        ),
                        transition: Transition.rightToLeftWithFade,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── TIPS CARD ───────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFE082)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.tips_and_updates_rounded,
                                  color: Color(0xFFFFA000), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Learning Tips',
                                style: TextStyle(
                                  color: Color(0xFFF57F17),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          _TipItem(text: 'Start with Hiragana before Katakana'),
                          SizedBox(height: 6),
                          _TipItem(text: 'Use mnemonics to remember shapes'),
                          SizedBox(height: 6),
                          _TipItem(text: 'Practice stroke order for muscle memory'),
                          SizedBox(height: 6),
                          _TipItem(text: 'Play the drag & drop game daily'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Module section card ─────────────────────────────────────────────
class _ModuleSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final int characterCount;
  final VoidCallback onChartTap;
  final VoidCallback onGameTap;

  const _ModuleSection({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.characterCount,
    required this.onChartTap,
    required this.onGameTap,
  });

  static const _sakura = Color(KanaData.sakuraPink);
  static const _sakuraDark = Color(KanaData.sakuraPinkDark);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _sakura.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row ─────────────────────────────────
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _sakura.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: _sakura, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Color(0xFF1A1A2E),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: _sakura,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$characterCount characters',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // ── Action buttons ────────────────────────────
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.grid_view_rounded,
                  label: 'Chart',
                  onTap: onChartTap,
                  filled: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: Icons.games_rounded,
                  label: 'Drag & Drop',
                  onTap: onGameTap,
                  filled: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.filled,
  });

  static const _sakura = Color(KanaData.sakuraPink);
  static const _sakuraDark = Color(KanaData.sakuraPinkDark);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: filled ? _sakura : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: filled ? null : Border.all(color: _sakura, width: 1.5),
          gradient: filled
              ? const LinearGradient(
                  colors: [_sakura, _sakuraDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: filled ? Colors.white : _sakura,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: filled ? Colors.white : _sakuraDark,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String text;
  const _TipItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('  \u2022  ',
            style: TextStyle(color: Color(0xFFFFA000), fontSize: 13)),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF5D4037),
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
