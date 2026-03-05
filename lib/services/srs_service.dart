import 'package:shared_preferences/shared_preferences.dart';

import 'package:ez_trainz/models/kana.dart';
import 'package:ez_trainz/models/kana_progress.dart';

/// Manages spaced repetition data for kana characters using local storage.
class SrsService {
  static const _storageKey = 'srs_kana_progress';
  static SrsService? _instance;

  late SharedPreferences _prefs;
  late List<KanaProgress> _progressList;

  SrsService._();

  static Future<SrsService> getInstance() async {
    if (_instance != null) return _instance!;
    final service = SrsService._();
    await service._init();
    _instance = service;
    return service;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      _progressList = KanaProgress.decodeList(raw);
    } else {
      _progressList = [];
    }
    _ensureAllKanaExist();
  }

  /// Make sure every kana character has a progress entry.
  void _ensureAllKanaExist() {
    final existing = {for (final p in _progressList) '${p.type}:${p.character}'};

    for (final kana in KanaData.hiragana) {
      final key = 'hiragana:${kana.character}';
      if (!existing.contains(key)) {
        _progressList.add(KanaProgress(
          character: kana.character,
          type: 'hiragana',
        ));
      }
    }
    for (final kana in KanaData.katakana) {
      final key = 'katakana:${kana.character}';
      if (!existing.contains(key)) {
        _progressList.add(KanaProgress(
          character: kana.character,
          type: 'katakana',
        ));
      }
    }
  }

  Future<void> _save() async {
    await _prefs.setString(_storageKey, KanaProgress.encodeList(_progressList));
  }

  /// Get progress for a specific character.
  KanaProgress getProgress(String character, String type) {
    return _progressList.firstWhere(
      (p) => p.character == character && p.type == type,
      orElse: () {
        final p = KanaProgress(character: character, type: type);
        _progressList.add(p);
        return p;
      },
    );
  }

  /// Get all progress entries for a kana type.
  List<KanaProgress> getAllProgress(String type) {
    return _progressList.where((p) => p.type == type).toList();
  }

  /// Characters due for review right now.
  List<KanaProgress> getDueCards(String type) {
    return _progressList
        .where((p) => p.type == type && p.isDue)
        .toList()
      ..sort((a, b) => a.nextReview.compareTo(b.nextReview));
  }

  /// Number of cards due for a given type.
  int dueCount(String type) {
    return _progressList.where((p) => p.type == type && p.isDue).length;
  }

  /// Apply a rating and persist.
  Future<void> rateCard(String character, String type, int quality) async {
    final progress = getProgress(character, type);
    progress.applyRating(quality);
    await _save();
  }

  /// Average mastery across all characters of a type (0.0–1.0).
  double averageMastery(String type) {
    final list = getAllProgress(type);
    if (list.isEmpty) return 0.0;
    return list.fold<double>(0.0, (sum, p) => sum + p.mastery) / list.length;
  }

  /// Total cards studied (at least one attempt).
  int studiedCount(String type) {
    return _progressList
        .where((p) => p.type == type && p.totalAttempts > 0)
        .length;
  }
}
