import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/game_controller.dart';
import 'package:ez_trainz/controllers/game_session_controller.dart';
import 'package:ez_trainz/models/game.dart';
import 'package:ez_trainz/screens/game_history_screen.dart';

/// Shows game details and actions (play history, delete).
class GameDetailScreen extends StatelessWidget {
  const GameDetailScreen({super.key, required this.game});
  final Game game;

  static const _bgColor = Color(0xFF4DA6E8);
  static const _accentColor = Color(0xFFFFE000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // ── Back button ──────────────────────────────────
              GestureDetector(
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
              const SizedBox(height: 24),

              // ── Game icon ────────────────────────────────────
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _accentColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: _accentColor, width: 2),
                  ),
                  child: const Icon(Icons.sports_esports_rounded,
                      color: _accentColor, size: 40),
                ),
              ),
              const SizedBox(height: 20),

              // ── Name ─────────────────────────────────────────
              Center(
                child: Text(
                  game.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),

              // ── Description ──────────────────────────────────
              if (game.description.isNotEmpty)
                Center(
                  child: Text(
                    game.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 24),

              // ── Info chips ───────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _InfoChip(
                      label: 'game_type'.tr, value: game.type.isNotEmpty ? game.type : '-'),
                  const SizedBox(width: 12),
                  _InfoChip(label: 'game_lesson'.tr, value: game.lessonId),
                  const SizedBox(width: 12),
                  _InfoChip(
                      label: 'game_status'.tr,
                      value: game.isActive ? 'game_active'.tr : 'game_inactive'.tr),
                ],
              ),
              const SizedBox(height: 32),

              // ── View History button ──────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.to(() => GameHistoryScreen(gameId: game.id, gameName: game.title));
                  },
                  icon: const Icon(Icons.history_rounded, size: 20),
                  label: Text('game_view_history'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Delete button ────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmDelete(context),
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  label: Text('game_delete'.tr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent.shade100,
                    side: BorderSide(color: Colors.redAccent.shade100),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('game_delete_confirm_title'.tr),
        content: Text('game_delete_confirm_body'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('profile_cancel'.tr),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await GameController.to.deleteGame(game.id);
              Get.back();
            },
            child: Text('game_delete'.tr,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7), fontSize: 11)),
        ],
      ),
    );
  }
}
