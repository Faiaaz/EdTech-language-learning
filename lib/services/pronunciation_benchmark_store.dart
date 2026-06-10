import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// One benchmark attempt: what the app scored vs. (optionally) a human grader.
class BenchmarkSample {
  BenchmarkSample({
    required this.id,
    required this.learner,
    required this.phraseKana,
    required this.phrasePron,
    required this.appScore,
    required this.transcript,
    required this.recordedAt,
    this.sttConfidence = 1.0,
    this.teacherScore,
  });

  final String id;
  final String learner;
  final String phraseKana;
  final String phrasePron;
  final int appScore;
  final String transcript;
  final DateTime recordedAt;

  /// Scribe's weakest per-word probability for this attempt — used to tune
  /// the scorer's low-confidence threshold against teacher grades.
  final double sttConfidence;

  /// Human (teacher) score 0–100, filled in later. Null until graded.
  final int? teacherScore;

  BenchmarkSample copyWith({int? teacherScore}) => BenchmarkSample(
        id: id,
        learner: learner,
        phraseKana: phraseKana,
        phrasePron: phrasePron,
        appScore: appScore,
        transcript: transcript,
        recordedAt: recordedAt,
        sttConfidence: sttConfidence,
        teacherScore: teacherScore ?? this.teacherScore,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'learner': learner,
        'phraseKana': phraseKana,
        'phrasePron': phrasePron,
        'appScore': appScore,
        'transcript': transcript,
        'recordedAt': recordedAt.toIso8601String(),
        'sttConfidence': sttConfidence,
        'teacherScore': teacherScore,
      };

  static BenchmarkSample fromJson(Map<String, dynamic> j) => BenchmarkSample(
        id: j['id'] as String,
        learner: (j['learner'] as String?) ?? '',
        phraseKana: (j['phraseKana'] as String?) ?? '',
        phrasePron: (j['phrasePron'] as String?) ?? '',
        appScore: (j['appScore'] as num?)?.toInt() ?? 0,
        transcript: (j['transcript'] as String?) ?? '',
        recordedAt:
            DateTime.tryParse(j['recordedAt'] as String? ?? '') ?? DateTime.now(),
        sttConfidence: (j['sttConfidence'] as num?)?.toDouble() ?? 1.0,
        teacherScore: (j['teacherScore'] as num?)?.toInt(),
      );
}

/// Agreement metrics between the app's scores and the human grades.
class BenchmarkStats {
  const BenchmarkStats({
    required this.total,
    required this.graded,
    required this.meanAbsError,
    required this.withinTen,
    required this.correlation,
  });

  final int total;

  /// How many samples have a teacher score filled in.
  final int graded;

  /// Mean absolute error between app and teacher scores (graded samples only).
  final double? meanAbsError;

  /// Fraction of graded samples where |app − teacher| ≤ 10.
  final double? withinTen;

  /// Pearson correlation between app and teacher scores.
  final double? correlation;

  /// Computes agreement over the [samples] that have a teacher score.
  static BenchmarkStats compute(List<BenchmarkSample> samples) {
    final graded = samples.where((s) => s.teacherScore != null).toList();
    if (graded.isEmpty) {
      return BenchmarkStats(
        total: samples.length,
        graded: 0,
        meanAbsError: null,
        withinTen: null,
        correlation: null,
      );
    }

    final app = graded.map((s) => s.appScore.toDouble()).toList();
    final human = graded.map((s) => s.teacherScore!.toDouble()).toList();
    final n = graded.length;

    var absErr = 0.0;
    var within = 0;
    for (var i = 0; i < n; i++) {
      final d = (app[i] - human[i]).abs();
      absErr += d;
      if (d <= 10) within++;
    }

    return BenchmarkStats(
      total: samples.length,
      graded: n,
      meanAbsError: absErr / n,
      withinTen: within / n,
      correlation: _pearson(app, human),
    );
  }

  static double? _pearson(List<double> a, List<double> b) {
    final n = a.length;
    if (n < 2) return null;
    final ma = a.reduce((x, y) => x + y) / n;
    final mb = b.reduce((x, y) => x + y) / n;
    var cov = 0.0, va = 0.0, vb = 0.0;
    for (var i = 0; i < n; i++) {
      final da = a[i] - ma, db = b[i] - mb;
      cov += da * db;
      va += da * da;
      vb += db * db;
    }
    if (va == 0 || vb == 0) return null; // no variance → undefined
    return cov / (_sqrt(va) * _sqrt(vb));
  }

  static double _sqrt(double x) {
    if (x <= 0) return 0;
    var g = x;
    for (var i = 0; i < 30; i++) {
      g = 0.5 * (g + x / g);
    }
    return g;
  }
}

/// Local persistence + CSV export for benchmark samples.
class PronunciationBenchmarkStore {
  static const _kKey = 'pron_benchmark_samples_v1';

  static Future<List<BenchmarkSample>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kKey) ?? const [];
    final out = <BenchmarkSample>[];
    for (final s in raw) {
      try {
        final decoded = jsonDecode(s);
        if (decoded is Map<String, dynamic>) {
          out.add(BenchmarkSample.fromJson(decoded));
        }
      } catch (_) {}
    }
    out.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return out;
  }

  static Future<void> _saveAll(List<BenchmarkSample> samples) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kKey,
      samples.map((s) => jsonEncode(s.toJson())).toList(),
    );
  }

  static Future<List<BenchmarkSample>> add(BenchmarkSample sample) async {
    final all = await load();
    all.insert(0, sample);
    await _saveAll(all);
    return all;
  }

  static Future<List<BenchmarkSample>> update(BenchmarkSample sample) async {
    final all = await load();
    final i = all.indexWhere((s) => s.id == sample.id);
    if (i >= 0) {
      all[i] = sample;
      await _saveAll(all);
    }
    return all;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
  }

  /// Renders all [samples] as a CSV document (RFC-4180 quoting).
  static String toCsv(List<BenchmarkSample> samples) {
    final buf = StringBuffer()
      ..writeln('recorded_at,learner,phrase_kana,phrase_pron,'
          'app_score,teacher_score,stt_confidence,transcript');
    for (final s in samples) {
      buf.writeln([
        s.recordedAt.toIso8601String(),
        s.learner,
        s.phraseKana,
        s.phrasePron,
        s.appScore.toString(),
        s.teacherScore?.toString() ?? '',
        s.sttConfidence.toStringAsFixed(3),
        s.transcript,
      ].map(_csvCell).join(','));
    }
    return buf.toString();
  }

  static String _csvCell(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
