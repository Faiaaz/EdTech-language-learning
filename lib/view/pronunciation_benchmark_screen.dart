import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:ez_trainz/services/jlc_stt.dart';
import 'package:ez_trainz/services/jlc_tts.dart';
import 'package:ez_trainz/services/pronunciation_benchmark_store.dart';
import 'package:ez_trainz/services/pronunciation_scorer.dart';
import 'package:ez_trainz/utils/app_theme.dart';

/// Internal accuracy-benchmark harness for the pronunciation coach.
///
/// Records learner attempts, logs the app's score + the Scribe transcript,
/// lets a teacher type a human score per attempt, then reports agreement
/// (mean abs error, within-10 rate, correlation) and exports everything to
/// CSV. This is the tool for collecting the labelled dataset that turns
/// "we think it works" into a measured accuracy figure.
class PronunciationBenchmarkScreen extends StatefulWidget {
  const PronunciationBenchmarkScreen({super.key});

  @override
  State<PronunciationBenchmarkScreen> createState() =>
      _PronunciationBenchmarkScreenState();
}

class _BenchPhrase {
  const _BenchPhrase(this.kana, this.pron);
  final String kana;
  final String pron;
}

enum _Phase { idle, recording, analyzing }

class _PronunciationBenchmarkScreenState
    extends State<PronunciationBenchmarkScreen> {
  static const _phrases = <_BenchPhrase>[
    _BenchPhrase('おはよう', 'ওহায়ো'),
    _BenchPhrase('こんにちは', 'কোন্‌নিচিওয়া'),
    _BenchPhrase('ありがとう', 'আরিগাতো'),
    _BenchPhrase('すみません', 'সুমিমাসেন'),
    _BenchPhrase('こんばんは', 'কোনবানওয়া'),
    _BenchPhrase('さようなら', 'সায়োনারা'),
    _BenchPhrase('おはようございます', 'ওহায়ো গোজাইমাস'),
    _BenchPhrase('ありがとうございます', 'আরিগাতো গোজাইমাস'),
    _BenchPhrase('わたしはがくせいです', 'ওয়াতাশি ওয়া গাকুসেই দেস'),
    _BenchPhrase('あのひとはせんせいです', 'আনো হিতো ওয়া সেনসেই দেস'),
  ];

  final _tts = JlcTts();
  final _stt = JlcStt();
  final _learnerCtrl = TextEditingController();

  _Phase _phase = _Phase.idle;
  int _phraseIdx = 0;
  bool _sttReady = false;
  String? _error;
  String _heard = '';
  double _heardConfidence = 1.0;

  List<BenchmarkSample> _samples = const [];
  BenchmarkStats _stats =
      const BenchmarkStats(total: 0, graded: 0, meanAbsError: null, withinTen: null, correlation: null);

  Timer? _recTimer;
  Duration _recorded = Duration.zero;
  static const _maxLen = Duration(seconds: 8);

  _BenchPhrase get _phrase => _phrases[_phraseIdx];

  @override
  void initState() {
    super.initState();
    // ignore: discarded_futures
    _init();
  }

  Future<void> _init() async {
    try {
      await _tts.setLanguage('ja-JP');
      await _tts.setSpeechRate(0.46);
      unawaited(_tts.prefetchTexts(_phrases.map((p) => p.kana)));
    } catch (_) {}
    try {
      final ok = await _stt.initialize(
        onError: (e) {
          if (!mounted) return;
          setState(() => _error = '$e');
        },
      );
      if (mounted) setState(() => _sttReady = ok);
    } catch (_) {
      if (mounted) setState(() => _sttReady = false);
    }
    await _reload();
  }

  Future<void> _reload() async {
    final all = await PronunciationBenchmarkStore.load();
    if (!mounted) return;
    setState(() {
      _samples = all;
      _stats = BenchmarkStats.compute(all);
    });
  }

  @override
  void dispose() {
    _recTimer?.cancel();
    _learnerCtrl.dispose();
    // ignore: discarded_futures
    _stt.cancel();
    // ignore: discarded_futures
    _tts.stop();
    super.dispose();
  }

  Future<void> _playModel() async {
    HapticFeedback.selectionClick();
    try {
      await _tts.stop();
      await _tts.speak(_phrase.kana);
    } catch (_) {}
  }

  Future<void> _toggleMic() async {
    if (_phase == _Phase.recording) {
      await _stopAndLog();
    } else if (_phase == _Phase.idle) {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (!_sttReady) {
      setState(() => _error = 'STT unavailable (mic/internet/API key).');
      return;
    }
    HapticFeedback.mediumImpact();
    await _tts.stop();
    setState(() {
      _error = null;
      _heard = '';
      _heardConfidence = 1.0;
      _phase = _Phase.recording;
      _recorded = Duration.zero;
    });
    try {
      await _stt.listen(onResult: (r) {
        _heard = r.recognizedWords;
        _heardConfidence = r.confidence;
      });
      _recTimer?.cancel();
      _recTimer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
        if (!mounted || _phase != _Phase.recording) return;
        setState(() => _recorded += const Duration(milliseconds: 100));
        if (_recorded >= _maxLen) await _stopAndLog();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.idle;
        _error = '$e';
      });
    }
  }

  Future<void> _stopAndLog() async {
    if (_phase != _Phase.recording) return;
    _recTimer?.cancel();
    HapticFeedback.selectionClick();
    setState(() => _phase = _Phase.analyzing);
    try {
      await _stt.stop();
      final result = PronunciationScorer.evaluate(
        targetKana: _phrase.kana,
        transcript: _heard,
        confidence: _heardConfidence,
      );
      final sample = BenchmarkSample(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        learner: _learnerCtrl.text.trim().isEmpty
            ? 'anon'
            : _learnerCtrl.text.trim(),
        phraseKana: _phrase.kana,
        phrasePron: _phrase.pron,
        appScore: result.score,
        transcript: _heard.trim(),
        recordedAt: DateTime.now(),
        sttConfidence: _heardConfidence,
      );
      await PronunciationBenchmarkStore.add(sample);
      if (!mounted) return;
      setState(() => _phase = _Phase.idle);
      HapticFeedback.mediumImpact();
      await _reload();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.idle;
        _error = '$e';
      });
    }
  }

  Future<void> _setTeacherScore(BenchmarkSample s, int? score) async {
    await PronunciationBenchmarkStore.update(s.copyWith(teacherScore: score));
    await _reload();
  }

  Future<void> _editTeacherScore(BenchmarkSample s) async {
    final ctrl = TextEditingController(text: s.teacherScore?.toString() ?? '');
    final value = await showDialog<int?>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('শিক্ষকের স্কোর — ${s.phraseKana}',
            style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 16)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            hintText: '0–100',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, -1),
            child: const Text('মুছুন'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () {
              final v = int.tryParse(ctrl.text.trim());
              Navigator.pop(ctx, v?.clamp(0, 100));
            },
            child: const Text('সেভ'),
          ),
        ],
      ),
    );
    if (value == null) return; // cancelled
    await _setTeacherScore(s, value == -1 ? null : value);
  }

  Future<void> _exportCsv() async {
    if (_samples.isEmpty) return;
    try {
      final csv = PronunciationBenchmarkStore.toCsv(_samples);
      final dir = await getTemporaryDirectory();
      final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${dir.path}/pron_benchmark_$stamp.csv');
      await file.writeAsString(csv, flush: true);
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject: 'Pronunciation benchmark (${_samples.length} samples)',
        sharePositionOrigin:
            box != null ? box.localToGlobal(Offset.zero) & box.size : null,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('সব ডেটা মুছবেন?',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 16)),
        content: Text('${_samples.length} টি স্যাম্পল মুছে যাবে। এটা ফেরানো যাবে না।',
            style: const TextStyle(color: AppColors.textPrimary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('মুছুন'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await PronunciationBenchmarkStore.clear();
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pageGradient),
        child: SafeArea(
          child: Column(
            children: [
              _header(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _statsCard(),
                    const SizedBox(height: 12),
                    _captureCard(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('লগ',
                            style: TextStyle(
                                color: Color(0xFF1E293B),
                                fontWeight: FontWeight.w900,
                                fontSize: 15)),
                        const SizedBox(width: 6),
                        Text('(${_samples.length})',
                            style: const TextStyle(
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_samples.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text('এখনও কোনো রেকর্ডিং নেই',
                              style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w700)),
                        ),
                      )
                    else
                      for (final s in _samples) _sampleRow(s),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E293B)),
          ),
          const Expanded(
            child: Text('Accuracy Benchmark (dev)',
                style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.w900,
                    fontSize: 18)),
          ),
          IconButton(
            tooltip: 'Export CSV',
            onPressed: _samples.isEmpty ? null : _exportCsv,
            icon: const Icon(Icons.ios_share_rounded, color: Color(0xFF1E293B)),
          ),
          IconButton(
            tooltip: 'Clear all',
            onPressed: _samples.isEmpty ? null : _confirmClear,
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFB91C1C)),
          ),
        ],
      ),
    );
  }

  Widget _statsCard() {
    final mae = _stats.meanAbsError;
    final within = _stats.withinTen;
    final corr = _stats.correlation;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('App vs. teacher agreement',
              style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w900,
                  fontSize: 15)),
          const SizedBox(height: 4),
          Text('${_stats.graded} / ${_stats.total} স্যাম্পলে শিক্ষকের স্কোর দেওয়া আছে',
              style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                  fontSize: 12)),
          const SizedBox(height: 14),
          Row(
            children: [
              _stat('গড় ত্রুটি', mae == null ? '—' : '±${mae.toStringAsFixed(1)}',
                  'MAE', const Color(0xFF8B5CF6)),
              _stat('১০-এর মধ্যে',
                  within == null ? '—' : '${(within * 100).round()}%',
                  'agreement', const Color(0xFF22C55E)),
              _stat('কোরিলেশন', corr == null ? '—' : corr.toStringAsFixed(2),
                  'Pearson r', const Color(0xFF3B82F6)),
            ],
          ),
          if (_stats.graded < 5) ...[
            const SizedBox(height: 10),
            const Text(
              'নির্ভরযোগ্য সংখ্যার জন্য ~২০ জন শিক্ষার্থী × ১০ বাক্য (≈২০০) দরকার।',
              style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                  fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stat(String label, String value, String sub, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w900, fontSize: 22)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w800,
                  fontSize: 12)),
          Text(sub,
              style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                  fontSize: 10)),
        ],
      ),
    );
  }

  Widget _captureCard() {
    final recording = _phase == _Phase.recording;
    final busy = _phase == _Phase.analyzing;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        children: [
          TextField(
            controller: _learnerCtrl,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              isDense: true,
              labelText: 'শিক্ষার্থীর নাম / আইডি',
              prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_phrase.kana,
                        style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.w900,
                            fontSize: 26)),
                    Text(_phrase.pron,
                        style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                  ],
                ),
              ),
              IconButton(
                onPressed: recording || busy ? null : _playModel,
                icon: const Icon(Icons.volume_up_rounded,
                    color: Color(0xFF1E293B)),
              ),
              DropdownButton<int>(
                value: _phraseIdx,
                underline: const SizedBox.shrink(),
                onChanged: recording || busy
                    ? null
                    : (v) => setState(() => _phraseIdx = v ?? 0),
                items: [
                  for (var i = 0; i < _phrases.length; i++)
                    DropdownMenuItem(value: i, child: Text('#${i + 1}')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: busy ? null : _toggleMic,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    recording ? const Color(0xFFEF4444) : const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : Icon(recording ? Icons.stop_rounded : Icons.mic_rounded),
              label: Text(
                busy
                    ? 'বিশ্লেষণ হচ্ছে…'
                    : recording
                        ? 'থামান (${_recorded.inSeconds}s) ও লগ করুন'
                        : 'রেকর্ড করে লগ করুন',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!,
                style: const TextStyle(
                    color: Color(0xFFB91C1C),
                    fontWeight: FontWeight.w700,
                    fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _sampleRow(BenchmarkSample s) {
    final teacher = s.teacherScore;
    final delta = teacher == null ? null : (s.appScore - teacher).abs();
    final deltaColor = delta == null
        ? const Color(0xFF94A3B8)
        : delta <= 10
            ? const Color(0xFF22C55E)
            : delta <= 20
                ? const Color(0xFFEAB308)
                : const Color(0xFFEF4444);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: _cardDeco(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(s.phraseKana,
                        style: const TextStyle(
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.w900,
                            fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(s.learner,
                        style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                            fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 2),
                Text('শুনেছে: ${s.transcript.isEmpty ? '—' : s.transcript}',
                    style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                        fontSize: 11)),
              ],
            ),
          ),
          _scorePill('app', '${s.appScore}', const Color(0xFF8B5CF6)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _editTeacherScore(s),
            child: _scorePill(
              'teacher',
              s.teacherScore?.toString() ?? '+',
              s.teacherScore == null ? const Color(0xFF94A3B8) : deltaColor,
              dashed: s.teacherScore == null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _scorePill(String label, String value, Color color,
      {bool dashed = false}) {
    return Container(
      width: 52,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: color.withValues(alpha: dashed ? 0.4 : 0.6), width: 1.2),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w900, fontSize: 16)),
          Text(label,
              style: TextStyle(
                  color: color.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w700,
                  fontSize: 9)),
        ],
      ),
    );
  }

  BoxDecoration _cardDeco() => BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      );
}
