import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/gamification_content_controller.dart';
import 'package:ez_trainz/models/gamification_api_models.dart';
import 'package:ez_trainz/screens/gamification_quiz_detail_screen.dart';

class GamificationContentScreen extends StatefulWidget {
  const GamificationContentScreen({super.key});

  @override
  State<GamificationContentScreen> createState() =>
      _GamificationContentScreenState();
}

class _GamificationContentScreenState extends State<GamificationContentScreen>
    with SingleTickerProviderStateMixin {
  static const _bg = Color(0xFF4DA6E8);
  static const _accent = Color(0xFFFFE000);

  late TabController _tabs;
  final _lessonIdCtrl = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    GamificationContentController.to.fetchAllQuizzes();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _lessonIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _openQuizSummary(GamQuizSummary s) async {
    if (s.embeddedDetail != null) {
      await Get.to(() => GamificationQuizDetailScreen(quiz: s.embeddedDetail!));
      return;
    }
    final lid = s.lessonId;
    if (lid != null && lid.isNotEmpty) {
      final d = await GamificationContentController.to.fetchQuizForLesson(lid);
      if (!mounted) return;
      if (d != null) {
        await Get.to(() => GamificationQuizDetailScreen(quiz: d));
      }
      return;
    }

    final lessonCtrl = TextEditingController();
    try {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Load quiz'),
          content: TextField(
            controller: lessonCtrl,
            decoration: const InputDecoration(
              labelText: 'lessonId',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.text,
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                final id = lessonCtrl.text.trim();
                Navigator.pop(ctx);
                if (id.isEmpty) return;
                final d =
                    await GamificationContentController.to.fetchQuizForLesson(id);
                if (!mounted) return;
                if (d != null) {
                  await Get.to(() => GamificationQuizDetailScreen(quiz: d));
                }
              },
              child: const Text('Load'),
            ),
          ],
        ),
      );
    } finally {
      lessonCtrl.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        title: const Text(
          'Quizzes & drills',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: GamificationContentController.to.fetchAllQuizzes,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: _accent,
          labelColor: _accent,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Quizzes'),
            Tab(text: 'Drills'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _QuizCatalogTab(onOpen: _openQuizSummary),
          _DrillsTab(lessonIdCtrl: _lessonIdCtrl),
        ],
      ),
    );
  }
}

class _QuizCatalogTab extends StatelessWidget {
  const _QuizCatalogTab({required this.onOpen});
  final Future<void> Function(GamQuizSummary s) onOpen;

  @override
  Widget build(BuildContext context) {
    final ctrl = GamificationContentController.to;
    return Obx(() {
      if (ctrl.isLoading.value && ctrl.quizCatalog.isEmpty) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFFFFE000)));
      }
      if (ctrl.error.value.isNotEmpty && ctrl.quizCatalog.isEmpty) {
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
      if (ctrl.quizCatalog.isEmpty) {
        return Center(
          child: Text(
            'No quizzes returned.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16),
          ),
        );
      }
      return RefreshIndicator(
        color: const Color(0xFFFFE000),
        onRefresh: () async {
          await ctrl.fetchAllQuizzes();
        },
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: ctrl.quizCatalog.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final q = ctrl.quizCatalog[i];
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                title: Text(
                  q.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _MiniChip(
                        text: 'id: ${q.id}',
                        color: Colors.grey.shade800,
                      ),
                      if (q.lessonId != null && q.lessonId!.isNotEmpty)
                        _MiniChip(text: 'lesson: ${q.lessonId}', color: const Color(0xFF1E88E5)),
                      if (q.questionCount != null)
                        _MiniChip(
                          text: '${q.questionCount} questions',
                          color: const Color(0xFF0F766E),
                        ),
                      if (q.embeddedDetail != null)
                        const _MiniChip(text: 'Ready to open', color: Color(0xFF7C3AED)),
                    ],
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => onOpen(q),
              ),
            );
          },
        ),
      );
    });
  }
}

class _DrillsTab extends StatelessWidget {
  const _DrillsTab({required this.lessonIdCtrl});
  final TextEditingController lessonIdCtrl;

  @override
  Widget build(BuildContext context) {
    final ctrl = GamificationContentController.to;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Load by lesson',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
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
              Obx(() {
                final busy = ctrl.isLoading.value;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _DrillBtn(
                      label: 'Grammar',
                      busy: busy,
                      onTap: () => ctrl.fetchGrammarForLesson(lessonIdCtrl.text.trim()),
                    ),
                    _DrillBtn(
                      label: 'Fill gaps',
                      busy: busy,
                      onTap: () =>
                          ctrl.fetchFillGapsForLesson(lessonIdCtrl.text.trim()),
                    ),
                    _DrillBtn(
                      label: 'Matching',
                      busy: busy,
                      onTap: () =>
                          ctrl.fetchMatchingForLesson(lessonIdCtrl.text.trim()),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (ctrl.error.value.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                ctrl.error.value,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        Obx(() {
          final p = ctrl.lessonDrill.value;
          if (p == null) {
            return Text(
              'Load grammar, fill-gaps, or matching for a lesson to preview items here.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), height: 1.35),
            );
          }
          return _DrillPayloadCard(payload: p);
        }),
      ],
    );
  }
}

class _DrillBtn extends StatelessWidget {
  const _DrillBtn({
    required this.label,
    required this.busy,
    required this.onTap,
  });
  final String label;
  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: busy ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFE000),
        foregroundColor: const Color(0xFF1A1A2E),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class _DrillPayloadCard extends StatelessWidget {
  const _DrillPayloadCard({required this.payload});
  final GamLessonPayload payload;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            payload.title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${payload.kind} · ${payload.items.length} items',
            style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (payload.items.isEmpty)
            const Text('No items in this response.')
          else
            ...List.generate(payload.items.length, (i) {
              final row = payload.items[i];
              final keys = row.keys.toList()..sort();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    title: Text(
                      'Item ${i + 1}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    children: keys
                        .map(
                          (k) => ListTile(
                            dense: true,
                            title: Text(k, style: const TextStyle(fontSize: 12)),
                            subtitle: SelectableText(
                              '${row[k]}',
                              style: const TextStyle(fontSize: 13, height: 1.35),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
