import 'package:flutter/material.dart';

/// Top-level language program. Used for navigation and API scope (e.g. /programs/jlc/courses).
enum Program {
  jlc('jlc', 'Japanese', 'JLC', 'Japanese Language and Career', [
    Color(0xFF667EEA),
    Color(0xFF764BA2),
  ]),
  klc('klc', 'Korean', 'KLC', 'Korean Language and Career', [
    Color(0xFF11998E),
    Color(0xFF38EF7D),
  ]),
  elc('elc', 'English', 'ELC', 'English Language and Career', [
    Color(0xFFF093FB),
    Color(0xFFF5576C),
  ]),
  glc('glc', 'German', 'GLC', 'German Language and Career', [
    Color(0xFFFF9800),
    Color(0xFFF44336),
  ]);

  const Program(
    this.id,
    this.name,
    this.shortName,
    this.subtitle,
    this.gradientColors,
  );

  final String id;
  final String name;
  final String shortName;
  final String subtitle;
  final List<Color> gradientColors;

  /// National flag emoji for visual cue: Japan, South Korea, UK, Germany.
  String get flagEmoji {
    switch (this) {
      case Program.jlc:
        return '\u{1F1EF}\u{1F1F5}'; // 🇯🇵 Japan
      case Program.klc:
        return '\u{1F1F0}\u{1F1F7}'; // 🇰🇷 South Korea
      case Program.elc:
        return '\u{1F1EC}\u{1F1E7}'; // 🇬🇧 United Kingdom
      case Program.glc:
        return '\u{1F1E9}\u{1F1EA}'; // 🇩🇪 Germany
    }
  }
}
