import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/models/hiragana_lesson_data.dart';

/// Logical drawing resolution (must match raster comparison in [_renderStrokesToImage]).
const kHiraganaDrawCanvas = 288.0;

/// Hiragana drawing practice — port of [hiragana_draw.html]: romaji prompt,
/// finger/mouse drawing, grid guide, optional trace overlay, F1 pixel match.
class HiraganaDrawScreen extends StatefulWidget {
  const HiraganaDrawScreen({super.key});

  @override
  State<HiraganaDrawScreen> createState() => _HiraganaDrawScreenState();
}

class _HiraganaDrawScreenState extends State<HiraganaDrawScreen> {
  static const _kanaPool = HiraganaLesson1Data.kanaList;
  static const _timeLimit = 180;

  HiraganaChar? _target;
  final _strokes = <List<Offset>>[];
  List<Offset>? _currentStroke;
  int? _activePointer;

  int _timeLeft = _timeLimit;
  int _score = 0;
  int _doneCount = 0;
  Timer? _timer;

  bool _guideVisible = false;
  bool _playing = false;
  bool _ended = false;
  bool _busy = false;
  bool _showReveal = false;

  String _message = '';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _hapticTap() => HapticFeedback.selectionClick();
  void _hapticLight() => HapticFeedback.lightImpact();
  void _hapticOk() => HapticFeedback.mediumImpact();

  void _startGame() {
    _hapticOk();
    setState(() {
      _playing = true;
      _ended = false;
      _timeLeft = _timeLimit;
      _score = 0;
      _doneCount = 0;
      _strokes.clear();
      _currentStroke = null;
      _guideVisible = false;
      _showReveal = false;
      _message = '';
    });
    _nextRound();
    _timer?.cancel();
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
      _playing = false;
      _ended = true;
    });
    HapticFeedback.heavyImpact();
  }

  void _nextRound() {
    final rng = math.Random();
    _target = _kanaPool[rng.nextInt(_kanaPool.length)];
    setState(() {
      _strokes.clear();
      _currentStroke = null;
      _guideVisible = false;
      _showReveal = false;
      _busy = false;
      _message = 'hiragana_draw_msg_round'.trParams({'romaji': _target!.romaji});
    });
  }

  void _clearCanvas() {
    _hapticTap();
    setState(() {
      _strokes.clear();
      _currentStroke = null;
    });
  }

  void _toggleGuide() {
    _hapticTap();
    setState(() {
      if (_guideVisible) {
        _guideVisible = false;
      } else {
        _guideVisible = true;
        _score = math.max(0, _score - 2);
        _message = 'hiragana_draw_guide_penalty'.tr;
      }
    });
  }

  Future<void> _checkAnswer() async {
    if (_busy || _target == null) return;
    final hasStroke = _strokes.any((s) => s.isNotEmpty);
    if (!hasStroke) {
      _hapticLight();
      setState(() => _message = 'hiragana_draw_empty'.tr);
      return;
    }

    setState(() => _busy = true);
    _hapticTap();

    const size = Size(kHiraganaDrawCanvas, kHiraganaDrawCanvas);
    ui.Image? userImg;
    ui.Image? refImg;
    try {
      userImg = await _renderStrokesToImage(size, _strokes);
      refImg = await _renderReferenceToImage(size, _target!.kana);
      final userBd = await userImg.toByteData(format: ui.ImageByteFormat.rawRgba);
      final refBd = await refImg.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (userBd == null || refBd == null) {
        setState(() => _busy = false);
        return;
      }

      final userInk = _countInkPixels(userBd, kHiraganaDrawCanvas.toInt());
      if (userInk < 50) {
        _hapticLight();
        setState(() {
          _message = 'hiragana_draw_empty'.tr;
          _busy = false;
        });
        return;
      }

      final sim = _computeSimilarity(refBd, userBd, kHiraganaDrawCanvas.toInt());
      final pct = (sim * 100).round();

      int earned = 0;
      if (pct >= 70) {
        earned = 15;
      } else if (pct >= 50) {
        earned = 10;
      } else if (pct >= 30) {
        earned = 5;
      }

      if (earned > 0) {
        _hapticOk();
        _score += earned;
        _doneCount++;
        final msgKey = pct >= 70
            ? 'hiragana_draw_result_high'
            : (pct >= 50
                ? 'hiragana_draw_result_mid'
                : 'hiragana_draw_result_low');
        setState(() {
          _showReveal = true;
          _message = msgKey.trParams({
            'pct': '$pct',
            'pts': '$earned',
            'char': _target!.kana,
          });
        });
      } else {
        _hapticLight();
        setState(() {
          _showReveal = true;
          _message = 'hiragana_draw_match_miss'.trParams({
            'pct': '$pct',
            'char': _target!.kana,
          });
        });
      }

      await Future.delayed(const Duration(milliseconds: 1800));
      if (!mounted) return;
      setState(() {
        _busy = false;
        _showReveal = false;
      });
      _nextRound();
    } finally {
      userImg?.dispose();
      refImg?.dispose();
    }
  }

  int _countInkPixels(ByteData bd, int s) {
    final data = bd.buffer.asUint8List();
    var count = 0;
    final total = s * s;
    for (var i = 0; i < total; i++) {
      if (data[i * 4 + 3] > 50) count++;
    }
    return count;
  }

  /// F1 overlap score (hiragana_draw.html).
  double _computeSimilarity(ByteData refBd, ByteData userBd, int s) {
    final refData = refBd.buffer.asUint8List();
    final userData = userBd.buffer.asUint8List();
    final total = s * s;
    final refMask = Uint8List(total);
    final userMask = Uint8List(total);
    for (var i = 0; i < total; i++) {
      refMask[i] = refData[i * 4 + 3] > 50 ? 1 : 0;
      userMask[i] = userData[i * 4 + 3] > 50 ? 1 : 0;
    }

    var userCount = 0;
    for (var i = 0; i < total; i++) {
      userCount += userMask[i];
    }
    if (userCount < 50) return 0;

    final radius = math.max(6, (s * 0.025).floor());

    var refSampled = 0;
    var hit = 0;
    for (var y = 0; y < s; y += 2) {
      for (var x = 0; x < s; x += 2) {
        final idx = y * s + x;
        if (refMask[idx] == 0) continue;
        refSampled++;
        var found = false;
        for (var dy = -radius; dy <= radius && !found; dy += 2) {
          final ny = y + dy;
          if (ny < 0 || ny >= s) continue;
          for (var dx = -radius; dx <= radius && !found; dx += 2) {
            final nx = x + dx;
            if (nx < 0 || nx >= s) continue;
            if (userMask[ny * s + nx] != 0) found = true;
          }
        }
        if (found) hit++;
      }
    }

    var userHit = 0;
    var userSampled = 0;
    for (var y = 0; y < s; y += 2) {
      for (var x = 0; x < s; x += 2) {
        final idx = y * s + x;
        if (userMask[idx] == 0) continue;
        userSampled++;
        var found = false;
        for (var dy = -radius; dy <= radius && !found; dy += 2) {
          final ny = y + dy;
          if (ny < 0 || ny >= s) continue;
          for (var dx = -radius; dx <= radius && !found; dx += 2) {
            final nx = x + dx;
            if (nx < 0 || nx >= s) continue;
            if (refMask[ny * s + nx] != 0) found = true;
          }
        }
        if (found) userHit++;
      }
    }

    final recall = refSampled > 0 ? hit / refSampled : 0.0;
    final precision = userSampled > 0 ? userHit / userSampled : 0.0;
    if (recall + precision == 0) return 0;
    return 2 * recall * precision / (recall + precision);
  }

  Future<ui.Image> _renderStrokesToImage(Size size, List<List<Offset>> strokes) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );
    final sw = math.max(4.0, size.width * 0.032);
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawCircle(stroke[0], sw / 2, Paint()..color = Colors.black);
        continue;
      }
      final path = Path()..moveTo(stroke[0].dx, stroke[0].dy);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    final picture = recorder.endRecording();
    return picture.toImage(size.width.ceil(), size.height.ceil());
  }

  Future<ui.Image> _renderReferenceToImage(Size size, String char) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );
    final tp = TextPainter(
      text: TextSpan(
        text: char,
        style: TextStyle(
          color: Colors.black,
          fontSize: size.width * 0.75,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(
        (size.width - tp.width) / 2,
        (size.height - tp.height) / 2,
      ),
    );
    final picture = recorder.endRecording();
    return picture.toImage(size.width.ceil(), size.height.ceil());
  }

  void _skipRound() {
    if (_busy || _target == null) return;
    _hapticTap();
    setState(() {
      _message = 'hiragana_draw_skipped'.trParams({'char': _target!.kana});
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _nextRound();
    });
  }

  /// Pointer-based drawing works reliably with mouse on web (no pan-gesture delay).
  void _onPointerDown(PointerDownEvent e) {
    if (_busy) return;
    if (_activePointer != null) return;
    _activePointer = e.pointer;
    _hapticTap();
    setState(() {
      _currentStroke = [e.localPosition];
    });
  }

  void _onPointerMove(PointerMoveEvent e) {
    if (_busy || _currentStroke == null) return;
    if (e.pointer != _activePointer) return;
    if (!e.down) return;
    setState(() {
      _currentStroke!.add(e.localPosition);
    });
  }

  void _finishStroke(int pointer) {
    if (pointer != _activePointer) return;
    _activePointer = null;
    if (_currentStroke == null || _currentStroke!.isEmpty) return;
    setState(() {
      _strokes.add(List.from(_currentStroke!));
      _currentStroke = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF34495E);
    const accent = Color(0xFFFFD86B);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: !_playing && !_ended
            ? _buildIntro(context, accent)
            : _ended
                ? _buildEnd(context, accent)
                : _buildPlay(context, accent),
      ),
    );
  }

  Widget _buildIntro(BuildContext context, Color accent) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () {
                          _hapticLight();
                          Get.back();
                        },
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('hiragana_draw_title'.tr,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 20),
                    Text('hiragana_draw_intro_1'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 15)),
                    const SizedBox(height: 12),
                    Text('hiragana_draw_intro_2'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14)),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _startGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: const Color(0xFF1E3C72),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text('hiragana_draw_start'.tr,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnd(BuildContext context, Color accent) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('hiragana_draw_times_up'.tr,
                    style: TextStyle(
                        color: accent,
                        fontSize: 28,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 20),
                Text('hiragana_draw_final_score'.trParams({'score': '$_score'}),
                    style: const TextStyle(color: Colors.white, fontSize: 20)),
                const SizedBox(height: 12),
                Text('hiragana_draw_drawn'.trParams({'n': '$_doneCount'}),
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16)),
                const SizedBox(height: 32),
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
                          side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.5)),
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
                          backgroundColor: accent,
                          foregroundColor: const Color(0xFF1E3C72),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('play_again'.tr),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlay(BuildContext context, Color accent) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(
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
                child: Text('hiragana_draw_title'.tr,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('⏱️ ${'hiragana_draw_hud_time'.trParams({'s': '$_timeLeft'})}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                Text('⭐ $_score',
                    style: const TextStyle(
                        color: Color(0xFFFFD86B),
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                Text('✅ $_doneCount',
                    style: const TextStyle(
                        color: Color(0xFFFFD86B),
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text('hiragana_draw_prompt_label'.tr,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  _target?.romaji ?? '',
                  style: const TextStyle(
                    color: Color(0xFFFFD86B),
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxSide = math.min(constraints.maxWidth, constraints.maxHeight);
              final scale = maxSide / kHiraganaDrawCanvas;
              return Center(
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: kHiraganaDrawCanvas,
                    height: kHiraganaDrawCanvas,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CustomPaint(
                            painter: _GridGuidePainter(),
                            size: const Size(kHiraganaDrawCanvas, kHiraganaDrawCanvas),
                          ),
                          if (_guideVisible && _target != null)
                            IgnorePointer(
                              child: Center(
                                child: Opacity(
                                  opacity: 0.22,
                                  child: Text(
                                    _target!.kana,
                                    style: TextStyle(
                                      fontSize: kHiraganaDrawCanvas * 0.72,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          CustomPaint(
                            painter: _StrokesPainter(
                              strokes: _strokes,
                              current: _currentStroke,
                            ),
                          ),
                          if (_showReveal && _target != null)
                            IgnorePointer(
                              child: Center(
                                child: Opacity(
                                  opacity: 0.35,
                                  child: Text(
                                    _target!.kana,
                                    style: TextStyle(
                                      fontSize: kHiraganaDrawCanvas * 0.72,
                                      color: const Color(0xFFE74C3C),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Positioned.fill(
                            child: Listener(
                              behavior: HitTestBehavior.opaque,
                              onPointerDown: _onPointerDown,
                              onPointerMove: _onPointerMove,
                              onPointerUp: (e) => _finishStroke(e.pointer),
                              onPointerCancel: (e) => _finishStroke(e.pointer),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _chipButton(
                'hiragana_draw_clear'.tr,
                accent,
                _clearCanvas,
                secondary: true,
              ),
              _chipButton(
                'hiragana_draw_guide'.tr,
                accent,
                _toggleGuide,
                secondary: true,
              ),
              _chipButton(
                'hiragana_draw_check'.tr,
                accent,
                _busy ? null : _checkAnswer,
                secondary: false,
              ),
              _chipButton(
                'hiragana_draw_skip'.tr,
                accent,
                _busy ? null : _skipRound,
                secondary: true,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            _message.isEmpty ? 'hiragana_draw_hint'.tr : _message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _chipButton(
    String label,
    Color accent,
    VoidCallback? onTap, {
    required bool secondary,
  }) {
    return Material(
      color: secondary
          ? Colors.white.withValues(alpha: 0.2)
          : accent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: secondary ? Colors.white : const Color(0xFF1E3C72),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _GridGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, s, s),
      Paint()..color = Colors.white,
    );
    final fine = s / 20;
    final finePaint = Paint()
      ..color = const Color(0xFFB8D4E8)
      ..strokeWidth = 1;
    for (var i = 1; i < 20; i++) {
      canvas.drawLine(Offset(i * fine, 0), Offset(i * fine, s), finePaint);
      canvas.drawLine(Offset(0, i * fine), Offset(s, i * fine), finePaint);
    }
    final boldPaint = Paint()
      ..color = const Color(0xFF7AA8C8)
      ..strokeWidth = 1.5;
    for (var i = 1; i < 4; i++) {
      final p = i * (s / 4);
      canvas.drawLine(Offset(p, 0), Offset(p, s), boldPaint);
      canvas.drawLine(Offset(0, p), Offset(s, p), boldPaint);
    }
    final crossPaint = Paint()
      ..color = const Color(0xFFD04A4A)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(s / 2, 0), Offset(s / 2, s), crossPaint);
    canvas.drawLine(Offset(0, s / 2), Offset(s, s / 2), crossPaint);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, s, s),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF5A8AA8),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StrokesPainter extends CustomPainter {
  _StrokesPainter({
    required this.strokes,
    required this.current,
  });

  final List<List<Offset>> strokes;
  final List<Offset>? current;

  @override
  void paint(Canvas canvas, Size size) {
    final sw = math.max(4.0, size.width * 0.032);
    final paint = Paint()
      ..color = const Color(0xFF222222)
      ..strokeWidth = sw
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    void drawStroke(List<Offset> pts) {
      if (pts.isEmpty) return;
      if (pts.length == 1) {
        canvas.drawCircle(pts[0], sw / 2, Paint()..color = const Color(0xFF222222));
        return;
      }
      final path = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (var i = 1; i < pts.length; i++) {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    for (final st in strokes) {
      drawStroke(st);
    }
    if (current != null && current!.isNotEmpty) {
      drawStroke(current!);
    }
  }

  @override
  bool shouldRepaint(covariant _StrokesPainter oldDelegate) =>
      oldDelegate.strokes != strokes || oldDelegate.current != current;
}
