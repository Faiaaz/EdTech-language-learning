import 'package:get/get.dart';

import 'package:ez_trainz/controllers/auth_controller.dart';
import 'package:ez_trainz/models/gamification_api_models.dart';
import 'package:ez_trainz/services/gamification_content_service.dart';
import 'package:ez_trainz/services/game_service.dart';

class GamificationContentController extends GetxController {
  static GamificationContentController get to => Get.find();

  final isLoading = false.obs;
  final error = ''.obs;

  final quizCatalog = <GamQuizSummary>[].obs;
  final quizDetail = Rxn<GamQuizDetail>();
  final submitResult = Rxn<GamQuizSubmitResult>();
  final lessonDrill = Rxn<GamLessonPayload>();

  void _clearDrill() => lessonDrill.value = null;
  void _clearQuizDetail() => quizDetail.value = null;

  static List<Map<String, dynamic>> _asMapList(dynamic data) {
    if (data is List) {
      return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return const [];
  }

  Future<void> fetchAllQuizzes() async {
    isLoading.value = true;
    error.value = '';
    _clearDrill();
    try {
      final data = await GamificationContentService.fetchAllQuizzes();
      final rows = _asMapList(data);
      quizCatalog.assignAll(
        rows.map(GamQuizSummary.fromJson).where((q) => q.id.isNotEmpty).toList(),
      );
    } on GamificationContentException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<GamQuizDetail?> fetchQuizForLesson(String lessonId) async {
    isLoading.value = true;
    error.value = '';
    _clearDrill();
    try {
      final data = await GamificationContentService.fetchQuizForLesson(lessonId);
      if (data is Map<String, dynamic>) {
        final d = GamQuizDetail.fromJson(Map<String, dynamic>.from(data));
        quizDetail.value = d;
        return d;
      }
      quizDetail.value = null;
      return null;
    } on GamificationContentException catch (e) {
      error.value = e.message;
      quizDetail.value = null;
      return null;
    } catch (e) {
      error.value = e.toString();
      quizDetail.value = null;
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitQuiz({
    required String quizId,
    required List<Map<String, dynamic>> answers,
  }) async {
    isLoading.value = true;
    error.value = '';
    submitResult.value = null;
    try {
      final jwt = AuthController.to.accessToken;
      final cognitoId = AuthController.to.cognitoId ??
          GameService.extractSubFromToken(jwt) ??
          '';
      if (cognitoId.isEmpty) {
        throw const GamificationContentException(
          'Missing cognitoId (login required).',
        );
      }

      final data = await GamificationContentService.submitQuiz(
        cognitoId: cognitoId,
        quizId: quizId,
        answers: answers,
      );
      if (data is Map<String, dynamic>) {
        submitResult.value = GamQuizSubmitResult.fromJson(data);
      } else {
        submitResult.value = null;
      }
    } on GamificationContentException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchGrammarForLesson(String lessonId) async {
    isLoading.value = true;
    error.value = '';
    _clearQuizDetail();
    try {
      final data = await GamificationContentService.fetchGrammarForLesson(lessonId);
      if (data is Map<String, dynamic>) {
        lessonDrill.value = GamLessonPayload.grammar(Map<String, dynamic>.from(data));
      } else {
        lessonDrill.value = null;
      }
    } on GamificationContentException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchFillGapsForLesson(String lessonId) async {
    isLoading.value = true;
    error.value = '';
    _clearQuizDetail();
    try {
      final data =
          await GamificationContentService.fetchFillGapsForLesson(lessonId);
      if (data is Map<String, dynamic>) {
        lessonDrill.value =
            GamLessonPayload.fillGaps(Map<String, dynamic>.from(data));
      } else {
        lessonDrill.value = null;
      }
    } on GamificationContentException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMatchingForLesson(String lessonId) async {
    isLoading.value = true;
    error.value = '';
    _clearQuizDetail();
    try {
      final data =
          await GamificationContentService.fetchMatchingForLesson(lessonId);
      if (data is Map<String, dynamic>) {
        lessonDrill.value =
            GamLessonPayload.matching(Map<String, dynamic>.from(data));
      } else {
        lessonDrill.value = null;
      }
    } on GamificationContentException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
