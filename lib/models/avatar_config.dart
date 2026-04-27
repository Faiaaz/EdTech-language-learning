import 'dart:convert';
import 'dart:ui';

/// Hair shape options. Each maps to an SVG asset in `assets/avatars/`.
enum HairStyle {
  short,
  long,
  bun;

  String get assetName => switch (this) {
        HairStyle.short => 'assets/avatars/hair_short.svg',
        HairStyle.long => 'assets/avatars/hair_long.svg',
        HairStyle.bun => 'assets/avatars/hair_bun.svg',
      };

  static HairStyle fromName(String? raw) =>
      HairStyle.values.firstWhere((h) => h.name == raw,
          orElse: () => HairStyle.short);
}

/// User's customizable avatar. Everything needed to render the avatar is
/// serializable here — hats/feathers/stripes are derived from XP level
/// separately (see `JourneyController`).
class AvatarConfig {
  const AvatarConfig({
    required this.skinTone,
    required this.hairColor,
    required this.hairStyle,
    this.displayName,
  });

  /// Body + head tint (applied via ColorFilter to the silhouette SVG).
  final Color skinTone;

  /// Hair tint.
  final Color hairColor;

  /// Which hair SVG to stack.
  final HairStyle hairStyle;

  /// Optional nickname the user picked during onboarding.
  final String? displayName;

  AvatarConfig copyWith({
    Color? skinTone,
    Color? hairColor,
    HairStyle? hairStyle,
    String? displayName,
  }) {
    return AvatarConfig(
      skinTone: skinTone ?? this.skinTone,
      hairColor: hairColor ?? this.hairColor,
      hairStyle: hairStyle ?? this.hairStyle,
      displayName: displayName ?? this.displayName,
    );
  }

  Map<String, dynamic> toJson() => {
        'skinTone': skinTone.toARGB32(),
        'hairColor': hairColor.toARGB32(),
        'hairStyle': hairStyle.name,
        'displayName': displayName,
      };

  static AvatarConfig fromJson(Map<String, dynamic> json) {
    return AvatarConfig(
      skinTone: Color(json['skinTone'] as int? ?? 0xFFEAD0B8),
      hairColor: Color(json['hairColor'] as int? ?? 0xFF2F2118),
      hairStyle: HairStyle.fromName(json['hairStyle'] as String?),
      displayName: json['displayName'] as String?,
    );
  }

  String encode() => jsonEncode(toJson());
  static AvatarConfig? tryDecode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is Map<String, dynamic>) return AvatarConfig.fromJson(map);
    } catch (_) {}
    return null;
  }

  /// A neutral, friendly default used until the user completes onboarding.
  static const AvatarConfig defaults = AvatarConfig(
    skinTone: Color(0xFFEAD0B8),
    hairColor: Color(0xFF2F2118),
    hairStyle: HairStyle.short,
  );
}

/// Curated palette the Quick Start grid picks from. Also the set that
/// Mirror Mode snaps to after analyzing the photo.
class AvatarPresets {
  static const List<Color> skinTones = [
    Color(0xFFF6DDC4), // very light
    Color(0xFFEAD0B8), // light
    Color(0xFFD8AE86), // light-medium
    Color(0xFFB98A64), // medium
    Color(0xFF8F5E3E), // medium-dark
    Color(0xFF5E3B24), // dark
  ];

  static const List<Color> hairColors = [
    Color(0xFF1F1510), // near-black
    Color(0xFF4B2E19), // dark brown
    Color(0xFF8B5A2B), // brown
    Color(0xFFD6A15E), // blonde
    Color(0xFFC94F3A), // auburn/red
    Color(0xFF6B7280), // ash/grey
    Color(0xFF7C3AED), // fantasy purple (for fun)
  ];

  static const List<HairStyle> styles = HairStyle.values;

  /// Six opinionated "Quick Start" avatars — a visually distinct grid
  /// the user can pick in one tap.
  static const List<AvatarConfig> quickStart = [
    AvatarConfig(
      skinTone: Color(0xFFF6DDC4),
      hairColor: Color(0xFFD6A15E),
      hairStyle: HairStyle.short,
    ),
    AvatarConfig(
      skinTone: Color(0xFFEAD0B8),
      hairColor: Color(0xFF1F1510),
      hairStyle: HairStyle.long,
    ),
    AvatarConfig(
      skinTone: Color(0xFFD8AE86),
      hairColor: Color(0xFF4B2E19),
      hairStyle: HairStyle.bun,
    ),
    AvatarConfig(
      skinTone: Color(0xFFB98A64),
      hairColor: Color(0xFFC94F3A),
      hairStyle: HairStyle.short,
    ),
    AvatarConfig(
      skinTone: Color(0xFF8F5E3E),
      hairColor: Color(0xFF1F1510),
      hairStyle: HairStyle.bun,
    ),
    AvatarConfig(
      skinTone: Color(0xFF5E3B24),
      hairColor: Color(0xFF7C3AED),
      hairStyle: HairStyle.long,
    ),
  ];
}
