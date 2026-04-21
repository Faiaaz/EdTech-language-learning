import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ez_trainz/services/ielts_service.dart';

/// IELTS Band Score Calculator — estimate overall band from section scores.
class IeltsBandCalculatorScreen extends StatefulWidget {
  const IeltsBandCalculatorScreen({super.key});

  @override
  State<IeltsBandCalculatorScreen> createState() => _IeltsBandCalculatorScreenState();
}

class _IeltsBandCalculatorScreenState extends State<IeltsBandCalculatorScreen> {
  double _reading = 6.0;
  double _listening = 6.0;
  double _writing = 6.0;
  double _speaking = 6.0;

  double get _overall => IeltsService.calculateOverallBand(_reading, _listening, _writing, _speaking);

  String _bandLabel(double band) {
    if (band >= 9.0) return 'expert'.tr;
    if (band >= 8.0) return 'very_good'.tr;
    if (band >= 7.0) return 'good'.tr;
    if (band >= 6.0) return 'competent'.tr;
    if (band >= 5.0) return 'modest'.tr;
    if (band >= 4.0) return 'limited'.tr;
    return 'developing'.tr;
  }

  Color _bandColor(double band) {
    if (band >= 8.0) return const Color(0xFF4CAF50);
    if (band >= 7.0) return const Color(0xFF2196F3);
    if (band >= 6.0) return const Color(0xFFFF9800);
    if (band >= 5.0) return const Color(0xFFF44336);
    return const Color(0xFF9E9E9E);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFF44336)])),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white38)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text('back'.tr, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('band_calc'.tr, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('band_calc_desc'.tr, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Overall score display
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: _bandColor(_overall).withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: Column(children: [
                        Text('overall_band'.tr, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(
                          _overall.toStringAsFixed(1),
                          style: TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: _bandColor(_overall)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(color: _bandColor(_overall).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                          child: Text(_bandLabel(_overall), style: TextStyle(color: _bandColor(_overall), fontSize: 16, fontWeight: FontWeight.w800)),
                        ),
                      ]),
                    ),

                    const SizedBox(height: 24),

                    // Section sliders
                    _BandSlider(
                      label: 'ielts_reading'.tr,
                      icon: Icons.menu_book_rounded,
                      color: const Color(0xFF4CAF50),
                      value: _reading,
                      onChanged: (v) => setState(() => _reading = v),
                    ),
                    const SizedBox(height: 16),
                    _BandSlider(
                      label: 'ielts_listening'.tr,
                      icon: Icons.headphones_rounded,
                      color: const Color(0xFF2196F3),
                      value: _listening,
                      onChanged: (v) => setState(() => _listening = v),
                    ),
                    const SizedBox(height: 16),
                    _BandSlider(
                      label: 'ielts_writing'.tr,
                      icon: Icons.edit_note_rounded,
                      color: const Color(0xFFFF9800),
                      value: _writing,
                      onChanged: (v) => setState(() => _writing = v),
                    ),
                    const SizedBox(height: 16),
                    _BandSlider(
                      label: 'ielts_speaking'.tr,
                      icon: Icons.record_voice_over_rounded,
                      color: const Color(0xFF9C27B0),
                      value: _speaking,
                      onChanged: (v) => setState(() => _speaking = v),
                    ),

                    const SizedBox(height: 24),

                    // Band descriptors
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('band_reference'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
                          const SizedBox(height: 12),
                          ...IeltsService.bandDescriptors.map((bd) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Container(
                                width: 36, height: 28,
                                decoration: BoxDecoration(color: _bandColor(bd.band).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                                child: Center(child: Text('${bd.band}', style: TextStyle(color: _bandColor(bd.band), fontSize: 13, fontWeight: FontWeight.w900))),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(bd.level, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                                Text(bd.description, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.3)),
                              ])),
                            ]),
                          )),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Common score requirements
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF90CAF9)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.school_rounded, color: Color(0xFF1565C0), size: 20),
                            const SizedBox(width: 8),
                            Text('score_requirements'.tr, style: const TextStyle(color: Color(0xFF0D47A1), fontSize: 14, fontWeight: FontWeight.w800)),
                          ]),
                          const SizedBox(height: 10),
                          const _RequirementRow(label: 'UK Universities (undergrad)', band: '6.0 - 6.5'),
                          const _RequirementRow(label: 'UK Universities (postgrad)', band: '6.5 - 7.0'),
                          const _RequirementRow(label: 'Australian Migration', band: '6.0 - 7.0'),
                          const _RequirementRow(label: 'Canadian PR', band: '6.0+'),
                          const _RequirementRow(label: 'US Top Universities', band: '7.0 - 7.5'),
                          const _RequirementRow(label: 'Medical/Nursing Registration', band: '7.0 - 7.5'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BandSlider extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final double value;
  final ValueChanged<double> onChanged;

  const _BandSlider({required this.label, required this.icon, required this.color, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Column(
        children: [
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Text(value.toStringAsFixed(1), style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
            ),
          ]),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.15),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.1),
              trackHeight: 6,
            ),
            child: Slider(
              value: value,
              min: 1.0,
              max: 9.0,
              divisions: 16,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final String label;
  final String band;
  const _RequirementRow({required this.label, required this.band});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF1565C0)))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
          child: Text(band, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1565C0))),
        ),
      ]),
    );
  }
}
