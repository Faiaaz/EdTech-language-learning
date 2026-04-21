import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'package:ez_trainz/services/transcribe_service.dart';
import 'package:ez_trainz/utils/read_bytes_from_path.dart';

class SpeechGameScreen extends StatefulWidget {
  const SpeechGameScreen({super.key});

  @override
  State<SpeechGameScreen> createState() => _SpeechGameScreenState();
}

class _SpeechGameScreenState extends State<SpeechGameScreen> {
  bool _checkingHealth = false;
  String? _health;

  bool _uploading = false;
  bool _startingRec = false;
  String? _error;
  TranscribeResult? _result;

  final _recorder = AudioRecorder();
  bool _recording = false;
  Duration _recorded = Duration.zero;
  Timer? _recTimer;
  double _level = 0.0; // 0..1
  static const _maxLen = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    _ping();
  }

  @override
  void dispose() {
    _recTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _ping() async {
    setState(() {
      _checkingHealth = true;
      _health = null;
    });
    try {
      final json = await TranscribeService.health();
      setState(() => _health = (json['status'] as String?) ?? 'ok');
    } catch (_) {
      setState(() => _health = 'offline');
    } finally {
      if (mounted) setState(() => _checkingHealth = false);
    }
  }

  void _tickTimer() {
    _recTimer?.cancel();
    _recTimer = Timer.periodic(const Duration(milliseconds: 120), (_) async {
      if (!mounted) return;
      if (!_recording) return;

      // Live mic level (best effort across platforms).
      try {
        final amp = await _recorder.getAmplitude();
        final db = amp.current; // dBFS-ish
        // Map roughly [-60..0] to [0..1]
        final v = ((db + 60) / 60).clamp(0.0, 1.0);
        _level = (0.75 * _level) + (0.25 * v);
      } catch (_) {}

      setState(() {
        _recorded += const Duration(milliseconds: 120);
      });
      if (_recorded >= _maxLen) {
        await _stopAndTranscribe();
      }
    });
  }

  Future<void> _startRecording() async {
    if (_uploading || _startingRec || _recording) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _error = null;
      _result = null;
      _startingRec = true;
    });

    try {
      final hasPerm = await _recorder.hasPermission(request: true);
      if (!hasPerm) {
        throw Exception('Microphone permission denied.');
      }

      // Prevent double-start if gesture fires rapidly.
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }

      _recorded = Duration.zero;
      _level = 0;

      final ext = kIsWeb ? 'webm' : 'm4a';
      final filename = 'speech_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final path = kIsWeb
          ? filename
          : '${(await getTemporaryDirectory()).path}/$filename';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      if (!mounted) return;
      setState(() {
        _recording = true;
        _startingRec = false;
      });
      _tickTimer();
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.lightImpact();
      setState(() {
        _error = e.toString();
        _startingRec = false;
        _recording = false;
      });
    }
  }

  Future<void> _stopAndTranscribe() async {
    if (_uploading || _startingRec) return;
    // If iOS fires "up" before record starts, ignore.
    if (!_recording && !(await _recorder.isRecording())) return;
    HapticFeedback.selectionClick();
    _recTimer?.cancel();
    setState(() {
      _uploading = true;
      _recording = false;
      _level = 0;
      _error = null;
      _result = null;
    });

    try {
      final path = await _recorder.stop();
      if (path == null || path.isEmpty) {
        throw Exception('Recording failed to save.');
      }

      final bytes = await readBytesFromPath(path);
      final result = await TranscribeService.transcribe(
        filename: kIsWeb ? 'speech.webm' : 'speech.m4a',
        bytes: bytes,
      );

      if (!mounted) return;
      HapticFeedback.mediumImpact();
      setState(() {
        _result = result;
        _uploading = false;
      });
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.lightImpact();
      setState(() {
        _error = e.toString();
        _uploading = false;
      });
    }
  }

  Future<void> _cancelRecording() async {
    if (_uploading || _startingRec) return;
    if (!_recording && !(await _recorder.isRecording())) return;
    HapticFeedback.lightImpact();
    _recTimer?.cancel();
    await _recorder.cancel();
    if (!mounted) return;
    setState(() {
      _recording = false;
      _uploading = false;
      _recorded = Duration.zero;
      _level = 0;
    });
  }

  static const _bgTop = Color(0xFF0B1220);
  static const _bgBottom = Color(0xFF1C3A8A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_bgTop, _bgBottom],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: LayoutBuilder(
              builder: (context, c) {
                final isLandscape = c.maxWidth > c.maxHeight;

                final content = Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white),
                        ),
                        const SizedBox(width: 4),
                        const Expanded(
                          child: Text(
                            'Speech Game',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        _ServerPill(
                          loading: _checkingHealth,
                          status: _health,
                          onTap: _ping,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (!isLandscape) ...[
                      _HeroCard(
                        uploading: _uploading,
                        starting: _startingRec,
                        recording: _recording,
                        recorded: _recorded,
                        level: _level,
                        onStart:
                            (_uploading || _startingRec) ? null : _startRecording,
                        onStop:
                            (_uploading || _startingRec) ? null : _stopAndTranscribe,
                        onCancel:
                            (_uploading || _startingRec) ? null : _cancelRecording,
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              if (_error != null) ...[
                                _ErrorCard(text: _error!),
                                const SizedBox(height: 12),
                              ],
                              if (_result != null) _ResultCard(result: _result!),
                              if (_result == null && _error == null) ...[
                                _TipCard(),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                                  _HeroCard(
                                    uploading: _uploading,
                                    starting: _startingRec,
                                    recording: _recording,
                                    recorded: _recorded,
                                    level: _level,
                                    onStart: (_uploading || _startingRec)
                                        ? null
                                        : _startRecording,
                                    onStop: (_uploading || _startingRec)
                                        ? null
                                        : _stopAndTranscribe,
                                    onCancel: (_uploading || _startingRec)
                                        ? null
                                        : _cancelRecording,
                                  ),
                                  const SizedBox(height: 12),
                                  if (_error != null) _ErrorCard(text: _error!),
                                  if (_error == null)
                                    const SizedBox.shrink(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (_result != null)
                                    _ResultCard(result: _result!)
                                  else
                                    const _TipCard(),
                                  const SizedBox(height: 12),
                                  if (_result != null)
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.06),
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          border: Border.all(
                                              color: Colors.white.withValues(
                                                  alpha: 0.10)),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'Record again to improve your pronunciation.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                  alpha: 0.75),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    const Spacer(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: content,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ServerPill extends StatelessWidget {
  const _ServerPill({required this.loading, required this.status, required this.onTap});

  final bool loading;
  final String? status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ok = status == 'ok';
    final color = loading
        ? Colors.white.withValues(alpha: 0.25)
        : ok
            ? const Color(0xFF22C55E).withValues(alpha: 0.25)
            : const Color(0xFFEF4444).withValues(alpha: 0.22);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            else
              Icon(
                ok ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                color: Colors.white,
                size: 16,
              ),
            const SizedBox(width: 6),
            Text(
              loading ? 'checking' : (ok ? 'server ok' : 'server offline'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.uploading,
    required this.starting,
    required this.recording,
    required this.recorded,
    required this.level,
    required this.onStart,
    required this.onStop,
    required this.onCancel,
  });

  final bool uploading;
  final bool starting;
  final bool recording;
  final Duration recorded;
  final double level;
  final VoidCallback? onStart;
  final VoidCallback? onStop;
  final VoidCallback? onCancel;

  static const _card = Color(0xFF0F172A);
  static const _accent = Color(0xFFFFD86B);

  @override
  Widget build(BuildContext context) {
    final secs = recorded.inSeconds;
    final mm = (secs ~/ 60).toString().padLeft(2, '0');
    final ss = (secs % 60).toString().padLeft(2, '0');

    final glow = (6 + 22 * level).clamp(6.0, 28.0);
    final ring = (2 + 6 * level).clamp(2.0, 8.0);
    final disabled = uploading || starting;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: _card.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.mic_rounded, color: _accent, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "You're trying our Speech Game now!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            recording
                ? 'Recording… release to stop (max 30s).'
                : 'Press and hold the mic, speak (≤ 30s), then release to transcribe.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              height: 1.35,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Column(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: disabled ? null : (_) => onStart?.call(),
                  onTapUp: disabled ? null : (_) => onStop?.call(),
                  onTapCancel: disabled ? null : () => onStop?.call(),
                  // Keep long-press working too (nice on desktop).
                  onLongPressStart: disabled ? null : (_) => onStart?.call(),
                  onLongPressEnd: disabled ? null : (_) => onStop?.call(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: recording
                          ? const Color(0xFFEF4444).withValues(alpha: 0.22)
                          : _accent.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: recording
                            ? const Color(0xFFFFB4B4).withValues(alpha: 0.7)
                            : Colors.white.withValues(alpha: 0.18),
                        width: ring,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (recording ? const Color(0xFFEF4444) : _accent)
                              .withValues(alpha: 0.35),
                          blurRadius: glow,
                          spreadRadius: level * 4,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: disabled
                        ? const Center(
                            child: SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Icon(
                            recording ? Icons.stop_rounded : Icons.mic_rounded,
                            color: Colors.white,
                            size: 38,
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: recording
                              ? const Color(0xFFEF4444)
                              : Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$mm:$ss',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 90,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: (recorded.inMilliseconds /
                                    _SpeechGameScreenState._maxLen.inMilliseconds)
                                .clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.12),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              recording ? const Color(0xFFEF4444) : _accent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (recording) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.25)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Cancel',
                            style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Try saying…',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '「ありがとうございます」\n「こんにちは」\n「すみません」',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tip: keep it short and speak clearly.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final TranscribeResult result;

  static const _accent = Color(0xFFFFD86B);

  @override
  Widget build(BuildContext context) {
    final jp = result.japanese.isEmpty ? '—' : result.japanese;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your result',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, c) {
              // Keep Japanese result always fully visible on small screens.
              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: c.maxWidth),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    jp,
                    maxLines: 1,
                    style: const TextStyle(
                      color: _accent,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _Line(label: 'Romaji', value: result.romaji, maxLines: 2),
          const SizedBox(height: 6),
          _Line(label: 'English', value: result.english, maxLines: 3),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, required this.maxLines});

  final String label;
  final String value;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.70),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              height: 1.35,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

