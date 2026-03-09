import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import 'package:ez_trainz/controllers/course_controller.dart';

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
  Timer? _hideTimer;

  static const _seekStep = Duration(seconds: 10);

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
        if (mounted) setState(() => _videoInitialised = true);
      }).catchError((_) {
        if (mounted) setState(() => _videoError = true);
      });
    _videoCtrl!.addListener(_onVideoUpdate);
  }

  void _onVideoUpdate() {
    if (mounted) setState(() {});
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
    if (_videoCtrl == null || !_videoInitialised) return;
    _videoCtrl!.value.isPlaying ? _videoCtrl!.pause() : _videoCtrl!.play();
    _resetHideTimer();
  }

  void _seekForward() {
    if (_videoCtrl == null || !_videoInitialised) return;
    final target = _videoCtrl!.value.position + _seekStep;
    final dur = _videoCtrl!.value.duration;
    _videoCtrl!.seekTo(target > dur ? dur : target);
    _resetHideTimer();
  }

  void _seekBackward() {
    if (_videoCtrl == null || !_videoInitialised) return;
    final target = _videoCtrl!.value.position - _seekStep;
    _videoCtrl!.seekTo(target < Duration.zero ? Duration.zero : target);
    _resetHideTimer();
  }

  // ── Controls visibility ──────────────────────────────────────────

  void _onVideoTap() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _resetHideTimer();
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    if (!mounted) return;
    setState(() => _showControls = true);
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && (_videoCtrl?.value.isPlaying ?? false)) {
        setState(() => _showControls = false);
      }
    });
  }

  // ── Fullscreen ───────────────────────────────────────────────────

  Future<void> _toggleFullscreen() async {
    if (_isFullscreen) {
      await _restoreSystemUI();
      if (mounted) setState(() => _isFullscreen = false);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      if (mounted) setState(() => _isFullscreen = true);
    }
    _resetHideTimer();
  }

  Future<void> _restoreSystemUI() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  // ── Helpers ──────────────────────────────────────────────────────

  String _fmt(Duration d) {
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
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 16:9 video centred on black background
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    Positioned.fill(child: _buildVideoContent()),
                    _buildControlsOverlay(),
                  ],
                ),
              ),
              // Fullscreen exit button below the video
              _buildFullscreenToggleBar(),
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Colors.white38, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text('back'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          )),
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
                      children: [
                        Positioned.fill(child: _buildVideoContent()),
                        _buildControlsOverlay(),
                      ],
                    ),
                  ),
                ),
              ),

            // ── Fullscreen toggle button below video ──────
            if (hasVideo) _buildFullscreenToggleBar(),

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

  // ── Raw video surface (error / loading / player) ─────────────────

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
              Text('failed_load_video'.tr,
                  style:
                      const TextStyle(color: Colors.white54, fontSize: 13)),
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

  // ── Controls overlay (inside video) ─────────────────────────────

  Widget _buildControlsOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onVideoTap,
        child: AnimatedOpacity(
          opacity: _showControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 250),
          child: IgnorePointer(
            ignoring: !_showControls,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.65),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
              child: Column(
                children: [
                  // ── Centre row: rewind | play/pause | forward ──
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _iconBtn(
                          icon: Icons.replay_10_rounded,
                          onTap: _seekBackward,
                          size: 36,
                        ),
                        const SizedBox(width: 28),
                        _iconBtn(
                          icon: (_videoCtrl?.value.isPlaying ?? false)
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_filled_rounded,
                          onTap: _togglePlay,
                          size: 56,
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

                  // ── Bottom row: time + progress bar ────
                  if (_videoInitialised)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          VideoProgressIndicator(
                            _videoCtrl!,
                            allowScrubbing: true,
                            colors: const VideoProgressColors(
                              playedColor: Color(0xFFFFE000),
                              bufferedColor: Colors.white30,
                              backgroundColor: Colors.white24,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _fmt(_videoCtrl!.value.position),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _fmt(_videoCtrl!.value.duration),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Fullscreen toggle bar (below the video) ──────────────────────

  Widget _buildFullscreenToggleBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: _toggleFullscreen,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white38, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isFullscreen
                        ? Icons.fullscreen_exit_rounded
                        : Icons.fullscreen_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isFullscreen ? 'Exit' : 'Fullscreen',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
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
      onTap: onTap,
      child: Icon(icon, color: Colors.white, size: size),
    );
  }

}
