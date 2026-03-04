import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/models/kana.dart';

/// Kana Drag-and-Drop game.
/// Users drag romaji tiles onto a shuffled 4x4 grid of kana characters.
/// Green flash for correct, red shake for incorrect.
/// Includes timer + score counter.
class KanaDragDropScreen extends StatefulWidget {
  final String title;
  final List<Kana> kanaList;

  const KanaDragDropScreen({
    super.key,
    required this.title,
    required this.kanaList,
  });

  @override
  State<KanaDragDropScreen> createState() => _KanaDragDropScreenState();
}

class _KanaDragDropScreenState extends State<KanaDragDropScreen>
    with TickerProviderStateMixin {
  static const _gridSize = 16; // 4x4

  // ── Sakura theme ──────────────────────────────────────────────
  static const _sakura = Color(KanaData.sakuraPink);
  static const _sakuraLight = Color(KanaData.sakuraPinkLight);
  static const _sakuraDark = Color(KanaData.sakuraPinkDark);
  static const _correctGreen = Color(0xFF4CAF50);
  static const _incorrectRed = Color(0xFFF44336);

  // ── Game state ────────────────────────────────────────────────
  late List<Kana> _gridKana; // 16 kana on the grid
  late List<Kana> _romajiTiles; // shuffled romaji tiles to drag
  final Map<int, bool> _matched = {}; // gridIndex -> matched
  final Map<int, _FeedbackState> _feedback = {}; // gridIndex -> feedback
  int _score = 0;
  int _attempts = 0;
  int _round = 0;
  bool _gameOver = false;

  // ── Timer ─────────────────────────────────────────────────────
  int _elapsedSeconds = 0;
  Timer? _timer;

  // ── Shake animation for incorrect ─────────────────────────────
  final Map<int, AnimationController> _shakeControllers = {};

  @override
  void initState() {
    super.initState();
    _startNewRound();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _shakeControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_gameOver && mounted) {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  String get _formattedTime {
    final m = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _startNewRound() {
    final rng = Random();
    // Pick 16 random kana (or all if list < 16)
    final available = List<Kana>.from(widget.kanaList)..shuffle(rng);
    _gridKana = available.take(_gridSize).toList();
    _romajiTiles = List<Kana>.from(_gridKana)..shuffle(rng);
    _matched.clear();
    _feedback.clear();
    _round++;
  }

  void _onCorrectMatch(int gridIndex) {
    setState(() {
      _matched[gridIndex] = true;
      _feedback[gridIndex] = _FeedbackState.correct;
      _score++;
      _attempts++;
      // Remove matched romaji tile
      final kana = _gridKana[gridIndex];
      _romajiTiles.removeWhere((k) => k.romaji == kana.romaji);
    });

    // Clear feedback after animation
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _feedback.remove(gridIndex));
    });

    // Check if round is complete
    if (_matched.length == _gridKana.length) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        if (_round * _gridSize >= widget.kanaList.length) {
          setState(() => _gameOver = true);
        } else {
          setState(() => _startNewRound());
        }
      });
    }
  }

  void _onIncorrectMatch(int gridIndex) {
    setState(() {
      _feedback[gridIndex] = _FeedbackState.incorrect;
      _attempts++;
    });

    // Shake animation
    if (!_shakeControllers.containsKey(gridIndex)) {
      _shakeControllers[gridIndex] = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
    }
    _shakeControllers[gridIndex]!.forward(from: 0);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _feedback.remove(gridIndex));
    });
  }

  void _restartGame() {
    setState(() {
      _score = 0;
      _attempts = 0;
      _elapsedSeconds = 0;
      _round = 0;
      _gameOver = false;
      _startNewRound();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _sakuraLight,
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────
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
                      Column(
                        children: [
                          Text(
                            'Kana Drag & Drop',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            widget.title,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const SizedBox(width: 70),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // ── Score + Timer row ──────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatChip(
                        icon: Icons.emoji_events_rounded,
                        label: 'Score',
                        value: '$_score',
                      ),
                      const SizedBox(width: 16),
                      _StatChip(
                        icon: Icons.timer_rounded,
                        label: 'Time',
                        value: _formattedTime,
                      ),
                      const SizedBox(width: 16),
                      _StatChip(
                        icon: Icons.percent_rounded,
                        label: 'Accuracy',
                        value: _attempts == 0
                            ? '—'
                            : '${(_score * 100 / _attempts).round()}%',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── GAME CONTENT ────────────────────────────────
            Expanded(
              child: _gameOver ? _buildGameOver() : _buildGame(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGame() {
    return Column(
      children: [
        const SizedBox(height: 12),

        // ── 4x4 Kana grid (drop targets) ────────────────
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: _gridKana.length,
              itemBuilder: (context, i) => _buildDropTarget(i),
            ),
          ),
        ),

        // ── Divider label ───────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const SizedBox(width: 24),
              Expanded(
                child: Container(height: 1, color: _sakura.withValues(alpha: 0.3)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'Drag romaji below onto the matching kana above',
                  style: TextStyle(
                    color: _sakuraDark.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Container(height: 1, color: _sakura.withValues(alpha: 0.3)),
              ),
              const SizedBox(width: 24),
            ],
          ),
        ),

        // ── Draggable romaji tiles ──────────────────────
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _romajiTiles.map((kana) => _buildDraggable(kana)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropTarget(int gridIndex) {
    final kana = _gridKana[gridIndex];
    final isMatched = _matched[gridIndex] == true;
    final fb = _feedback[gridIndex];

    Color bgColor = Colors.white;
    Color borderColor = const Color(0xFFE0E0E0);

    if (isMatched) {
      bgColor = _correctGreen.withValues(alpha: 0.1);
      borderColor = _correctGreen;
    } else if (fb == _FeedbackState.correct) {
      bgColor = _correctGreen.withValues(alpha: 0.25);
      borderColor = _correctGreen;
    } else if (fb == _FeedbackState.incorrect) {
      bgColor = _incorrectRed.withValues(alpha: 0.15);
      borderColor = _incorrectRed;
    }

    Widget card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: isMatched ? 2 : 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              kana.character,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: isMatched
                    ? _correctGreen
                    : const Color(0xFF1A1A2E),
              ),
            ),
            if (isMatched) ...[
              const SizedBox(height: 2),
              Text(
                kana.romaji,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _correctGreen,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    // Shake animation for incorrect
    if (fb == _FeedbackState.incorrect &&
        _shakeControllers.containsKey(gridIndex)) {
      card = AnimatedBuilder(
        animation: _shakeControllers[gridIndex]!,
        builder: (context, child) {
          final value = _shakeControllers[gridIndex]!.value;
          final offset = sin(value * pi * 4) * 6;
          return Transform.translate(
            offset: Offset(offset, 0),
            child: child,
          );
        },
        child: card,
      );
    }

    if (isMatched) return card;

    return DragTarget<Kana>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) {
        final draggedKana = details.data;
        if (draggedKana.romaji == kana.romaji) {
          _onCorrectMatch(gridIndex);
        } else {
          _onIncorrectMatch(gridIndex);
        }
      },
      builder: (context, candidates, rejected) {
        if (candidates.isNotEmpty) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: _sakura.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _sakura, width: 2),
            ),
            child: Center(
              child: Text(
                kana.character,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
          );
        }
        return card;
      },
    );
  }

  Widget _buildDraggable(Kana kana) {
    return Draggable<Kana>(
      data: kana,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: _sakura,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _sakura.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            kana.romaji.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
      childWhenDragging: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Text(
          kana.romaji.toUpperCase(),
          style: TextStyle(
            color: Colors.grey.withValues(alpha: 0.5),
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _sakura.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: _sakura.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          kana.romaji.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF1A1A2E),
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildGameOver() {
    final accuracy = _attempts > 0 ? (_score * 100 / _attempts).round() : 0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _sakura.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration_rounded,
                color: _sakura,
                size: 42,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Great Job!',
              style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You matched all characters!',
              style: TextStyle(
                color: const Color(0xFF6B7280),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            // ── Stats ───────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ResultStat(label: 'Score', value: '$_score'),
                const SizedBox(width: 24),
                _ResultStat(label: 'Time', value: _formattedTime),
                const SizedBox(width: 24),
                _ResultStat(label: 'Accuracy', value: '$accuracy%'),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _restartGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _sakura,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Play Again',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Back to Module',
                style: TextStyle(
                  color: _sakuraDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Feedback state enum ─────────────────────────────────────────────
enum _FeedbackState { correct, incorrect }

// ── Stat chip widget (header) ───────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Result stat widget (game over) ──────────────────────────────────
class _ResultStat extends StatelessWidget {
  final String label;
  final String value;

  const _ResultStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1A1A2E),
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
