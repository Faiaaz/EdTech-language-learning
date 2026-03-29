import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/ielts_controller.dart';
import 'package:ez_trainz/models/ielts.dart';
import 'package:ez_trainz/services/ielts_service.dart';

/// IELTS Mini Games screen with interactive word games.
class IeltsMiniGamesScreen extends StatelessWidget {
  const IeltsMiniGamesScreen({super.key});

  static const _teal = Color(0xFF11998E);
  static const _tealLight = Color(0xFF38EF7D);

  @override
  Widget build(BuildContext context) {
    final ctrl = IeltsController.to;

    return Scaffold(
      backgroundColor: const Color(0xFFE0F2F1),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [_teal, _tealLight])),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white38)),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('Back', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('IELTS Mini Games', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('Learn while having fun!', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Choose a Game', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 14),

                    // Synonym Sprint
                    _GameCard(
                      icon: Icons.sync_alt_rounded,
                      title: 'Synonym Sprint',
                      subtitle: 'Match words to their synonyms!',
                      color: const Color(0xFF2196F3),
                      difficulty: 'Band 6+',
                      onTap: () {
                        ctrl.startSynonymGame();
                        Get.to(() => _SynonymGameScreen(ctrl: ctrl), transition: Transition.rightToLeftWithFade);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Error Detective
                    _GameCard(
                      icon: Icons.bug_report_rounded,
                      title: 'Error Detective',
                      subtitle: 'Find grammar errors in sentences!',
                      color: const Color(0xFFF44336),
                      difficulty: 'Band 7+',
                      onTap: () {
                        ctrl.startErrorSpottingGame();
                        Get.to(() => _ErrorSpottingGameScreen(ctrl: ctrl), transition: Transition.rightToLeftWithFade);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Sentence Architect
                    _GameCard(
                      icon: Icons.construction_rounded,
                      title: 'Sentence Architect',
                      subtitle: 'Build correct sentences from words!',
                      color: const Color(0xFF9C27B0),
                      difficulty: 'Band 7+',
                      onTap: () {
                        ctrl.startSentenceBuilderGame();
                        Get.to(() => _SentenceBuilderGameScreen(ctrl: ctrl), transition: Transition.rightToLeftWithFade);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Collocation Connect
                    _GameCard(
                      icon: Icons.link_rounded,
                      title: 'Collocation Connect',
                      subtitle: 'Match words that go together!',
                      color: const Color(0xFFFF9800),
                      difficulty: 'Band 7+',
                      onTap: () {
                        ctrl.startCollocationGame();
                        Get.to(() => _CollocationGameScreen(ctrl: ctrl), transition: Transition.rightToLeftWithFade);
                      },
                    ),

                    const SizedBox(height: 24),

                    // Games played counter
                    Obx(() => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
                      ),
                      child: Row(children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(color: _teal.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.sports_esports_rounded, color: _teal, size: 24),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(child: Text('Total Games Played', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)))),
                        Text('${ctrl.totalGamesPlayed.value}', style: const TextStyle(color: _teal, fontSize: 24, fontWeight: FontWeight.w900)),
                      ]),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String difficulty;
  final VoidCallback onTap;

  const _GameCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.difficulty, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Text(difficulty, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SYNONYM SPRINT GAME
// ═══════════════════════════════════════════════════════════════════
class _SynonymGameScreen extends StatefulWidget {
  final IeltsController ctrl;
  const _SynonymGameScreen({required this.ctrl});

  @override
  State<_SynonymGameScreen> createState() => _SynonymGameScreenState();
}

class _SynonymGameScreenState extends State<_SynonymGameScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _answered = false;
  String _selectedAnswer = '';
  late List<Map<String, dynamic>> _items;
  late List<String> _currentOptions;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.ctrl.gameItems);
    _generateOptions();
  }

  void _generateOptions() {
    if (_currentIndex >= _items.length) return;
    final correct = _items[_currentIndex]['synonym'] as String;
    final allSynonyms = IeltsService.synonymPairs.map((p) => p['synonym']!).toList()..shuffle(Random());
    final options = <String>[correct];
    for (final s in allSynonyms) {
      if (options.length >= 4) break;
      if (!options.contains(s)) options.add(s);
    }
    options.shuffle(Random());
    _currentOptions = options;
  }

  void _selectAnswer(String answer) {
    if (_answered) return;
    final correct = _items[_currentIndex]['synonym'] as String;
    setState(() {
      _answered = true;
      _selectedAnswer = answer;
      if (answer == correct) _score++;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (_currentIndex < _items.length - 1) {
        setState(() {
          _currentIndex++;
          _answered = false;
          _selectedAnswer = '';
          _generateOptions();
        });
      } else {
        widget.ctrl.endGame();
        _showResults();
      }
    });
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Game Over!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('$_score / ${_items.length}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF2196F3))),
          const SizedBox(height: 8),
          Text('${(_score / _items.length * 100).round()}% accuracy', style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
        ]),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); Get.back(); }, child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const Scaffold(body: Center(child: Text('No data')));
    final item = _items[_currentIndex];
    final word = item['word'] as String;
    final correct = item['synonym'] as String;

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            color: const Color(0xFF2196F3),
            child: Row(children: [
              GestureDetector(onTap: () { widget.ctrl.endGame(); Get.back(); }, child: const Icon(Icons.close_rounded, color: Colors.white, size: 24)),
              const SizedBox(width: 12),
              const Expanded(child: Text('Synonym Sprint', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
              Text('$_score pts', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
            ]),
          ),
          // Progress bar
          LinearProgressIndicator(value: (_currentIndex + 1) / _items.length, backgroundColor: const Color(0xFFBBDEFB), valueColor: const AlwaysStoppedAnimation(Color(0xFF2196F3)), minHeight: 4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${_currentIndex + 1} / ${_items.length}', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
                const SizedBox(height: 8),
                const Text('What is a synonym for:', style: TextStyle(fontSize: 16, color: Color(0xFF555555))),
                const SizedBox(height: 12),
                Text(word, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 32),
                ...(_currentOptions).map((opt) {
                  Color bgColor = Colors.white;
                  Color borderColor = const Color(0xFFE0E0E0);
                  if (_answered) {
                    if (opt == correct) {
                      bgColor = const Color(0xFFE8F5E9);
                      borderColor = const Color(0xFF4CAF50);
                    } else if (opt == _selectedAnswer && opt != correct) {
                      bgColor = const Color(0xFFFCE4EC);
                      borderColor = const Color(0xFFF44336);
                    }
                  } else if (opt == _selectedAnswer) {
                    bgColor = const Color(0xFFE3F2FD);
                    borderColor = const Color(0xFF2196F3);
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => _selectAnswer(opt),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: borderColor, width: 2)),
                        child: Text(opt, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)), textAlign: TextAlign.center),
                      ),
                    ),
                  );
                }),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ERROR DETECTIVE GAME
// ═══════════════════════════════════════════════════════════════════
class _ErrorSpottingGameScreen extends StatefulWidget {
  final IeltsController ctrl;
  const _ErrorSpottingGameScreen({required this.ctrl});

  @override
  State<_ErrorSpottingGameScreen> createState() => _ErrorSpottingGameScreenState();
}

class _ErrorSpottingGameScreenState extends State<_ErrorSpottingGameScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _revealed = false;

  List<Map<String, dynamic>> get _items => widget.ctrl.gameItems;

  void _reveal() {
    setState(() => _revealed = true);
  }

  void _next(bool gotIt) {
    if (gotIt) _score++;
    if (_currentIndex < _items.length - 1) {
      setState(() {
        _currentIndex++;
        _revealed = false;
      });
    } else {
      widget.ctrl.endGame();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Game Over!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900)),
          content: Text('Score: $_score / ${_items.length}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          actions: [TextButton(onPressed: () { Navigator.pop(context); Get.back(); }, child: const Text('Done'))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const Scaffold(body: Center(child: Text('No data')));
    final item = _items[_currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      body: SafeArea(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            color: const Color(0xFFF44336),
            child: Row(children: [
              GestureDetector(onTap: () { widget.ctrl.endGame(); Get.back(); }, child: const Icon(Icons.close_rounded, color: Colors.white, size: 24)),
              const SizedBox(width: 12),
              const Expanded(child: Text('Error Detective', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
              Text('$_score pts', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
            ]),
          ),
          LinearProgressIndicator(value: (_currentIndex + 1) / _items.length, backgroundColor: const Color(0xFFFFCDD2), valueColor: const AlwaysStoppedAnimation(Color(0xFFF44336)), minHeight: 4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${_currentIndex + 1} / ${_items.length}', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
                const SizedBox(height: 8),
                const Text('Find the error in this sentence:', style: TextStyle(fontSize: 16, color: Color(0xFF555555))),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12)]),
                  child: Text(item['sentence'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E), height: 1.5), textAlign: TextAlign.center),
                ),
                const SizedBox(height: 24),

                if (!_revealed)
                  GestureDetector(
                    onTap: _reveal,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFF44336), Color(0xFFC62828)]), borderRadius: BorderRadius.circular(14)),
                      child: const Center(child: Text('Reveal Answer', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800))),
                    ),
                  ),

                if (_revealed) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(14)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      RichText(text: TextSpan(children: [
                        const TextSpan(text: 'Error: ', style: TextStyle(color: Color(0xFFC62828), fontSize: 14, fontWeight: FontWeight.w800)),
                        TextSpan(text: '${item['error']}', style: const TextStyle(color: Color(0xFFC62828), fontSize: 14, decoration: TextDecoration.lineThrough)),
                        const TextSpan(text: '  \u2192  ', style: TextStyle(color: Color(0xFF333333), fontSize: 14)),
                        TextSpan(text: '${item['correction']}', style: const TextStyle(color: Color(0xFF2E7D32), fontSize: 14, fontWeight: FontWeight.w800)),
                      ])),
                      const SizedBox(height: 8),
                      Text(item['rule'] as String, style: const TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.4)),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: GestureDetector(
                      onTap: () => _next(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(color: const Color(0xFFF44336), borderRadius: BorderRadius.circular(12)),
                        child: const Center(child: Text('Missed it', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                      ),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: GestureDetector(
                      onTap: () => _next(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(color: const Color(0xFF4CAF50), borderRadius: BorderRadius.circular(12)),
                        child: const Center(child: Text('Got it!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                      ),
                    )),
                  ]),
                ],
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SENTENCE BUILDER GAME
// ═══════════════════════════════════════════════════════════════════
class _SentenceBuilderGameScreen extends StatefulWidget {
  final IeltsController ctrl;
  const _SentenceBuilderGameScreen({required this.ctrl});

  @override
  State<_SentenceBuilderGameScreen> createState() => _SentenceBuilderGameScreenState();
}

class _SentenceBuilderGameScreenState extends State<_SentenceBuilderGameScreen> {
  int _currentIndex = 0;
  int _score = 0;
  List<String> _shuffledWords = [];
  List<String> _selectedWords = [];
  bool _checked = false;
  bool _isCorrect = false;

  List<Map<String, dynamic>> get _items => widget.ctrl.gameItems;

  @override
  void initState() {
    super.initState();
    _setupRound();
  }

  void _setupRound() {
    if (_currentIndex >= _items.length) return;
    final words = List<String>.from(_items[_currentIndex]['words'] as List);
    words.shuffle(Random());
    _shuffledWords = words;
    _selectedWords = [];
    _checked = false;
    _isCorrect = false;
  }

  void _tapWord(String word) {
    if (_checked) return;
    setState(() {
      _shuffledWords.remove(word);
      _selectedWords.add(word);
    });
  }

  void _removeWord(String word) {
    if (_checked) return;
    setState(() {
      _selectedWords.remove(word);
      _shuffledWords.add(word);
    });
  }

  void _check() {
    final correct = _items[_currentIndex]['correct'] as String;
    final attempt = _selectedWords.join(' ');
    setState(() {
      _checked = true;
      _isCorrect = attempt == correct;
      if (_isCorrect) _score++;
    });
  }

  void _next() {
    if (_currentIndex < _items.length - 1) {
      setState(() { _currentIndex++; _setupRound(); });
    } else {
      widget.ctrl.endGame();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Game Over!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900)),
          content: Text('Score: $_score / ${_items.length}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          actions: [TextButton(onPressed: () { Navigator.pop(context); Get.back(); }, child: const Text('Done'))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      body: SafeArea(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            color: const Color(0xFF9C27B0),
            child: Row(children: [
              GestureDetector(onTap: () { widget.ctrl.endGame(); Get.back(); }, child: const Icon(Icons.close_rounded, color: Colors.white, size: 24)),
              const SizedBox(width: 12),
              const Expanded(child: Text('Sentence Architect', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
              Text('$_score pts', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
            ]),
          ),
          LinearProgressIndicator(value: (_currentIndex + 1) / _items.length, backgroundColor: const Color(0xFFE1BEE7), valueColor: const AlwaysStoppedAnimation(Color(0xFF9C27B0)), minHeight: 4),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Text('${_currentIndex + 1} / ${_items.length}', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
                const SizedBox(height: 8),
                const Text('Arrange the words to form a correct sentence:', style: TextStyle(fontSize: 16, color: Color(0xFF555555), fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                const SizedBox(height: 20),

                // Selected words area
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 80),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _checked ? (_isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFF44336)) : const Color(0xFFCE93D8), width: 2),
                  ),
                  child: Wrap(spacing: 6, runSpacing: 6, children: _selectedWords.map((w) => GestureDetector(
                    onTap: () => _removeWord(w),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: const Color(0xFF9C27B0).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                      child: Text(w, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF6A1B9A))),
                    ),
                  )).toList()),
                ),

                const SizedBox(height: 16),

                // Available words
                Wrap(spacing: 8, runSpacing: 8, children: _shuffledWords.map((w) => GestureDetector(
                  onTap: () => _tapWord(w),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE0E0E0))),
                    child: Text(w, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF333333))),
                  ),
                )).toList()),

                const SizedBox(height: 24),

                if (!_checked && _shuffledWords.isEmpty)
                  GestureDetector(
                    onTap: _check,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFF6A1B9A)]), borderRadius: BorderRadius.circular(14)),
                      child: const Center(child: Text('Check', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800))),
                    ),
                  ),

                if (_checked) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _isCorrect ? const Color(0xFFE8F5E9) : const Color(0xFFFCE4EC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_isCorrect ? 'Correct!' : 'Not quite. Correct answer:', style: TextStyle(fontWeight: FontWeight.w800, color: _isCorrect ? const Color(0xFF2E7D32) : const Color(0xFFC62828))),
                      if (!_isCorrect) ...[
                        const SizedBox(height: 6),
                        Text(_items[_currentIndex]['correct'] as String, style: const TextStyle(fontSize: 14, color: Color(0xFF333333), fontStyle: FontStyle.italic)),
                      ],
                    ]),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _next,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFF6A1B9A)]), borderRadius: BorderRadius.circular(14)),
                      child: const Center(child: Text('Next', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800))),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// COLLOCATION CONNECT GAME
// ═══════════════════════════════════════════════════════════════════
class _CollocationGameScreen extends StatefulWidget {
  final IeltsController ctrl;
  const _CollocationGameScreen({required this.ctrl});

  @override
  State<_CollocationGameScreen> createState() => _CollocationGameScreenState();
}

class _CollocationGameScreenState extends State<_CollocationGameScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _answered = false;
  String _selectedAnswer = '';
  late List<String> _options;

  List<Map<String, dynamic>> get _items => widget.ctrl.gameItems;

  @override
  void initState() {
    super.initState();
    _generateOptions();
  }

  void _generateOptions() {
    if (_currentIndex >= _items.length) return;
    final correct = _items[_currentIndex]['second'] as String;
    final allSeconds = IeltsService.collocationPairs.map((p) => p['second']!).toList()..shuffle(Random());
    final opts = <String>[correct];
    for (final s in allSeconds) {
      if (opts.length >= 4) break;
      if (!opts.contains(s)) opts.add(s);
    }
    opts.shuffle(Random());
    _options = opts;
  }

  void _select(String answer) {
    if (_answered) return;
    final correct = _items[_currentIndex]['second'] as String;
    setState(() {
      _answered = true;
      _selectedAnswer = answer;
      if (answer == correct) _score++;
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (_currentIndex < _items.length - 1) {
        setState(() { _currentIndex++; _answered = false; _selectedAnswer = ''; _generateOptions(); });
      } else {
        widget.ctrl.endGame();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Game Over!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w900)),
            content: Text('Score: $_score / ${_items.length}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
            actions: [TextButton(onPressed: () { Navigator.pop(context); Get.back(); }, child: const Text('Done'))],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const Scaffold(body: Center(child: Text('No data')));
    final item = _items[_currentIndex];
    final correct = item['second'] as String;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      body: SafeArea(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            color: const Color(0xFFFF9800),
            child: Row(children: [
              GestureDetector(onTap: () { widget.ctrl.endGame(); Get.back(); }, child: const Icon(Icons.close_rounded, color: Colors.white, size: 24)),
              const SizedBox(width: 12),
              const Expanded(child: Text('Collocation Connect', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700))),
              Text('$_score pts', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
            ]),
          ),
          LinearProgressIndicator(value: (_currentIndex + 1) / _items.length, backgroundColor: const Color(0xFFFFE0B2), valueColor: const AlwaysStoppedAnimation(Color(0xFFFF9800)), minHeight: 4),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${_currentIndex + 1} / ${_items.length}', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14)),
                const SizedBox(height: 8),
                const Text('Complete the collocation:', style: TextStyle(fontSize: 16, color: Color(0xFF555555))),
                const SizedBox(height: 16),
                RichText(text: TextSpan(children: [
                  TextSpan(text: '${item['first']} ', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFFE65100))),
                  const TextSpan(text: '+ ???', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w400, color: Color(0xFF9E9E9E))),
                ])),
                const SizedBox(height: 32),
                ..._options.map((opt) {
                  Color bgColor = Colors.white;
                  Color borderColor = const Color(0xFFE0E0E0);
                  if (_answered) {
                    if (opt == correct) { bgColor = const Color(0xFFE8F5E9); borderColor = const Color(0xFF4CAF50); }
                    else if (opt == _selectedAnswer) { bgColor = const Color(0xFFFCE4EC); borderColor = const Color(0xFFF44336); }
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => _select(opt),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: borderColor, width: 2)),
                        child: Text(opt, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)), textAlign: TextAlign.center),
                      ),
                    ),
                  );
                }),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
