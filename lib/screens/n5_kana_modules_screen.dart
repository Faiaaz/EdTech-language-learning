import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/srs_controller.dart';
import 'package:ez_trainz/models/kana.dart';
import 'package:ez_trainz/screens/kana_chart_screen.dart';
import 'package:ez_trainz/screens/kana_drag_drop_screen.dart';
import 'package:ez_trainz/screens/kana_review_screen.dart';
import 'package:ez_trainz/screens/kana_progress_screen.dart';
import 'package:ez_trainz/screens/kana_srs_review_screen.dart';
import 'package:ez_trainz/services/srs_service.dart';

/// N5 Kana sub-modules: Hiragana and Katakana sections.
/// Each section offers a Chart view and a Drag-and-Drop game.
/// Uses Sakura Pink accent for JLC-specific styling.
class N5KanaModulesScreen extends StatefulWidget {
  const N5KanaModulesScreen({super.key});

  @override
  State<N5KanaModulesScreen> createState() => _N5KanaModulesScreenState();
}

class _N5KanaModulesScreenState extends State<N5KanaModulesScreen> {
  static const _sakura = Color(KanaData.sakuraPink);
  static const _sakuraLight = Color(KanaData.sakuraPinkLight);
  static const _sakuraDark = Color(KanaData.sakuraPinkDark);

  int _hiraganaDue = 0;
  int _katakanaDue = 0;

  @override
  void initState() {
    super.initState();
    _loadDueCounts();
  }

  Future<void> _loadDueCounts() async {
    final srs = await SrsService.getInstance();
    if (mounted) {
      setState(() {
        _hiraganaDue = srs.dueCount('hiragana');
        _katakanaDue = srs.dueCount('katakana');
      });
    }
  }

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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_back_ios_rounded,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text('back'.tr,
                              style: const TextStyle(
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
                    child: Text(
                      'n5_beginner'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'jp_writing_systems'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'master_kana_desc'.tr,
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
                      title: 'hiragana'.tr,
                      subtitle: 'ひらがな',
                      description: 'hiragana_desc'.tr,
                      icon: Icons.brush_rounded,
                      characterCount: 46,
                      dueCount: _hiraganaDue,
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
                      onReviewTap: () => Get.to(
                        () => KanaReviewScreen(
                          title: 'Hiragana',
                          kanaList: KanaData.hiragana,
                          kanaType: 'hiragana',
                        ),
                        transition: Transition.rightToLeftWithFade,
                        duration: const Duration(milliseconds: 300),
                      )?.then((_) => _loadDueCounts()),
                      onProgressTap: () => Get.to(
                        () => KanaProgressScreen(
                          title: 'Hiragana',
                          kanaList: KanaData.hiragana,
                          kanaType: 'hiragana',
                        ),
                        transition: Transition.rightToLeftWithFade,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── KATAKANA MODULE ─────────────────────────
                    _ModuleSection(
                      title: 'katakana'.tr,
                      subtitle: 'カタカナ',
                      description: 'katakana_desc'.tr,
                      icon: Icons.translate_rounded,
                      characterCount: 46,
                      dueCount: _katakanaDue,
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
                      onReviewTap: () => Get.to(
                        () => KanaReviewScreen(
                          title: 'Katakana',
                          kanaList: KanaData.katakana,
                          kanaType: 'katakana',
                        ),
                        transition: Transition.rightToLeftWithFade,
                        duration: const Duration(milliseconds: 300),
                      )?.then((_) => _loadDueCounts()),
                      onProgressTap: () => Get.to(
                        () => KanaProgressScreen(
                          title: 'Katakana',
                          kanaList: KanaData.katakana,
                          kanaType: 'katakana',
                        ),
                        transition: Transition.rightToLeftWithFade,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── SRS REVIEW CARD ─────────────────────────
                    _SrsReviewCard(),

                    const SizedBox(height: 20),

                    // ── TIPS CARD ───────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFE082)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.tips_and_updates_rounded,
                                  color: Color(0xFFFFA000), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'learning_tips'.tr,
                                style: const TextStyle(
                                  color: Color(0xFFF57F17),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _TipItem(text: 'tip_start_hiragana'.tr),
                          const SizedBox(height: 6),
                          _TipItem(text: 'tip_mnemonics'.tr),
                          const SizedBox(height: 6),
                          _TipItem(text: 'tip_stroke_order'.tr),
                          const SizedBox(height: 6),
                          _TipItem(text: 'tip_drag_drop'.tr),
                          const SizedBox(height: 6),
                          _TipItem(text: 'tip_srs'.tr),
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
  final int dueCount;
  final VoidCallback onChartTap;
  final VoidCallback onGameTap;
  final VoidCallback onReviewTap;
  final VoidCallback onProgressTap;

  const _ModuleSection({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.characterCount,
    this.dueCount = 0,
    required this.onChartTap,
    required this.onGameTap,
    required this.onReviewTap,
    required this.onProgressTap,
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
                      'characters_count'.trParams({'count': '$characterCount'}),
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
                  label: 'chart'.tr,
                  onTap: onChartTap,
                  filled: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: Icons.games_rounded,
                  label: 'drag_drop'.tr,
                  onTap: onGameTap,
                  filled: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.style_rounded,
                  label: 'review'.tr,
                  onTap: onReviewTap,
                  filled: true,
                  badge: dueCount > 0 ? '$dueCount' : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: Icons.insights_rounded,
                  label: 'progress'.tr,
                  onTap: onProgressTap,
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
  final String? badge;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.filled,
    this.badge,
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
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: filled
                      ? Colors.white
                      : _sakuraDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    color: filled ? _sakuraDark : Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── SRS Review card ─────────────────────────────────────────────────────────
class _SrsReviewCard extends StatelessWidget {
  static const _sakura = Color(KanaData.sakuraPink);
  static const _sakuraDark = Color(KanaData.sakuraPinkDark);
  static const _sakuraLight = Color(KanaData.sakuraPinkLight);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SrsController>();

    return Obx(() {
      final due = ctrl.dueCount.value;
      final total = ctrl.totalCount.value;

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7B1FA2), Color(0xFFAD1457)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B1FA2).withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.style_rounded,
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
                        'flashcard_review'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'srs_desc'.tr,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stats row
            Row(
              children: [
                _SrsStat(
                  value: '$due',
                  label: 'due_today'.tr,
                  highlight: due > 0,
                ),
                const SizedBox(width: 16),
                _SrsStat(value: '$total', label: 'total_cards'.tr),
              ],
            ),
            const SizedBox(height: 16),

            // Start button
            GestureDetector(
              onTap: due == 0
                  ? null
                  : () {
                      ctrl.startSession();
                      Get.to(
                        () => const KanaSrsReviewScreen(),
                        transition: Transition.rightToLeftWithFade,
                        duration: const Duration(milliseconds: 300),
                      );
                    },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: due > 0
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      due > 0
                          ? Icons.play_arrow_rounded
                          : Icons.check_circle_rounded,
                      color: due > 0
                          ? const Color(0xFF7B1FA2)
                          : Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      due > 0
                          ? 'start_review_count'.trParams({'count': '$due'})
                          : 'all_caught_up'.tr,
                      style: TextStyle(
                        color: due > 0
                            ? const Color(0xFF7B1FA2)
                            : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _SrsStat extends StatelessWidget {
  final String value;
  final String label;
  final bool highlight;

  const _SrsStat({
    required this.value,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          value,
          style: TextStyle(
            color: highlight ? const Color(0xFFFFCC02) : Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
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
