import 'package:get/get.dart';

import 'package:ez_trainz/controllers/auth_controller.dart';
import 'package:ez_trainz/models/lms_api_models.dart';
import 'package:ez_trainz/services/lms_service.dart';

class LmsController extends GetxController {
  static LmsController get to => Get.find();

  final catalogCourses = <LmsCourseSummary>[].obs;
  final myEnrollments = <LmsMyEnrollment>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  static List<Map<String, dynamic>> _asMapList(dynamic data) {
    if (data is List) {
      return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (data is Map && data['items'] is List) {
      return (data['items'] as List)
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }

  Future<void> loadCourses() async {
    final token = AuthController.to.accessToken;
    if (token.isEmpty) {
      error.value = 'Login required.';
      return;
    }

    isLoading.value = true;
    error.value = '';
    try {
      final data = await LmsService.fetchCourses(bearerToken: token);
      final rows = _asMapList(data);
      catalogCourses.value =
          rows.map(LmsCourseSummary.fromJson).where((c) => c.id.isNotEmpty).toList();
    } on LmsException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMyCourses() async {
    final token = AuthController.to.accessToken;
    if (token.isEmpty) {
      error.value = 'Login required.';
      return;
    }

    isLoading.value = true;
    error.value = '';
    try {
      final data = await LmsService.fetchMyCourses(bearerToken: token);
      final rows = _asMapList(data);
      myEnrollments.value =
          rows.map(LmsMyEnrollment.fromJson).where((e) => e.courseId.isNotEmpty).toList();
    } on LmsException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> enroll(String courseId) async {
    final token = AuthController.to.accessToken;
    if (token.isEmpty) {
      error.value = 'Login required.';
      return;
    }
    isLoading.value = true;
    error.value = '';
    try {
      await LmsService.enroll(bearerToken: token, courseId: courseId);
      await loadMyCourses();
    } on LmsException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> unenroll(String courseId) async {
    final token = AuthController.to.accessToken;
    if (token.isEmpty) {
      error.value = 'Login required.';
      return;
    }
    isLoading.value = true;
    error.value = '';
    try {
      await LmsService.unenroll(bearerToken: token, courseId: courseId);
      await loadMyCourses();
    } on LmsException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateLessonProgress({
    required String lessonId,
    required bool completed,
    required double progressPct,
  }) async {
    final token = AuthController.to.accessToken;
    if (token.isEmpty) {
      error.value = 'Login required.';
      return;
    }
    isLoading.value = true;
    error.value = '';
    try {
      await LmsService.updateLessonProgress(
        bearerToken: token,
        lessonId: lessonId,
        completed: completed,
        progressPct: progressPct,
      );
    } on LmsException catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  LmsCourseSummary? findCatalogCourse(String courseId) {
    for (final c in catalogCourses) {
      if (c.id == courseId) return c;
    }
    return null;
  }
}
