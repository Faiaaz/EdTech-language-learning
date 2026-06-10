import 'dart:math' as math;

/// Per-mora verdict for one target syllable.
enum MoraStatus { perfect, close, wrong, missing }

/// One target mora, its Bengali phonetic label, and how it was pronounced.
class MoraResult {
  const MoraResult(this.mora, this.label, this.status);
  final String mora;

  /// Bengali phonetic label shown under the kana.
  final String label;
  final MoraStatus status;
}

/// Result of scoring one utterance: a verdict per target mora plus a 0–100 score.
class PronunciationResult {
  const PronunciationResult(this.morae, this.score, {this.uncertain = false});
  final List<MoraResult> morae;
  final int score;

  /// True when the STT's acoustic confidence was low — the transcript may be
  /// a language-model auto-correction, so perfect matches were downgraded
  /// and the learner should be asked to retry rather than celebrated.
  final bool uncertain;
}

/// Mora-level pronunciation scorer.
///
/// Normalizes the STT transcript (kanji→kana for deck vocabulary,
/// katakana→hiragana, long-vowel expansion), splits both sides into morae,
/// then runs a Needleman–Wunsch alignment so each target mora is judged
/// perfect / close / wrong / missing.
///
/// Pure, deterministic, and free of Flutter/IO so it can be unit-tested and
/// reused by both the learner-facing coach and the accuracy benchmark harness.
class PronunciationScorer {
  static const Map<String, String> _romaji = {
    'あ': 'a', 'い': 'i', 'う': 'u', 'え': 'e', 'お': 'o',
    'か': 'ka', 'き': 'ki', 'く': 'ku', 'け': 'ke', 'こ': 'ko',
    'さ': 'sa', 'し': 'shi', 'す': 'su', 'せ': 'se', 'そ': 'so',
    'た': 'ta', 'ち': 'chi', 'つ': 'tsu', 'て': 'te', 'と': 'to',
    'な': 'na', 'に': 'ni', 'ぬ': 'nu', 'ね': 'ne', 'の': 'no',
    'は': 'ha', 'ひ': 'hi', 'ふ': 'fu', 'へ': 'he', 'ほ': 'ho',
    'ま': 'ma', 'み': 'mi', 'む': 'mu', 'め': 'me', 'も': 'mo',
    'や': 'ya', 'ゆ': 'yu', 'よ': 'yo',
    'ら': 'ra', 'り': 'ri', 'る': 'ru', 'れ': 're', 'ろ': 'ro',
    'わ': 'wa', 'を': 'wo', 'ん': 'n',
    'が': 'ga', 'ぎ': 'gi', 'ぐ': 'gu', 'げ': 'ge', 'ご': 'go',
    'ざ': 'za', 'じ': 'ji', 'ず': 'zu', 'ぜ': 'ze', 'ぞ': 'zo',
    'だ': 'da', 'ぢ': 'ji', 'づ': 'zu', 'で': 'de', 'ど': 'do',
    'ば': 'ba', 'び': 'bi', 'ぶ': 'bu', 'べ': 'be', 'ぼ': 'bo',
    'ぱ': 'pa', 'ぴ': 'pi', 'ぷ': 'pu', 'ぺ': 'pe', 'ぽ': 'po',
    'っ': 'ʔ',
    'きゃ': 'kya', 'きゅ': 'kyu', 'きょ': 'kyo',
    'しゃ': 'sha', 'しゅ': 'shu', 'しょ': 'sho',
    'ちゃ': 'cha', 'ちゅ': 'chu', 'ちょ': 'cho',
    'にゃ': 'nya', 'にゅ': 'nyu', 'にょ': 'nyo',
    'ひゃ': 'hya', 'ひゅ': 'hyu', 'ひょ': 'hyo',
    'みゃ': 'mya', 'みゅ': 'myu', 'みょ': 'myo',
    'りゃ': 'rya', 'りゅ': 'ryu', 'りょ': 'ryo',
    'ぎゃ': 'gya', 'ぎゅ': 'gyu', 'ぎょ': 'gyo',
    'じゃ': 'ja', 'じゅ': 'ju', 'じょ': 'jo',
    'びゃ': 'bya', 'びゅ': 'byu', 'びょ': 'byo',
    'ぴゃ': 'pya', 'ぴゅ': 'pyu', 'ぴょ': 'pyo',
  };

  /// Bengali phonetic label per mora, shown under each kana chip.
  static const Map<String, String> _bengali = {
    'あ': 'আ', 'い': 'ই', 'う': 'উ', 'え': 'এ', 'お': 'ও',
    'か': 'কা', 'き': 'কি', 'く': 'কু', 'け': 'কে', 'こ': 'কো',
    'さ': 'সা', 'し': 'শি', 'す': 'সু', 'せ': 'সে', 'そ': 'সো',
    'た': 'তা', 'ち': 'চি', 'つ': 'ৎসু', 'て': 'তে', 'と': 'তো',
    'な': 'না', 'に': 'নি', 'ぬ': 'নু', 'ね': 'নে', 'の': 'নো',
    'は': 'হা', 'ひ': 'হি', 'ふ': 'ফু', 'へ': 'হে', 'ほ': 'হো',
    'ま': 'মা', 'み': 'মি', 'む': 'মু', 'め': 'মে', 'も': 'মো',
    'や': 'ইয়া', 'ゆ': 'ইউ', 'よ': 'ইয়ো',
    'ら': 'রা', 'り': 'রি', 'る': 'রু', 'れ': 'রে', 'ろ': 'রো',
    'わ': 'ওয়া', 'を': 'ও', 'ん': 'ন',
    'が': 'গা', 'ぎ': 'গি', 'ぐ': 'গু', 'げ': 'গে', 'ご': 'গো',
    'ざ': 'জা', 'じ': 'জি', 'ず': 'জু', 'ぜ': 'জে', 'ぞ': 'জো',
    'だ': 'দা', 'ぢ': 'জি', 'づ': 'জু', 'で': 'দে', 'ど': 'দো',
    'ば': 'বা', 'び': 'বি', 'ぶ': 'বু', 'べ': 'বে', 'ぼ': 'বো',
    'ぱ': 'পা', 'ぴ': 'পি', 'ぷ': 'পু', 'ぺ': 'পে', 'ぽ': 'পো',
    'っ': 'ৎ',
    'きゃ': 'কিয়া', 'きゅ': 'কিউ', 'きょ': 'কিয়ো',
    'しゃ': 'শা', 'しゅ': 'শু', 'しょ': 'শো',
    'ちゃ': 'চা', 'ちゅ': 'চু', 'ちょ': 'চো',
    'にゃ': 'নিয়া', 'にゅ': 'নিউ', 'にょ': 'নিয়ো',
    'ひゃ': 'হিয়া', 'ひゅ': 'হিউ', 'ひょ': 'হিয়ো',
    'みゃ': 'মিয়া', 'みゅ': 'মিউ', 'みょ': 'মিয়ো',
    'りゃ': 'রিয়া', 'りゅ': 'রিউ', 'りょ': 'রিয়ো',
    'ぎゃ': 'গিয়া', 'ぎゅ': 'গিউ', 'ぎょ': 'গিয়ো',
    'じゃ': 'জা', 'じゅ': 'জু', 'じょ': 'জো',
    'びゃ': 'বিয়া', 'びゅ': 'বিউ', 'びょ': 'বিয়ো',
    'ぴゃ': 'পিয়া', 'ぴゅ': 'পিউ', 'ぴょ': 'পিয়ো',
  };

  /// Kanji / alternate spellings Scribe may return for deck vocabulary.
  static const Map<String, String> _kanaSpellings = {
    'お早うございます': 'おはようございます',
    'お早う': 'おはよう',
    '有り難うございます': 'ありがとうございます',
    '有難うございます': 'ありがとうございます',
    '有り難う': 'ありがとう',
    '有難う': 'ありがとう',
    '今日は': 'こんにちは',
    '今晩は': 'こんばんは',
    '済みません': 'すみません',
    '左様なら': 'さようなら',
    '私': 'わたし',
    '学生': 'がくせい',
    '先生': 'せんせい',
    'あの人': 'あのひと',
    '人': 'ひと',
  };

  static const Map<String, String> _devoiced = {
    'が': 'か', 'ぎ': 'き', 'ぐ': 'く', 'げ': 'け', 'ご': 'こ',
    'ざ': 'さ', 'じ': 'し', 'ず': 'す', 'ぜ': 'せ', 'ぞ': 'そ',
    'だ': 'た', 'ぢ': 'ち', 'づ': 'つ', 'で': 'て', 'ど': 'と',
    'ば': 'は', 'び': 'ひ', 'ぶ': 'ふ', 'べ': 'へ', 'ぼ': 'ほ',
    'ぱ': 'は', 'ぴ': 'ひ', 'ぷ': 'ふ', 'ぺ': 'へ', 'ぽ': 'ほ',
  };

  /// Bengali phonetic label for a single mora (falls back to the kana itself).
  static String bengaliOf(String mora) => _bengali[mora] ?? mora;

  /// Below this STT word probability the transcript is treated as a likely
  /// auto-correction: perfect morae are downgraded to close. Tune against
  /// the benchmark harness data (confidence is logged per sample).
  static const double lowConfidenceThreshold = 0.55;

  /// Scores [transcript] against [targetKana].
  ///
  /// [labelOverrides] maps a target mora index to a custom Bengali label,
  /// for particles like は pronounced "ওয়া".
  ///
  /// [confidence] is the STT's weakest per-word acoustic probability (0..1).
  /// STT language models snap mispronounced speech to the nearest real phrase
  /// (こんにちぱ → こんにちは), so when confidence is below
  /// [lowConfidenceThreshold] a textually perfect mora only earns "close" —
  /// the text claims perfection but the audio didn't support it.
  static PronunciationResult evaluate({
    required String targetKana,
    required String transcript,
    Map<int, String> labelOverrides = const {},
    double confidence = 1.0,
  }) {
    final target = segmentMorae(targetKana);
    final said = segmentMorae(normalize(transcript));

    final aligned = _align(target, said);
    var statuses = aligned.$1;

    final uncertain =
        said.isNotEmpty && confidence < lowConfidenceThreshold;
    if (uncertain) {
      statuses = [
        for (final s in statuses)
          s == MoraStatus.perfect ? MoraStatus.close : s,
      ];
    }

    final morae = <MoraResult>[
      for (var i = 0; i < target.length; i++)
        MoraResult(
          target[i],
          labelOverrides[i] ?? bengaliOf(target[i]),
          statuses[i],
        ),
    ];

    var points = 0.0;
    for (final s in statuses) {
      points += switch (s) {
        MoraStatus.perfect => 1.0,
        MoraStatus.close => 0.5,
        _ => 0.0,
      };
    }
    points -= aligned.$2 * 0.15; // small penalty per extra mora
    final score = target.isEmpty
        ? 0
        : (points / target.length * 100).clamp(0, 100).round();
    return PronunciationResult(morae, score, uncertain: uncertain);
  }

  /// Kanji→kana for known words, katakana→hiragana, strips everything that
  /// is not hiragana, and expands ー into the previous mora's vowel.
  static String normalize(String raw) {
    var s = raw;
    final spellings = _kanaSpellings.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    for (final e in spellings) {
      s = s.replaceAll(e.key, e.value);
    }

    final buf = StringBuffer();
    for (final rune in s.runes) {
      var r = rune;
      if (r >= 0x30A1 && r <= 0x30F6) r -= 0x60; // katakana → hiragana
      if (r >= 0x3041 && r <= 0x3096) {
        buf.write(String.fromCharCode(r));
      } else if (r == 0x30FC && buf.isNotEmpty) {
        final prev = buf.toString();
        final vowel = _vowelOf(prev[prev.length - 1]);
        if (vowel != null) buf.write(vowel);
      }
    }
    return buf.toString();
  }

  static String? _vowelOf(String kana) {
    final r = _romaji[kana];
    if (r == null || r.isEmpty) return null;
    return switch (r[r.length - 1]) {
      'a' => 'あ',
      'i' => 'い',
      'u' => 'う',
      'e' => 'え',
      'o' => 'お',
      _ => null,
    };
  }

  static const _smallKana = {'ゃ', 'ゅ', 'ょ', 'ぁ', 'ぃ', 'ぅ', 'ぇ', 'ぉ', 'ゎ'};

  /// Splits a hiragana string into morae, gluing small kana (ゃゅょ…) onto the
  /// preceding character so digraphs like きょ count as one mora.
  static List<String> segmentMorae(String hira) {
    final morae = <String>[];
    for (final rune in hira.runes) {
      final ch = String.fromCharCode(rune);
      if (_smallKana.contains(ch) && morae.isNotEmpty) {
        morae[morae.length - 1] += ch;
      } else {
        morae.add(ch);
      }
    }
    return morae;
  }

  /// Needleman–Wunsch alignment. Returns per-target-mora statuses and the
  /// number of extra (inserted) morae the learner said.
  static (List<MoraStatus>, int) _align(
      List<String> target, List<String> said) {
    final m = target.length, n = said.length;
    const gap = 2, sub = 3, close = 1;

    final dp = List.generate(m + 1, (_) => List<int>.filled(n + 1, 0));
    for (var i = 1; i <= m; i++) {
      dp[i][0] = i * gap;
    }
    for (var j = 1; j <= n; j++) {
      dp[0][j] = j * gap;
    }
    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        final diag = dp[i - 1][j - 1] +
            (target[i - 1] == said[j - 1]
                ? 0
                : _isClose(target[i - 1], said[j - 1])
                    ? close
                    : sub);
        dp[i][j] = math.min(
            diag, math.min(dp[i - 1][j] + gap, dp[i][j - 1] + gap));
      }
    }

    final statuses = List<MoraStatus>.filled(m, MoraStatus.missing);
    var insertions = 0;
    var i = m, j = n;
    while (i > 0 || j > 0) {
      if (i > 0 && j > 0) {
        final cost = target[i - 1] == said[j - 1]
            ? 0
            : _isClose(target[i - 1], said[j - 1])
                ? close
                : sub;
        if (dp[i][j] == dp[i - 1][j - 1] + cost) {
          statuses[i - 1] = cost == 0
              ? MoraStatus.perfect
              : cost == close
                  ? MoraStatus.close
                  : MoraStatus.wrong;
          i--;
          j--;
          continue;
        }
      }
      if (i > 0 && dp[i][j] == dp[i - 1][j] + gap) {
        statuses[i - 1] = MoraStatus.missing;
        i--;
      } else {
        insertions++;
        j--;
      }
    }
    return (statuses, insertions);
  }

  static bool _isClose(String a, String b) {
    if (a == b) return true;
    String devoice(String mora) {
      final head = _devoiced[mora[0]] ?? mora[0];
      return head + mora.substring(1);
    }

    if (devoice(a) == devoice(b)) return true;

    final ra = _romaji[a], rb = _romaji[b];
    if (ra == null || rb == null || ra == 'ʔ' || rb == 'ʔ') return false;
    if (ra == 'n' || rb == 'n') return false;

    final va = ra[ra.length - 1], vb = rb[rb.length - 1];
    final ca = ra.substring(0, ra.length - 1);
    final cb = rb.substring(0, rb.length - 1);
    // Same consonant, different vowel (か vs こ) — close.
    if (ca.isNotEmpty && ca == cb) return true;
    // Same vowel, different consonant (か vs た) — close.
    if (va == vb && ca.isNotEmpty && cb.isNotEmpty) return true;
    return false;
  }
}
