import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/models/kana.dart';

/// Interactive kana grid chart. Shows 46 base characters in a grid.
/// Tapping a character shows its romaji, mnemonic, and stroke order animation.
class KanaChartScreen extends StatefulWidget {
  final String title; // 'Hiragana' or 'Katakana'
  final List<Kana> kanaList;

  const KanaChartScreen({
    super.key,
    required this.title,
    required this.kanaList,
  });

  @override
  State<KanaChartScreen> createState() => _KanaChartScreenState();
}

class _KanaChartScreenState extends State<KanaChartScreen> {
  bool _showDakuten = false;
  Kana? _selectedKana;

  List<Kana> get _displayList =>
      _showDakuten ? KanaData.getDakutenList(widget.kanaList) : widget.kanaList;

  // ── Sakura Pink theme ──────────────────────────────────────────
  static const _sakura = Color(KanaData.sakuraPink);
  static const _sakuraLight = Color(KanaData.sakuraPinkLight);
  static const _sakuraDark = Color(KanaData.sakuraPinkDark);

  void _onTapKana(Kana kana) {
    setState(() => _selectedKana = kana);
    _showDetailSheet(kana);
  }

  void _showDetailSheet(Kana kana) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _KanaDetailSheet(kana: kana),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _displayList;

    return Scaffold(
      backgroundColor: _sakuraLight,
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
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
                            border:
                                Border.all(color: Colors.white38, width: 1),
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
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 70), // balance the back button
                    ],
                  ),
                  const SizedBox(height: 12),
                  // ── Dakuten toggle ─────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Dakuten (゛)',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: _showDakuten,
                        onChanged: (v) => setState(() {
                          _showDakuten = v;
                          _selectedKana = null;
                        }),
                        activeColor: Colors.white,
                        activeTrackColor: _sakuraDark,
                        inactiveThumbColor: Colors.white70,
                        inactiveTrackColor:
                            Colors.white.withValues(alpha: 0.3),
                      ),
                      Text(
                        _showDakuten ? 'ON' : 'OFF',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _showDakuten
                        ? 'G, Z, D, B, P variations'
                        : 'Tap any character to learn more',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // ── GRID ────────────────────────────────────────────
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.85,
                ),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final kana = list[i];
                  final isSelected = _selectedKana == kana;

                  return GestureDetector(
                    onTap: () => _onTapKana(kana),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _sakura.withValues(alpha: 0.15)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? _sakura : const Color(0xFFE0E0E0),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            kana.character,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? _sakuraDark
                                  : const Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            kana.romaji,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? _sakura
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Detail bottom sheet with mnemonic and stroke order ────────────────
class _KanaDetailSheet extends StatefulWidget {
  final Kana kana;
  const _KanaDetailSheet({required this.kana});

  @override
  State<_KanaDetailSheet> createState() => _KanaDetailSheetState();
}

class _KanaDetailSheetState extends State<_KanaDetailSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _strokeCtrl;
  late Animation<double> _strokeProgress;
  final FlutterTts _tts = FlutterTts();

  static const _sakura = Color(KanaData.sakuraPink);
  static const _sakuraDark = Color(KanaData.sakuraPinkDark);

  @override
  void initState() {
    super.initState();
    _strokeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _strokeProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _strokeCtrl, curve: Curves.easeInOut),
    );
    // Auto-play stroke animation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _strokeCtrl.forward();
    });
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('ja-JP');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await _tts.speak(text);
  }

  @override
  void dispose() {
    _tts.stop();
    _strokeCtrl.dispose();
    super.dispose();
  }

  void _replayStroke() {
    _strokeCtrl.reset();
    _strokeCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final kana = widget.kana;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ────────────────────────────────────
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // ── Character + stroke animation ───────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Big character
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _sakura.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _sakura.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    kana.character,
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Stroke order animation box
              GestureDetector(
                onTap: _replayStroke,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: AnimatedBuilder(
                    animation: _strokeProgress,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _StrokeOrderPainter(
                          character: kana.character,
                          progress: _strokeProgress.value,
                          color: _sakuraDark,
                        ),
                        child: _strokeProgress.value >= 1.0
                            ? const Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Icon(Icons.replay_rounded,
                                      color: Color(0xFF9E9E9E), size: 16),
                                ),
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Romaji ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: _sakura,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              kana.romaji.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Mnemonic hint ──────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFE082)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded,
                    color: Color(0xFFFFA000), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Memory Hint',
                        style: TextStyle(
                          color: Color(0xFFF57F17),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        kana.mnemonic,
                        style: const TextStyle(
                          color: Color(0xFF5D4037),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Audio button (TTS) ──────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _speak(kana.character),
              icon: const Icon(Icons.volume_up_rounded),
              label: Text('Listen to "${kana.romaji}"'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _sakura,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stroke order painter — simulates character drawing ───────────────
class _StrokeOrderPainter extends CustomPainter {
  final String character;
  final double progress;
  final Color color;

  _StrokeOrderPainter({
    required this.character,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final textPainter = TextPainter(
      text: TextSpan(
        text: character,
        style: TextStyle(
          fontSize: 52,
          fontWeight: FontWeight.w500,
          foreground: Paint()
            ..color = color.withValues(alpha: progress.clamp(0.0, 1.0))
            ..style = PaintingStyle.fill,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    // Clip to simulate progressive reveal
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height * progress));
    textPainter.paint(canvas, offset);
    canvas.restore();

    // Draw guide lines
    final guidePaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 0.5;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      guidePaint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      guidePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _StrokeOrderPainter old) =>
      old.progress != progress;
}
