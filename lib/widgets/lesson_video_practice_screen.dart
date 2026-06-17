import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'package:ez_trainz/controllers/course_controller.dart';
import 'package:ez_trainz/utils/app_theme.dart';
import 'package:ez_trainz/widgets/lesson_practice_game_cards.dart';

/// Video on top + প্র্যাকটিস / চ্যালেঞ্জ game cards (shared by N5 lessons ২–৭).
class LessonVideoPracticeScreen extends StatefulWidget {
  const LessonVideoPracticeScreen({
    super.key,
    required this.titleKey,
    required this.practiceGames,
    required this.challengeGames,
  });

  final String titleKey;
  final List<LessonPracticeGame> practiceGames;
  final List<LessonPracticeGame> challengeGames;

  @override
  State<LessonVideoPracticeScreen> createState() =>
      _LessonVideoPracticeScreenState();
}

class _LessonVideoPracticeScreenState extends State<LessonVideoPracticeScreen> {
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
  static const _navyBg = Colors.transparent;
  static const _navyCard = AppColors.cardAlt;
  static const _textMuted = AppColors.textMuted;
  static const _accentBlue = Color(0xFF3B82F6);

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
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      }
      if (mounted) setState(() => _isFullscreen = true);
    }
    _resetHideTimer();
  }

  Future<void> _restoreUI() async {
    if (kIsWeb) return;
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) return '${d.inHours.toString().padLeft(2, '0')}:$m:$s';
    return '$m:$s';
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

  Widget _buildGamesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LessonPracticeGameGroup(
          title: 'প্র্যাকটিস',
          icon: Icons.fitness_center_rounded,
          accent: _accentBlue,
          games: widget.practiceGames,
        ),
        const SizedBox(height: 12),
        LessonPracticeGameGroup(
          title: 'চ্যালেঞ্জ',
          icon: Icons.bolt_rounded,
          accent: const Color(0xFFEF4444),
          games: widget.challengeGames,
        ),
      ],
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

  Widget _videoSurface() {
    if (_videoError) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white54, size: 36),
              const SizedBox(height: 8),
              Text(
                'failed_load_video'.tr,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }
    if (!_videoInit) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
    return VideoPlayer(_videoCtrl!);
  }

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
          child: Stack(
            fit: StackFit.expand,
            children: [
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
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
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
                            58,
                          ),
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
            ],
          ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _progressBar(buf, durMs),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                _fmt(pos),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(' / ',
                  style: TextStyle(color: Colors.white54, fontSize: 11)),
              Text(
                _fmt(dur),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressBar(double buf, int durMs) {
    const h = 3.0;
    return SizedBox(
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: h,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(h / 2),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: buf,
              child: Container(
                height: h,
                decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(h / 2),
                ),
              ),
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
                  borderRadius: BorderRadius.circular(h / 2),
                ),
              ),
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
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, double size) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Icon(icon, color: Colors.white, size: size),
    );
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
          body: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _videoSurface(),
                ),
              ),
              _controlsOverlay(true),
            ],
          ),
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
                      widget.titleKey.tr,
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
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
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
                      ],
                    ),
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
}
