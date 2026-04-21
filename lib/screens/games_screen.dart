import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/game_controller.dart';
import 'package:ez_trainz/models/game.dart';
import 'package:ez_trainz/screens/game_detail_screen.dart';
import 'package:ez_trainz/screens/gamification_content_screen.dart';

/// Displays the list of available games fetched from GET /games.
class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  static const _bgColor = Color(0xFF4DA6E8);
  static const _accentColor = Color(0xFFFFE000);

  @override
  void initState() {
    super.initState();
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
                  Expanded(
                    child: Text(
                      'games_title'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.to(() => const GamificationContentScreen()),
                    icon: const Icon(Icons.quiz_rounded, color: Colors.white),
                    tooltip: 'Quizzes & drills',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 6, 24, 16),
              child: Text(
                'games_subtitle'.tr,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 14,
                ),
              ),
            ),

            // ── Game list ──────────────────────────────────────
            Expanded(
              child: Obx(() {
                final ctrl = GameController.to;

                if (ctrl.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: _accentColor),
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
                          Text(
                            ctrl.error.value,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => ctrl.loadGames(),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: _accentColor),
                            child: Text('retry'.tr,
                                style: const TextStyle(color: Colors.black87)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (ctrl.games.isEmpty) {
                  return Center(
                    child: Text(
                      'games_empty'.tr,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 16),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ctrl.loadGames(),
                  color: _accentColor,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: ctrl.games.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _GameCard(game: ctrl.games[i]),
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

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game});
  final Game game;

  static const _gradients = [
    [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
    [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
    [Color(0xFF00B894), Color(0xFF55EFC4)],
    [Color(0xFFFDCB6E), Color(0xFFE17055)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _gradients[game.title.length % _gradients.length];

    return GestureDetector(
      onTap: () {
        GameController.to.selectGame(game);
        Get.to(() => GameDetailScreen(game: game));
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.sports_esports_rounded,
                  color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  if (game.description.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      game.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
