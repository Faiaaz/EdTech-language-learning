import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:ez_trainz/models/course.dart';
import 'package:ez_trainz/models/lesson.dart';

class CourseException implements Exception {
  final String message;
  const CourseException(this.message);
}

class CourseService {
  static const _baseUrl =
      'https://arlvajyrck.execute-api.us-east-1.amazonaws.com/dev';

  // ── Video base URL (CloudFront) ──────────────────────────────────
  // TODO: replace with dynamic signed-URL fetching from API
  static const _videoBaseUrl =
      'https://d3c6o5lhf089bb.cloudfront.net';

  // ── Shared GET helper ────────────────────────────────────────────
  // ignore: unused_element
  static Future<dynamic> _get(
    String path, {
    String? accessToken,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');

    // ignore: avoid_print
    print('[CourseService] GET $uri');

    final headers = <String, String>{'Content-Type': 'application/json'};
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    late http.Response response;
    try {
      response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20));
    } on SocketException catch (e) {
      throw CourseException('No internet connection. ($e)');
    } on HandshakeException catch (e) {
      throw CourseException('SSL error. ($e)');
    } catch (e) {
      throw CourseException('Network error: $e');
    }

    // ignore: avoid_print
    print('[CourseService] Status: ${response.statusCode}');

    dynamic data;
    try {
      data = jsonDecode(response.body);
    } catch (_) {}

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    final apiMsg = (data is Map)
        ? (data['message'] as String? ??
            data['error'] as String? ??
            'Request failed (${response.statusCode}).')
        : 'Request failed (${response.statusCode}).';
    throw CourseException(apiMsg);
  }

  // ── Fetch all courses ────────────────────────────────────────────
  // TODO: uncomment and use when backend is ready
  // static Future<List<Course>> fetchCourses({String? accessToken}) async {
  //   final data = await _get('/courses', accessToken: accessToken);
  //   return (data as List<dynamic>)
  //       .map((c) => Course.fromJson(c as Map<String, dynamic>))
  //       .toList();
  // }

  // ── Fetch lessons for a course ───────────────────────────────────
  // TODO: uncomment and use when backend is ready
  // static Future<List<Lesson>> fetchLessons({
  //   required int courseId,
  //   String? accessToken,
  // }) async {
  //   final data = await _get('/courses/$courseId/lessons', accessToken: accessToken);
  //   return (data as List<dynamic>)
  //       .map((l) => Lesson.fromJson(l as Map<String, dynamic>))
  //       .toList();
  // }

  // ── Fetch single lesson ──────────────────────────────────────────
  // TODO: uncomment and use when backend is ready
  // static Future<Lesson> fetchLesson({
  //   required int lessonId,
  //   String? accessToken,
  // }) async {
  //   final data = await _get('/lessons/$lessonId', accessToken: accessToken);
  //   return Lesson.fromJson(data as Map<String, dynamic>);
  // }

  // ── Fetch video URL for a lesson ─────────────────────────────────
  // TODO: replace with signed-URL endpoint when backend is ready
  // static Future<String> fetchVideoUrl({
  //   required int lessonId,
  //   String? accessToken,
  // }) async {
  //   final data = await _get('/lessons/$lessonId/video', accessToken: accessToken);
  //   return data['url'] as String;
  // }

  // ══════════════════════════════════════════════════════════════════
  // ══  STATIC DATA (remove once API is integrated)  ════════════════
  // ══════════════════════════════════════════════════════════════════

  /// Video URLs mapped by lesson ID.
  /// TODO: replace with [fetchVideoUrl] once backend delivers signed URLs.
  static final Map<int, String> _staticVideoUrls = {
    1: '$_videoBaseUrl/N5-Basics/1.mp4?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9kM2M2bzVsaGYwODliYi5jbG91ZGZyb250Lm5ldC9ONS1CYXNpY3MvMS5tcDQiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE3NzI0OTYwMDB9fX1dfQ__&Key-Pair-Id=K3SL4B0PI402BI&Signature=h-W7jbUTBEIBq~5a2VZIfChQx9XB6q31AWVASF2TP215lrfKXHKL6f1WakyN9SyAuyYgOT9qD1ISH-aD3iJR5YS6CglRRYyppBgc~wzb8WD1XXL5aXQIl9N5g3e7~GBm4FZO3ZDwqO~1iJbMukMvD9RK2DtcXhegzfnJkO98jkLHcJnE6MDtA3eG9UFLpuI~-2parVc~QozxMC0wokA4nvQoT~JcQ1LG5cbC9Y1lUnJdH~ZXfuSUjMv~kkRUAnlVe7arJHQI8lD9m97e-mMWAPwTAAQXF18RHsxYgjqw7Ix2hV~Jx9u55Ym-hV6Nb0KaIParRBFO9-UT2L6UlmZ~pg__',
  };

  /// Returns the video URL for a lesson, or null if not available.
  static String? getVideoUrl(int lessonId) => _staticVideoUrls[lessonId];

  /// Static courses data. Follows the same JSON shape the API will return.
  static List<Course> getStaticCourses() {
    const raw = [
      {
        "id": 1,
        "title": "N5 Beginner",
        "description":
            "Introductory level Japanese course for absolute beginners.",
        "level": "N5",
        "createdAt": "2026-01-27T08:42:17.818Z",
        "updatedAt": "2026-01-27T08:42:17.818Z",
        "lessons": [
          {
            "id": 1,
            "courseId": 1,
            "title": "Lesson 1: Greetings",
            "description": "Basic Japanese greetings and introductions.",
            "content": {
              "body":
                  "Learn to say hello, goodbye, and introduce yourself in Japanese.",
              "type": "text"
            },
            "createdAt": "2026-01-27T08:42:17.818Z",
            "updatedAt": "2026-01-27T08:42:17.818Z"
          },
          {
            "id": 2,
            "courseId": 1,
            "title": "Lesson 2: Numbers",
            "description": "Learn to count from 1 to 10 in Japanese.",
            "content": {
              "body": "Basic numbers from ichi (1) to juu (10).",
              "type": "text"
            },
            "createdAt": "2026-01-27T08:42:17.818Z",
            "updatedAt": "2026-01-27T08:42:17.818Z"
          },
          {
            "id": 3,
            "courseId": 1,
            "title": "Lesson 3: Basic Grammar",
            "description": "Learn basic Japanese sentence structure.",
            "content": {
              "body": "Understand subject-object-verb order.",
              "type": "text"
            },
            "createdAt": "2026-01-27T08:42:17.818Z",
            "updatedAt": "2026-01-27T08:42:17.818Z"
          }
        ]
      },
      {
        "id": 2,
        "title": "N4 Elementary",
        "description":
            "Continue learning with simple grammar and kanji.",
        "level": "N4",
        "createdAt": "2026-01-27T08:42:22.825Z",
        "updatedAt": "2026-01-27T08:42:22.825Z",
        "lessons": [
          {
            "id": 4,
            "courseId": 2,
            "title": "Lesson 1: Simple Sentences",
            "description": "Learn how to make basic sentences.",
            "content": {
              "body": "Watashi wa gakusei desu.",
              "type": "text"
            },
            "createdAt": "2026-01-27T08:42:22.825Z",
            "updatedAt": "2026-01-27T08:42:22.825Z"
          },
          {
            "id": 5,
            "courseId": 2,
            "title": "Lesson 2: Verb Forms",
            "description": "Understand basic verb conjugations.",
            "content": {
              "body": "Taberu \u2192 Tabetai \u2192 Tabemashita",
              "type": "text"
            },
            "createdAt": "2026-01-27T08:42:22.825Z",
            "updatedAt": "2026-01-27T08:42:22.825Z"
          },
          {
            "id": 6,
            "courseId": 2,
            "title": "Lesson 3: Kanji Basics",
            "description": "Introduction to basic kanji characters.",
            "content": {
              "body": "\u65E5 (day), \u6708 (month), \u4EBA (person).",
              "type": "text"
            },
            "createdAt": "2026-01-27T08:42:22.825Z",
            "updatedAt": "2026-01-27T08:42:22.825Z"
          }
        ]
      }
    ];

    return raw
        .map((c) => Course.fromJson(Map<String, dynamic>.from(c)))
        .toList();
  }

  /// Static lessons with quizzes included. Same shape the API will return.
  static List<Lesson> getStaticLessons() {
    const raw = [
      {
        "id": 1,
        "courseId": 1,
        "title": "Lesson 1: Greetings",
        "description": "Basic Japanese greetings and introductions.",
        "content": {
          "body":
              "Learn to say hello, goodbye, and introduce yourself in Japanese.",
          "type": "text"
        },
        "createdAt": "2026-01-27T08:42:17.818Z",
        "updatedAt": "2026-01-27T08:42:17.818Z",
        "quizzes": [
          {
            "id": 1,
            "lessonId": 1,
            "title": "Greetings Quiz 1",
            "passingScore": 70,
            "createdAt": "2026-01-27T08:42:17.818Z",
            "updatedAt": "2026-01-27T08:42:17.818Z"
          },
          {
            "id": 2,
            "lessonId": 1,
            "title": "Greetings Quiz 2",
            "passingScore": 70,
            "createdAt": "2026-01-27T08:42:17.818Z",
            "updatedAt": "2026-01-27T08:42:17.818Z"
          },
          {
            "id": 3,
            "lessonId": 1,
            "title": "Greetings Quiz 3",
            "passingScore": 70,
            "createdAt": "2026-01-27T08:42:17.818Z",
            "updatedAt": "2026-01-27T08:42:17.818Z"
          }
        ]
      },
      {
        "id": 2,
        "courseId": 1,
        "title": "Lesson 2: Numbers",
        "description": "Learn to count from 1 to 10 in Japanese.",
        "content": {
          "body": "Basic numbers from ichi (1) to juu (10).",
          "type": "text"
        },
        "createdAt": "2026-01-27T08:42:17.818Z",
        "updatedAt": "2026-01-27T08:42:17.818Z",
        "quizzes": []
      },
      {
        "id": 3,
        "courseId": 1,
        "title": "Lesson 3: Basic Grammar",
        "description": "Learn basic Japanese sentence structure.",
        "content": {
          "body": "Understand subject-object-verb order.",
          "type": "text"
        },
        "createdAt": "2026-01-27T08:42:17.818Z",
        "updatedAt": "2026-01-27T08:42:17.818Z",
        "quizzes": []
      },
      {
        "id": 4,
        "courseId": 2,
        "title": "Lesson 1: Simple Sentences",
        "description": "Learn how to make basic sentences.",
        "content": {
          "body": "Watashi wa gakusei desu.",
          "type": "text"
        },
        "createdAt": "2026-01-27T08:42:22.825Z",
        "updatedAt": "2026-01-27T08:42:22.825Z",
        "quizzes": []
      },
      {
        "id": 5,
        "courseId": 2,
        "title": "Lesson 2: Verb Forms",
        "description": "Understand basic verb conjugations.",
        "content": {
          "body": "Taberu \u2192 Tabetai \u2192 Tabemashita",
          "type": "text"
        },
        "createdAt": "2026-01-27T08:42:22.825Z",
        "updatedAt": "2026-01-27T08:42:22.825Z",
        "quizzes": []
      },
      {
        "id": 6,
        "courseId": 2,
        "title": "Lesson 3: Kanji Basics",
        "description": "Introduction to basic kanji characters.",
        "content": {
          "body": "\u65E5 (day), \u6708 (month), \u4EBA (person).",
          "type": "text"
        },
        "createdAt": "2026-01-27T08:42:22.825Z",
        "updatedAt": "2026-01-27T08:42:22.825Z",
        "quizzes": []
      }
    ];

    return raw
        .map((l) => Lesson.fromJson(Map<String, dynamic>.from(l)))
        .toList();
  }
}
