import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/auth_controller.dart';
import 'package:ez_trainz/controllers/game_session_controller.dart';
import 'package:ez_trainz/models/game_session.dart';

/// Shows game session history for the current user, optionally filtered by gameId.
class GameHistoryScreen extends StatefulWidget {
  const GameHistoryScreen({super.key, this.gameId, this.gameName});
  final String? gameId;
  final String? gameName;

  @override
  State<GameHistoryScreen> createState() => _GameHistoryScreenState();
}

class _GameHistoryScreenState extends State<GameHistoryScreen> {
  static const _bgColor = Color(0xFF4DA6E8);
  static const _accentColor = Color(0xFFFFE000);

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final cognitoId = AuthController.to.userEmail ?? 'dev-user';
    if (widget.gameId != null) {
      GameSessionController.to.loadGameHistory(cognitoId, widget.gameId!);
    } else {
      GameSessionController.to.loadHistory(cognitoId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────
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
                        style: const TextStyle(
                            color: Colors.white, fontSize: 16)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Text(
                widget.gameName != null
                    ? '${'game_history'.tr} — ${widget.gameName}'
                    : 'game_history'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            // ── Sessions list ──────────────────────────────────
            Expanded(
              child: Obx(() {
                final ctrl = GameSessionController.to;

                if (ctrl.isLoading.value) {
                  return const Center(
                      child: CircularProgressIndicator(color: _accentColor));
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
                    child: Text('game_history_empty'.tr,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 16)),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => _load(),
                  color: _accentColor,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: ctrl.sessions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) =>
                        _SessionCard(session: ctrl.sessions[i]),
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

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});
  final GameSession session;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'game_score'.tr}: ${session.score}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${session.accuracy.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: Color(0xFFFFE000),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${session.correctAnswers}/${session.totalQuestions} ${'game_correct'.tr}  •  ${session.durationSeconds}s',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(session.completedAt),
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
