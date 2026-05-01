import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/models/program.dart';
import 'package:ez_trainz/screens/nihongo_trial_game_screen.dart';

class TrialGameLanguagePickerScreen extends StatelessWidget {
  const TrialGameLanguagePickerScreen({super.key});

  static const _bg = Color(0xFF0B1326);
  static const _gold = Color(0xFFFFE000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white54),
                  ),
                  const Expanded(
                    child: Text(
                      'TRIAL GAME',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _gold,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Pick a language to try. Nihongo is ready now — the others are coming soon.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 13.5,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.05,
                  children: [
                    _LangTile(
                      program: Program.jlc,
                      enabled: true,
                      badge: 'READY',
                      onTap: () {
                        HapticFeedback.selectionClick();
                        Get.to(
                          () => const NihongoTrialGameScreen(),
                          transition: Transition.rightToLeftWithFade,
                          duration: const Duration(milliseconds: 260),
                        );
                      },
                    ),
                    _LangTile(
                      program: Program.klc,
                      enabled: false,
                      badge: 'SOON',
                      onTap: () => _comingSoon(),
                    ),
                    _LangTile(
                      program: Program.elc,
                      enabled: false,
                      badge: 'SOON',
                      onTap: () => _comingSoon(),
                    ),
                    _LangTile(
                      program: Program.glc,
                      enabled: false,
                      badge: 'SOON',
                      onTap: () => _comingSoon(),
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

  void _comingSoon() {
    HapticFeedback.selectionClick();
    Get.snackbar(
      'Coming soon',
      'This trial game will be available soon.',
      backgroundColor: const Color(0xFF111827),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      borderRadius: 14,
    );
  }
}

class _LangTile extends StatelessWidget {
  const _LangTile({
    required this.program,
    required this.enabled,
    required this.badge,
    required this.onTap,
  });

  final Program program;
  final bool enabled;
  final String badge;
  final VoidCallback onTap;

  static const _gold = Color(0xFFFFE000);

  @override
  Widget build(BuildContext context) {
    final opacity = enabled ? 1.0 : 0.55;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: opacity,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: enabled
                  ? _gold.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: enabled
                    ? _gold.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.15),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      program.flagEmoji,
                      style: const TextStyle(fontSize: 24, height: 1.1),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    program.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    program.shortName,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          enabled ? 'Start trial' : 'Locked',
                          style: TextStyle(
                            color: enabled
                                ? _gold
                                : Colors.white.withValues(alpha: 0.45),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Icon(
                        enabled
                            ? Icons.play_arrow_rounded
                            : Icons.lock_rounded,
                        color:
                            enabled ? _gold : Colors.white.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: enabled ? _gold : Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: enabled ? Colors.black87 : Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

