import 'package:ez_trainz/services/sm2_srs_service.dart';

sealed class DailySessionStep {
  const DailySessionStep();
}

class SrsReviewStep extends DailySessionStep {
  final List<SrsCard> cards;
  const SrsReviewStep({required this.cards});
}

class MicroLessonStep extends DailySessionStep {
  final String title;
  final String excerpt;
  const MicroLessonStep({required this.title, required this.excerpt});
}

class QuickCheckStep extends DailySessionStep {
  final String title;
  final String prompt;
  const QuickCheckStep({required this.title, required this.prompt});
}

class WrapUpStep extends DailySessionStep {
  final String title;
  final String message;
  const WrapUpStep({required this.title, required this.message});
}

class DailySessionPlan {
  final List<DailySessionStep> steps;
  const DailySessionPlan({required this.steps});
}

