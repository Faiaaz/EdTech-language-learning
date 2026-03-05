import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/models/kana.dart';
import 'package:ez_trainz/models/kana_progress.dart';
import 'package:ez_trainz/services/srs_service.dart';

/// Mastery heatmap showing per-character progress.
/// Each cell is colored from grey (unseen) → red (weak) → yellow → green (mastered).
class KanaProgressScreen extends StatefulWidget {
  final String title;
  final List<Kana> kanaList;
  final String kanaType;

  const KanaProgressScreen({
    super.key,
    required this.title,
    required this.kanaList,
    required this.kanaType,
  });

  @override
  State<KanaProgressScreen> createState() => _KanaProgressScreenState();
}

class _KanaProgressScreenState extends State<KanaProgressScreen> {
  static const _sakura = Color(KanaData.sakuraPink);
  static const _sakuraLight = Color(KanaData.sakuraPinkLight);
  static const _sakuraDark = Color(KanaData.sakuraPinkDark);

  SrsService? _srs;
  List<KanaProgress> _progress = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final srs = await SrsService.getInstance();
    setState(() {
      _srs = srs;
      _progress = srs.getAllProgress(widget.kanaType);
    });
  }

  Color _masteryColor(double mastery) {
    if (mastery <= 0) return const Color(0xFFE0E0E0);
    if (mastery < 0.25) return const Color(0xFFEF5350);
    if (mastery < 0.5) return const Color(0xFFFF9800);
    if (mastery < 0.75) return const Color(0xFFFFEB3B);
    return const Color(0xFF4CAF50);
  }

  Color _masteryTextColor(double mastery) {
    if (mastery <= 0) return const Color(0xFF9E9E9E);
    if (mastery < 0.25) return Colors.white;
    if (mastery < 0.5) return Colors.white;
    if (mastery < 0.75) return const Color(0xFF5D4037);
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final studied = _progress.where((p) => p.totalAttempts > 0).length;
    final total = widget.kanaList.length;
    final avgMastery = _srs != null
        ? (_srs!.averageMastery(widget.kanaType) * 100).round()
        : 0;
    final dueCount = _srs?.dueCount(widget.kanaType) ?? 0;

    return Scaffold(
      backgroundColor: _sakuraLight,
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_sakura, _sakuraDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Row(
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
                      const Spacer(),
                      Column(
                        children: [
                          const Text('Progress',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              )),
                          Text(widget.title,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              )),
                        ],
                      ),
                      const Spacer(),
                      const SizedBox(width: 70),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: _srs == null
                  ? const Center(
                      child: CircularProgressIndicator(color: _sakura))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Stats cards ───────────────────────────
                          Row(
                            children: [
                              _StatCard(
                                icon: Icons.school_rounded,
                                label: 'Studied',
                                value: '$studied / $total',
                                color: const Color(0xFF2196F3),
                              ),
                              const SizedBox(width: 10),
                              _StatCard(
                                icon: Icons.trending_up_rounded,
                                label: 'Mastery',
                                value: '$avgMastery%',
                                color: const Color(0xFF4CAF50),
                              ),
                              const SizedBox(width: 10),
                              _StatCard(
                                icon: Icons.schedule_rounded,
                                label: 'Due Now',
                                value: '$dueCount',
                                color: dueCount > 0
                                    ? const Color(0xFFFF9800)
                                    : const Color(0xFF9E9E9E),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // ── Legend ─────────────────────────────────
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _LegendItem(
                                    color: const Color(0xFFE0E0E0),
                                    label: 'New'),
                                _LegendItem(
                                    color: const Color(0xFFEF5350),
                                    label: 'Weak'),
                                _LegendItem(
                                    color: const Color(0xFFFF9800),
                                    label: 'Learning'),
                                _LegendItem(
                                    color: const Color(0xFFFFEB3B),
                                    label: 'Good'),
                                _LegendItem(
                                    color: const Color(0xFF4CAF50),
                                    label: 'Mastered'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── Heatmap grid ───────────────────────────
                          const Text('Character Mastery',
                              style: TextStyle(
                                color: Color(0xFF1A1A2E),
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              )),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: widget.kanaList.length,
                            itemBuilder: (context, i) {
                              final kana = widget.kanaList[i];
                              final prog = _progress.firstWhere(
                                (p) => p.character == kana.character,
                                orElse: () => KanaProgress(
                                  character: kana.character,
                                  type: widget.kanaType,
                                ),
                              );
                              final m = prog.mastery;
                              final bgColor = _masteryColor(m);
                              final textColor = _masteryTextColor(m);

                              return GestureDetector(
                                onTap: () => _showDetail(kana, prog),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            bgColor.withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(kana.character,
                                          style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w700,
                                            color: textColor,
                                          )),
                                      const SizedBox(height: 2),
                                      Text(kana.romaji,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: textColor
                                                .withValues(alpha: 0.8),
                                          )),
                                      if (prog.totalAttempts > 0) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          '${(m * 100).round()}%',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: textColor
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(Kana kana, KanaProgress prog) {
    final acc = prog.totalAttempts > 0
        ? (prog.totalCorrect * 100 / prog.totalAttempts).round()
        : 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _masteryColor(prog.mastery),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(kana.character,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: _masteryTextColor(prog.mastery),
                        )),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kana.romaji.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A2E),
                        )),
                    Text(kana.mnemonic,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        )),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _sakuraLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _DetailStat(label: 'Mastery', value: '${(prog.mastery * 100).round()}%'),
                  _DetailStat(label: 'Accuracy', value: '$acc%'),
                  _DetailStat(label: 'Reviews', value: '${prog.totalAttempts}'),
                  _DetailStat(label: 'Streak', value: '${prog.repetitions}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule_rounded,
                    color: const Color(0xFF6B7280), size: 14),
                const SizedBox(width: 6),
                Text(
                  prog.isDue
                      ? 'Due for review now'
                      : 'Next review: ${_formatDate(prog.nextReview)}',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Tomorrow';
    if (diff.inDays < 7) return 'In ${diff.inDays} days';
    return '${date.month}/${date.day}';
  }
}

// ── Helper widgets ───────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                )),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                )),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            )),
      ],
    );
  }
}

class _DetailStat extends StatelessWidget {
  final String label;
  final String value;

  const _DetailStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
              color: Color(0xFF1A1A2E),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            )),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            )),
      ],
    );
  }
}
