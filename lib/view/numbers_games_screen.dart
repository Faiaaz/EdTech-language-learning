import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ez_trainz/utils/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:ez_trainz/services/jlc_tts.dart';
import 'package:get/get.dart';
import 'package:ez_trainz/services/jlc_stt.dart';

enum NumbersGameMode { listening, speaking, flashcard, matching }

extension NumbersGameModeX on NumbersGameMode {
  String get titleBn {
    switch (this) {
      case NumbersGameMode.listening:
        return 'শুনতে কি পারো?';
      case NumbersGameMode.speaking:
        return 'বলতে কি পারো?';
      case NumbersGameMode.flashcard:
        return 'চিনতে কি পারো?';
      case NumbersGameMode.matching:
        return 'ম্যাচ করতে কি পারো?';
    }
  }

  String get subtitleBn {
    switch (this) {
      case NumbersGameMode.listening:
        return 'Listening game';
      case NumbersGameMode.speaking:
        return 'Speaking game';
      case NumbersGameMode.flashcard:
        return 'Flashcard game';
      case NumbersGameMode.matching:
        return 'Matching game';
    }
  }
}

class NumbersGameScreen extends StatelessWidget {
  const NumbersGameScreen({super.key, required this.mode});

  final NumbersGameMode mode;

  static const _bg = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      mode.titleBn,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: switch (mode) {
                NumbersGameMode.listening => const _ListeningNumbersGame(),
                NumbersGameMode.speaking => const _SpeakingNumbersGame(),
                NumbersGameMode.flashcard => const _FlashcardNumbersGame(),
                NumbersGameMode.matching => const _MatchingNumbersGame(),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NumItem {
  const _NumItem({
    required this.n,
    required this.kanji,
    required this.kana,
    required this.romaji,
    required this.bnPronunciation,
    required this.bnDigit,
    required this.bnWord,
  });

  final int n;
  final String kanji;
  final String kana;
  final String romaji;
  final String bnPronunciation;
  final String bnDigit;
  final String bnWord;
}

const _numbers = <_NumItem>[
  _NumItem(
      n: 1,
      kanji: '一',
      kana: 'いち',
      romaji: 'ichi',
      bnPronunciation: 'ইচি',
      bnDigit: '১',
      bnWord: 'এক'),
  _NumItem(
      n: 2,
      kanji: '二',
      kana: 'に',
      romaji: 'ni',
      bnPronunciation: 'নি',
      bnDigit: '২',
      bnWord: 'দুই'),
  _NumItem(
      n: 3,
      kanji: '三',
      kana: 'さん',
      romaji: 'san',
      bnPronunciation: 'সান',
      bnDigit: '৩',
      bnWord: 'তিন'),
  _NumItem(
      n: 4,
      kanji: '四',
      kana: 'よん',
      romaji: 'yon',
      bnPronunciation: 'ইয়োন',
      bnDigit: '৪',
      bnWord: 'চার'),
  _NumItem(
      n: 5,
      kanji: '五',
      kana: 'ご',
      romaji: 'go',
      bnPronunciation: 'গো',
      bnDigit: '৫',
      bnWord: 'পাঁচ'),
  _NumItem(
      n: 6,
      kanji: '六',
      kana: 'ろく',
      romaji: 'roku',
      bnPronunciation: 'রোকু',
      bnDigit: '৬',
      bnWord: 'ছয়'),
  _NumItem(
      n: 7,
      kanji: '七',
      kana: 'なな',
      romaji: 'nana',
      bnPronunciation: 'নানা',
      bnDigit: '৭',
      bnWord: 'সাত'),
  _NumItem(
      n: 8,
      kanji: '八',
      kana: 'はち',
      romaji: 'hachi',
      bnPronunciation: 'হাচি',
      bnDigit: '৮',
      bnWord: 'আট'),
  _NumItem(
      n: 9,
      kanji: '九',
      kana: 'きゅう',
      romaji: 'kyuu',
      bnPronunciation: 'কিউ',
      bnDigit: '৯',
      bnWord: 'নয়'),
  _NumItem(
      n: 10,
      kanji: '十',
      kana: 'じゅう',
      romaji: 'juu',
      bnPronunciation: 'জু',
      bnDigit: '১০',
      bnWord: 'দশ'),
];

class _ListeningNumbersGame extends StatefulWidget {
  const _ListeningNumbersGame();

  @override
  State<_ListeningNumbersGame> createState() => _ListeningNumbersGameState();
}

class _ListeningNumbersGameState extends State<_ListeningNumbersGame> {
  static const _card = AppColors.card;
  static const _muted = Color(0xFF94A3B8);
  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);

  final _rng = math.Random();
  final _tts = JlcTts();
  late final Future<void> _ttsReady;

  late _NumItem _target;
  late List<_NumItem> _options;

  int _score = 0;
  int _lives = 3;
  bool _answered = false;
  int? _pickedN;

  @override
  void initState() {
    super.initState();
    _ttsReady = _initTts();
    _nextRound();
  }

  Future<void> _initTts() async {
    await _tts.awaitSpeakCompletion(true);
    await _tts.setLanguage('ja-JP');
    await _tts.setSpeechRate(0.52);
    await _tts.setPitch(1.05);
    await _tts.setVolume(1.0);
  }

  Future<void> _speakTarget() async {
    await _ttsReady;
    await _tts.stop();
    await _tts.speak('${_target.kana}。');
  }

  void _nextRound() {
    final nextTarget = _numbers[_rng.nextInt(_numbers.length)];
    final pool = _numbers.where((n) => n.n != nextTarget.n).toList()..shuffle(_rng);
    final options = <_NumItem>[nextTarget, ...pool.take(3)]..shuffle(_rng);
    setState(() {
      _target = nextTarget;
      _options = options;
      _answered = false;
      _pickedN = null;
    });
    // ignore: discarded_futures
    _speakTarget();
  }

  void _pick(_NumItem picked) {
    if (_answered) return;
    final isCorrect = picked.n == _target.n;
    setState(() {
      _answered = true;
      _pickedN = picked.n;
      if (isCorrect) {
        _score += 1;
      } else {
        _lives = (_lives - 1).clamp(0, 3);
      }
    });
    HapticFeedback.selectionClick();
    Future.delayed(const Duration(milliseconds: 550), () {
      if (!mounted) return;
      if (_lives <= 0) {
        _showGameOver();
      } else {
        _nextRound();
      }
    });
  }

  void _showGameOver() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('গেম শেষ!', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('আপনার স্কোর: $_score', style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _score = 0;
                _lives = 3;
              });
              _nextRound();
            },
            child: const Text('আবার খেলুন'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.back();
            },
            child: const Text('শেষ'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.score_rounded, color: Color(0xFFFFE000), size: 18),
                const SizedBox(width: 6),
                Text('স্কোর: $_score',
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900)),
                const Spacer(),
                for (var i = 0; i < 3; i++)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.favorite_rounded,
                      size: 18,
                      color: i < _lives ? _red : _muted.withValues(alpha: 0.4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Icon(Icons.hearing_rounded, color: Color(0xFFFFE000), size: 34),
                const SizedBox(height: 8),
                const Text(
                  'শুনে সঠিক বাংলা নির্বাচন করুন',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Text(
                  'ইঙ্গিত: ${_target.kanji} (${_target.kana})',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _speakTarget,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE000),
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.volume_up_rounded),
                  label: const Text('আবার শুনুন', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _options.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.8,
              ),
              itemBuilder: (_, i) {
                final option = _options[i];
                final isCorrect = option.n == _target.n;
                final isPicked = _pickedN == option.n;
                var bg = AppColors.bg;
                var border = AppColors.border;
                if (_answered && isCorrect) {
                  bg = _green.withValues(alpha: 0.2);
                  border = _green.withValues(alpha: 0.8);
                } else if (_answered && isPicked && !isCorrect) {
                  bg = _red.withValues(alpha: 0.2);
                  border = _red.withValues(alpha: 0.8);
                }
                return GestureDetector(
                  onTap: () => _pick(option),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: border, width: 1.6),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(option.bnDigit,
                            style: const TextStyle(
                              color: Color(0xFFFFE000),
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            )),
                        const SizedBox(height: 4),
                        Text(
                          option.bnWord,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeakingNumbersGame extends StatefulWidget {
  const _SpeakingNumbersGame();

  @override
  State<_SpeakingNumbersGame> createState() => _SpeakingNumbersGameState();
}

class _SpeakingNumbersGameState extends State<_SpeakingNumbersGame> {
  static const _card = AppColors.card;
  static const _accent = Color(0xFFFFE000);
  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);

  final _rng = math.Random();
  final _tts = JlcTts();
  final _stt = JlcStt();

  late List<_NumItem> _deck;
  int _index = 0;
  int _score = 0;
  bool _listening = false;
  bool _ttsReady = false;
  bool _sttReady = false;
  String? _sttLocaleId;
  String _recognized = '';
  String? _error;
  bool? _lastCorrect;

  _NumItem get _current => _deck[_index];

  @override
  void initState() {
    super.initState();
    _deck = List<_NumItem>.of(_numbers)..shuffle(_rng);
    // ignore: discarded_futures
    _initTts();
    // ignore: discarded_futures
    _initStt();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('ja-JP');
      await _tts.setSpeechRate(0.46);
      await _tts.setPitch(1.05);
      await _tts.setVolume(1.0);
      if (!mounted) return;
      setState(() => _ttsReady = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _ttsReady = false);
    }
  }

  Future<void> _initStt() async {
    try {
      final ok = await _stt.initialize(
        onError: (e) {
          if (!mounted) return;
          setState(() => _error = e.errorMsg);
        },
        onStatus: (_) {},
      );
      if (!mounted) return;
      if (!ok) {
        setState(() {
          _sttReady = false;
          _sttLocaleId = null;
        });
        return;
      }
      final locales = await _stt.locales();
      final ja = locales.where((l) => l.localeId.toLowerCase().startsWith('ja'));
      setState(() {
        _sttLocaleId = ja.isNotEmpty
            ? ja.first.localeId
            : (locales.isNotEmpty ? locales.first.localeId : null);
        _sttReady = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sttReady = false;
        _sttLocaleId = null;
      });
    }
  }

  Future<void> _playModel() async {
    if (!_ttsReady) return;
    HapticFeedback.selectionClick();
    await _tts.stop();
    await _tts.speak(_current.kana);
  }

  Future<void> _startListening() async {
    if (_listening || !_sttReady) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _error = null;
      _recognized = '';
      _lastCorrect = null;
    });
    try {
      // ignore: deprecated_member_use
      await _stt.listen(
        localeId: _sttLocaleId,
        listenMode: ListenMode.confirmation,
        partialResults: true,
        cancelOnError: true,
        onResult: _onSttResult,
      );
      if (!mounted) return;
      setState(() => _listening = true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    }
  }

  void _onSttResult(JlcSttResult result) {
    if (!mounted) return;
    setState(() => _recognized = result.recognizedWords);
  }

  Future<void> _stopListeningAndJudge() async {
    if (!_listening) return;
    HapticFeedback.selectionClick();
    await _stt.stop();
    final correct = _isCorrect(_recognized, _current);
    if (!mounted) return;
    setState(() {
      _listening = false;
      _lastCorrect = correct;
      if (correct) _score += 1;
    });
  }

  bool _isCorrect(String raw, _NumItem target) {
    final heard = _normalize(raw);
    if (heard.isEmpty) return false;
    final kana = _normalize(target.kana);
    final romaji = _normalize(target.romaji);
    return heard.contains(kana) || heard == kana || heard.contains(romaji) || heard == romaji;
  }

  String _normalize(String text) {
    final lower = text.toLowerCase();
    final out = StringBuffer();
    for (final rune in lower.runes) {
      final isAsciiAlphaNum =
          (rune >= 0x30 && rune <= 0x39) || (rune >= 0x61 && rune <= 0x7A);
      final isJapanese = (rune >= 0x3040 && rune <= 0x30FF) || (rune >= 0x4E00 && rune <= 0x9FFF);
      if (isAsciiAlphaNum || isJapanese) {
        out.write(String.fromCharCode(rune));
      }
    }
    return out.toString();
  }

  void _next() {
    HapticFeedback.selectionClick();
    setState(() {
      _error = null;
      _recognized = '';
      _lastCorrect = null;
      if (_index >= _deck.length - 1) {
        _deck = List<_NumItem>.of(_numbers)..shuffle(_rng);
        _index = 0;
      } else {
        _index += 1;
      }
    });
  }

  @override
  void dispose() {
    _stt.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultColor = _lastCorrect == null
        ? AppColors.textMuted
        : (_lastCorrect! ? _green : _red);
    final resultText = _lastCorrect == null
        ? 'মাইক চালু করে জাপানি উচ্চারণ বলুন'
        : (_lastCorrect! ? 'দারুণ! সঠিক হয়েছে' : 'আবার চেষ্টা করুন');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Text(
                  _current.kanji,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 68,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _current.kana,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'বাংলা: ${_current.bnDigit} ${_current.bnWord}',
                  style: const TextStyle(
                    color: _accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _playModel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: AppColors.textPrimary,
                          shape:
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.volume_up_rounded),
                        label:
                            const Text('শুনুন', style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _listening ? _stopListeningAndJudge : _startListening,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _listening ? _red : const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          shape:
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: Icon(_listening ? Icons.stop_rounded : Icons.mic_rounded),
                        label: Text(
                          _listening ? 'Stop' : 'Record',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'শোনা ফলাফল: ${_recognized.isEmpty ? '---' : _recognized}',
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  resultText,
                  style: TextStyle(color: resultColor, fontWeight: FontWeight.w900),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Colors.red.shade300,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'স্কোর: $_score',
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: _next,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.accentBlue.withValues(alpha: 0.5)),
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.navigate_next_rounded),
                label: const Text('Next', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlashcardNumbersGame extends StatefulWidget {
  const _FlashcardNumbersGame();

  @override
  State<_FlashcardNumbersGame> createState() => _FlashcardNumbersGameState();
}

class _FlashcardNumbersGameState extends State<_FlashcardNumbersGame> {
  static const _card = AppColors.card;
  static const _muted = Color(0xFF94A3B8);
  int _index = 0;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
  }

  _NumItem get _item => _numbers[_index];

  void _flip() {
    HapticFeedback.selectionClick();
    setState(() => _isFront = !_isFront);
  }

  void _goPrev() {
    if (_index == 0) return;
    HapticFeedback.selectionClick();
    setState(() {
      _index -= 1;
      _isFront = true;
    });
  }

  void _goNext() {
    if (_index >= _numbers.length - 1) return;
    HapticFeedback.selectionClick();
    setState(() {
      _index += 1;
      _isFront = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.style_rounded, color: Color(0xFFFFE000)),
                const SizedBox(width: 8),
                Text(
                  'ফ্ল্যাশকার্ড ${_index + 1}/${_numbers.length}',
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                Text(
                  _isFront ? 'Front' : 'Back',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GestureDetector(
              onTap: _flip,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _isFront
                    ? _FlashSideCard(
                        key: const ValueKey('front'),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _item.kanji,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 86,
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _item.kana,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color(0xFF3B82F6).withValues(alpha: 0.45)),
                              ),
                              child: Text(
                                _item.bnPronunciation,
                                style: const TextStyle(
                                  color: Color(0xFFFFE000),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'ট্যাপ করে অর্থ দেখুন',
                              style: TextStyle(
                                color: _muted.withValues(alpha: 0.95),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _FlashSideCard(
                        key: const ValueKey('back'),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _item.bnWord,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 54,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _item.bnDigit,
                              style: const TextStyle(
                                color: Color(0xFFFFE000),
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${_item.kanji} (${_item.kana})',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'ট্যাপ করে সামনে ফিরুন',
                              style: TextStyle(
                                color: _muted.withValues(alpha: 0.95),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _index == 0 ? null : _goPrev,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.accentBlue.withValues(alpha: 0.5)),
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.navigate_before_rounded),
                  label: const Text('আগেরটি', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _index >= _numbers.length - 1 ? null : _goNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.navigate_next_rounded),
                  label: const Text('পরেরটি', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlashSideCard extends StatelessWidget {
  const _FlashSideCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MatchCard {
  const _MatchCard({
    required this.id,
    required this.n,
    required this.label,
    required this.jpSide,
  });

  final String id;
  final int n;
  final String label;
  final bool jpSide;
}

class _MatchingNumbersGame extends StatefulWidget {
  const _MatchingNumbersGame();

  @override
  State<_MatchingNumbersGame> createState() => _MatchingNumbersGameState();
}

class _MatchingNumbersGameState extends State<_MatchingNumbersGame> {
  static const _card = AppColors.card;
  static const _muted = Color(0xFF94A3B8);
  static const _green = Color(0xFF10B981);

  final _rng = math.Random();
  late List<_MatchCard> _cards;
  String? _pickedId;
  int? _pickedN;
  final _matched = <String>{};
  int _moves = 0;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    final pool = List<_NumItem>.of(_numbers)..shuffle(_rng);
    final take = pool.take(6).toList();
    final cards = <_MatchCard>[];
    for (final it in take) {
      cards.add(_MatchCard(
        id: 'jp_${it.n}',
        n: it.n,
        label: '${it.kanji}\n${it.kana}',
        jpSide: true,
      ));
      cards.add(_MatchCard(
        id: 'bn_${it.n}',
        n: it.n,
        label: '${it.bnDigit} ${it.bnWord}',
        jpSide: false,
      ));
    }
    cards.shuffle(_rng);
    setState(() {
      _cards = cards;
      _pickedId = null;
      _pickedN = null;
      _matched.clear();
      _moves = 0;
    });
  }

  void _tap(_MatchCard c) {
    if (_matched.contains(c.id)) return;
    HapticFeedback.selectionClick();
    if (_pickedId == null) {
      setState(() {
        _pickedId = c.id;
        _pickedN = c.n;
      });
      return;
    }
    if (_pickedId == c.id) return;
    _moves += 1;
    final isCorrect = _pickedN == c.n;
    if (isCorrect) {
      setState(() {
        _matched.add(_pickedId!);
        _matched.add(c.id);
        _pickedId = null;
        _pickedN = null;
      });
      if (_matched.length == _cards.length) {
        Future.delayed(const Duration(milliseconds: 300), _showDone);
      }
    } else {
      final secondPickId = c.id;
      setState(() {
        _pickedId = secondPickId;
        _pickedN = c.n;
      });
      Future.delayed(const Duration(milliseconds: 480), () {
        if (!mounted) return;
        setState(() {
          if (_pickedId == secondPickId) {
            _pickedId = null;
            _pickedN = null;
          }
        });
      });
    }
  }

  void _showDone() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('সব মিলেছে!', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('মুভ: $_moves', style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _reset();
            },
            child: const Text('আবার খেলুন'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.back();
            },
            child: const Text('শেষ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.extension_rounded, color: Color(0xFFFFE000), size: 18),
                const SizedBox(width: 6),
                const Text(
                  'জাপানি ↔ বাংলা মিলান',
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                Text(
                  'মুভ: $_moves',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _cards.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.12,
              ),
              itemBuilder: (_, i) {
                final c = _cards[i];
                final matched = _matched.contains(c.id);
                final selected = _pickedId == c.id;
                var border = AppColors.border;
                var bg = AppColors.bg;
                if (matched) {
                  border = _green.withValues(alpha: 0.75);
                  bg = _green.withValues(alpha: 0.14);
                } else if (selected) {
                  border = const Color(0xFFFFE000);
                  bg = const Color(0xFFFFE000).withValues(alpha: 0.14);
                }
                return GestureDetector(
                  onTap: () => _tap(c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: border, width: selected ? 2.3 : 1.4),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          c.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: c.jpSide ? 20 : 16,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          c.jpSide ? 'জাপানি' : 'বাংলা',
                          style: TextStyle(
                            color: _muted.withValues(alpha: 0.86),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _reset,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.accentBlue.withValues(alpha: 0.5)),
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('রি-স্টার্ট', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}
