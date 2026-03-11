import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/ielts_controller.dart';
import 'package:ez_trainz/models/ielts.dart';

/// IELTS Speaking practice with Part 1, 2, 3 topics, cue cards, and tips.
class IeltsSpeakingScreen extends StatelessWidget {
  const IeltsSpeakingScreen({super.key});

  static const _purple = Color(0xFF9C27B0);
  static const _purpleDark = Color(0xFF6A1B9A);

  @override
  Widget build(BuildContext context) {
    final ctrl = IeltsController.to;

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [_purple, _purpleDark])),
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
                  const Text('Speaking Practice', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('Practice all 3 parts with guided prompts and tips', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Select a Topic', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 14),
                    ...List.generate(ctrl.speakingTopics.length, (i) {
                      final t = ctrl.speakingTopics[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            ctrl.selectSpeakingTopic(i);
                            Get.to(() => _SpeakingPractice(ctrl: ctrl), transition: Transition.rightToLeftWithFade, duration: const Duration(milliseconds: 300));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Row(children: [
                              Container(
                                width: 48, height: 48,
                                decoration: BoxDecoration(
                                  color: _partColor(t.part).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(child: Text('P${t.part}', style: TextStyle(color: _partColor(t.part), fontSize: 16, fontWeight: FontWeight.w900))),
                              ),
                              const SizedBox(width: 14),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(t.topic, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                                const SizedBox(height: 4),
                                Text('Part ${t.part} \u2022 ${t.questions.length} questions', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                              ])),
                              const Icon(Icons.chevron_right_rounded, color: Color(0xFFB0B0B0)),
                            ]),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFCE93D8))),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.mic_rounded, color: Color(0xFF7B1FA2), size: 20),
                            SizedBox(width: 8),
                            Text('Speaking Strategies', style: TextStyle(color: Color(0xFF4A148C), fontSize: 14, fontWeight: FontWeight.w800)),
                          ]),
                          SizedBox(height: 10),
                          Text(
                            '\u2022 Part 1: Keep answers 2-3 sentences. Be natural, not rehearsed\n'
                            '\u2022 Part 2: Use the 1 minute to plan. Cover ALL cue card points\n'
                            '\u2022 Part 3: Give extended answers with reasons and examples\n'
                            '\u2022 Use a range of tenses and vocabulary to show ability\n'
                            '\u2022 Self-correct naturally — it shows language awareness',
                            style: TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF6A1B9A)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _partColor(int part) {
    switch (part) {
      case 1: return const Color(0xFF4CAF50);
      case 2: return const Color(0xFF2196F3);
      case 3: return const Color(0xFF9C27B0);
      default: return const Color(0xFF9C27B0);
    }
  }
}

class _SpeakingPractice extends StatefulWidget {
  final IeltsController ctrl;
  const _SpeakingPractice({required this.ctrl});

  @override
  State<_SpeakingPractice> createState() => _SpeakingPracticeState();
}

class _SpeakingPracticeState extends State<_SpeakingPractice> {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;

  void _startTimer(int maxSeconds) {
    _seconds = maxSeconds;
    _isRunning = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds <= 0) {
        t.cancel();
        setState(() => _isRunning = false);
      } else {
        setState(() => _seconds--);
      }
    });
    setState(() {});
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topic = widget.ctrl.currentSpeakingTopic;

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              color: const Color(0xFF9C27B0),
              child: Row(children: [
                GestureDetector(onTap: () { _stopTimer(); Get.back(); }, child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20)),
                const SizedBox(width: 12),
                Expanded(child: Text('Part ${topic.part}: ${topic.topic}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cue card for Part 2
                    if (topic.cueCard != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFCE93D8), width: 2),
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Row(children: [
                            Icon(Icons.card_membership_rounded, color: Color(0xFF9C27B0), size: 18),
                            SizedBox(width: 8),
                            Text('Cue Card', style: TextStyle(color: Color(0xFF6A1B9A), fontSize: 14, fontWeight: FontWeight.w800)),
                          ]),
                          const SizedBox(height: 12),
                          Text(topic.cueCard!, style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF333333))),
                        ]),
                      ),
                      const SizedBox(height: 16),

                      // Timer for Part 2
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _isRunning
                                ? [const Color(0xFF9C27B0), const Color(0xFF6A1B9A)]
                                : [const Color(0xFFE1BEE7), const Color(0xFFCE93D8)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(children: [
                          Text(
                            _formatTime(_seconds),
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: _isRunning ? Colors.white : const Color(0xFF6A1B9A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            _TimerButton(
                              label: 'Think (1 min)',
                              icon: Icons.psychology_rounded,
                              onTap: () => _startTimer(60),
                              isActive: _isRunning,
                            ),
                            const SizedBox(width: 12),
                            _TimerButton(
                              label: 'Speak (2 min)',
                              icon: Icons.mic_rounded,
                              onTap: () => _startTimer(120),
                              isActive: _isRunning,
                            ),
                            const SizedBox(width: 12),
                            _TimerButton(
                              label: 'Stop',
                              icon: Icons.stop_rounded,
                              onTap: _stopTimer,
                              isActive: !_isRunning,
                            ),
                          ]),
                        ]),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Questions
                    const Text('Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 14),
                    ...topic.questions.asMap().entries.map((e) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
                      ),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(color: const Color(0xFF9C27B0).withValues(alpha: 0.12), shape: BoxShape.circle),
                          child: Center(child: Text('${e.key + 1}', style: const TextStyle(color: Color(0xFF9C27B0), fontSize: 13, fontWeight: FontWeight.w800))),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(e.value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E), height: 1.4))),
                      ]),
                    )),

                    const SizedBox(height: 20),

                    // Sample answer points
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(14)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Row(children: [
                          Icon(Icons.tips_and_updates_rounded, color: Color(0xFF2E7D32), size: 18),
                          SizedBox(width: 8),
                          Text('Sample Answer Points', style: TextStyle(color: Color(0xFF1B5E20), fontSize: 14, fontWeight: FontWeight.w800)),
                        ]),
                        const SizedBox(height: 10),
                        ...topic.sampleAnswerPoints.map((p) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('\u2022 ', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w700)),
                            Expanded(child: Text(p, style: const TextStyle(fontSize: 13, color: Color(0xFF33691E), height: 1.4))),
                          ]),
                        )),
                      ]),
                    ),

                    // Vocabulary tips
                    if (topic.vocabularyTips.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(14)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Row(children: [
                            Icon(Icons.auto_stories_rounded, color: Color(0xFF1565C0), size: 18),
                            SizedBox(width: 8),
                            Text('Useful Vocabulary', style: TextStyle(color: Color(0xFF0D47A1), fontSize: 14, fontWeight: FontWeight.w800)),
                          ]),
                          const SizedBox(height: 10),
                          Wrap(spacing: 8, runSpacing: 8, children: topic.vocabularyTips.map((v) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF90CAF9))),
                            child: Text(v, style: const TextStyle(color: Color(0xFF1565C0), fontSize: 12, fontWeight: FontWeight.w600)),
                          )).toList()),
                        ]),
                      ),
                    ],

                    // Grammar tips
                    if (topic.grammarTips.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(14)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Row(children: [
                            Icon(Icons.spellcheck_rounded, color: Color(0xFFE65100), size: 18),
                            SizedBox(width: 8),
                            Text('Grammar Tips', style: TextStyle(color: Color(0xFFBF360C), fontSize: 14, fontWeight: FontWeight.w800)),
                          ]),
                          const SizedBox(height: 10),
                          ...topic.grammarTips.map((g) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const Text('\u2022 ', style: TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.w700)),
                              Expanded(child: Text(g, style: const TextStyle(fontSize: 13, color: Color(0xFF4E342E), height: 1.4))),
                            ]),
                          )),
                        ]),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Complete button
                    GestureDetector(
                      onTap: () {
                        widget.ctrl.completeSpeakingSession();
                        Get.back();
                        Get.snackbar('Session Complete', 'Great practice! Keep speaking daily.',
                            backgroundColor: const Color(0xFF9C27B0), colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFF6A1B9A)]),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(child: Text('Complete Session', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800))),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _TimerButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  const _TimerButton({required this.label, required this.icon, required this.onTap, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: isActive ? const Color(0xFF9C27B0) : Colors.white),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isActive ? const Color(0xFF9C27B0) : Colors.white)),
        ]),
      ),
    );
  }
}
