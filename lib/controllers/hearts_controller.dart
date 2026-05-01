import 'dart:async';

import 'package:get/get.dart';

/// Simple local hearts state (max 5).
///
/// Persistence + refill timers can be added later; for Step 1 we keep it local.
class HeartsController extends GetxController {
  static HeartsController get to => Get.find<HeartsController>();

  static const int maxHearts = 5;

  final RxInt hearts = maxHearts.obs;

  Timer? _refillTimer;

  bool get isEmpty => hearts.value <= 0;

  void reset() => hearts.value = maxHearts;

  /// Lose one heart. Returns the new value.
  int loseOne() {
    hearts.value = (hearts.value - 1).clamp(0, maxHearts);
    return hearts.value;
  }

  /// Placeholder for future refill options (timer, ads, gems, etc).
  void startPassiveRefillTimer({Duration interval = const Duration(minutes: 5)}) {
    _refillTimer?.cancel();
    _refillTimer = Timer.periodic(interval, (_) {
      if (hearts.value < maxHearts) hearts.value++;
    });
  }

  @override
  void onClose() {
    _refillTimer?.cancel();
    super.onClose();
  }
}

