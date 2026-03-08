import 'package:flutter/material.dart';
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
  }

  @override
  void dispose() {
    _videoCtrl?.dispose();
    super.dispose();
  }

  // ── Toggle play / pause ──────────────────────────────────────────
  void _togglePlay() {
    if (_videoCtrl == null || !_videoInitialised) return;
    setState(() {
      _videoCtrl!.value.isPlaying
          ? _videoCtrl!.pause()
          : _videoCtrl!.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lesson = CourseController.to.selectedLesson;
    if (lesson == null) {
      return Scaffold(
        body: Center(child: Text('lesson_not_found'.tr)),
      );
    }

    final hasVideo = CourseController.to.getVideoUrl(lesson.id) != null;

    return Scaffold(
      backgroundColor: const Color(0xFF4DA6E8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── BACK BUTTON ────────────────────────────────────
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
                    border: Border.all(color: Colors.white38, width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.white, size: 14),
                      SizedBox(width: 4),
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

            // ── VIDEO PLAYER ───────────────────────────────────
            if (hasVideo)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _buildVideoPlayer(),
                  ),
                ),
              ),

            if (hasVideo) const SizedBox(height: 20),

            // ── LESSON CONTENT ─────────────────────────────────
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Title ────────────────────────────────
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

                      // ── Divider ──────────────────────────────
                      Container(
                        height: 1,
                        color: const Color(0xFFE5E7EB),
                      ),
                      const SizedBox(height: 20),

                      // ── Body content ─────────────────────────
                      Text(
                        lesson.content.body,
                        style: const TextStyle(
                          color: Color(0xFF374151),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                        ),
                      ),

                      // ── Quizzes section ──────────────────────
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
                        ...lesson.quizzes.map((quiz) => Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFFFFA726).withValues(alpha: 0.08),
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
                                          'passing_score'.trParams({'score': quiz.passingScore.toString()}),
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
                                      borderRadius:
                                          BorderRadius.circular(16),
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
                            )),
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

  // ── Video player builder ─────────────────────────────────────────
  Widget _buildVideoPlayer() {
    if (_videoError) {
      return Container(
        color: const Color(0xFF1A1A2E),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  color: Colors.white54, size: 36),
              SizedBox(height: 8),
              Text('failed_load_video'.tr,
                  style: const TextStyle(color: Colors.white54, fontSize: 13)),
            ],
          ),
        ),
      );
    }

    if (!_videoInitialised) {
      return Container(
        color: const Color(0xFF1A1A2E),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_videoCtrl!),

          // ── Play/pause overlay ──────────────────────────
          AnimatedOpacity(
            opacity: _videoCtrl!.value.isPlaying ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 36),
            ),
          ),

          // ── Progress bar ────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: VideoProgressIndicator(
              _videoCtrl!,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: Color(0xFFFFE000),
                bufferedColor: Colors.white30,
                backgroundColor: Colors.white12,
              ),
              padding: const EdgeInsets.symmetric(vertical: 4),
            ),
          ),
        ],
      ),
    );
  }
}
