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
}
