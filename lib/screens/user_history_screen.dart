import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/auth_controller.dart';
import 'package:ez_trainz/controllers/game_controller.dart';
import 'package:ez_trainz/controllers/game_session_controller.dart';
import 'package:ez_trainz/models/game_session.dart';

/// Comprehensive user history dashboard showing all game attempts and stats.
class UserHistoryScreen extends StatefulWidget {
  const UserHistoryScreen({super.key});

  @override
  State<UserHistoryScreen> createState() => _UserHistoryScreenState();
}

class _UserHistoryScreenState extends State<UserHistoryScreen> {
  static const _bgColor = Color(0xFF4DA6E8);
  static const _accentColor = Color(0xFFFFE000);

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final cognitoId = AuthController.to.userEmail ?? 'dev-user';
    GameSessionController.to.loadHistory(cognitoId);
    if (GameController.to.games.isEmpty) {
      GameController.to.loadGames();
    }
  }

  String _gameName(String gameId) {
    final game = GameController.to.games.firstWhereOrNull((g) => g.id == gameId);
    return game?.title ?? 'Game';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back_rounded,
                        color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    Text('back'.tr,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
              child: Text(
                'history_title'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Text(
                'history_subtitle'.tr,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 14,
                ),
              ),
            ),

            // ── Body ────────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                final ctrl = GameSessionController.to;

                if (ctrl.isLoading.value) {
                  return const Center(
                    child:
                        CircularProgressIndicator(color: _accentColor),
                  );
                }

                if (ctrl.error.value.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 48),
                          const SizedBox(height: 12),
                          Text(ctrl.error.value,
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8)),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _load,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: _accentColor),
                            child: Text('retry'.tr,
                                style:
                                    const TextStyle(color: Colors.black87)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (ctrl.sessions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history_rounded,
                            color: Colors.white.withValues(alpha: 0.35),
                            size: 72),
                        const SizedBox(height: 16),
                        Text(
                          'history_empty'.tr,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                // Sort newest first
                final sessions = ctrl.sessions.toList()
                  ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

                // Compute summary stats
                final total = sessions.length;
                final bestScore = sessions
                    .map((s) => s.score)
                    .reduce((a, b) => a > b ? a : b);
                final avgAccuracy = sessions
                        .map((s) => s.accuracy)
                        .reduce((a, b) => a + b) /
                    total;

                return RefreshIndicator(
                  onRefresh: () async => _load(),
                  color: _accentColor,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    children: [
                      // ── Stats card ──────────────────────────────
                      _StatsCard(
                        totalSessions: total,
                        bestScore: bestScore,
                        avgAccuracy: avgAccuracy,
                      ),
                      const SizedBox(height: 20),

                      // ── Recent label ────────────────────────────
                      Text(
                        'history_recent'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Session cards ───────────────────────────
                      ...sessions.map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _SessionCard(
                            session: s,
                            gameName: _gameName(s.gameId),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stats summary card ─────────────────────────────────────────────────────
class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.totalSessions,
    required this.bestScore,
    required this.avgAccuracy,
  });

  final int totalSessions;
  final int bestScore;
  final double avgAccuracy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          _StatItem(
            icon: Icons.videogame_asset_rounded,
            value: '$totalSessions',
            label: 'history_total_sessions'.tr,
          ),
          _VerticalDivider(),
          _StatItem(
            icon: Icons.star_rounded,
            value: '$bestScore',
            label: 'history_best_score'.tr,
          ),
          _VerticalDivider(),
          _StatItem(
            icon: Icons.track_changes_rounded,
            value: '${avgAccuracy.toStringAsFixed(0)}%',
            label: 'history_avg_accuracy'.tr,
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 44,
      color: Colors.white.withValues(alpha: 0.25),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFFFE000), size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Individual session card ────────────────────────────────────────────────
class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.gameName});

  final GameSession session;
  final String gameName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Game name + accuracy
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  gameName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE000).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${session.accuracy.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Color(0xFFFFE000),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Score + correct answers
          Row(
            children: [
              _IconLabel(
                icon: Icons.emoji_events_rounded,
                text: '${'game_score'.tr}: ${session.score}',
              ),
              const SizedBox(width: 16),
              _IconLabel(
                icon: Icons.check_circle_outline_rounded,
                text:
                    '${session.correctAnswers}/${session.totalQuestions} ${'game_correct'.tr}',
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Duration + date
          Row(
            children: [
              _IconLabel(
                icon: Icons.timer_outlined,
                text: '${session.durationSeconds}s',
              ),
              const SizedBox(width: 16),
              _IconLabel(
                icon: Icons.calendar_today_outlined,
                text: _formatDate(session.completedAt),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _IconLabel extends StatelessWidget {
  const _IconLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white54, size: 13),
        const SizedBox(width: 4),
        Text(
          text,
          style:
              TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12),
        ),
      ],
    );
  }
}
