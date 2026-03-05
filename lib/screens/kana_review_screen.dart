import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/models/kana.dart';
import 'package:ez_trainz/models/kana_progress.dart';
import 'package:ez_trainz/services/srs_service.dart';

/// Spaced Repetition flashcard review screen.
/// Shows a kana → user taps to reveal romaji → rates difficulty.
/// SM-2 algorithm schedules next review based on rating.
class KanaReviewScreen extends StatefulWidget {
  final String title;
  final List<Kana> kanaList;
  final String kanaType; // 'hiragana' or 'katakana'

  const KanaReviewScreen({
    super.key,
    required this.title,
    required this.kanaList,
    required this.kanaType,
  });

  @override
  State<KanaReviewScreen> createState() => _KanaReviewScreenState();
}

class _KanaReviewScreenState extends State<KanaReviewScreen>
    with TickerProviderStateMixin {
  // ── Sakura theme ──────────────────────────────────────────────
  static const _sakura = Color(KanaData.sakuraPink);
  static const _sakuraLight = Color(KanaData.sakuraPinkLight);
  static const _sakuraDark = Color(KanaData.sakuraPinkDark);

  // ── State ─────────────────────────────────────────────────────
  SrsService? _srs;
  List<KanaProgress> _dueCards = [];
  int _currentIndex = 0;
  bool _revealed = false;
  int _sessionCorrect = 0;
  int _sessionTotal = 0;
  bool _sessionComplete = false;

  // ── Flip animation ────────────────────────────────────────────
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;

  // ── Slide-out animation ───────────────────────────────────────
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  // ── TTS ───────────────────────────────────────────────────────
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOutBack),
    );

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 0),
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeInBack));

    _initTts();
    _loadDueCards();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('ja-JP');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
  }

  Future<void> _loadDueCards() async {
    final srs = await SrsService.getInstance();
    final due = srs.getDueCards(widget.kanaType);

    // If nothing is due, offer all unstudied cards (new cards)
    List<KanaProgress> cards;
    if (due.isEmpty) {
      final all = srs.getAllProgress(widget.kanaType);
      final unstudied = all.where((p) => p.totalAttempts == 0).toList();
      if (unstudied.isEmpty) {
        cards = all..shuffle(Random());
        cards = cards.take(10).toList();
      } else {
        cards = unstudied.take(10).toList();
      }
    } else {
      cards = due;
    }

    setState(() {
      _srs = srs;
      _dueCards = cards;
      _currentIndex = 0;
    });
  }

  @override
  void dispose() {
    _tts.stop();
    _flipCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  Kana? get _currentKana {
    if (_dueCards.isEmpty || _currentIndex >= _dueCards.length) return null;
    final progress = _dueCards[_currentIndex];
    return widget.kanaList.firstWhereOrNull(
      (k) => k.character == progress.character,
    );
  }

  void _revealCard() {
    if (_revealed) return;
    setState(() => _revealed = true);
    _flipCtrl.forward();
    final kana = _currentKana;
    if (kana != null) _tts.speak(kana.character);
  }

  Future<void> _rateAndAdvance(int quality) async {
    if (_srs == null) return;
    final progress = _dueCards[_currentIndex];
    await _srs!.rateCard(progress.character, progress.type, quality);

    _sessionTotal++;
    if (quality >= 3) _sessionCorrect++;

    // Slide out, then show next card
    await _slideCtrl.forward();

    if (_currentIndex + 1 >= _dueCards.length) {
      setState(() => _sessionComplete = true);
    } else {
      setState(() {
        _currentIndex++;
        _revealed = false;
      });
      _flipCtrl.reset();
      _slideCtrl.reset();
    }
  }

  void _restartSession() {
    setState(() {
      _sessionComplete = false;
      _sessionCorrect = 0;
      _sessionTotal = 0;
    });
    _flipCtrl.reset();
    _slideCtrl.reset();
    _loadDueCards();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _sakuraLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _srs == null
                  ? const Center(child: CircularProgressIndicator(color: _sakura))
                  : _sessionComplete
                      ? _buildSessionComplete()
                      : _dueCards.isEmpty
                          ? _buildEmptyState()
                          : _buildFlashcard(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final remaining = _dueCards.length - _currentIndex;
    return Container(
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white38, width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 14),
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
                  const Text('SRS Review',
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
          if (!_sessionComplete && _dueCards.isNotEmpty) ...[
            const SizedBox(height: 12),
            // Progress bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _dueCards.isEmpty
                          ? 0
                          : _currentIndex / _dueCards.length,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$remaining left',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFlashcard() {
    final kana = _currentKana;
    if (kana == null) return _buildEmptyState();
    final progress = _dueCards[_currentIndex];

    return SlideTransition(
      position: _slideAnim,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(flex: 1),

            // ── Flashcard ─────────────────────────────────────────
            GestureDetector(
              onTap: _revealCard,
              child: AnimatedBuilder(
                animation: _flipAnim,
                builder: (context, child) {
                  final angle = _flipAnim.value * pi;
                  final showBack = angle > pi / 2;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    child: showBack
                        ? Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(pi),
                            child: _buildCardBack(kana, progress),
                          )
                        : _buildCardFront(kana),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // ── Tap hint or rating buttons ─────────────────────────
            if (!_revealed)
              Text(
                'Tap the card to reveal',
                style: TextStyle(
                  color: _sakuraDark.withValues(alpha: 0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              _buildRatingButtons(),

            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFront(Kana kana) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _sakura.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _sakura.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'What sound does this make?',
              style: TextStyle(
                color: _sakuraDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            kana.character,
            style: const TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          Icon(Icons.touch_app_rounded,
              color: _sakura.withValues(alpha: 0.4), size: 28),
        ],
      ),
    );
  }

  Widget _buildCardBack(Kana kana, KanaProgress progress) {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, _sakuraLight],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _sakura.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            kana.character,
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w700,
              color: _sakuraDark,
            ),
          ),
          const SizedBox(height: 8),
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
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lightbulb_outline_rounded,
                    color: Color(0xFFFFA000), size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    kana.mnemonic,
                    style: const TextStyle(
                      color: Color(0xFF5D4037),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Speak button
          GestureDetector(
            onTap: () => _tts.speak(kana.character),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _sakura.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.volume_up_rounded, color: _sakura, size: 18),
                  const SizedBox(width: 6),
                  Text('Listen again',
                      style: TextStyle(
                        color: _sakuraDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingButtons() {
    return Column(
      children: [
        Text('How well did you know it?',
            style: TextStyle(
              color: _sakuraDark,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            )),
        const SizedBox(height: 14),
        Row(
          children: [
            _RatingButton(
              label: 'Again',
              subtitle: '<1 min',
              color: const Color(0xFFF44336),
              icon: Icons.replay_rounded,
              onTap: () => _rateAndAdvance(1),
            ),
            const SizedBox(width: 8),
            _RatingButton(
              label: 'Hard',
              subtitle: '1 day',
              color: const Color(0xFFFF9800),
              icon: Icons.sentiment_neutral_rounded,
              onTap: () => _rateAndAdvance(3),
            ),
            const SizedBox(width: 8),
            _RatingButton(
              label: 'Good',
              subtitle: '3 days',
              color: const Color(0xFF4CAF50),
              icon: Icons.sentiment_satisfied_rounded,
              onTap: () => _rateAndAdvance(4),
            ),
            const SizedBox(width: 8),
            _RatingButton(
              label: 'Easy',
              subtitle: '7 days',
              color: const Color(0xFF2196F3),
              icon: Icons.sentiment_very_satisfied_rounded,
              onTap: () => _rateAndAdvance(5),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
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
                color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline_rounded,
                  color: Color(0xFF4CAF50), size: 42),
            ),
            const SizedBox(height: 24),
            const Text('All caught up!',
                style: TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                )),
            const SizedBox(height: 8),
            Text(
              'No cards are due for review right now.\nCome back later to keep your memory fresh!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF6B7280),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _sakura,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Back to Module',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionComplete() {
    final accuracy =
        _sessionTotal > 0 ? (_sessionCorrect * 100 / _sessionTotal).round() : 0;
    final srs = _srs!;
    final studied = srs.studiedCount(widget.kanaType);
    final total = widget.kanaList.length;
    final masteryPct = (srs.averageMastery(widget.kanaType) * 100).round();

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
              child: const Icon(Icons.auto_awesome_rounded,
                  color: _sakura, size: 42),
            ),
            const SizedBox(height: 24),
            const Text('Session Complete!',
                style: TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                )),
            const SizedBox(height: 8),
            Text(
              'Great work! Keep reviewing daily.',
              style: TextStyle(color: const Color(0xFF6B7280), fontSize: 14),
            ),
            const SizedBox(height: 28),
            // ── Stats row ─────────────────────────────────
            Container(
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SessionStat(
                      value: '$_sessionTotal', label: 'Reviewed', color: _sakura),
                  Container(width: 1, height: 40, color: const Color(0xFFE0E0E0)),
                  _SessionStat(
                      value: '$accuracy%',
                      label: 'Accuracy',
                      color: const Color(0xFF4CAF50)),
                  Container(width: 1, height: 40, color: const Color(0xFFE0E0E0)),
                  _SessionStat(
                      value: '$studied/$total',
                      label: 'Studied',
                      color: const Color(0xFF2196F3)),
                  Container(width: 1, height: 40, color: const Color(0xFFE0E0E0)),
                  _SessionStat(
                      value: '$masteryPct%',
                      label: 'Mastery',
                      color: const Color(0xFFFF9800)),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _restartSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _sakura,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Review More',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Back to Module',
                  style: TextStyle(
                    color: _sakuraDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Rating button widget ───────────────────────────────────────────────
class _RatingButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _RatingButton({
    required this.label,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  )),
              Text(subtitle,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Session stat widget ─────────────────────────────────────────────────
class _SessionStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _SessionStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
              color: color,
              fontSize: 20,
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
