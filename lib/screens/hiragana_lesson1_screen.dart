import 'dart:async';

import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'package:ez_trainz/controllers/course_controller.dart';
import 'package:ez_trainz/screens/speech_game_screen.dart';

class HiraganaLesson1Screen extends StatefulWidget {
  const HiraganaLesson1Screen({super.key});

  @override
  State<HiraganaLesson1Screen> createState() => _HiraganaLesson1ScreenState();
}

class _HiraganaLesson1ScreenState extends State<HiraganaLesson1Screen> {
  VideoPlayerController? _videoCtrl;
  bool _videoInit = false;
  bool _videoError = false;
  bool _showControls = true;
  bool _isFullscreen = false;
  bool _isDragging = false;
  double _sliderVal = 0.0;
  Timer? _hideTimer;

  static const _seekStep = Duration(seconds: 10);
  static const _autoHide = Duration(seconds: 3);
  static const _dark = Color(0xFF1A1A2E);
  static const _bgTop = Color(0xFFF2FBFF);
  static const _bgMid = Color(0xFFBFEFFF);
  static const _bgBottom = Color(0xFF2BA8D6);

  // ── Interactive checkpoint (Lesson 1) ─────────────────────────
  static const Duration _mcqPauseAt = Duration(seconds: 70); // 1:10
  static const Duration _mcqPauseAt2 = Duration(seconds: 116); // 1:56
  static const Duration _mcqPauseAt3 = Duration(seconds: 160); // 2:40
  bool _mcqShown1 = false;
  bool _mcqShown2 = false;
  bool _mcqShown3 = false;
  bool _mcqOpen = false;
  bool _speechPrompted = false;

  static const _vowelPairs = <(String romaji, String kana)>[
    ('a', 'あ'),
    ('i', 'い'),
    ('u', 'う'),
    ('e', 'え'),
    ('o', 'お'),
  ];

  static const _kRowPairs = <(String romaji, String kana)>[
    ('ka', 'か'),
    ('ki', 'き'),
    ('ku', 'く'),
    ('ke', 'け'),
    ('ko', 'こ'),
  ];

  static const _sRowPairs = <(String romaji, String kana)>[
    ('sa', 'さ'),
    ('shi', 'し'),
    ('su', 'す'),
    ('se', 'せ'),
    ('so', 'そ'),
  ];

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    final lesson = CourseController.to.selectedLesson;
    if (lesson == null) return;
    final url = CourseController.to.getVideoUrl(lesson.id);
    if (url == null) return;
    _videoCtrl = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _videoInit = true);
          _resetHideTimer();
        }
      }).catchError((_) {
        if (mounted) setState(() => _videoError = true);
      });
    _videoCtrl!.addListener(_onVideoTick);
  }

  void _onVideoTick() {
    if (!mounted) return;
    final c = _videoCtrl;
    if (c == null || !c.value.isInitialized) return;

    // Auto-pause at 1:10 and run MCQ once.
    final pos = c.value.position;
    final shouldTrigger1 =
        !_mcqShown1 && !_mcqOpen && pos >= _mcqPauseAt && c.value.isPlaying;
    final shouldTrigger2 =
        !_mcqShown2 && !_mcqOpen && pos >= _mcqPauseAt2 && c.value.isPlaying;
    final shouldTrigger3 =
        !_mcqShown3 && !_mcqOpen && pos >= _mcqPauseAt3 && c.value.isPlaying;

    if (shouldTrigger1 || shouldTrigger2 || shouldTrigger3) {
      _mcqOpen = true;
      if (shouldTrigger1) _mcqShown1 = true;
      if (shouldTrigger2) _mcqShown2 = true;
      if (shouldTrigger3) _mcqShown3 = true;
      _hideTimer?.cancel();
      if (!_showControls) setState(() => _showControls = true);

      final pairs = shouldTrigger3
          ? _sRowPairs
          : (shouldTrigger2 ? _kRowPairs : _vowelPairs);
      final title = shouldTrigger3
          ? 'Quick Check — S Row'
          : (shouldTrigger2 ? 'Quick Check — K Row' : 'Quick Check — Vowels');

      // Don't block the video listener; run async flow separately.
      Future<void>(() async {
        var shouldResume = false;
        try {
          await c.pause();
          if (!mounted) return;
          shouldResume = true;
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.black.withValues(alpha: 0.72),
            builder: (_) => _HiraganaMcqDialog(
              title: title,
              pairs: pairs,
            ),
          );
        } finally {
          if (mounted) _mcqOpen = false;
          if (shouldResume && mounted) {
            final vc = _videoCtrl;
            if (vc != null && (vc.value.isInitialized)) {
              await vc.play();
              _resetHideTimer();
            }
          }
        }
      });
    }

    if (c.value.isCompleted) {
      _hideTimer?.cancel();
      if (!_showControls) setState(() => _showControls = true);

      if (!_speechPrompted && !_mcqOpen) {
        _speechPrompted = true;
        Future<void>(() async {
          if (!mounted) return;
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.black.withValues(alpha: 0.72),
            builder: (_) => _SpeechGamePrompt(
              onStart: () {
                Navigator.of(context).pop();
                Get.to(() => const SpeechGameScreen());
              },
            ),
          );
        });
      }
      return;
    }
    if (!_isDragging) {
      final ms = c.value.duration.inMilliseconds;
      if (ms > 0) {
        final v = c.value.position.inMilliseconds / ms;
        if ((v - _sliderVal).abs() > 0.001) {
          setState(() => _sliderVal = v.clamp(0.0, 1.0));
        }
      }
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _videoCtrl?.removeListener(_onVideoTick);
    _videoCtrl?.dispose();
    _restoreUI();
    super.dispose();
  }

  void _togglePlay() {
    final c = _videoCtrl;
    if (c == null || !_videoInit) return;
    if (c.value.isPlaying) {
      c.pause();
      _hideTimer?.cancel();
      setState(() => _showControls = true);
    } else {
      c.play();
      _resetHideTimer();
    }
  }

  void _seekFwd() {
    final c = _videoCtrl;
    if (c == null || !_videoInit) return;
    final t = c.value.position + _seekStep;
    c.seekTo(t > c.value.duration ? c.value.duration : t);
    _resetHideTimer();
  }

  void _seekBwd() {
    final c = _videoCtrl;
    if (c == null || !_videoInit) return;
    final t = c.value.position - _seekStep;
    c.seekTo(t < Duration.zero ? Duration.zero : t);
    _resetHideTimer();
  }

  void _onVideoTap() {
    if (_showControls) {
      if (_videoCtrl?.value.isPlaying ?? false) {
        _hideTimer?.cancel();
        setState(() => _showControls = false);
      }
    } else {
      setState(() => _showControls = true);
      _resetHideTimer();
    }
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    if (!mounted) return;
    if (!_showControls) setState(() => _showControls = true);
    if ((_videoCtrl?.value.isPlaying ?? false) && !_isDragging) {
      _hideTimer = Timer(_autoHide, () {
        if (mounted && (_videoCtrl?.value.isPlaying ?? false) && !_isDragging) {
          setState(() => _showControls = false);
        }
      });
    }
  }

  Future<void> _toggleFs() async {
    if (_isFullscreen) {
      await _restoreUI();
      if (mounted) setState(() => _isFullscreen = false);
    } else {
      if (!kIsWeb) {
        await SystemChrome.setPreferredOrientations(
            [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      }
      if (mounted) setState(() => _isFullscreen = true);
    }
    _resetHideTimer();
  }

  Future<void> _restoreUI() async {
    if (kIsWeb) return;
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) return '${d.inHours.toString().padLeft(2, '0')}:$m:$s';
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final lesson = CourseController.to.selectedLesson;
    if (lesson == null) {
      return Scaffold(body: Center(child: Text('lesson_not_found'.tr)));
    }
    final hasVideo = CourseController.to.getVideoUrl(lesson.id) != null;

    if (_isFullscreen) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (d, _) {
          if (!d) _toggleFs();
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(fit: StackFit.expand, children: [
            Center(
                child: AspectRatio(
                    aspectRatio: 16 / 9, child: _videoSurface())),
            _controlsOverlay(true),
          ]),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgTop, _bgMid, _bgBottom],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        _videoCtrl?.pause();
                        Get.back();
                      },
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.65),
                              width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Color(0xFF1E88E5), size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'back'.tr,
                              style: const TextStyle(
                                color: Color(0xFF1E88E5),
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (hasVideo)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.14),
                          blurRadius: 26,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Stack(fit: StackFit.expand, children: [
                          _videoSurface(),
                          _controlsOverlay(false),
                        ]),
                      ),
                    ),
                  ),
                ),
              if (hasVideo) const SizedBox(height: 12),
              Expanded(child: _buildContent(lesson)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(dynamic lesson) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.38),
              borderRadius: BorderRadius.circular(26),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.60), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 28,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: const TextStyle(
                            color: _dark,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          lesson.description,
                          style: const TextStyle(
                            color: Color(0xFF4B5563),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'What we are learning',
                          style: TextStyle(
                            color: _dark,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          lesson.description,
                          style: TextStyle(
                            color: _dark.withValues(alpha: 0.75),
                            fontSize: 14,
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.70)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E88E5)
                                      .withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.quiz_rounded,
                                    color: Color(0xFF1E88E5)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Interactive checkpoints: 1:10, 1:56, 2:40',
                                  style: TextStyle(
                                    color: _dark.withValues(alpha: 0.78),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Align(
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Get.to(() => const SpeechGameScreen());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E88E5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: const Text(
                          'Next',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Games and supplementary grids removed from Lesson 1 for now.

  // ── Video surface ──────────────────────────────────────────

  Widget _videoSurface() {
    if (_videoError) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline, color: Colors.white54, size: 36),
            const SizedBox(height: 8),
            Text('failed_load_video'.tr,
                style: const TextStyle(color: Colors.white54, fontSize: 13)),
          ]),
        ),
      );
    }
    if (!_videoInit) {
      return Container(
          color: Colors.black,
          child:
              const Center(child: CircularProgressIndicator(color: Colors.white)));
    }
    return VideoPlayer(_videoCtrl!);
  }

  // ── Controls overlay ───────────────────────────────────────

  Widget _controlsOverlay(bool fs) {
    final c = _videoCtrl;
    final playing = c?.value.isPlaying ?? false;
    final buffering = c?.value.isBuffering ?? false;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onVideoTap,
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: IgnorePointer(
          ignoring: !_showControls,
          child: Stack(fit: StackFit.expand, children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                  stops: const [0.0, 0.25, 0.6, 1.0],
                ),
              ),
            ),
            Center(
              child: buffering && _videoInit
                  ? const SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _iconBtn(Icons.replay_10_rounded, _seekBwd, 36),
                        const SizedBox(width: 28),
                        _iconBtn(
                            playing
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_filled_rounded,
                            _togglePlay,
                            58),
                        const SizedBox(width: 28),
                        _iconBtn(Icons.forward_10_rounded, _seekFwd, 36),
                      ],
                    ),
            ),
            if (_videoInit)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _bottomBar(fs),
              ),
          ]),
        ),
      ),
    );
  }

  Widget _bottomBar(bool fs) {
    final c = _videoCtrl!;
    final pos = c.value.position;
    final dur = c.value.duration;
    final durMs = dur.inMilliseconds;
    double buf = 0;
    if (durMs > 0 && c.value.buffered.isNotEmpty) {
      buf = (c.value.buffered.last.end.inMilliseconds / durMs).clamp(0.0, 1.0);
    }
    final hp = fs ? 20.0 : 12.0;
    final bp = fs ? 20.0 : 10.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(hp, 0, hp, bp),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _progressBar(buf, durMs),
        const SizedBox(height: 2),
        Row(children: [
          Text(_fmt(pos),
              style: const TextStyle(
                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
          const Text(' / ',
              style: TextStyle(color: Colors.white54, fontSize: 11)),
          Text(_fmt(dur),
              style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          GestureDetector(
            onTap: _toggleFs,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                  fs
                      ? Icons.fullscreen_exit_rounded
                      : Icons.fullscreen_rounded,
                  color: Colors.white,
                  size: 26),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _progressBar(double buf, int durMs) {
    const h = 3.0;
    return SizedBox(
      height: 24,
      child: Stack(alignment: Alignment.center, children: [
        Container(
            height: h,
            decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(h / 2))),
        Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: buf,
            child: Container(
                height: h,
                decoration: BoxDecoration(
                    color: Colors.white38,
                    borderRadius: BorderRadius.circular(h / 2))),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: _sliderVal.clamp(0.0, 1.0),
            child: Container(
                height: h,
                decoration: BoxDecoration(
                    color: const Color(0xFFFFE000),
                    borderRadius: BorderRadius.circular(h / 2))),
          ),
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: h,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: Colors.transparent,
            inactiveTrackColor: Colors.transparent,
            thumbColor: const Color(0xFFFFE000),
            overlayColor: const Color(0xFFFFE000).withValues(alpha: 0.25),
          ),
          child: Slider(
            value: _sliderVal.clamp(0.0, 1.0),
            onChangeStart: (_) {
              _isDragging = true;
              _hideTimer?.cancel();
            },
            onChanged: (v) => setState(() => _sliderVal = v),
            onChangeEnd: (v) {
              if (durMs > 0) {
                _videoCtrl
                    ?.seekTo(Duration(milliseconds: (v * durMs).round()));
              }
              _isDragging = false;
              _resetHideTimer();
            },
          ),
        ),
      ]),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, double size) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Icon(icon, color: Colors.white, size: size),
    );
  }
}

class _HiraganaMcqDialog extends StatefulWidget {
  const _HiraganaMcqDialog({
    required this.title,
    required this.pairs,
  });

  final String title;
  final List<(String romaji, String kana)> pairs;

  @override
  State<_HiraganaMcqDialog> createState() => _HiraganaMcqDialogState();
}

class _HiraganaMcqDialogState extends State<_HiraganaMcqDialog> {
  static const _accent = Color(0xFFFFD86B);
  static const _bgTop = Color(0xFF1E3C72);
  static const _bgBottom = Color(0xFF2A5298);

  List<(String romaji, String kana)> get _pairs => widget.pairs;

  int _index = 0;
  int _score = 0;
  bool _locked = false;
  String? _selected;
  bool? _correct;
  late List<String> _options;

  @override
  void initState() {
    super.initState();
    _options = _optionsFor(_pairs[_index].$2);
  }

  List<String> _optionsFor(String correctKana) {
    final opts = _pairs.map((p) => p.$2).toList();
    opts.shuffle();
    // Ensure the correct answer is present (it always is) and return all 5.
    return opts;
  }

  @override
  Widget build(BuildContext context) {
    final q = _pairs[_index];
    final options = _options;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      backgroundColor: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth;
          final maxH = constraints.maxHeight;
          final isLandscape = maxW > maxH;
          final isShort = maxH < 520;

          final inset = EdgeInsets.symmetric(
            horizontal: isLandscape ? 10 : 14,
            vertical: isLandscape ? 6 : 12,
          );

          final dialogW = math.min(maxW - inset.horizontal, 560.0);
          // In landscape fullscreen the height can be tight: fit to available space.
          final dialogH = math.min(maxH - inset.vertical, isShort ? 500.0 : 620.0);

          final pad = isLandscape ? 12.0 : (isShort ? 14.0 : 18.0);
          final headerFont = isLandscape ? 16.0 : (isShort ? 16.0 : 18.0);
          final promptFont = isLandscape ? 36.0 : (isShort ? 38.0 : 44.0);

          final crossAxisCount = isLandscape ? 5 : 3;

          final tile = ((dialogW - pad * 2 - (crossAxisCount - 1) * 10) /
                  crossAxisCount)
              .clamp(isLandscape ? 64.0 : (isShort ? 78.0 : 90.0), 140.0);

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints.tightFor(width: dialogW, height: dialogH),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_bgTop, _bgBottom],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(pad, pad, pad, pad),
                      child: Column(
                        children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: headerFont,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
                        ),
                        child: Text(
                          '${_index + 1}/${_pairs.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isShort ? 12 : 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Tap the hiragana for',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          q.$1.toUpperCase(),
                          style: TextStyle(
                            color: _accent,
                            fontSize: promptFont,
                            fontWeight: FontWeight.w900,
                            height: 1,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: _correct == null
                              ? Text(
                                  'Choose wisely…',
                                  key: const ValueKey('hint'),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.70),
                                    fontSize: 12,
                                  ),
                                )
                              : Text(
                                  _correct! ? 'Correct!' : 'Not quite — try the next one.',
                                  key: ValueKey(_correct),
                                  style: TextStyle(
                                    color: _correct! ? const Color(0xFFB6F6C9) : const Color(0xFFFFB4B4),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: dialogW,
                        child: GridView.count(
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: isLandscape ? 8 : 10,
                          crossAxisSpacing: isLandscape ? 8 : 10,
                          childAspectRatio: isLandscape ? 1.2 : 1.0,
                          padding: const EdgeInsets.all(0),
                          children: [
                            for (final opt in options)
                              SizedBox(
                                width: tile,
                                height: tile,
                                child: _OptionCard(
                                  label: opt,
                                  selected: _selected == opt,
                                  state: _correct == null
                                      ? null
                                      : (opt == q.$2
                                          ? _OptionState.correct
                                          : (_selected == opt
                                              ? _OptionState.wrong
                                              : null)),
                                  onTap: _locked
                                      ? null
                                      : () async {
                                          HapticFeedback.selectionClick();
                                          setState(() {
                                            _locked = true;
                                            _selected = opt;
                                            _correct = opt == q.$2;
                                            if (_correct!) _score++;
                                          });
                                          await Future.delayed(
                                              const Duration(milliseconds: 650));
                                          if (!mounted) return;
                                          if (_index == _pairs.length - 1) {
                                            await _showFinish();
                                            if (!context.mounted) return;
                                            Navigator.of(context).pop();
                                            return;
                                          }
                                          setState(() {
                                            _index++;
                                            _options =
                                                _optionsFor(_pairs[_index].$2);
                                            _locked = false;
                                            _selected = null;
                                            _correct = null;
                                          });
                                        },
                                ),
                              ),
                            if (!isLandscape) const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Score: $_score/${_pairs.length}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          // Let them skip but keep the “interactive” feel.
                          HapticFeedback.lightImpact();
                          await _showFinish(skipped: true);
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.white),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showFinish({bool skipped = false}) async {
    final title = skipped ? 'Quiz skipped' : 'Nice!';
    final subtitle = skipped
        ? 'You can replay and try it anytime.'
        : 'You scored $_score/${_pairs.length} on あ・い・う・え・お.';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4CC),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.stars_rounded, color: Color(0xFFFFB300), size: 30),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      height: 1.35,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Continue video', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

enum _OptionState { correct, wrong }

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.state,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final _OptionState? state;

  @override
  Widget build(BuildContext context) {
    final base = Colors.white.withValues(alpha: 0.12);
    final border = Colors.white.withValues(alpha: 0.18);
    final bg = switch (state) {
      _OptionState.correct => const Color(0xFF14B86A).withValues(alpha: 0.18),
      _OptionState.wrong => const Color(0xFFE53935).withValues(alpha: 0.16),
      _ => base,
    };
    final b = switch (state) {
      _OptionState.correct => const Color(0xFFB6F6C9),
      _OptionState.wrong => const Color(0xFFFFB4B4),
      _ => border,
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: selected ? Colors.white.withValues(alpha: 0.55) : b, width: selected ? 2 : 1),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w900,
                height: 1,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeechGamePrompt extends StatelessWidget {
  const _SpeechGamePrompt({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.30),
                blurRadius: 28,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD86B).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.mic_rounded, color: Color(0xFFFFD86B), size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                "Great job finishing the video!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Now let's try our Speech Game — upload a short audio clip and we’ll transcribe it to Japanese, romaji, and English.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.80),
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD86B),
                    foregroundColor: const Color(0xFF0B1220),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Start Speech Game', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
