import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'package:ez_trainz/controllers/course_controller.dart';
import 'package:ez_trainz/controllers/game_controller.dart';
import 'package:ez_trainz/models/game.dart';
import 'package:ez_trainz/screens/game_detail_screen.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  VideoPlayerController? _videoCtrl;
  bool _videoInitialised = false;
  bool _videoError = false;
  bool _showControls = true;
  bool _isFullscreen = false;
  bool _isDraggingSlider = false;
  double _sliderValue = 0.0;
  Timer? _hideTimer;

  static const _seekStep = Duration(seconds: 10);
  static const _autoHideDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _initVideo();
    _loadLessonGames();
  }

  void _loadLessonGames() {
    final lesson = CourseController.to.selectedLesson;
    if (lesson == null) return;
    GameController.to.loadGamesByLesson(lesson.id.toString());
  }

  void _initVideo() {
    final lesson = CourseController.to.selectedLesson;
    if (lesson == null) return;
    final url = CourseController.to.getVideoUrl(lesson.id);
    if (url == null) return;

    _videoCtrl = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _videoInitialised = true);
          _resetHideTimer();
        }
      }).catchError((_) {
        if (mounted) setState(() => _videoError = true);
      });

    _videoCtrl!.addListener(_onVideoUpdate);
  }

  void _onVideoUpdate() {
    if (!mounted) return;
    final ctrl = _videoCtrl;
    if (ctrl == null || !ctrl.value.isInitialized) return;

    // Keep controls visible when video ends
    if (ctrl.value.isCompleted) {
      _hideTimer?.cancel();
      if (!_showControls) setState(() => _showControls = true);
      return;
    }

    // Sync slider position only while not dragging
    if (!_isDraggingSlider) {
      final durationMs = ctrl.value.duration.inMilliseconds;
      if (durationMs > 0) {
        final newVal = ctrl.value.position.inMilliseconds / durationMs;
        if ((newVal - _sliderValue).abs() > 0.001) {
          setState(() => _sliderValue = newVal.clamp(0.0, 1.0));
        }
      }
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _videoCtrl?.removeListener(_onVideoUpdate);
    _videoCtrl?.dispose();
    _restoreSystemUI();
    super.dispose();
  }

  // ── Playback controls ────────────────────────────────────────────

  void _togglePlay() {
    final ctrl = _videoCtrl;
    if (ctrl == null || !_videoInitialised) return;
    if (ctrl.value.isPlaying) {
      ctrl.pause();
      // Keep controls visible when paused
      _hideTimer?.cancel();
      setState(() => _showControls = true);
    } else {
      ctrl.play();
      _resetHideTimer();
    }
  }

  void _seekForward() {
    final ctrl = _videoCtrl;
    if (ctrl == null || !_videoInitialised) return;
    final target = ctrl.value.position + _seekStep;
    final dur = ctrl.value.duration;
    ctrl.seekTo(target > dur ? dur : target);
    _resetHideTimer();
  }

  void _seekBackward() {
    final ctrl = _videoCtrl;
    if (ctrl == null || !_videoInitialised) return;
    final target = ctrl.value.position - _seekStep;
    ctrl.seekTo(target < Duration.zero ? Duration.zero : target);
    _resetHideTimer();
  }

  // ── Controls visibility ──────────────────────────────────────────

  void _onVideoTap() {
    if (_showControls) {
      // Tap while visible: hide if playing, keep if paused
      if (_videoCtrl?.value.isPlaying ?? false) {
        _hideTimer?.cancel();
        setState(() => _showControls = false);
      }
    } else {
      // Tap while hidden: always show
      setState(() => _showControls = true);
      _resetHideTimer();
    }
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    if (!mounted) return;
    if (!_showControls) setState(() => _showControls = true);
    // Only auto-hide when playing and not scrubbing
    if ((_videoCtrl?.value.isPlaying ?? false) && !_isDraggingSlider) {
      _hideTimer = Timer(_autoHideDuration, () {
        if (mounted &&
            (_videoCtrl?.value.isPlaying ?? false) &&
            !_isDraggingSlider) {
          setState(() => _showControls = false);
        }
      });
    }
  }

  // ── Fullscreen (YouTube-style) ───────────────────────────────────

  Future<void> _toggleFullscreen() async {
    if (_isFullscreen) {
      await _restoreSystemUI();
      if (mounted) setState(() => _isFullscreen = false);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      if (mounted) setState(() => _isFullscreen = true);
    }
    _resetHideTimer();
  }

  Future<void> _restoreSystemUI() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────

  String _fmt(Duration d) {
    if (d.inHours > 0) {
      final h = d.inHours.toString().padLeft(2, '0');
      final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
      final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '$h:$m:$s';
    }
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Build ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final lesson = CourseController.to.selectedLesson;
    if (lesson == null) {
      return Scaffold(body: Center(child: Text('lesson_not_found'.tr)));
    }

    final hasVideo = CourseController.to.getVideoUrl(lesson.id) != null;

    // ── FULLSCREEN layout ──────────────────────────────────────────
    if (_isFullscreen) {
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop) _toggleFullscreen();
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _buildVideoContent(),
                ),
              ),
              _buildControlsOverlay(fullscreen: true),
            ],
          ),
        ),
      );
    }

    // ── NORMAL layout ──────────────────────────────────────────────
    return Scaffold(
      backgroundColor: const Color(0xFF4DA6E8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Back button ───────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: GestureDetector(
                onTap: () {
                  _videoCtrl?.pause();
                  Get.back();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      Text(
                        'back'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Video player ──────────────────────────────
            if (hasVideo)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildVideoContent(),
                        _buildControlsOverlay(fullscreen: false),
                      ],
                    ),
                  ),
                ),
              ),

            if (hasVideo) const SizedBox(height: 8),

            // ── Lesson content ────────────────────────────
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: const TextStyle(
                          color: Color(0xFF1A1A2E),
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lesson.description,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(height: 1, color: const Color(0xFFE5E7EB)),
                      const SizedBox(height: 20),
                      Text(
                        lesson.content.body,
                        style: const TextStyle(
                          color: Color(0xFF374151),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                        ),
                      ),

                      // ── Quizzes ───────────────────────
                      if (lesson.quizzes.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        Text(
                          'quizzes'.tr,
                          style: const TextStyle(
                            color: Color(0xFF1A1A2E),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...lesson.quizzes.map(
                          (quiz) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFA726)
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFFA726)
                                    .withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.quiz_outlined,
                                    color: Color(0xFFFFA726), size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        quiz.title,
                                        style: const TextStyle(
                                          color: Color(0xFF1A1A2E),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'passing_score'.trParams({
                                          'score':
                                              quiz.passingScore.toString()
                                        }),
                                        style: const TextStyle(
                                          color: Color(0xFF6B7280),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFA726),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    'start'.tr,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // ── Games for this lesson ──────────
                      Obx(() {
                        final gameCtrl = GameController.to;
                        if (gameCtrl.isLoading.value) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 28),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF4DA6E8),
                              ),
                            ),
                          );
                        }
                        if (gameCtrl.games.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 28),
                            Text(
                              'games_title'.tr,
                              style: const TextStyle(
                                color: Color(0xFF1A1A2E),
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...gameCtrl.games.map(
                              (game) => _LessonGameCard(game: game),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Raw video surface ────────────────────────────────────────────

  Widget _buildVideoContent() {
    if (_videoError) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Colors.white54, size: 36),
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

    if (!_videoInitialised) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return VideoPlayer(_videoCtrl!);
  }

  // ── Controls overlay (YouTube-style: all controls inside video) ──

  Widget _buildControlsOverlay({required bool fullscreen}) {
    final ctrl = _videoCtrl;
    final isPlaying = ctrl?.value.isPlaying ?? false;
    final isBuffering = ctrl?.value.isBuffering ?? false;

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
              // Dark gradient for control visibility
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

              // Centre: buffering spinner or play controls
              Center(
                child: isBuffering && _videoInitialised
                    ? const SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _iconBtn(
                            icon: Icons.replay_10_rounded,
                            onTap: _seekBackward,
                            size: 36,
                          ),
                          const SizedBox(width: 28),
                          _iconBtn(
                            icon: isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_filled_rounded,
                            onTap: _togglePlay,
                            size: 58,
                          ),
                          const SizedBox(width: 28),
                          _iconBtn(
                            icon: Icons.forward_10_rounded,
                            onTap: _seekForward,
                            size: 36,
                          ),
                        ],
                      ),
              ),

              // Bottom bar: progress + time + fullscreen button
              if (_videoInitialised)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildBottomBar(fullscreen: fullscreen),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom control bar ───────────────────────────────────────────

  Widget _buildBottomBar({required bool fullscreen}) {
    final ctrl = _videoCtrl!;
    final position = ctrl.value.position;
    final duration = ctrl.value.duration;
    final durationMs = duration.inMilliseconds;

    // Compute buffered %
    double bufferedFraction = 0.0;
    if (durationMs > 0 && ctrl.value.buffered.isNotEmpty) {
      final bufEndMs = ctrl.value.buffered.last.end.inMilliseconds;
      bufferedFraction = (bufEndMs / durationMs).clamp(0.0, 1.0);
    }

    final hPad = fullscreen ? 20.0 : 12.0;
    final bPad = fullscreen ? 20.0 : 10.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, bPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Custom seekable progress bar
          _buildProgressBar(
            bufferedFraction: bufferedFraction,
            durationMs: durationMs,
          ),

          const SizedBox(height: 2),

          // Time labels + fullscreen toggle
          Row(
            children: [
              Text(
                _fmt(position),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                ' / ',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
              Text(
                _fmt(duration),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              // Fullscreen button lives here (YouTube-style)
              GestureDetector(
                onTap: _toggleFullscreen,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    fullscreen
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

  // ── Custom progress bar with buffer track and draggable thumb ────

  Widget _buildProgressBar({
    required double bufferedFraction,
    required int durationMs,
  }) {
    const trackH = 3.0;
    const thumbR = 6.0;

    return SizedBox(
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          Container(
            height: trackH,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(trackH / 2),
            ),
          ),

          // Buffered track
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: bufferedFraction,
              child: Container(
                height: trackH,
                decoration: BoxDecoration(
                  color: Colors.white38,
                  borderRadius: BorderRadius.circular(trackH / 2),
                ),
              ),
            ),
          ),

          // Played track
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: _sliderValue.clamp(0.0, 1.0),
              child: Container(
                height: trackH,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE000),
                  borderRadius: BorderRadius.circular(trackH / 2),
                ),
              ),
            ),
          ),

          // Invisible-track Slider for drag interaction
          SliderTheme(
            data: SliderThemeData(
              trackHeight: trackH,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: thumbR),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              thumbColor: const Color(0xFFFFE000),
              overlayColor:
                  const Color(0xFFFFE000).withValues(alpha: 0.25),
            ),
            child: Slider(
              value: _sliderValue.clamp(0.0, 1.0),
              onChangeStart: (_) {
                _isDraggingSlider = true;
                _hideTimer?.cancel();
              },
              onChanged: (v) => setState(() => _sliderValue = v),
              onChangeEnd: (v) {
                if (durationMs > 0) {
                  _videoCtrl?.seekTo(
                    Duration(milliseconds: (v * durationMs).round()),
                  );
                }
                _isDraggingSlider = false;
                _resetHideTimer();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Reusable icon button ─────────────────────────────────────────

  Widget _iconBtn({
    required IconData icon,
    required VoidCallback onTap,
    double size = 28,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Icon(icon, color: Colors.white, size: size),
    );
  }
}

class _LessonGameCard extends StatelessWidget {
  const _LessonGameCard({required this.game});
  final Game game;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        GameController.to.selectGame(game);
        Get.to(() => GameDetailScreen(game: game));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF4DA6E8).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF4DA6E8).withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.sports_esports_rounded,
                color: Color(0xFF4DA6E8), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    style: const TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (game.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      game.description,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4DA6E8).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                game.type,
                style: const TextStyle(
                  color: Color(0xFF4DA6E8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Color(0xFF9CA3AF), size: 14),
          ],
        ),
      ),
    );
  }
}
