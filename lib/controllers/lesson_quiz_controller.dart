import 'package:get/get.dart';

import 'package:ez_trainz/controllers/hearts_controller.dart';
import 'package:ez_trainz/models/lesson_challenge.dart';

enum LessonQuizCtaState {
  check,
  continueNext,
  tryAgain,
}

class LessonQuizController extends GetxController {
  LessonQuizController({
    required List<LessonChallenge> challenges,
    required bool practiceMode,
    required bool showRomaji,
  })  : _challenges = challenges,
        _practiceMode = practiceMode,
        _showRomaji = showRomaji;

  final List<LessonChallenge> _challenges;
  final bool _practiceMode;
  final bool _showRomaji;

  final RxInt index = 0.obs;
  final RxnString selectedChoiceId = RxnString();
  final RxnBool lastAnswerCorrect = RxnBool();
  final Rx<LessonQuizCtaState> cta = LessonQuizCtaState.check.obs;

  bool get practiceMode => _practiceMode;
  bool get showRomaji => _showRomaji;

  int get total => _challenges.length;
  LessonChallenge get current => _challenges[index.value];

  double get progress {
    if (total == 0) return 0;
    return (index.value) / total;
  }

  void select(String choiceId) {
    if (cta.value != LessonQuizCtaState.check) return;
    selectedChoiceId.value = choiceId;
  }

  /// Returns true if it was a correct answer.
  bool checkAnswer() {
    final selected = selectedChoiceId.value;
    if (selected == null) return false;
    final correct = selected == current.correctChoiceId;
    lastAnswerCorrect.value = correct;
    if (correct) {
      cta.value = LessonQuizCtaState.continueNext;
    } else {
      if (!_practiceMode) {
        HeartsController.to.loseOne();
      }
      cta.value = LessonQuizCtaState.tryAgain;
    }
    return correct;
  }

  bool advance() {
    if (index.value + 1 >= total) return false;
    index.value++;
    selectedChoiceId.value = null;
    lastAnswerCorrect.value = null;
    cta.value = LessonQuizCtaState.check;
    return true;
  }

  void retry() {
    selectedChoiceId.value = null;
    lastAnswerCorrect.value = null;
    cta.value = LessonQuizCtaState.check;
  }
}

