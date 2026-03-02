import 'package:get/get.dart';

import 'package:ez_trainz/models/course.dart';
import 'package:ez_trainz/models/lesson.dart';
import 'package:ez_trainz/services/course_service.dart';

class CourseController extends GetxController {
  static CourseController get to => Get.find();

  // ── Observable state ─────────────────────────────────────────────
  final courses = <Course>[].obs;
  final lessons = <Lesson>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

  // ── Currently selected ───────────────────────────────────────────
  final _selectedCourse = Rxn<Course>();
  final _selectedLesson = Rxn<Lesson>();

  Course? get selectedCourse => _selectedCourse.value;
  Lesson? get selectedLesson => _selectedLesson.value;

  @override
  void onInit() {
    super.onInit();
    loadCourses();
  }

  // ── Load all courses ─────────────────────────────────────────────
  /// TODO: replace static call with [CourseService.fetchCourses] once API is ready
  void loadCourses() {
    isLoading.value = true;
    error.value = '';
    try {
      // ── STATIC: swap this block with the async API call ──
      courses.value = CourseService.getStaticCourses();
      // ── FUTURE API USAGE: ────────────────────────────────
      // final token = AuthController.to.accessToken;
      // courses.value = await CourseService.fetchCourses(accessToken: token);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Select a course & load its lessons ───────────────────────────
  void selectCourse(Course course) {
    _selectedCourse.value = course;
    loadLessonsForCourse(course.id);
  }

  // ── Load lessons for a specific course ───────────────────────────
  /// TODO: replace static call with [CourseService.fetchLessons] once API is ready
  void loadLessonsForCourse(int courseId) {
    isLoading.value = true;
    error.value = '';
    try {
      // ── STATIC: filter from full list ────────────────────
      final allLessons = CourseService.getStaticLessons();
      lessons.value =
          allLessons.where((l) => l.courseId == courseId).toList();
      // ── FUTURE API USAGE: ────────────────────────────────
      // final token = AuthController.to.accessToken;
      // lessons.value = await CourseService.fetchLessons(
      //   courseId: courseId,
      //   accessToken: token,
      // );
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Select a lesson ──────────────────────────────────────────────
  void selectLesson(Lesson lesson) {
    _selectedLesson.value = lesson;
  }

  // ── Get video URL for a lesson ───────────────────────────────────
  /// TODO: replace with [CourseService.fetchVideoUrl] once API is ready
  String? getVideoUrl(int lessonId) {
    return CourseService.getVideoUrl(lessonId);
    // ── FUTURE API USAGE: ──────────────────────────────────
    // final token = AuthController.to.accessToken;
    // return await CourseService.fetchVideoUrl(
    //   lessonId: lessonId,
    //   accessToken: token,
    // );
  }
}
