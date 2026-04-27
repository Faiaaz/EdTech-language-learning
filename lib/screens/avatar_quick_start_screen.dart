import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/controllers/journey_controller.dart';
import 'package:ez_trainz/models/avatar_config.dart';
import 'package:ez_trainz/models/hat_tier.dart';
import 'package:ez_trainz/screens/journey_screen.dart';
import 'package:ez_trainz/widgets/layered_avatar.dart';

/// Grid of preset avatars. Tapping one plays a Pop & Scale animation
/// and then continues to the Journey dashboard.
class AvatarQuickStartScreen extends StatefulWidget {
  const AvatarQuickStartScreen({super.key});

  @override
  State<AvatarQuickStartScreen> createState() => _AvatarQuickStartScreenState();
}

class _AvatarQuickStartScreenState extends State<AvatarQuickStartScreen>
    with SingleTickerProviderStateMixin {
  int _selected = 0;
  late final AnimationController _popAnim;

  @override
  void initState() {
    super.initState();
    _popAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    )..forward();
  }

  @override
  void dispose() {
    _popAnim.dispose();
    super.dispose();
  }

  void _onPick(int i) {
    setState(() => _selected = i);
    _popAnim
      ..reset()
      ..forward();
  }

  Future<void> _onConfirm() async {
    final picked = AvatarPresets.quickStart[_selected];
    await JourneyController.to.setAvatar(picked);
    if (!mounted) return;
    Get.offAll(() => const JourneyScreen(showOnboardCelebration: true));
  }

  @override
  Widget build(BuildContext context) {
    final picked = AvatarPresets.quickStart[_selected];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                  ),
                  const Spacer(),
                  const Text(
                    'Quick Start',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 4),
              // Preview
              Center(
                child: AnimatedBuilder(
                  animation: _popAnim,
                  builder: (_, child) {
                    final t = Curves.elasticOut.transform(_popAnim.value);
                    return Transform.scale(
                      scale: 0.75 + 0.25 * t,
                      child: child,
                    );
                  },
                  child: LayeredAvatar(
                    config: picked,
                    tier: HatTier.none,
                    size: 180,
                    showHatGear: false,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Tap to change',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: AvatarPresets.quickStart.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  itemBuilder: (_, i) {
                    final isSel = i == _selected;
                    return GestureDetector(
                      onTap: () => _onPick(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSel
                              ? const Color(0xFFFFE000).withValues(alpha: 0.14)
                              : Colors.white.withValues(alpha: 0.06),
                          border: Border.all(
                            color: isSel
                                ? const Color(0xFFFFE000)
                                : Colors.white.withValues(alpha: 0.1),
                            width: isSel ? 1.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(6),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: LayeredAvatar(
                            config: AvatarPresets.quickStart[i],
                            tier: HatTier.none,
                            size: 110,
                            showHatGear: false,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE000),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Start my journey',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
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
