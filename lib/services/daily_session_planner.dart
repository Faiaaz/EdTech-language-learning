import 'dart:math' as math;

import 'package:ez_trainz/models/daily_session.dart';
import 'package:ez_trainz/models/lesson.dart';
import 'package:ez_trainz/services/sm2_srs_service.dart';

class DailySessionPlanner {
  const DailySessionPlanner();

  DailySessionPlan build({
    required Lesson lesson,
    required List<SrsCard> dueCards,
    int maxSrsCards = 3,
  }) {
    final steps = <DailySessionStep>[];

    // 1) SRS reviews (1–3 due cards)
    if (dueCards.isNotEmpty) {
      steps.add(SrsReviewStep(
        cards: dueCards.take(maxSrsCards).toList(),
      ));
    }

    // 2) Micro lesson (comprehensible input)
    final excerpt = _excerpt(lesson.content.body, maxChars: 360);
    steps.add(MicroLessonStep(
      title: lesson.title,
      excerpt: excerpt,
    ));

    // 3) Quick check (active recall-ish)
    // NOTE: LMS quiz items don’t include questions yet; we keep this as a self-check.
    final prompt = lesson.quizzes.isNotEmpty
        ? 'Quick check: did you understand “${lesson.quizzes.first.title}”?'
        : 'Quick check: can you explain today’s lesson in one sentence?';
    steps.add(QuickCheckStep(title: 'Quick check', prompt: prompt));

    // 4) Wrap up (never end on failure)
    steps.add(const WrapUpStep(
      title: 'Nice work',
      message: 'Session complete. You’re building momentum — come back tomorrow to protect your streak.',
    ));

    return DailySessionPlan(steps: steps);
  }

  String _excerpt(String body, {required int maxChars}) {
    final normalized = body.replaceAll(RegExp(r'\\s+'), ' ').trim();
    if (normalized.length <= maxChars) return normalized;
    final cutoff = math.min(maxChars, normalized.length);
    final slice = normalized.substring(0, cutoff);
    final lastPeriod = slice.lastIndexOf('.');
    if (lastPeriod > 160) return slice.substring(0, lastPeriod + 1).trim();
    return '${slice.trim()}…';
  }
}

