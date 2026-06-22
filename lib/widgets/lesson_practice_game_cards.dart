import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ez_trainz/utils/app_theme.dart';

class LessonPracticeGame {
  const LessonPracticeGame({
    required this.label,
    required this.sub,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final String sub;
  final IconData icon;
  final List<Color> colors;
  final void Function(BuildContext context) onTap;
}

String lessonPracticeBnCount(int n) {
  const digits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  return n.toString().split('').map((c) {
    final d = int.tryParse(c);
    return d == null ? c : digits[d];
  }).join();
}

/// Expandable প্র্যাকটিস / চ্যালেঞ্জ card with a 2-column mini-game grid.
class LessonPracticeGameGroup extends StatefulWidget {
  const LessonPracticeGameGroup({
    super.key,
    required this.title,
    required this.icon,
    required this.accent,
    required this.games,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final List<LessonPracticeGame> games;

  @override
  State<LessonPracticeGameGroup> createState() =>
      _LessonPracticeGameGroupState();
}

class _LessonPracticeGameGroupState extends State<LessonPracticeGameGroup> {
  bool _expanded = true;

  static const _cardBg = AppColors.cardAlt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _expanded = !_expanded);
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: widget.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          Icon(widget.icon, color: widget.accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${lessonPracticeBnCount(widget.games.length)}টি গেম',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeInOut,
                      child: const Icon(
                        Icons.expand_more_rounded,
                        color: AppColors.textMuted,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 10.0;
                  final cellW = (constraints.maxWidth - spacing) / 2;
                  final cellH = cellW / 1.05;
                  final rows = <Widget>[];
                  for (var i = 0; i < widget.games.length; i += 2) {
                    rows.add(
                      Row(
                        children: [
                          SizedBox(
                            width: cellW,
                            height: cellH,
                            child: _LessonPracticeGameTile(
                              game: widget.games[i],
                            ),
                          ),
                          const SizedBox(width: spacing),
                          if (i + 1 < widget.games.length)
                            SizedBox(
                              width: cellW,
                              height: cellH,
                              child: _LessonPracticeGameTile(
                                game: widget.games[i + 1],
                              ),
                            )
                          else
                            SizedBox(width: cellW, height: cellH),
                        ],
                      ),
                    );
                    if (i + 2 < widget.games.length) {
                      rows.add(const SizedBox(height: spacing));
                    }
                  }
                  return Column(children: rows);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _LessonPracticeGameTile extends StatelessWidget {
  const _LessonPracticeGameTile({required this.game});

  final LessonPracticeGame game;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.selectionClick();
          game.onTap(context);
        },
        child: Ink(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: game.colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: game.colors.first.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(game.icon, color: Colors.white, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    game.sub,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
