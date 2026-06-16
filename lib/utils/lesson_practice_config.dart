import 'package:flutter/widgets.dart';

/// Question count for games opened from a lesson's প্র্যাকটিস section.
const int kLessonPracticeQuestions = 3;

/// Provides optional session length to nested lesson games.
class LessonSessionScope extends InheritedWidget {
  const LessonSessionScope({
    super.key,
    required this.sessionRounds,
    required super.child,
  });

  final int? sessionRounds;

  static int roundsFor(BuildContext context, int defaultRounds) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<LessonSessionScope>();
    return scope?.sessionRounds ?? defaultRounds;
  }

  static int itemCountFor(BuildContext context, int fullCount) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<LessonSessionScope>();
    final rounds = scope?.sessionRounds;
    if (rounds == null) return fullCount;
    return rounds < fullCount ? rounds : fullCount;
  }

  @override
  bool updateShouldNotify(LessonSessionScope oldWidget) =>
      oldWidget.sessionRounds != sessionRounds;
}
