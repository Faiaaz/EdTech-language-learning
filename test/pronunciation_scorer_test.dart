import 'package:flutter_test/flutter_test.dart';

import 'package:ez_trainz/services/pronunciation_benchmark_store.dart';
import 'package:ez_trainz/services/pronunciation_scorer.dart';

int _score(String targetKana, String transcript) =>
    PronunciationScorer.evaluate(targetKana: targetKana, transcript: transcript)
        .score;

void main() {
  group('segmentation', () {
    test('splits a plain word into morae', () {
      expect(PronunciationScorer.segmentMorae('こんにちは').join('|'),
          'こ|ん|に|ち|は');
    });
    test('glues digraphs into one mora', () {
      expect(PronunciationScorer.segmentMorae('きょうとじゃ').join('|'),
          'きょ|う|と|じゃ');
    });
  });

  group('normalization', () {
    test('katakana → hiragana', () {
      expect(PronunciationScorer.normalize('アリガトウ'), 'ありがとう');
    });
    test('kanji sentence → kana', () {
      expect(PronunciationScorer.normalize('私は学生です'), 'わたしはがくせいです');
    });
    test('kanji greeting → kana', () {
      expect(PronunciationScorer.normalize('今日は'), 'こんにちは');
    });
    test('long-vowel dash expands to the previous vowel', () {
      expect(PronunciationScorer.normalize('オハヨー'), 'おはよお');
    });
    test('strips trailing punctuation', () {
      expect(PronunciationScorer.normalize('こんにちは。'), 'こんにちは');
    });
  });

  group('scoring', () {
    test('exact match scores 100', () {
      expect(_score('こんにちは', 'こんにちは'), 100);
    });
    test('kanji transcript scores 100 against kana target', () {
      expect(_score('わたしはがくせいです', '私は学生です。'), 100);
    });
    test('empty transcript scores 0', () {
      expect(_score('ありがとう', ''), 0);
    });
    test('a dropped mora costs but stays high', () {
      final s = _score('さようなら', 'さよなら');
      expect(s, greaterThanOrEqualTo(70));
      expect(s, lessThan(100));
    });
    test('a voicing slip counts as close, not wrong', () {
      final s = _score('わたしはがくせいです', 'わたしはかくせいです');
      expect(s, greaterThanOrEqualTo(85));
      expect(s, lessThan(100));
    });
    test('an unrelated phrase scores low', () {
      expect(_score('おはよう', 'こんばんは'), lessThanOrEqualTo(40));
    });
    test('extra trailing morae are penalised but not zeroed', () {
      final s = _score('おはよう', 'おはようございます');
      expect(s, greaterThan(50));
      expect(s, lessThan(100));
    });
    test('low STT confidence downgrades a "perfect" transcript', () {
      // こんにちぱ auto-corrected by Scribe to こんにちは: the text matches
      // perfectly but the weak word probability betrays the correction.
      final r = PronunciationScorer.evaluate(
        targetKana: 'こんにちは',
        transcript: 'こんにちは。',
        confidence: 0.3,
      );
      expect(r.uncertain, isTrue);
      expect(r.score, lessThan(60));
      expect(r.morae.every((m) => m.status == MoraStatus.close), isTrue);
    });

    test('high STT confidence keeps the perfect score', () {
      final r = PronunciationScorer.evaluate(
        targetKana: 'こんにちは',
        transcript: 'こんにちは。',
        confidence: 0.95,
      );
      expect(r.uncertain, isFalse);
      expect(r.score, 100);
    });

    test('empty transcript is not flagged uncertain', () {
      final r = PronunciationScorer.evaluate(
        targetKana: 'おはよう',
        transcript: '',
        confidence: 0.0,
      );
      expect(r.uncertain, isFalse);
      expect(r.score, 0);
    });

    test('per-mora statuses mark the dropped syllable as missing', () {
      // すみません said as ごめーん → ごめえん
      final result = PronunciationScorer.evaluate(
        targetKana: 'すみません',
        transcript: 'ごめーん',
      );
      expect(result.morae.map((m) => m.mora).toList(),
          ['す', 'み', 'ま', 'せ', 'ん']);
      expect(result.morae.first.status, MoraStatus.missing); // す skipped
      expect(result.morae.last.status, MoraStatus.perfect); // ん nailed
    });
  });

  group('benchmark stats', () {
    BenchmarkSample sample(int app, int? teacher) => BenchmarkSample(
          id: '$app-$teacher-${DateTime.now().microsecondsSinceEpoch}',
          learner: 'x',
          phraseKana: 'おはよう',
          phrasePron: 'ওহায়ো',
          appScore: app,
          transcript: 'おはよう',
          recordedAt: DateTime.now(),
          teacherScore: teacher,
        );

    test('reports nulls when nothing is graded', () {
      final s = BenchmarkStats.compute([sample(80, null), sample(60, null)]);
      expect(s.total, 2);
      expect(s.graded, 0);
      expect(s.meanAbsError, isNull);
    });

    test('mean abs error and within-10 rate', () {
      final s = BenchmarkStats.compute([
        sample(80, 85), // |Δ| 5  ✓within10
        sample(60, 90), // |Δ| 30 ✗
        sample(70, 72), // |Δ| 2  ✓within10
      ]);
      expect(s.graded, 3);
      expect(s.meanAbsError, closeTo((5 + 30 + 2) / 3, 1e-9));
      expect(s.withinTen, closeTo(2 / 3, 1e-9));
    });

    test('perfect agreement gives correlation 1', () {
      final s = BenchmarkStats.compute([
        sample(40, 40),
        sample(60, 60),
        sample(90, 90),
      ]);
      expect(s.correlation, closeTo(1.0, 1e-6));
    });
  });
}
