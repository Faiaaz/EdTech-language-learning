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
    // JLC lessons
    1: '$_videoBaseUrl/output_grp/Hiragana%20Part-1%20_EZTrainZ_JLC.m3u8?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9kM2M2bzVsaGYwODliYi5jbG91ZGZyb250Lm5ldC9vdXRwdXRfZ3JwL0hpcmFnYW5hJTIwUGFydC0xJTIwX0VaVHJhaW5aX0pMQy5tM3U4IiwiQ29uZGl0aW9uIjp7IkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNzczMTg3MjAwfX19XX0_&Key-Pair-Id=K3SL4B0PI402BI&Signature=A2ulpY2mb~Np-b4YUn3tVb7Etq-Y1JtZdYt0Bx7YoFhKlUu4Mzzph-rQgQa1uWyesmeSy76D~ojYZ6Nrjn8h-NkNyc8UZSN5MpaTVxqe9O5dr182a5tCjRbgI25CNs0YNx7owrfzt97tENy1ZMcbbpnxVoI3-CXki2HUzaElkpeLe~yNBGAwIfFsonPphoJz7EZcmQXAyCBHvWOwDoneUD7XwPLGBnejhQyRuorWBmCAsPmDCaXa3oX-VM~-4comhy571h-FtBEbEN3fYhYSeH1iklF1KV1jcMap9U6Z5Io3xD8EziMtp9MDjJ~~GgOw9tkpdmEz-IEnFTSAa3k4wQ__',
    // JLC Hiragana Part 2 & 3
    13: 'https://d3c6o5lhf089bb.cloudfront.net/JLC_output_grp/Hiragana%20Part-2_EZTrainZ_JLC.m3u8?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9kM2M2bzVsaGYwODliYi5jbG91ZGZyb250Lm5ldC9KTENfb3V0cHV0X2dycC9IaXJhZ2FuYSUyMFBhcnQtMl9FWlRyYWluWl9KTEMubTN1OCIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc3MzE4NzIwMH19fV19&Key-Pair-Id=K3SL4B0PI402BI&Signature=NmBQuiV-gu8FTnW0QoS8xG3j6JGGTnLl1WQBh3LzJuBMrKV8G4YbJ3IbPfz~Xdonz0X5743AK5gZuAY-XS0C1TYhy8jmmoH64hsIk2dGgAGbUppRFbgcGV7fO0VBdl6WxJvdlZxmFVcl4l5QkZILi9dqbttY9pMd0aLgmkgCeRYPA59pBS2UdwYOxydjgvfvRvSDT1INFrK4qY68POvT6T9NRQW7InmD5H-l~g7nqfwpHleD2Yfz25feOUCkKU~LYz2NRLLbIoMTminVocQGjVdHLwn7qYsXrXKrh3Cd~92xwExJysphz-MVTCDyzxJS~145o0cwqDCl8TAI4jFDOA__',
    14: 'https://d3c6o5lhf089bb.cloudfront.net/JLC_output_grp/Hiragana-Part-3_EZTrainZ_JLC.m3u8?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9kM2M2bzVsaGYwODliYi5jbG91ZGZyb250Lm5ldC9KTENfb3V0cHV0X2dycC9IaXJhZ2FuYS1QYXJ0LTNfRVpUcmFpblpfSkxDLm0zdTgiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE3NzMxODcyMDB9fX1dfQ__&Key-Pair-Id=K3SL4B0PI402BI&Signature=KIbX2sgDrl5wR-RcA45VXZbajX0uwS~eksEpyYmkWC~XmHKXOigCZ-hS~b84TdYGSyERTYGioB7ulPUYcAfP27SoKVQUXlmELw-Q5xGw1JlHD9lgH~L6EJKEEJ8vGxzq2ejFL8LM0Zz-tH9SEi1a0-5ZDiwjEhJ69qNqcdeNC2Hddm3OGkEOX-G6eADXLBxWQcw4CJwdgaqYgbPxmdPlZzKCIhnC5jptlQcTQ9JIryhWSp1R0xHPnIJG1V7Ss0GCZEhU6fWuGDX9FT-Gp24SZXuJgyucoPt-TO2zbvPgVcXkcOfYFMKSO2Bos11mcbOAF2k8QG25XntkmeQqhkKbHg__',
    // KLC lessons
    7: '$_videoBaseUrl/KLC_output_grp/CLASS-1-VIDEO-1__EZTrainZ_KLC.m3u8?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9kM2M2bzVsaGYwODliYi5jbG91ZGZyb250Lm5ldC9LTENfb3V0cHV0X2dycC9DTEFTUy0xLVZJREVPLTFfX0VaVHJhaW5aX0tMQy5tM3U4IiwiQ29uZGl0aW9uIjp7IkRhdGVMZXNzVGhhbiI6eyJBV1M6RXBvY2hUaW1lIjoxNzczMTg3MjAwfX19XX0_&Key-Pair-Id=K3SL4B0PI402BI&Signature=gpcyUnBsXrctyXwzgx~gAGnGj7LZPt3Ev~9~kMBHxpD65O4-YshSw~S7spLuI-U0Yegj7pJ~rOaN6EDoCQJFNksTajQc893dwNbs9HCwGsze1PuCGjVWFODOYcDin2ughew1yX4KO09OpEKc0ARmsaj3XIOfzp6q8-78diZa1S5X9IwkAeYRF6detDrGToool6mIuLYt6dsT~ICGhLgfDx4p6coBZsslH-ETnicAN4S4~5XJrQw-cWuJ9mAizu5DJy2tRWxqm3wc~TMEAZFzD55d2yBBhz15Dh6unwslhekdypl0UAKT9WX1RlSruM~tnxDblBvhAXhghl7EPsmVQQ__',
    8: '$_videoBaseUrl/KLC_output_grp/CLASS-2-VIDEO-2_EZTrainZ_KLC.m3u8?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9kM2M2bzVsaGYwODliYi5jbG91ZGZyb250Lm5ldC9LTENfb3V0cHV0X2dycC9DTEFTUy0yLVZJREVPLTJfRVpUcmFpblpfS0xDLm0zdTgiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE3NzMxODcyMDB9fX1dfQ__&Key-Pair-Id=K3SL4B0PI402BI&Signature=XK1i8bTVLxOcSqAQgapHoEWdjmC89VD-ULC67LJDX4B8ta2POqtaZkj6XDWSd6uGoH10VZVUHlV4MZ5qXxUAhnN0LbZS~nAeBGiEkMUuvpOxRTybw1QOUgga7UkVX0Rsq4avMjOeS5F7uq~teUGT1CQ95kU67gQdnIUMcmM0~1BQ-M0wAEm-XrX9~kGw5fhZAbw5aWqZtO4qOpZJ0uldC66-2NG1dl~Gh1K5eICzc5TzGGtvyjhkIFMT7du4tk2~x6PfB3UxJA3wtZoDD5XsxpgaQjDBY32SguBs9E0iA7k3wKWWQwLoq-dqCgHFDX-FNS8FcIuAhXVbVl4e6GCOWA__',
    9: '$_videoBaseUrl/KLC_output_grp/CLASS-3-VIDEO-3_EZTrainZ_KLC.m3u8?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9kM2M2bzVsaGYwODliYi5jbG91ZGZyb250Lm5ldC9LTENfb3V0cHV0X2dycC9DTEFTUy0zLVZJREVPLTNfRVpUcmFpblpfS0xDLm0zdTgiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE3NzMxODcyMDB9fX1dfQ__&Key-Pair-Id=K3SL4B0PI402BI&Signature=WEWUAkWZwF4zNZZtjQQ40b~lrJEElMaZ9J~0eOM4IiZdwtpBXU-43Ged4O817rJQwojpg1zqqX0i9y5Q7oXaG3VeG9k1HlzCzSKT03oWN51yYE3Mp3gSvkr-RZJpecqE5y-EJvPMfw9M0JoQ7ucF4q39HKOp7GIq2J5a3JqtD33IMnDbMtprolzJHXi9bthF8-HHRvTjIGTsNITFh2OEKOmikRJ6sQ1emdGRG6IoftOW5Ew2VhyuuLIhzSzkhXXQcP3mK~46Dl~Bctq8ecwjGtTT9xTzs4WM0linqcGfOcadPpzu49nuWURFmZT~R2wk1qNM00Pf7r7tOgRdwMoA0w__',
    // GLC lessons
    10: '$_videoBaseUrl/GLC_output_group/Class%201_EZTrainZ_GLC.m3u8?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9kM2M2bzVsaGYwODliYi5jbG91ZGZyb250Lm5ldC9HTENfb3V0cHV0X2dyb3VwL0NsYXNzJTIwMV9FWlRyYWluWl9HTEMubTN1OCIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc3MzE4NzIwMH19fV19&Key-Pair-Id=K3SL4B0PI402BI&Signature=CdcdFM9QaBo6C7IKufWgK~7K9RDVYj82SMsr~YAG5xnbcwMnpsuGOIGmcea21-hbQZjTxDH8o8Z17h~gJfVmXJYS6mQZIADyNLFCCpUjcKoA7KCdPK9Ph00BYnATbiCD2FrklvcbUqWlx4jy18ddL3dRMw81Jg9bWfeZZkkSO0WjK9hJB1L~bcj8nNrtmVb-WOS61moZAHY0CqBImxBcx0Cms2FN2BRLsPRge8sqyp~WbjFqkAINJ8r3-CCtrVTFw-DHHVFfozcIMeNpTu8Sebm6wbrVoCqIm~qIz1ibp3c816a1zAFE13o47nkLM5bAXAnpE6oHLWrIwAdIWf04tQ__',
    11: '$_videoBaseUrl/GLC_output_group/Class%202_EZTrainZ_GLC.m3u8?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9kM2M2bzVsaGYwODliYi5jbG91ZGZyb250Lm5ldC9HTENfb3V0cHV0X2dyb3VwL0NsYXNzJTIwMl9FWlRyYWluWl9HTEMubTN1OCIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc3MzE4NzIwMH19fV19&Key-Pair-Id=K3SL4B0PI402BI&Signature=CjU~kJER9yKD6kpNCl0Ipu8rAddzury-1wO-qzpRi6f6yj5htbXB5chhSgFVTFMTmgCcnfNI-fG-KGMygDQ~8pVxAeVQviPB8snR6WRNyo7Df8iX~ER9PhHafGfn7ohkZ1sfzyShI1KK~YYg66dajRwtEWHlxPIngFGRsISbK1puDD1d1pePtKTPumthcmQD7bnt7mPeub~HgFrOtuQCJ90eiAd3ZQMKjEPUc14AwGL67fA0LMvuCh52AGQ43bxSqYie29oVOimbXGGyZ8IUFK7u3HuklgnHwd0HoXHFPFayQAXngaeB~CcQ92u~hilpmBPY~Oj~2zlMLJz4Ad8-4w__',
    12: '$_videoBaseUrl/GLC_output_group/Class%203_EZTrainZ_GLC.m3u8?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9kM2M2bzVsaGYwODliYi5jbG91ZGZyb250Lm5ldC9HTENfb3V0cHV0X2dyb3VwL0NsYXNzJTIwM19FWlRyYWluWl9HTEMubTN1OCIsIkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTc3MzE4NzIwMH19fV19&Key-Pair-Id=K3SL4B0PI402BI&Signature=GdaWEDrrmX6yGvgeoTt-Nh2EuYH0KHKELcXspTatpp5qyejUO87mfu65~Ro6cvLxUWHB~c0cKHKd1VjlWie3K7w5K34~NgDFPscjRaoHmgu4E4jOpXlbYFnVWp59c-BA1RJAO~~7Ae3udJCukjZW2~OOWM765TJFWrHcoP7N01k9B2J6DARVTIjWn49gtfKCevgUeq5oX84YHbneDbUHP9PjpmCMN8d0ebyqdFe5fq-PccsXd1ymp~laAmQ188xxuYNdN-LkC04uKXfE-irUnLVk5qE6mqUSxFfFzoNDM2sb8jWrOnVeEDteV5f5FAJsZ-SvUzm3gUDnz7tR2CuioA__',
  };

  /// Returns the video URL for a lesson, or null if not available.
  static String? getVideoUrl(int lessonId) => _staticVideoUrls[lessonId];

  /// Static courses data per program. API will be GET /programs/{programId}/courses.
  /// [programId] e.g. 'jlc', 'klc', 'elc', 'glc'.
  static List<Course> getStaticCourses([String? programId]) {
    if (programId == 'klc') return _klcCourses;
    if (programId == 'glc') return _glcCourses;
    return _jlcCourses;
  }

  static final List<Course> _jlcCourses = _parseCourses([
    {
      "id": 1,
      "title": "N5 Beginner",
      "description": "Introductory level Japanese course for absolute beginners.",
      "level": "N5",
      "createdAt": "2026-01-27T08:42:17.818Z",
      "updatedAt": "2026-01-27T08:42:17.818Z",
      "lessons": [
        {
          "id": 1,
          "courseId": 1,
          "title": "Lesson 1: Hiragana Part 1",
          "description": "Introduction to Hiragana — the foundational Japanese syllabary.",
          "content": {
            "body":
                "Learn the first set of Hiragana characters used in the Japanese writing system. Hiragana is one of three scripts in Japanese and is essential for reading and writing. This lesson covers the vowels (あ い う え お) and the K-row (か き く け こ).",
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
        },
        {
          "id": 13,
          "courseId": 1,
          "title": "Lesson 4: Hiragana Part 2",
          "description": "Continue learning Hiragana — S, T, N, and H rows.",
          "content": {
            "body":
                "In this lesson, we continue building your Hiragana foundation. You will learn the S-row (さ し す せ そ), T-row (た ち つ て と), N-row (な に ぬ ね の), and H-row (は ひ ふ へ ほ). Practice each character carefully to improve your reading and writing skills.",
            "type": "text"
          },
          "createdAt": "2026-01-27T08:42:17.818Z",
          "updatedAt": "2026-01-27T08:42:17.818Z"
        },
        {
          "id": 14,
          "courseId": 1,
          "title": "Lesson 5: Hiragana Part 3",
          "description": "Complete your Hiragana — M, Y, R, W rows and the N character.",
          "content": {
            "body":
                "This final Hiragana lesson covers the M-row (ま み む め も), Y-row (や ゆ よ), R-row (ら り る れ ろ), W-row (わ を), and the standalone N (ん). By the end of this lesson you will have mastered all 46 basic Hiragana characters.",
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
      "description": "Continue learning with simple grammar and kanji.",
      "level": "N4",
      "createdAt": "2026-01-27T08:42:22.825Z",
      "updatedAt": "2026-01-27T08:42:22.825Z",
      "lessons": [
        {
          "id": 4,
          "courseId": 2,
          "title": "Lesson 1: Simple Sentences",
          "description": "Learn how to make basic sentences.",
          "content": {"body": "Watashi wa gakusei desu.", "type": "text"},
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
  ]);

  static final List<Course> _klcCourses = _parseCourses([
    {
      "id": 3,
      "title": "Korean Beginner",
      "description": "Introductory Korean language course covering the fundamentals.",
      "level": "Class 1",
      "createdAt": "2026-01-27T08:42:17.818Z",
      "updatedAt": "2026-01-27T08:42:17.818Z",
      "lessons": [
        {
          "id": 7,
          "courseId": 3,
          "title": "Class 1: Introduction to Korean",
          "description": "Get started with Korean language fundamentals in this first class video.",
          "content": {
            "body":
                "Welcome to Korean Language and Career (KLC). This class introduces you to the Korean language, covering basic greetings, pronunciation, and the Hangul writing system. Watch the video to begin your Korean learning journey.",
            "type": "text"
          },
          "createdAt": "2026-01-27T08:42:17.818Z",
          "updatedAt": "2026-01-27T08:42:17.818Z"
        },
        {
          "id": 8,
          "courseId": 3,
          "title": "Class 2: Korean Basics Continued",
          "description": "Build on your Korean foundation with Class 2 video lessons.",
          "content": {
            "body":
                "In this class, you will continue learning Korean essentials including vocabulary, common phrases, and sentence structure. Follow along with the video to reinforce your skills.",
            "type": "text"
          },
          "createdAt": "2026-01-27T08:42:17.818Z",
          "updatedAt": "2026-01-27T08:42:17.818Z"
        },
        {
          "id": 9,
          "courseId": 3,
          "title": "Class 3: Korean Intermediate Concepts",
          "description": "Advance your Korean skills with Class 3 video content.",
          "content": {
            "body":
                "Class 3 takes your Korean skills further with intermediate concepts, grammar patterns, and expanded vocabulary. Watch the full video and practice what you learn.",
            "type": "text"
          },
          "createdAt": "2026-01-27T08:42:17.818Z",
          "updatedAt": "2026-01-27T08:42:17.818Z"
        }
      ]
    }
  ]);

  static final List<Course> _glcCourses = _parseCourses([
    {
      "id": 4,
      "title": "German Beginner",
      "description": "Introductory German language course covering the fundamentals.",
      "level": "Class 1",
      "createdAt": "2026-01-27T08:42:17.818Z",
      "updatedAt": "2026-01-27T08:42:17.818Z",
      "lessons": [
        {
          "id": 10,
          "courseId": 4,
          "title": "Class 1: Introduction to German",
          "description": "Get started with German language fundamentals in this first class video.",
          "content": {
            "body":
                "Welcome to German Language and Career (GLC). This class introduces you to the German language, covering basic greetings, pronunciation, and essential vocabulary. Watch the video to begin your German learning journey.",
            "type": "text"
          },
          "createdAt": "2026-01-27T08:42:17.818Z",
          "updatedAt": "2026-01-27T08:42:17.818Z"
        },
        {
          "id": 11,
          "courseId": 4,
          "title": "Class 2: German Basics Continued",
          "description": "Build on your German foundation with Class 2 video lessons.",
          "content": {
            "body":
                "In this class, you will continue learning German essentials including vocabulary, common phrases, and sentence structure. Follow along with the video to reinforce your skills.",
            "type": "text"
          },
          "createdAt": "2026-01-27T08:42:17.818Z",
          "updatedAt": "2026-01-27T08:42:17.818Z"
        },
        {
          "id": 12,
          "courseId": 4,
          "title": "Class 3: German Intermediate Concepts",
          "description": "Advance your German skills with Class 3 video content.",
          "content": {
            "body":
                "Class 3 takes your German skills further with intermediate concepts, grammar patterns, and expanded vocabulary. Watch the full video and practice what you learn.",
            "type": "text"
          },
          "createdAt": "2026-01-27T08:42:17.818Z",
          "updatedAt": "2026-01-27T08:42:17.818Z"
        }
      ]
    }
  ]);

  static List<Course> _parseCourses(List<Map<String, dynamic>> raw) =>
      raw.map((c) => Course.fromJson(Map<String, dynamic>.from(c))).toList();

  /// Static lessons with quizzes included. Same shape the API will return.
  static List<Lesson> getStaticLessons() {
    const raw = [
      // JLC lessons
      {
        "id": 1,
        "courseId": 1,
        "title": "Lesson 1: Hiragana Part 1",
        "description": "Introduction to Hiragana — the foundational Japanese syllabary.",
        "content": {
          "body":
              "Learn the first set of Hiragana characters used in the Japanese writing system. Hiragana is one of three scripts in Japanese and is essential for reading and writing. This lesson covers the vowels (あ い う え お) and the K-row (か き く け こ).",
          "type": "text"
        },
        "createdAt": "2026-01-27T08:42:17.818Z",
        "updatedAt": "2026-01-27T08:42:17.818Z",
        "quizzes": [
          {
            "id": 1,
            "lessonId": 1,
            "title": "Hiragana Quiz 1",
            "passingScore": 70,
            "createdAt": "2026-01-27T08:42:17.818Z",
            "updatedAt": "2026-01-27T08:42:17.818Z"
          },
          {
            "id": 2,
            "lessonId": 1,
            "title": "Hiragana Quiz 2",
            "passingScore": 70,
            "createdAt": "2026-01-27T08:42:17.818Z",
            "updatedAt": "2026-01-27T08:42:17.818Z"
          },
          {
            "id": 3,
            "lessonId": 1,
            "title": "Hiragana Quiz 3",
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
        "content": {"body": "Basic numbers from ichi (1) to juu (10).", "type": "text"},
        "createdAt": "2026-01-27T08:42:17.818Z",
        "updatedAt": "2026-01-27T08:42:17.818Z",
        "quizzes": []
      },
      {
        "id": 3,
        "courseId": 1,
        "title": "Lesson 3: Basic Grammar",
        "description": "Learn basic Japanese sentence structure.",
        "content": {"body": "Understand subject-object-verb order.", "type": "text"},
        "createdAt": "2026-01-27T08:42:17.818Z",
        "updatedAt": "2026-01-27T08:42:17.818Z",
        "quizzes": []
      },
      {
        "id": 13,
        "courseId": 1,
        "title": "Lesson 4: Hiragana Part 2",
        "description": "Continue learning Hiragana — S, T, N, and H rows.",
        "content": {
          "body":
              "In this lesson, we continue building your Hiragana foundation. You will learn the S-row (さ し す せ そ), T-row (た ち つ て と), N-row (な に ぬ ね の), and H-row (は ひ ふ へ ほ). Practice each character carefully to improve your reading and writing skills.",
          "type": "text"
        },
        "createdAt": "2026-01-27T08:42:17.818Z",
        "updatedAt": "2026-01-27T08:42:17.818Z",
        "quizzes": []
      },
      {
        "id": 14,
        "courseId": 1,
        "title": "Lesson 5: Hiragana Part 3",
        "description": "Complete your Hiragana — M, Y, R, W rows and the N character.",
        "content": {
          "body":
              "This final Hiragana lesson covers the M-row (ま み む め も), Y-row (や ゆ よ), R-row (ら り る れ ろ), W-row (わ を), and the standalone N (ん). By the end of this lesson you will have mastered all 46 basic Hiragana characters.",
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
        "content": {"body": "Watashi wa gakusei desu.", "type": "text"},
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
      },
      // KLC lessons
      {
        "id": 7,
        "courseId": 3,
        "title": "Class 1: Introduction to Korean",
        "description": "Get started with Korean language fundamentals in this first class video.",
        "content": {
          "body":
              "Welcome to Korean Language and Career (KLC). This class introduces you to the Korean language, covering basic greetings, pronunciation, and the Hangul writing system. Watch the video to begin your Korean learning journey.",
          "type": "text"
        },
        "createdAt": "2026-01-27T08:42:17.818Z",
        "updatedAt": "2026-01-27T08:42:17.818Z",
        "quizzes": []
      },
      {
        "id": 8,
        "courseId": 3,
        "title": "Class 2: Korean Basics Continued",
        "description": "Build on your Korean foundation with Class 2 video lessons.",
        "content": {
          "body":
              "In this class, you will continue learning Korean essentials including vocabulary, common phrases, and sentence structure. Follow along with the video to reinforce your skills.",
          "type": "text"
        },
        "createdAt": "2026-01-27T08:42:17.818Z",
        "updatedAt": "2026-01-27T08:42:17.818Z",
        "quizzes": []
      },
      {
        "id": 9,
        "courseId": 3,
        "title": "Class 3: Korean Intermediate Concepts",
        "description": "Advance your Korean skills with Class 3 video content.",
        "content": {
          "body":
              "Class 3 takes your Korean skills further with intermediate concepts, grammar patterns, and expanded vocabulary. Watch the full video and practice what you learn.",
          "type": "text"
        },
        "createdAt": "2026-01-27T08:42:17.818Z",
        "updatedAt": "2026-01-27T08:42:17.818Z",
        "quizzes": []
      },
      // GLC lessons
      {
        "id": 10,
        "courseId": 4,
        "title": "Class 1: Introduction to German",
        "description": "Get started with German language fundamentals in this first class video.",
        "content": {
          "body":
              "Welcome to German Language and Career (GLC). This class introduces you to the German language, covering basic greetings, pronunciation, and essential vocabulary. Watch the video to begin your German learning journey.",
          "type": "text"
        },
        "createdAt": "2026-01-27T08:42:17.818Z",
        "updatedAt": "2026-01-27T08:42:17.818Z",
        "quizzes": []
      },
      {
        "id": 11,
        "courseId": 4,
        "title": "Class 2: German Basics Continued",
        "description": "Build on your German foundation with Class 2 video lessons.",
        "content": {
          "body":
              "In this class, you will continue learning German essentials including vocabulary, common phrases, and sentence structure. Follow along with the video to reinforce your skills.",
          "type": "text"
        },
        "createdAt": "2026-01-27T08:42:17.818Z",
        "updatedAt": "2026-01-27T08:42:17.818Z",
        "quizzes": []
      },
      {
        "id": 12,
        "courseId": 4,
        "title": "Class 3: German Intermediate Concepts",
        "description": "Advance your German skills with Class 3 video content.",
        "content": {
          "body":
              "Class 3 takes your German skills further with intermediate concepts, grammar patterns, and expanded vocabulary. Watch the full video and practice what you learn.",
          "type": "text"
        },
        "createdAt": "2026-01-27T08:42:17.818Z",
        "updatedAt": "2026-01-27T08:42:17.818Z",
        "quizzes": []
      }
    ];

    return raw
        .map((l) => Lesson.fromJson(Map<String, dynamic>.from(l)))
        .toList();
  }
}
