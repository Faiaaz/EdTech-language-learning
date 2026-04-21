import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/models/hiragana_lesson_data.dart';

/// First 10 kana (あ–こ): vowels + K-row — matches [hiragana_hunt.html].
final List<HiraganaChar> _huntPool =
    HiraganaLesson1Data.kanaList.take(10).toList();

const _gridSize = 12;
const _timeLimit = 120;

/// Hiragana Hunt — tap all tiles matching the target romaji on a 4×3 grid.
class HiraganaHuntScreen extends StatefulWidget {
  const HiraganaHuntScreen({super.key});

  @override
  State<HiraganaHuntScreen> createState() => _HiraganaHuntScreenState();
}

class _HiraganaHuntScreenState extends State<HiraganaHuntScreen> {
  final _rng = math.Random();

  bool _intro = true;
  bool _ended = false;
  bool _roundBusy = false;

  int _timeLeft = _timeLimit;
  int _score = 0;
  int _streak = 0;
  int _roundCount = 0;
  int _correctTotal = 0;
  int _wrongTotal = 0;

  HiraganaChar? _target;
  int _targetTotal = 0;
  int _foundCount = 0;
  List<_HuntTile> _tiles = [];
  bool _hintShowsKana = false;

  String _message = '';

  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _hapticTap() => HapticFeedback.selectionClick();
  void _hapticLight() => HapticFeedback.lightImpact();
  void _hapticOk() => HapticFeedback.mediumImpact();
  void _hapticWrong() => HapticFeedback.heavyImpact();

  void _startGame() {
    _hapticOk();
    _timer?.cancel();
    setState(() {
      _intro = false;
      _ended = false;
      _timeLeft = _timeLimit;
      _score = 0;
      _streak = 0;
      _roundCount = 0;
      _correctTotal = 0;
      _wrongTotal = 0;
      _hintShowsKana = false;
      _message = 'hiragana_hunt_play_hint'.tr;
    });
    _nextRound();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) _endGame();
      });
    });
  }

  void _endGame() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _ended = true;
      _intro = false;
    });
    HapticFeedback.heavyImpact();
  }

  void _nextRound() {
    _hintShowsKana = false;
    _target = _huntPool[_rng.nextInt(_huntPool.length)];
    final targetInstances = 2 + _rng.nextInt(4);
    final tiles = <HiraganaChar>[];
    for (var i = 0; i < targetInstances; i++) {
      tiles.add(_target!);
    }
    final distractors = _huntPool.where((h) => h.kana != _target!.kana).toList();
    while (tiles.length < _gridSize) {
      tiles.add(distractors[_rng.nextInt(distractors.length)]);
    }
    tiles.shuffle(_rng);

    setState(() {
      _targetTotal = targetInstances;
      _foundCount = 0;
      _roundBusy = false;
      _tiles = [
        for (var i = 0; i < tiles.length; i++)
          _HuntTile(
            data: tiles[i],
            style: _randomTileStyle(i),
            transform: _randomTransform(),
          ),
      ];
      _message = 'hiragana_hunt_play_hint'.tr;
    });
  }

  TextStyle _randomTileStyle(int seed) {
    final variants = [
      const TextStyle(
          fontSize: 40, fontWeight: FontWeight.w800, height: 1),
      const TextStyle(
          fontSize: 36, fontWeight: FontWeight.w400, height: 1),
      TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.italic,
          height: 1,
          letterSpacing: seed.isEven ? 0 : -1.5,
        ),
      const TextStyle(
          fontSize: 38, fontWeight: FontWeight.w900, height: 1.1),
      TextStyle(
          fontSize: 40,
          fontWeight: seed % 3 == 0 ? FontWeight.w300 : FontWeight.w600,
          height: 1,
        ),
    ];
    return variants[seed % variants.length];
  }

  Matrix4 _randomTransform() {
    final t = _rng.nextInt(8);
    switch (t) {
      case 0:
        return Matrix4.identity();
      case 1:
        return Matrix4.rotationZ(-0.14);
      case 2:
        return Matrix4.rotationZ(0.14);
      case 3:
        return Matrix4.rotationZ(0.08) * Matrix4.diagonal3Values(1.08, 0.92, 1.0);
      case 4:
        return Matrix4.rotationZ(-0.06) * Matrix4.diagonal3Values(0.92, 1.08, 1.0);
      case 5:
        return Matrix4.skewX(-0.12);
      case 6:
        return Matrix4.skewY(0.08);
      default:
        return Matrix4.diagonal3Values(1.05, 0.95, 1.0);
    }
  }

  Future<void> _onTileTap(int index) async {
    if (_roundBusy || _target == null) return;
    final tile = _tiles[index];
    if (tile.used) return;

    final isCorrect = tile.data.kana == _target!.kana;

    if (isCorrect) {
      _hapticOk();
      final pts = 10 + _streak * 2;
      setState(() {
        _tiles = List.of(_tiles);
        _tiles[index] = tile.copyWith(correct: true, used: true);
        _score += pts;
        _streak++;
        _foundCount++;
        _correctTotal++;
        _message = 'hiragana_hunt_pts'.trParams({'pts': '$pts'});
      });

      if (_foundCount >= _targetTotal) {
        setState(() {
          _score += 20;
          _roundCount++;
          _message = 'hiragana_hunt_round_clear'.tr;
          _roundBusy = true;
        });
        await Future.delayed(const Duration(milliseconds: 700));
        if (!mounted) return;
        setState(() => _roundBusy = false);
        _nextRound();
      }
    } else {
      _hapticWrong();
      setState(() {
        _tiles = List.of(_tiles);
        _tiles[index] = tile.copyWith(wrong: true, used: true);
        _score = math.max(0, _score - 5);
        _streak = 0;
        _wrongTotal++;
        _message = 'hiragana_hunt_wrong'.trParams({
          'char': tile.data.kana,
          'romaji': tile.data.romaji,
        });
      });
    }
  }

  void _skipRound() {
    _hapticTap();
    setState(() {
      _streak = 0;
      _message = 'hiragana_hunt_skipped'.tr;
    });
    _nextRound();
  }

  void _toggleHint() {
    if (_target == null) return;
    _hapticTap();
    setState(() {
      if (!_hintShowsKana) {
        _hintShowsKana = true;
        _score = math.max(0, _score - 3);
        _message = 'hiragana_hunt_hint_used'.tr;
      } else {
        _hintShowsKana = false;
      }
    });
  }

  static const _bgTop = Color(0xFF1E3C72);
  static const _bgBottom = Color(0xFF2A5298);
  static const _accent = Color(0xFFFFD86B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: SafeArea(
          child: _intro
              ? _buildIntro()
              : _ended
                  ? _buildEnd()
                  : _buildPlay(),
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () {
                _hapticLight();
                Get.back();
              },
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          ),
          Text('hiragana_hunt_title'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text('hiragana_hunt_intro'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9), fontSize: 15)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.85,
            ),
            itemCount: _huntPool.length,
            itemBuilder: (_, i) {
              final h = _huntPool[i];
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(h.kana,
                        style: const TextStyle(
                            fontSize: 36,
                            color: _accent,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(h.romaji,
                        style: const TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: _bgTop,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('hiragana_hunt_start'.tr,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnd() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('hiragana_hunt_times_up'.tr,
              style: const TextStyle(
                  color: _accent, fontSize: 30, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          Text('hiragana_hunt_final_score'.trParams({'score': '$_score'}),
              style: const TextStyle(color: Colors.white, fontSize: 22)),
          const SizedBox(height: 12),
          Text('hiragana_hunt_final_rounds'.trParams({'n': '$_roundCount'}),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.95))),
          const SizedBox(height: 8),
          Text(
            'hiragana_hunt_final_stats'.trParams({
              'c': '$_correctTotal',
              'w': '$_wrongTotal',
            }),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _hapticTap();
                    Get.back();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('done'.tr),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: _bgTop,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('play_again'.tr),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlay() {
    final target = _target;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  _timer?.cancel();
                  _hapticLight();
                  Get.back();
                },
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              Expanded(
                child: Text('hiragana_hunt_title'.tr,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 12,
              runSpacing: 8,
              children: [
                Text('⏱️ ${'hiragana_draw_hud_time'.trParams({'s': '$_timeLeft'})}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                Text('⭐ $_score',
                    style: const TextStyle(
                        color: _accent, fontWeight: FontWeight.w700)),
                Text('hiragana_hunt_streak'.trParams({'n': '$_streak'}),
                    style: const TextStyle(
                        color: _accent, fontWeight: FontWeight.w700)),
                Text('hiragana_hunt_rounds'.trParams({'n': '$_roundCount'}),
                    style: const TextStyle(
                        color: _accent, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text('hiragana_hunt_find_label'.tr,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  target == null
                      ? ''
                      : (_hintShowsKana ? target.kana : target.romaji),
                  style: const TextStyle(
                    color: _accent,
                    fontSize: 52,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _toggleHint,
                  style: TextButton.styleFrom(
                    foregroundColor: _accent,
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                  ),
                  child: Text(
                    _hintShowsKana
                        ? 'hiragana_hunt_hide_hint'.tr
                        : 'hiragana_hunt_show_hint'.tr,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'hiragana_hunt_progress'.trParams({
              'found': '$_foundCount',
              'total': '$_targetTotal',
            }),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9), fontSize: 15),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: _tiles.length,
            itemBuilder: (_, i) {
              final t = _tiles[i];
              Color bg = Colors.white.withValues(alpha: 0.92);
              Color fg = const Color(0xFF222222);
              if (t.correct) {
                bg = const Color(0xFF4CAF50);
                fg = Colors.white;
              } else if (t.wrong) {
                bg = const Color(0xFFF44336);
                fg = Colors.white;
              }
              return Material(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: t.used ? null : () => _onTileTap(i),
                  borderRadius: BorderRadius.circular(12),
                  child: Transform(
                    transform: t.transform,
                    alignment: Alignment.center,
                    child: Center(
                      child: Text(
                        t.data.kana,
                        style: t.style.copyWith(color: fg),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            _message,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95), fontSize: 15),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _roundBusy ? null : _skipRound,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text('hiragana_draw_skip'.tr),
          ),
        ],
      ),
    );
  }
}

class _HuntTile {
  const _HuntTile({
    required this.data,
    required this.style,
    required this.transform,
    this.used = false,
    this.correct = false,
    this.wrong = false,
  });

  final HiraganaChar data;
  final TextStyle style;
  final Matrix4 transform;
  final bool used;
  final bool correct;
  final bool wrong;

  _HuntTile copyWith({
    bool? used,
    bool? correct,
    bool? wrong,
  }) {
    return _HuntTile(
      data: data,
      style: style,
      transform: transform,
      used: used ?? this.used,
      correct: correct ?? this.correct,
      wrong: wrong ?? this.wrong,
    );
  }
}
