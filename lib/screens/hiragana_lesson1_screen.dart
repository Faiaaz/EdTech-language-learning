import 'dart:async';

import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:ez_trainz/utils/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:confetti/confetti.dart';

import 'package:ez_trainz/controllers/course_controller.dart';
import 'package:ez_trainz/controllers/collectibles_controller.dart';
import 'package:ez_trainz/screens/hat_preview_interstitial_screen.dart';
import 'package:ez_trainz/screens/n5_hero_number1_lesson_screen.dart';

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
  bool _leafCelebrated = false;

  static const _seekStep = Duration(seconds: 10);
  static const _autoHide = Duration(seconds: 3);
  static const _navyBg = Colors.transparent;
  static const _navyCard = Color(0xFF1E293B);
  static const _textMuted = Color(0xFF94A3B8);
  static const _accentBlue = Color(0xFF3B82F6);

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
          ? 'hiragana_l1_quick_check_s_row'.tr
          : (shouldTrigger2
              ? 'hiragana_l1_quick_check_k_row'.tr
              : 'hiragana_l1_quick_check_vowels'.tr);

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
          if (!_leafCelebrated) {
            _leafCelebrated = true;
            final awarded =
                await CollectiblesController.to.awardLesson1LeafIfNeeded();
            if (awarded && mounted) {
              await showDialog<void>(
                context: context,
                barrierDismissible: true,
                barrierColor: Colors.black.withValues(alpha: 0.72),
                builder: (_) => const _LeafEarnedDialog(),
              );
            }
          }
          if (!mounted) return;
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.black.withValues(alpha: 0.72),
            builder: (_) => _SpeechGamePrompt(
              onStart: () {
                Navigator.of(context).pop();
                Get.to(() => const HatPreviewInterstitialScreen());
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
      backgroundColor: _navyBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _videoCtrl?.pause();
                      Get.back();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_back_ios_new_rounded,
                            color: _textMuted, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          'lesson_nav_chip'.tr,
                          style: const TextStyle(
                            color: _textMuted,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'hiragana_l1_screen_title'.tr,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (hasVideo)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(fit: StackFit.expand, children: [
                      _videoSurface(),
                      const Positioned(
                        top: 8,
                        left: 10,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'EZ',
                              style: TextStyle(
                                color: Color(0xFFFFE000),
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                            ),
                            SizedBox(width: 2),
                            Text(
                              'TRAINZ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _controlsOverlay(false),
                    ]),
                  ),
                ),
              ),
            if (hasVideo) const SizedBox(height: 14),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGamesSection(),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _openCalendly();
            },
            child: _rainbowBorderCard(
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
                    child: const Icon(Icons.video_call_rounded,
                        color: AppColors.textPrimary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'hiragana_l1_live_lesson'.tr,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'hiragana_l1_live_lesson_sub'.tr,
                          style: const TextStyle(
                            color: _textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      color: _textMuted, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                'next'.tr,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Mini-games grouped into tappable প্র্যাকটিস / চ্যালেঞ্জ cards ────
  Widget _buildGamesSection() {
    const practice = <_GameDef>[
      (
        label: 'শুনে ট্যাপ',
        sub: 'শুনে বাংলা বাছাই',
        icon: Icons.headphones_rounded,
        colors: [Color(0xFFFF8C00), Color(0xFFFF5722)],
        tab: 0,
      ),
      (
        label: 'পড়া মাস্টার',
        sub: 'পড়ে উত্তর দাও',
        icon: Icons.menu_book_rounded,
        colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
        tab: 1,
      ),
      (
        label: '১-১০ বলো',
        sub: 'ক্রমে বলো',
        icon: Icons.record_voice_over_rounded,
        colors: [Color(0xFF14B8A6), Color(0xFF0F766E)],
        tab: 3,
      ),
    ];
    const challenge = <_GameDef>[
      (
        label: 'সাজাও',
        sub: 'ক্রমে সাজাও',
        icon: Icons.swap_vert_rounded,
        colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
        tab: 2,
      ),
      (
        label: 'স্পিড বস',
        sub: 'দ্রুত উত্তরের পরীক্ষা',
        icon: Icons.bolt_rounded,
        colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
        tab: 6,
      ),
    ];

    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GameGroupCard(
          title: 'প্র্যাকটিস',
          icon: Icons.fitness_center_rounded,
          accent: _accentBlue,
          games: practice,
        ),
        SizedBox(height: 12),
        _GameGroupCard(
          title: 'চ্যালেঞ্জ',
          icon: Icons.bolt_rounded,
          accent: Color(0xFFEF4444),
          games: challenge,
        ),
      ],
    );
  }

  Future<void> _openCalendly() async {
    const url = 'https://calendly.com/eztrainz/live-lesson';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Unable to Open',
        'Could not open the booking page. Please try again later.',
        backgroundColor: AppColors.card,
        colorText: AppColors.textPrimary,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _rainbowBorderCard({required Widget child}) {
    return Container(
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
          color: _navyCard,
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
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
  static const _bgTop = AppColors.skyTop;
  static const _bgBottom = AppColors.goldBottom;

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
                            color: AppColors.textPrimary,
                            fontSize: headerFont,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          '${_index + 1}/${_pairs.length}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
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
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'hiragana_l1_mcq_prompt'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textMuted,
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
                                  'hiragana_l1_mcq_hint'.tr,
                                  key: const ValueKey('hint'),
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 12,
                                  ),
                                )
                              : Text(
                                  _correct!
                                      ? 'hiragana_l1_mcq_correct'.tr
                                      : 'hiragana_l1_mcq_try_next'.tr,
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
                          'hiragana_l1_mcq_score'.trParams({
                            'cur': '$_score',
                            'total': '${_pairs.length}',
                          }),
                          style: TextStyle(
                            color: AppColors.textMuted,
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
                        style: TextButton.styleFrom(foregroundColor: AppColors.accentBlueDk),
                        child: Text(
                          'skip'.tr,
                          style: TextStyle(
                            color: AppColors.textPrimary,
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
    final title = skipped
        ? 'hiragana_l1_quick_skipped_title'.tr
        : 'hiragana_l1_quick_done_title'.tr;
    final subtitle = skipped
        ? 'hiragana_l1_quick_skipped_body'.tr
        : 'hiragana_l1_quick_done_body'.trParams({
            'cur': '$_score',
            'total': '${_pairs.length}',
          });

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
                color: AppColors.card,
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
                      child: Text('hiragana_l1_continue_video'.tr,
                          style:
                              const TextStyle(fontWeight: FontWeight.w900)),
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
    final base = AppColors.border;
    final border = AppColors.border;
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
            border: Border.all(color: selected ? AppColors.accentBlue : b, width: selected ? 2 : 1),
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
                color: AppColors.textPrimary,
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
            border: Border.all(color: AppColors.border),
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
                'hiragana_l1_speech_title'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'hiragana_l1_speech_body'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMuted,
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
                  child: Text('hiragana_l1_speech_cta'.tr,
                      style:
                          const TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeafEarnedDialog extends StatefulWidget {
  const _LeafEarnedDialog();

  @override
  State<_LeafEarnedDialog> createState() => _LeafEarnedDialogState();
}

class _LeafEarnedDialogState extends State<_LeafEarnedDialog>
    with TickerProviderStateMixin {
  static const _gold = Color(0xFFFFE000);

  late final ConfettiController _confetti;
  late final AnimationController _drop;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _drop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      HapticFeedback.heavyImpact();
      _confetti.play();
      await _drop.forward();
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    _drop.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF111827),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: Listenable.merge([_drop, _pulse]),
                  builder: (_, __) {
                    final t = Curves.easeOutBack.transform(_drop.value);
                    final y = (1 - t) * -70;
                    final glow = 0.25 + 0.20 * _pulse.value;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                _gold.withValues(alpha: glow),
                                _gold.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(0, y),
                          child: Transform.rotate(
                            angle: -0.4 + 0.25 * _pulse.value,
                            child: Icon(
                              Icons.eco_rounded,
                              size: 64,
                              color: _gold,
                              shadows: [
                                Shadow(
                                  color: _gold.withValues(alpha: 0.55),
                                  blurRadius: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'hiragana_l1_leaf_title'.tr,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'hiragana_l1_leaf_body'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13.5,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _gold,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'hiragana_l1_leaf_cta'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirection: math.pi / 2,
              numberOfParticles: 18,
              maxBlastForce: 22,
              minBlastForce: 10,
              gravity: 0.22,
              emissionFrequency: 0.07,
              colors: const [
                Color(0xFFFFE000),
                Color(0xFF3B82F6),
                Color(0xFF10B981),
                Color(0xFF8B5CF6),
                Color(0xFFF59E0B),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mini-game grouping (Practice / Challenge) ────────────────────────
typedef _GameDef = ({
  String label,
  String sub,
  IconData icon,
  List<Color> colors,
  int tab,
});

String _bnNum(int n) {
  const digits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  return n.toString().split('').map((c) {
    final d = int.tryParse(c);
    return d == null ? c : digits[d];
  }).join();
}

/// A rectangular dark card that groups mini-game tiles under a heading and
/// reveals them in a 2-column grid when tapped.
class _GameGroupCard extends StatefulWidget {
  const _GameGroupCard({
    required this.title,
    required this.icon,
    required this.accent,
    required this.games,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final List<_GameDef> games;

  @override
  State<_GameGroupCard> createState() => _GameGroupCardState();
}

class _GameGroupCardState extends State<_GameGroupCard> {
  bool _expanded = false;

  static const _navyCard = Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _navyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _expanded = !_expanded);
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: widget.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(widget.icon, color: widget.accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${_bnNum(widget.games.length)}টি গেম',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      child: const Icon(Icons.expand_more_rounded,
                          color: Colors.white70, size: 26),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.05,
                      children: [
                        for (final g in widget.games) _GameTile(game: g),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

/// A single mini-game tile that deep-links into its game mode.
class _GameTile extends StatelessWidget {
  const _GameTile({required this.game});

  final _GameDef game;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Get.to(
          () => N5HeroNumber1LessonScreen(initialTab: game.tab, showTabs: false),
          transition: Transition.rightToLeftWithFade,
          duration: const Duration(milliseconds: 300),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: game.colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: game.colors.first.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(game.icon, color: Colors.white, size: 22),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  game.sub,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
