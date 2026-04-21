import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/lms_controller.dart';
import 'package:ez_trainz/models/lms_api_models.dart';
import 'package:ez_trainz/screens/lms_course_detail_screen.dart';

class LmsApiScreen extends StatefulWidget {
  const LmsApiScreen({super.key});

  @override
  State<LmsApiScreen> createState() => _LmsApiScreenState();
}

class _LmsApiScreenState extends State<LmsApiScreen>
    with SingleTickerProviderStateMixin {
  static const _bg = Color(0xFF4DA6E8);
  static const _accent = Color(0xFFFFE000);

  late TabController _tabs;

  final _courseIdCtrl = TextEditingController();
  final _lessonIdCtrl = TextEditingController();
  final _progressCtrl = TextEditingController(text: '100');
  bool _completed = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    LmsController.to.loadCourses();
    LmsController.to.loadMyCourses();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _courseIdCtrl.dispose();
    _lessonIdCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = LmsController.to;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        title: const Text('LMS', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            onPressed: () {
              ctrl.loadCourses();
              ctrl.loadMyCourses();
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: _accent,
          labelColor: _accent,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Catalog'),
            Tab(text: 'My courses'),
            Tab(text: 'Actions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _CatalogTab(onOpen: (c) => Get.to(() => LmsCourseDetailScreen(course: c))),
          _MyCoursesTab(
            onOpenCatalog: (id) {
              final c = ctrl.findCatalogCourse(id);
              if (c != null) {
                Get.to(() => LmsCourseDetailScreen(course: c));
              } else {
                Get.snackbar(
                  'Not in catalog',
                  'This enrollment id was not found in the loaded catalog list.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.white,
                  colorText: const Color(0xFF1A1A2E),
                );
              }
            },
          ),
          _ActionsTab(
            courseIdCtrl: _courseIdCtrl,
            lessonIdCtrl: _lessonIdCtrl,
            progressCtrl: _progressCtrl,
            completed: _completed,
            onCompletedChanged: (v) => setState(() => _completed = v),
          ),
        ],
      ),
    );
  }
}

class _CatalogTab extends StatelessWidget {
  const _CatalogTab({required this.onOpen});
  final void Function(LmsCourseSummary course) onOpen;

  @override
  Widget build(BuildContext context) {
    final ctrl = LmsController.to;
    return Obx(() {
      if (ctrl.isLoading.value && ctrl.catalogCourses.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFFFFE000)));
      }
      if (ctrl.error.value.isNotEmpty && ctrl.catalogCourses.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              ctrl.error.value,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
      return RefreshIndicator(
        color: const Color(0xFFFFE000),
        onRefresh: () async {
          await ctrl.loadCourses();
        },
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: ctrl.catalogCourses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final c = ctrl.catalogCourses[i];
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onOpen(c),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              c.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Enroll',
                            onPressed: ctrl.isLoading.value
                                ? null
                                : () => ctrl.enroll(c.id),
                            icon: const Icon(Icons.add_circle_outline_rounded,
                                color: Color(0xFF1E88E5)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          if (c.level != null && c.level!.isNotEmpty)
                            _Chip(text: c.level!, color: const Color(0xFF1E88E5)),
                          _Chip(
                            text: '${c.lessons.length} lessons',
                            color: Colors.grey.shade700,
                          ),
                        ],
                      ),
                      if (c.description != null && c.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          c.description!,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey.shade800, height: 1.3),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

class _MyCoursesTab extends StatelessWidget {
  const _MyCoursesTab({required this.onOpenCatalog});
  final void Function(String courseId) onOpenCatalog;

  @override
  Widget build(BuildContext context) {
    final ctrl = LmsController.to;
    return Obx(() {
      if (ctrl.isLoading.value && ctrl.myEnrollments.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFFFFE000)));
      }
      if (ctrl.myEnrollments.isEmpty) {
        return Center(
          child: Text(
            'No enrollments yet.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16),
          ),
        );
      }
      return RefreshIndicator(
        color: const Color(0xFFFFE000),
        onRefresh: () async {
          await ctrl.loadMyCourses();
        },
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: ctrl.myEnrollments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final e = ctrl.myEnrollments[i];
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Course ${e.courseId}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    if (e.enrolledAt != null && e.enrolledAt!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Enrolled: ${e.enrolledAt}',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: ctrl.isLoading.value
                              ? null
                              : () => onOpenCatalog(e.courseId),
                          child: const Text('Open in catalog'),
                        ),
                        const SizedBox(width: 10),
                        TextButton(
                          onPressed: ctrl.isLoading.value
                              ? null
                              : () => ctrl.unenroll(e.courseId),
                          child: const Text(
                            'Unenroll',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

class _ActionsTab extends StatelessWidget {
  const _ActionsTab({
    required this.courseIdCtrl,
    required this.lessonIdCtrl,
    required this.progressCtrl,
    required this.completed,
    required this.onCompletedChanged,
  });

  final TextEditingController courseIdCtrl;
  final TextEditingController lessonIdCtrl;
  final TextEditingController progressCtrl;
  final bool completed;
  final ValueChanged<bool> onCompletedChanged;

  @override
  Widget build(BuildContext context) {
    final ctrl = LmsController.to;
    return Obx(() {
      final loading = ctrl.isLoading.value;
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (ctrl.error.value.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                ctrl.error.value,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          _GlassCard(
            title: 'Enroll / Unenroll',
            child: Column(
              children: [
                TextField(
                  controller: courseIdCtrl,
                  decoration: const InputDecoration(
                    labelText: 'courseId',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            loading ? null : () => ctrl.enroll(courseIdCtrl.text.trim()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFE000),
                          foregroundColor: const Color(0xFF1A1A2E),
                        ),
                        child: const Text('Enroll'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: loading
                            ? null
                            : () => ctrl.unenroll(courseIdCtrl.text.trim()),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.7)),
                        ),
                        child: const Text('Unenroll'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _GlassCard(
            title: 'Lesson progress',
            child: Column(
              children: [
                TextField(
                  controller: lessonIdCtrl,
                  decoration: const InputDecoration(
                    labelText: 'lessonId',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: progressCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'progressPct (0–100)',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                SwitchListTile.adaptive(
                  value: completed,
                  onChanged: loading ? null : onCompletedChanged,
                  title: const Text('completed', style: TextStyle(color: Colors.white)),
                  contentPadding: EdgeInsets.zero,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading
                        ? null
                        : () async {
                            final lid = lessonIdCtrl.text.trim();
                            if (lid.isEmpty) return;
                            final pct = double.tryParse(progressCtrl.text.trim()) ?? 0;
                            await ctrl.updateLessonProgress(
                              lessonId: lid,
                              completed: completed,
                              progressPct: pct,
                            );
                            final err = ctrl.error.value;
                            Get.snackbar(
                              err.isEmpty ? 'Saved' : 'Error',
                              err.isEmpty ? 'Lesson progress updated.' : err,
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor:
                                  err.isEmpty ? Colors.white : Colors.redAccent,
                              colorText: err.isEmpty
                                  ? const Color(0xFF1A1A2E)
                                  : Colors.white,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFE000),
                      foregroundColor: const Color(0xFF1A1A2E),
                    ),
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}
