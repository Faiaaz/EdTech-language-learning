import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/screens/hiragana_lesson1_screen.dart';
import 'package:ez_trainz/screens/lesson1_game_flow_screen.dart';
import 'package:ez_trainz/widgets/duo_path_node.dart';
import 'package:ez_trainz/widgets/duo_top_currency_bar.dart';
import 'package:ez_trainz/widgets/duo_unit_header.dart';

/// Duolingo-style Learn screen: top currency bar, colored unit headers and
/// a vertical winding path of circular lesson nodes.
class DuoLearnScreen extends StatelessWidget {
  const DuoLearnScreen({super.key});

  static const _bg = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: DuoTopCurrencyBar()),
            SliverToBoxAdapter(
              child: DuoUnitHeader(
                section: 1,
                unit: 1,
                title: 'Master the basics of Hiragana',
                color: const Color(0xFF22C55E),
                onGuidebook: () {
                  HapticFeedback.selectionClick();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Unit guidebook coming soon!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(child: _PathColumn(nodes: _unit1Nodes())),
            const SliverToBoxAdapter(
              child: DuoSectionDivider(label: 'SECTION 1 · UNIT 2'),
            ),
            SliverToBoxAdapter(
              child: DuoUnitHeader(
                section: 1,
                unit: 2,
                title: 'Greetings & introductions',
                color: const Color(0xFF3B82F6),
              ),
            ),
            SliverToBoxAdapter(child: _PathColumn(nodes: _unit2Nodes())),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  static List<_NodeSpec> _unit1Nodes() => [
        _NodeSpec(
          state: DuoNodeState.active,
          icon: Icons.star_rounded,
          showStart: true,
          onTap: () => Get.to(() => const HiraganaLesson1Screen()),
        ),
        _NodeSpec(
          state: DuoNodeState.locked,
          icon: Icons.sports_esports_rounded,
          onTap: () => Get.to(() => const Lesson1GameFlowScreen()),
        ),
        const _NodeSpec(state: DuoNodeState.locked, icon: Icons.menu_book_rounded),
        const _NodeSpec(state: DuoNodeState.locked, icon: Icons.translate_rounded),
        const _NodeSpec(
          state: DuoNodeState.checkpoint,
          icon: Icons.workspace_premium_rounded,
          size: 92,
          tint: Color(0xFF8B5CF6),
        ),
      ];

  static List<_NodeSpec> _unit2Nodes() => const [
        _NodeSpec(state: DuoNodeState.locked, icon: Icons.headphones_rounded),
        _NodeSpec(state: DuoNodeState.locked, icon: Icons.mic_rounded),
        _NodeSpec(state: DuoNodeState.locked, icon: Icons.edit_rounded),
        _NodeSpec(state: DuoNodeState.locked, icon: Icons.chat_bubble_rounded),
        _NodeSpec(
          state: DuoNodeState.locked,
          icon: Icons.workspace_premium_rounded,
          size: 92,
          tint: Color(0xFF8B5CF6),
        ),
      ];
}

class _PathColumn extends StatelessWidget {
  const _PathColumn({required this.nodes});
  final List<_NodeSpec> nodes;

  static const _mascotEvery = 3;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (int i = 0; i < nodes.length; i++) {
      children.add(_PathRow(spec: nodes[i], index: i));
      children.add(const SizedBox(height: 26));

      // Periodic mascot peek between nodes
      if ((i + 1) % _mascotEvery == 0 && i != nodes.length - 1) {
        children.add(const _MascotPeek());
        children.add(const SizedBox(height: 14));
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(children: children),
    );
  }
}

class _PathRow extends StatelessWidget {
  const _PathRow({required this.spec, required this.index});

  final _NodeSpec spec;
  final int index;

  @override
  Widget build(BuildContext context) {
    // Sine-based zigzag offset (approx Duolingo's path geometry).
    final xOffset = math.sin(index * math.pi / 2.4) * 64;

    return SizedBox(
      height: spec.size + 8 + (spec.showStart ? 36 : 0),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (spec.showStart)
            Positioned(
              top: 0,
              child: Transform.translate(
                offset: Offset(xOffset, 0),
                child: const DuoStartBadge(),
              ),
            ),
          Positioned(
            bottom: 0,
            child: Transform.translate(
              offset: Offset(xOffset, 0),
              child: DuoPathNode(
                state: spec.state,
                icon: spec.icon,
                size: spec.size,
                tint: spec.tint,
                onTap: spec.onTap == null
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        spec.onTap!();
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MascotPeek extends StatelessWidget {
  const _MascotPeek();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/ninja_penguin_transparent.png',
            height: 90,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

class _NodeSpec {
  const _NodeSpec({
    required this.state,
    required this.icon,
    this.showStart = false,
    this.onTap,
    this.size = 78,
    this.tint,
  });

  final DuoNodeState state;
  final IconData icon;
  final bool showStart;
  final VoidCallback? onTap;
  final double size;
  final Color? tint;
}
