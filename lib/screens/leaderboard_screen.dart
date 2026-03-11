import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/game_controller.dart';
import 'package:ez_trainz/controllers/leaderboard_controller.dart';
import 'package:ez_trainz/models/leaderboard_entry.dart';

/// Full leaderboard screen with global and per-game tabs.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  static const _bgColor = Color(0xFF4DA6E8);
  static const _accentColor = Color(0xFFFFE000);

  @override
  void initState() {
    super.initState();
    LeaderboardController.to.loadGlobal();
    GameController.to.loadGames();
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
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_rounded,
                      color: _accentColor, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    'nav_leaderboard'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Filter chips ───────────────────────────────────
            SizedBox(
              height: 40,
              child: Obx(() {
                final lbCtrl = LeaderboardController.to;
                final gameCtrl = GameController.to;

                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _FilterChip(
                      label: 'leaderboard_global'.tr,
                      selected: lbCtrl.selectedGameId.value == null,
                      onTap: () => lbCtrl.loadGlobal(),
                    ),
                    ...gameCtrl.games.map((g) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _FilterChip(
                            label: g.name,
                            selected: lbCtrl.selectedGameId.value == g.id,
                            onTap: () => lbCtrl.loadByGame(g.id),
                          ),
                        )),
                  ],
                );
              }),
            ),
            const SizedBox(height: 16),

            // ── Leaderboard list ───────────────────────────────
            Expanded(
              child: Obx(() {
                final ctrl = LeaderboardController.to;

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
                                  color:
                                      Colors.white.withValues(alpha: 0.8)),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              if (ctrl.selectedGameId.value != null) {
                                ctrl.loadByGame(ctrl.selectedGameId.value!);
                              } else {
                                ctrl.loadGlobal();
                              }
                            },
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

                if (ctrl.entries.isEmpty) {
                  return Center(
                    child: Text(
                      'leaderboard_empty'.tr,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 16),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    if (ctrl.selectedGameId.value != null) {
                      await ctrl.loadByGame(ctrl.selectedGameId.value!);
                    } else {
                      await ctrl.loadGlobal();
                    }
                  },
                  color: _accentColor,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: ctrl.entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final entry = ctrl.entries[i];
                      return _LeaderboardRow(entry: entry, index: i);
                    },
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _accentColor = Color(0xFFFFE000);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? _accentColor.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: selected ? Border.all(color: _accentColor, width: 1.5) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _accentColor : Colors.white,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry, required this.index});
  final LeaderboardEntry entry;
  final int index;

  static const _accentColor = Color(0xFFFFE000);

  @override
  Widget build(BuildContext context) {
    final rank = entry.rank > 0 ? entry.rank : index + 1;
    final isTopThree = rank <= 3;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isTopThree
            ? _accentColor.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: isTopThree
            ? Border.all(color: _accentColor.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          // ── Rank ─────────────────────────────────────────
          SizedBox(
            width: 36,
            child: rank <= 3
                ? Text(
                    rank == 1
                        ? '🥇'
                        : rank == 2
                            ? '🥈'
                            : '🥉',
                    style: const TextStyle(fontSize: 22),
                    textAlign: TextAlign.center,
                  )
                : Text(
                    '#$rank',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
          const SizedBox(width: 12),

          // ── User info ────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${entry.gamesPlayed} ${'leaderboard_games_played'.tr}',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12),
                ),
              ],
            ),
          ),

          // ── Score ────────────────────────────────────────
          Text(
            entry.totalScore.toString(),
            style: TextStyle(
              color: isTopThree ? _accentColor : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
