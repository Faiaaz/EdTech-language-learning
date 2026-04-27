import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/models/avatar_config.dart';
import 'package:ez_trainz/models/hat_tier.dart';
import 'package:ez_trainz/models/xp_event.dart';
import 'package:ez_trainz/services/avatar_storage_service.dart';
import 'package:ez_trainz/services/xp_service.dart';

/// Drives the "Journey & Achievement" feature: avatar config, XP
/// accumulation, and the level/hat-tier derived from it.
///
/// Design:
///  - XP is computed from a log of `XpEvent`s (hybrid approach). Today
///    those events are added locally; when the backend exposes history,
///    we'll populate the log from the server and keep it cached.
///  - The visible hat/feather/stripes are a pure function of total XP.
///  - `pendingLevelUp` is the last level change that the UI hasn't
///    celebrated yet — screens consume it to show the overlay and then
///    call `consumeLevelUp()`.
class JourneyController extends GetxController {
  static JourneyController get to => Get.find();

  // ── Avatar ────────────────────────────────────────────────────────
  final avatar = AvatarConfig.defaults.obs;
  final hasOnboarded = false.obs;

  // ── XP ────────────────────────────────────────────────────────────
  final events = <XpEvent>[].obs;

  int get totalXp => XpService.totalFromEvents(events);
  HatTier get tier => HatTier.fromXp(totalXp);
  int get level => tier.level;

  /// Progress (0..1) within the current tier towards the next one.
  /// Returns 1.0 when the user has reached the max tier.
  double get progressWithinTier {
    final next = tier.next;
    if (next == null) return 1.0;
    final span = next.xpRequired - tier.xpRequired;
    if (span <= 0) return 1.0;
    final into = (totalXp - tier.xpRequired).clamp(0, span);
    return into / span;
  }

  int get xpIntoTier => (totalXp - tier.xpRequired).clamp(0, 1 << 30);
  int get xpForTierSpan {
    final n = tier.next;
    if (n == null) return 0;
    return n.xpRequired - tier.xpRequired;
  }

  // ── Level-up signaling ────────────────────────────────────────────
  final Rxn<HatTier> pendingLevelUp = Rxn<HatTier>();
  void consumeLevelUp() => pendingLevelUp.value = null;

  // ── Lifecycle ─────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _restore();
  }

  Future<void> _restore() async {
    try {
      final saved = await AvatarStorageService.loadAvatar();
      if (saved != null) {
        avatar.value = saved;
        hasOnboarded.value = true;
      }
      final savedEvents = await AvatarStorageService.loadXpEvents();
      events.assignAll(savedEvents);
    } catch (e) {
      if (kDebugMode) debugPrint('JourneyController restore failed: $e');
    }
  }

  // ── Avatar API ────────────────────────────────────────────────────
  Future<void> setAvatar(AvatarConfig next, {bool markOnboarded = true}) async {
    avatar.value = next;
    if (markOnboarded) hasOnboarded.value = true;
    await AvatarStorageService.saveAvatar(next);
  }

  Future<void> resetAvatar() async {
    avatar.value = AvatarConfig.defaults;
    hasOnboarded.value = false;
    await AvatarStorageService.clearAvatar();
  }

  // ── XP API ────────────────────────────────────────────────────────
  /// Grants XP for a completion event and triggers a level-up signal
  /// if the new total crossed a tier boundary.
  Future<void> grantXp({
    required XpSource source,
    int? amount,
    String? note,
  }) async {
    final reward = amount ?? XpRewards.forSource(source);
    final previousTier = tier;

    final event = XpEvent(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      amount: reward,
      source: source,
      earnedAt: DateTime.now(),
      note: note,
    );
    events.add(event);
    await AvatarStorageService.saveXpEvents(events.toList());

    if (tier.level > previousTier.level) {
      pendingLevelUp.value = tier;
    }
  }

  Future<void> resetProgress() async {
    events.clear();
    pendingLevelUp.value = null;
    await AvatarStorageService.clearXpEvents();
  }
}
