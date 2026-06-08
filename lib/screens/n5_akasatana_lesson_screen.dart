// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:ez_trainz/utils/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:ez_trainz/screens/hiragana_draw_game_screen.dart';
import 'package:ez_trainz/widgets/spiral_notepad_frame.dart';

enum _LessonKind { akasatana, bornomala, dakuten }

class N5AkasatanaLessonScreen extends StatefulWidget {
  const N5AkasatanaLessonScreen({super.key})
      : _lessonKind = _LessonKind.akasatana;
  const N5AkasatanaLessonScreen._forKind({
    required _LessonKind lessonKind,
  }) : _lessonKind = lessonKind;

  final _LessonKind _lessonKind;

  @override
  State<N5AkasatanaLessonScreen> createState() => _N5AkasatanaLessonScreenState();
}

class N5BorneBorneBornomalaLessonScreen extends StatelessWidget {
  const N5BorneBorneBornomalaLessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const N5AkasatanaLessonScreen._forKind(
      lessonKind: _LessonKind.bornomala,
    );
  }
}

class N5DakutenLessonScreen extends StatelessWidget {
  const N5DakutenLessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const N5AkasatanaLessonScreen._forKind(
      lessonKind: _LessonKind.dakuten,
    );
  }
}

enum _AkaTab { draw, notepadDraw, flashcard, quiz, match, practice }

class _N5AkasatanaLessonScreenState extends State<N5AkasatanaLessonScreen> {
  /// The অনুশীলন শিট (practice sheet) download is offered for the lessons
  /// that ship a bundled hiragana writing-drill PDF (আকাসাতানা & বর্ণমালা).
  List<_AkaTab> get _tabs => [
        _AkaTab.draw,
        _AkaTab.notepadDraw,
        _AkaTab.flashcard,
        _AkaTab.quiz,
        _AkaTab.match,
        if (_practiceSheet != null) _AkaTab.practice,
      ];

  List<String> get _tabLabels => [
        'আঁকা',
        'নোটবুক',
        'ফ্ল্যাশকার্ড',
        'কুইজ রান',
        'কানা ম্যাচ',
        if (_practiceSheet != null) 'অনুশীলন শিট',
      ];

  /// Per-lesson bundled practice sheet, or null when the lesson has none.
  _PracticeSheet? get _practiceSheet => switch (_kind) {
        _LessonKind.akasatana => const _PracticeSheet(
            asset: 'assets/pdf/hiragana_akasatana_practice.pdf',
            fileName: 'EZ-Trainz-akasatana-onushilon-sheet.pdf',
            title: 'আকাসাতানা অনুশীলন শিট',
            description:
                'あ・か・さ・た・な সারির হিরাগানা হাতে লেখার অনুশীলন শিট (৫ পৃষ্ঠা)। '
                'ডাউনলোড করে প্রিন্ট করে অনুশীলন করো।',
          ),
        _LessonKind.bornomala => const _PracticeSheet(
            asset: 'assets/pdf/hiragana_bornomala_practice.pdf',
            fileName: 'EZ-Trainz-bornomala-onushilon-sheet.pdf',
            title: 'বর্ণে বর্ণে বর্ণমালা অনুশীলন শিট',
            description:
                'は・ま・や・ら・わ সারির হিরাগানা হাতে লেখার অনুশীলন শিট (৫ পৃষ্ঠা)। '
                'ডাউনলোড করে প্রিন্ট করে অনুশীলন করো।',
          ),
        _LessonKind.dakuten => null,
      };

  int _tab = 0;

  _LessonKind get _kind => widget._lessonKind;
  bool get _isDakuten => _kind == _LessonKind.dakuten;

  String get _title => switch (_kind) {
    _LessonKind.akasatana => 'আকাসাতানা',
    _LessonKind.bornomala => 'বর্ণে বর্ণে বর্ণমালা',
    _LessonKind.dakuten  => 'জাপানের চন্দ্রবিন্দু',
  };
  String get _subtitle => switch (_kind) {
    _LessonKind.akasatana => 'হিরাগানা ৫ সারি: あかさたな → বাংলা উচ্চারণ',
    _LessonKind.bornomala => 'は・ま・や・ら・わ সারি: はひふへほ・まみむめも・やゆよ・らりるれろ・わをん',
    _LessonKind.dakuten  => 'てんてん ゛ ও まる ゜: がざだばぱ → ধ্বনি পরিবর্তন',
  };
  List<_RowInfo> get _rows => switch (_kind) {
    _LessonKind.akasatana => _akasatanaRows,
    _LessonKind.bornomala => _bornomalaRows,
    _LessonKind.dakuten  => _dakutenRows,
  };
  List<_Kana> get _kanaList => switch (_kind) {
    _LessonKind.akasatana => _akasatanaKanaList,
    _LessonKind.bornomala => _bornomalaKanaList,
    _LessonKind.dakuten  => _dakutenKanaList,
  };
  List<HiraganaChar>? get _charSet => _isDakuten ? kDakutenHiraganaSet : null;
  int get _drawStart => _rows.first.startIdx;
  int get _drawEnd => _rows.last.endIdx;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: Get.back,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_title,
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 18)),
                        Text(_subtitle,
                            style: TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _AkaTabPills(
                index: _tab,
                labels: _tabLabels,
                onChange: (i) => setState(() => _tab = i),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: switch (_tabs[_tab]) {
                  _AkaTab.draw => _AkaDrawPicker(
                    key: const ValueKey('akaDraw'),
                    startIdx: _drawStart,
                    endIdx: _drawEnd,
                    charSet: _charSet,
                  ),
                  _AkaTab.notepadDraw =>
                    _NotebookRowPicker(
                      key: const ValueKey('akaNotepadDraw'),
                      rows: _rows,
                      charSet: _charSet,
                    ),
                  _AkaTab.flashcard => _AkaFlashGame(
                    key: const ValueKey('akaFlash'),
                    kanaList: _kanaList,
                  ),
                  _AkaTab.quiz => _AkaQuizGame(
                    key: const ValueKey('akaQuiz'),
                    kanaList: _kanaList,
                  ),
                  _AkaTab.match => _AkaMatchGame(
                    key: const ValueKey('akaMatch'),
                    kanaList: _kanaList,
                  ),
                  _AkaTab.practice => _PracticeSheetTab(
                    key: const ValueKey('akaPractice'),
                    sheet: _practiceSheet!,
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AkaTabPills extends StatelessWidget {
  const _AkaTabPills({
    required this.index,
    required this.labels,
    required this.onChange,
  });
  final int index;
  final List<String> labels;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              GestureDetector(
                onTap: () => onChange(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: i == index
                        ? AppColors.tabActive
                        : Colors.white.withValues(alpha: 0.58),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(labels[i],
                      style: TextStyle(
                          color: i == index ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w900, fontSize: 12)),
                ),
              ),
              if (i != labels.length - 1) const SizedBox(width: 6),
            ]
          ],
        ),
      ),
    );
  }
}

// ── Practice sheet download ───────────────────────────────────────────────────

/// A bundled, EZ Trainz–branded hiragana writing-practice PDF for a lesson.
class _PracticeSheet {
  const _PracticeSheet({
    required this.asset,
    required this.fileName,
    required this.title,
    required this.description,
  });

  final String asset;
  final String fileName;
  final String title;
  final String description;
}

/// অনুশীলন শিট tab — lets the learner download/share the lesson's bundled
/// hiragana writing-practice PDF (EZ Trainz–branded on every page).
class _PracticeSheetTab extends StatefulWidget {
  const _PracticeSheetTab({super.key, required this.sheet});

  final _PracticeSheet sheet;

  @override
  State<_PracticeSheetTab> createState() => _PracticeSheetTabState();
}

class _PracticeSheetTabState extends State<_PracticeSheetTab> {
  static const _accent = AppColors.tabActive;
  bool _busy = false;

  Future<void> _download() async {
    if (_busy) return;
    setState(() => _busy = true);
    HapticFeedback.selectionClick();
    try {
      final sheet = widget.sheet;
      final bytes = await rootBundle.load(sheet.asset);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${sheet.fileName}');
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        subject: '${sheet.title} — EZ Trainz',
        sharePositionOrigin:
            box != null ? box.localToGlobal(Offset.zero) & box.size : null,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('শিটটি খোলা যায়নি, আবার চেষ্টা করুন।')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded,
                      color: _accent, size: 34),
                ),
                const SizedBox(height: 14),
                Text(
                  widget.sheet.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.sheet.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.5),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _busy ? null : _download,
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.download_rounded, size: 20),
                    label: Text(_busy ? 'প্রস্তুত হচ্ছে…' : 'শিট ডাউনলোড করুন',
                        style: const TextStyle(fontWeight: FontWeight.w900)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Draw picker ───────────────────────────────────────────────────────────────

/// Embeds the drawing game directly in the আঁকা tab — starts at あ and
/// auto-advances to the next hiragana after each completion.
class _AkaDrawPicker extends StatelessWidget {
  const _AkaDrawPicker({
    super.key,
    required this.startIdx,
    required this.endIdx,
    this.charSet,
  });

  final int startIdx;
  final int endIdx;
  final List<HiraganaChar>? charSet;

  @override
  Widget build(BuildContext context) {
    return HiraganaDrawGameScreen(
      initialIndex: startIdx,
      endIndex: endIdx,
      embedded: true,
      autoAdvance: true,
      charSet: charSet,
    );
  }
}

class _RowInfo {
  const _RowInfo({
    required this.leader,
    required this.members,
    required this.bn,
    required this.startIdx,
    required this.endIdx,
    required this.accent,
  });
  final String leader;
  final List<String> members;
  final String bn;
  final int startIdx;
  final int endIdx;
  final Color accent;
}

class _NotebookRowPicker extends StatefulWidget {
  const _NotebookRowPicker({
    super.key,
    required this.rows,
    this.charSet,
  });

  final List<_RowInfo> rows;
  final List<HiraganaChar>? charSet;

  @override
  State<_NotebookRowPicker> createState() => _NotebookRowPickerState();
}

class _NotebookRowPickerState extends State<_NotebookRowPicker> {
  List<_RowInfo> get _rows => widget.rows;

  int? _activeRow;
  int _sessionId = 0;
  final Set<int> _completedRows = {};

  void _selectRow(int index) {
    setState(() {
      _activeRow = index;
      _sessionId++;
    });
  }

  void _onRowComplete() {
    if (_activeRow != null) {
      HapticFeedback.mediumImpact();
      setState(() {
        _completedRows.add(_activeRow!);
        _activeRow = null;
      });
    }
  }

  void _goBack() {
    setState(() => _activeRow = null);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: _activeRow != null
          ? _buildDrawingMode(key: ValueKey('draw_$_sessionId'))
          : _buildRowSelection(key: const ValueKey('selection')),
    );
  }

  Widget _buildDrawingMode({Key? key}) {
    final row = _rows[_activeRow!];
    return Column(
      key: key,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
          child: Row(
            children: [
              GestureDetector(
                onTap: _goBack,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: row.accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: row.accent.withValues(alpha: 0.3)),
                  ),
                  child: Icon(Icons.arrow_back_rounded, color: row.accent, size: 17),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: row.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: row.accent.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(row.leader,
                        style: TextStyle(color: row.accent, fontSize: 16, fontWeight: FontWeight.w900)),
                    const SizedBox(width: 6),
                    Text(row.bn,
                        style: TextStyle(
                            color: row.accent.withValues(alpha: 0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              const Spacer(),
              for (var i = 0; i < _rows.length; i++) ...[
                GestureDetector(
                  onTap: () => _selectRow(i),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: i == _activeRow
                          ? _rows[i].accent.withValues(alpha: 0.2)
                          : _completedRows.contains(i)
                              ? AppColors.correct.withValues(alpha: 0.12)
                              : AppColors.bg,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: i == _activeRow
                            ? _rows[i].accent.withValues(alpha: 0.5)
                            : _completedRows.contains(i)
                                ? AppColors.correct.withValues(alpha: 0.3)
                                : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: _completedRows.contains(i) && i != _activeRow
                          ? const Icon(Icons.check_rounded, color: AppColors.correct, size: 14)
                          : Text(_rows[i].leader,
                              style: TextStyle(
                                color: i == _activeRow
                                    ? _rows[i].accent
                                    : AppColors.textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              )),
                    ),
                  ),
                ),
                if (i < _rows.length - 1) const SizedBox(width: 3),
              ],
            ],
          ),
        ),
        Expanded(
          child: HiraganaDrawGameScreen(
            key: ValueKey('notepadRow_$_sessionId'),
            initialIndex: row.startIdx,
            endIndex: row.endIdx,
            embedded: true,
            autoAdvance: true,
            surface: HiraganaDrawSurface.spiralNotepad,
            onAllComplete: _onRowComplete,
            charSet: widget.charSet,
          ),
        ),
      ],
    );
  }

  Widget _buildRowSelection({Key? key}) {
    final doneCount = _completedRows.length;
    return SizedBox.expand(
      key: key,
      child: LayoutBuilder(
        builder: (context, c) {
          const bindingReserve = 54.0;
          final pageWidth =
              math.min(c.maxWidth - bindingReserve, 400.0).clamp(260.0, 400.0);
          // Never exceed available height, or the page overflows the buttons.
          final pageHeight =
              math.min(c.maxHeight - 8, 680.0).clamp(240.0, 680.0);

          return SpiralNotepadFrame(
            pageWidth: pageWidth,
            pageHeight: pageHeight,
            child: SizedBox(
              width: pageWidth,
              height: pageHeight,
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size(pageWidth, pageHeight),
                    painter: const _RuledLinesPainter(),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 14, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('সারি বেছে নাও',
                                style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14)),
                            const Spacer(),
                            if (doneCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.correct.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                    '$doneCount / ${_rows.length} সম্পন্ন',
                                    style: const TextStyle(
                                        color: AppColors.correct,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.only(bottom: 8),
                            itemCount: _rows.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final row = _rows[index];
                              final done = _completedRows.contains(index);
                              return _RowCard(
                                  row: row,
                                  done: done,
                                  onTap: () => _selectRow(index));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RowCard extends StatelessWidget {
  const _RowCard({required this.row, required this.done, required this.onTap});
  final _RowInfo row;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = row.accent;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: done ? accent.withValues(alpha: 0.08) : AppColors.cardAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: done ? accent.withValues(alpha: 0.45) : accent.withValues(alpha: 0.18),
            width: done ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: done
                  ? accent.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent.withValues(alpha: 0.22), accent.withValues(alpha: 0.10)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Text(row.leader,
                    style: TextStyle(
                        color: accent, fontSize: 24, fontWeight: FontWeight.w900, height: 1)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(row.bn,
                      style: TextStyle(
                          color: done ? accent : AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 13)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      for (var i = 0; i < row.members.length; i++) ...[
                        Text(row.members[i],
                            style: TextStyle(
                                color: done
                                    ? accent.withValues(alpha: 0.65)
                                    : AppColors.textMuted,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        if (i < row.members.length - 1) const SizedBox(width: 6),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: done ? accent.withValues(alpha: 0.14) : AppColors.bg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                done ? Icons.check_rounded : Icons.brush_rounded,
                color: done ? accent : AppColors.textDim,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuledLinesPainter extends CustomPainter {
  const _RuledLinesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rulePaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.8)
      ..strokeWidth = 0.7;
    const spacing = 26.0;
    for (double y = 42; y < size.height - 8; y += spacing) {
      canvas.drawLine(Offset(12, y), Offset(size.width - 6, y), rulePaint);
    }
    final marginPaint = Paint()
      ..color = AppColors.accentBlue.withValues(alpha: 0.18)
      ..strokeWidth = 1.0;
    canvas.drawLine(const Offset(10, 0), Offset(10, size.height), marginPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Kana data ─────────────────────────────────────────────────────────────────

class _Kana {
  const _Kana({required this.kana, required this.romaji, required this.bn, required this.row});
  final String kana;
  final String romaji;
  final String bn;
  final String row;
}

const _akasatanaRows = <_RowInfo>[
  _RowInfo(leader: 'あ', members: ['あ', 'い', 'う', 'え', 'お'], bn: 'আ-সারি', startIdx: 0, endIdx: 5, accent: AppColors.accentBlue),
  _RowInfo(leader: 'か', members: ['か', 'き', 'く', 'け', 'こ'], bn: 'কা-সারি', startIdx: 5, endIdx: 10, accent: AppColors.accentBlueDk),
  _RowInfo(leader: 'さ', members: ['さ', 'し', 'す', 'せ', 'そ'], bn: 'সা-সারি', startIdx: 10, endIdx: 15, accent: AppColors.tabActive),
  _RowInfo(leader: 'た', members: ['た', 'ち', 'つ', 'て', 'と'], bn: 'তা-সারি', startIdx: 15, endIdx: 20, accent: AppColors.accentYellow),
  _RowInfo(leader: 'な', members: ['な', 'に', 'ぬ', 'ね', 'の'], bn: 'না-সারি', startIdx: 20, endIdx: 25, accent: AppColors.audio),
];

const _bornomalaRows = <_RowInfo>[
  _RowInfo(leader: 'は', members: ['は', 'ひ', 'ふ', 'へ', 'ほ'], bn: 'হা-সারি', startIdx: 25, endIdx: 30, accent: AppColors.audio),
  _RowInfo(leader: 'ま', members: ['ま', 'み', 'む', 'め', 'も'], bn: 'মা-সারি', startIdx: 30, endIdx: 35, accent: AppColors.accentBlue),
  _RowInfo(leader: 'や', members: ['や', 'ゆ', 'よ'], bn: 'ইয়া-সারি', startIdx: 35, endIdx: 38, accent: AppColors.accentBlueDk),
  _RowInfo(leader: 'ら', members: ['ら', 'り', 'る', 'れ', 'ろ'], bn: 'রা-সারি', startIdx: 38, endIdx: 43, accent: AppColors.tabActive),
  _RowInfo(leader: 'わ', members: ['わ', 'を', 'ん'], bn: 'ওয়া-সারি', startIdx: 43, endIdx: 46, accent: AppColors.accentYellow),
];

const _akasatanaKanaList = <_Kana>[
  // あ row
  _Kana(kana: 'あ', romaji: 'a', bn: 'আ', row: 'আ-সারি'),
  _Kana(kana: 'い', romaji: 'i', bn: 'ই', row: 'আ-সারি'),
  _Kana(kana: 'う', romaji: 'u', bn: 'উ', row: 'আ-সারি'),
  _Kana(kana: 'え', romaji: 'e', bn: 'এ', row: 'আ-সারি'),
  _Kana(kana: 'お', romaji: 'o', bn: 'ও', row: 'আ-সারি'),
  // か row
  _Kana(kana: 'か', romaji: 'ka', bn: 'কা', row: 'কা-সারি'),
  _Kana(kana: 'き', romaji: 'ki', bn: 'কি', row: 'কা-সারি'),
  _Kana(kana: 'く', romaji: 'ku', bn: 'কু', row: 'কা-সারি'),
  _Kana(kana: 'け', romaji: 'ke', bn: 'কে', row: 'কা-সারি'),
  _Kana(kana: 'こ', romaji: 'ko', bn: 'কো', row: 'কা-সারি'),
  // さ row
  _Kana(kana: 'さ', romaji: 'sa', bn: 'সা', row: 'সা-সারি'),
  _Kana(kana: 'し', romaji: 'shi', bn: 'শি', row: 'সা-সারি'),
  _Kana(kana: 'す', romaji: 'su', bn: 'সু', row: 'সা-সারি'),
  _Kana(kana: 'せ', romaji: 'se', bn: 'সে', row: 'সা-সারি'),
  _Kana(kana: 'そ', romaji: 'so', bn: 'সো', row: 'সা-সারি'),
  // た row
  _Kana(kana: 'た', romaji: 'ta', bn: 'তা', row: 'তা-সারি'),
  _Kana(kana: 'ち', romaji: 'chi', bn: 'চি', row: 'তা-সারি'),
  _Kana(kana: 'つ', romaji: 'tsu', bn: 'তসু', row: 'তা-সারি'),
  _Kana(kana: 'て', romaji: 'te', bn: 'তে', row: 'তা-সারি'),
  _Kana(kana: 'と', romaji: 'to', bn: 'তো', row: 'তা-সারি'),
  // な row
  _Kana(kana: 'な', romaji: 'na', bn: 'না', row: 'না-সারি'),
  _Kana(kana: 'に', romaji: 'ni', bn: 'নি', row: 'না-সারি'),
  _Kana(kana: 'ぬ', romaji: 'nu', bn: 'নু', row: 'না-সারি'),
  _Kana(kana: 'ね', romaji: 'ne', bn: 'নে', row: 'না-সারি'),
  _Kana(kana: 'の', romaji: 'no', bn: 'নো', row: 'না-সারি'),
];

const _bornomalaKanaList = <_Kana>[
  // は row
  _Kana(kana: 'は', romaji: 'ha', bn: 'হা', row: 'হা-সারি'),
  _Kana(kana: 'ひ', romaji: 'hi', bn: 'হি', row: 'হা-সারি'),
  _Kana(kana: 'ふ', romaji: 'fu', bn: 'ফু', row: 'হা-সারি'),
  _Kana(kana: 'へ', romaji: 'he', bn: 'হে', row: 'হা-সারি'),
  _Kana(kana: 'ほ', romaji: 'ho', bn: 'হো', row: 'হা-সারি'),
  // ま row
  _Kana(kana: 'ま', romaji: 'ma', bn: 'মা', row: 'মা-সারি'),
  _Kana(kana: 'み', romaji: 'mi', bn: 'মি', row: 'মা-সারি'),
  _Kana(kana: 'む', romaji: 'mu', bn: 'মু', row: 'মা-সারি'),
  _Kana(kana: 'め', romaji: 'me', bn: 'মে', row: 'মা-সারি'),
  _Kana(kana: 'も', romaji: 'mo', bn: 'মো', row: 'মা-সারি'),
  // や row
  _Kana(kana: 'や', romaji: 'ya', bn: 'ইয়া', row: 'ইয়া-সারি'),
  _Kana(kana: 'ゆ', romaji: 'yu', bn: 'ইউ', row: 'ইয়া-সারি'),
  _Kana(kana: 'よ', romaji: 'yo', bn: 'ইও', row: 'ইয়া-সারি'),
  // ら row
  _Kana(kana: 'ら', romaji: 'ra', bn: 'রা', row: 'রা-সারি'),
  _Kana(kana: 'り', romaji: 'ri', bn: 'রি', row: 'রা-সারি'),
  _Kana(kana: 'る', romaji: 'ru', bn: 'রু', row: 'রা-সারি'),
  _Kana(kana: 'れ', romaji: 're', bn: 'রে', row: 'রা-সারি'),
  _Kana(kana: 'ろ', romaji: 'ro', bn: 'রো', row: 'রা-সারি'),
  // わ row
  _Kana(kana: 'わ', romaji: 'wa', bn: 'ওয়া', row: 'ওয়া-সারি'),
  _Kana(kana: 'を', romaji: 'wo', bn: 'ও', row: 'ওয়া-সারি'),
  _Kana(kana: 'ん', romaji: 'n', bn: 'ন', row: 'ওয়া-সারি'),
];

// ── Dakuten data ─────────────────────────────────────────────────────────────

const _dakutenRows = <_RowInfo>[
  _RowInfo(leader: 'が', members: ['が', 'ぎ', 'ぐ', 'げ', 'ご'], bn: 'গা-সারি', startIdx: 0, endIdx: 5, accent: AppColors.accentBlue),
  _RowInfo(leader: 'ざ', members: ['ざ', 'じ', 'ず', 'ぜ', 'ぞ'], bn: 'জা-সারি', startIdx: 5, endIdx: 10, accent: AppColors.accentBlueDk),
  _RowInfo(leader: 'だ', members: ['だ', 'ぢ', 'づ', 'で', 'ど'], bn: 'দা-সারি', startIdx: 10, endIdx: 15, accent: AppColors.tabActive),
  _RowInfo(leader: 'ば', members: ['ば', 'び', 'ぶ', 'べ', 'ぼ'], bn: 'বা-সারি', startIdx: 15, endIdx: 20, accent: AppColors.accentYellow),
  _RowInfo(leader: 'ぱ', members: ['ぱ', 'ぴ', 'ぷ', 'ぺ', 'ぽ'], bn: 'পা-সারি', startIdx: 20, endIdx: 25, accent: AppColors.audio),
];

const _dakutenKanaList = <_Kana>[
  // が row
  _Kana(kana: 'が', romaji: 'ga', bn: 'গা', row: 'গা-সারি'),
  _Kana(kana: 'ぎ', romaji: 'gi', bn: 'গি', row: 'গা-সারি'),
  _Kana(kana: 'ぐ', romaji: 'gu', bn: 'গু', row: 'গা-সারি'),
  _Kana(kana: 'げ', romaji: 'ge', bn: 'গে', row: 'গা-সারি'),
  _Kana(kana: 'ご', romaji: 'go', bn: 'গো', row: 'গা-সারি'),
  // ざ row
  _Kana(kana: 'ざ', romaji: 'za', bn: 'জা', row: 'জা-সারি'),
  _Kana(kana: 'じ', romaji: 'ji', bn: 'জি', row: 'জা-সারি'),
  _Kana(kana: 'ず', romaji: 'zu', bn: 'জু', row: 'জা-সারি'),
  _Kana(kana: 'ぜ', romaji: 'ze', bn: 'জে', row: 'জা-সারি'),
  _Kana(kana: 'ぞ', romaji: 'zo', bn: 'জো', row: 'জা-সারি'),
  // だ row
  _Kana(kana: 'だ', romaji: 'da', bn: 'দা', row: 'দা-সারি'),
  _Kana(kana: 'ぢ', romaji: 'di', bn: 'দি', row: 'দা-সারি'),
  _Kana(kana: 'づ', romaji: 'dzu', bn: 'দ্জু', row: 'দা-সারি'),
  _Kana(kana: 'で', romaji: 'de', bn: 'দে', row: 'দা-সারি'),
  _Kana(kana: 'ど', romaji: 'do', bn: 'দো', row: 'দা-সারি'),
  // ば row
  _Kana(kana: 'ば', romaji: 'ba', bn: 'বা', row: 'বা-সারি'),
  _Kana(kana: 'び', romaji: 'bi', bn: 'বি', row: 'বা-সারি'),
  _Kana(kana: 'ぶ', romaji: 'bu', bn: 'বু', row: 'বা-সারি'),
  _Kana(kana: 'べ', romaji: 'be', bn: 'বে', row: 'বা-সারি'),
  _Kana(kana: 'ぼ', romaji: 'bo', bn: 'বো', row: 'বা-সারি'),
  // ぱ row
  _Kana(kana: 'ぱ', romaji: 'pa', bn: 'পা', row: 'পা-সারি'),
  _Kana(kana: 'ぴ', romaji: 'pi', bn: 'পি', row: 'পা-সারি'),
  _Kana(kana: 'ぷ', romaji: 'pu', bn: 'পু', row: 'পা-সারি'),
  _Kana(kana: 'ぺ', romaji: 'pe', bn: 'পে', row: 'পা-সারি'),
  _Kana(kana: 'ぽ', romaji: 'po', bn: 'পো', row: 'পা-সারি'),
];

// ── Flashcard game ────────────────────────────────────────────────────────────

class _AkaFlashGame extends StatefulWidget {
  const _AkaFlashGame({
    super.key,
    required this.kanaList,
  });

  final List<_Kana> kanaList;

  @override
  State<_AkaFlashGame> createState() => _AkaFlashGameState();
}

class _AkaFlashGameState extends State<_AkaFlashGame> {
  late List<_Kana> _deck;
  int _i = 0;
  bool _flipped = false;
  final _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _deck = List.of(widget.kanaList)..shuffle(_rng);
  }

  void _next() {
    if (_i >= _deck.length - 1) {
      setState(() {
        _deck.shuffle(_rng);
        _i = 0;
        _flipped = false;
      });
    } else {
      setState(() {
        _i++;
        _flipped = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final k = _deck[_i];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_i + 1} / ${_deck.length}',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  k.row,
                  style: const TextStyle(
                    color: AppColors.accentBlueDk,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _flipped = !_flipped),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _flipped
                    ? _FlipCard(
                        key: const ValueKey('back'),
                        topText: k.kana,
                        midText: k.romaji,
                        bottomText: k.bn,
                        accent: AppColors.tabActive,
                        flipped: true,
                      )
                    : _FlipCard(
                        key: const ValueKey('front'),
                        topText: k.kana,
                        midText: '',
                        bottomText: 'ট্যাপ করুন',
                        accent: AppColors.tabActive,
                        flipped: false,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _next,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.tabActive, AppColors.accentBlueDk],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('পরের কার্ড',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 15)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FlipCard extends StatelessWidget {
  const _FlipCard({
    super.key,
    required this.topText,
    required this.midText,
    required this.bottomText,
    required this.accent,
    required this.flipped,
  });

  final String topText;
  final String midText;
  final String bottomText;
  final Color accent;
  final bool flipped;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: flipped ? accent.withValues(alpha: 0.5) : AppColors.bg,
          width: flipped ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: flipped ? accent.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            topText,
            style: TextStyle(
              color: flipped ? accent : AppColors.display,
              fontSize: 96,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          if (midText.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                midText,
                style: TextStyle(
                  color: accent,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            bottomText,
            style: TextStyle(
              color: flipped ? AppColors.textPrimary : AppColors.textMuted,
              fontSize: flipped ? 28 : 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quiz game ─────────────────────────────────────────────────────────────────

class _AkaQuizGame extends StatefulWidget {
  const _AkaQuizGame({
    super.key,
    required this.kanaList,
  });

  final List<_Kana> kanaList;

  @override
  State<_AkaQuizGame> createState() => _AkaQuizGameState();
}

class _AkaQuizGameState extends State<_AkaQuizGame> {
  static const _accent = AppColors.tabActive;
  final _rng = math.Random();
  late List<_Kana> _deck;
  int _i = 0;
  int _score = 0;
  bool _locked = false;
  String? _picked;
  bool? _correct;
  late List<String> _opts;

  @override
  void initState() {
    super.initState();
    _deck = List.of(widget.kanaList)..shuffle(_rng);
    _opts = _optionsFor(_deck[_i]);
  }

  List<String> _optionsFor(_Kana q) {
    final distractors = List.of(widget.kanaList)
      ..removeWhere((k) => k.bn == q.bn)
      ..shuffle(_rng);
    final opts = <String>{q.bn};
    for (final k in distractors) {
      if (opts.length >= 4) break;
      opts.add(k.bn);
    }
    return opts.toList()..shuffle(_rng);
  }

  Future<void> _tap(String bn) async {
    if (_locked) return;
    HapticFeedback.selectionClick();
    final correct = bn == _deck[_i].bn;
    setState(() {
      _locked = true;
      _picked = bn;
      _correct = correct;
      if (correct) _score++;
    });
    await Future.delayed(const Duration(milliseconds: 520));
    if (!mounted) return;
    if (_i >= _deck.length - 1) {
      _showResult();
      return;
    }
    setState(() {
      _i++;
      _locked = false;
      _picked = null;
      _correct = null;
      _opts = _optionsFor(_deck[_i]);
    });
  }

  void _showResult() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.emoji_events_rounded, color: _accent, size: 30),
              ),
              const SizedBox(height: 12),
              const Text('কুইজ শেষ!',
                  style: TextStyle(
                      color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(
                'স্কোর: $_score / ${_deck.length}',
                style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    setState(() {
                      _deck.shuffle(_rng);
                      _i = 0;
                      _score = 0;
                      _locked = false;
                      _picked = null;
                      _correct = null;
                      _opts = _optionsFor(_deck[0]);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('আবার খেলো', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _deck[_i];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_i + 1} / ${_deck.length}',
                  style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
              Text('স্কোর: $_score',
                  style: const TextStyle(
                      color: _accent, fontWeight: FontWeight.w800, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.bg),
            ),
            child: Column(
              children: [
                Text('এই কানার উচ্চারণ কী?',
                    style: TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                const SizedBox(height: 12),
                Text(q.kana,
                    style: const TextStyle(
                        color: AppColors.textPrimary, fontSize: 80, fontWeight: FontWeight.w900, height: 1)),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: _correct == null
                      ? const SizedBox(height: 20)
                      : Text(
                          _correct! ? 'সঠিক!' : 'ভুল — পরেরটা',
                          key: ValueKey(_correct),
                          style: TextStyle(
                            color: _correct! ? AppColors.correct : AppColors.wrong,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.6,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final opt in _opts)
                  _QuizChoice(
                    label: opt,
                    selected: _picked == opt,
                    state: _correct == null
                        ? null
                        : (opt == q.bn
                            ? _ChoiceState.correct
                            : (_picked == opt ? _ChoiceState.wrong : null)),
                    onTap: _locked ? null : () => _tap(opt),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _ChoiceState { correct, wrong }

class _QuizChoice extends StatelessWidget {
  const _QuizChoice({
    required this.label,
    required this.selected,
    required this.state,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final _ChoiceState? state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = switch (state) {
      _ChoiceState.correct => AppColors.correct.withValues(alpha: 0.18),
      _ChoiceState.wrong => AppColors.wrong.withValues(alpha: 0.16),
      _ => AppColors.bg,
    };
    final border = switch (state) {
      _ChoiceState.correct => AppColors.correct.withValues(alpha: 0.65),
      _ChoiceState.wrong => AppColors.wrong.withValues(alpha: 0.6),
      _ => AppColors.border,
    };
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: selected ? 2 : 1.2),
        ),
        child: Center(
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

// ── Match game ────────────────────────────────────────────────────────────────

class _AkaMatchGame extends StatefulWidget {
  const _AkaMatchGame({
    super.key,
    required this.kanaList,
  });

  final List<_Kana> kanaList;

  @override
  State<_AkaMatchGame> createState() => _AkaMatchGameState();
}

class _AkaMatchGameState extends State<_AkaMatchGame> {
  static const _accent = AppColors.tabActive;
  final _rng = math.Random();

  late List<_MatchTile> _tiles;
  String? _selectedId;
  Set<String> _matched = {};
  int _errors = 0;

  @override
  void initState() {
    super.initState();
    _buildBoard();
  }

  void _buildBoard() {
    final sample = (List.of(widget.kanaList)..shuffle(_rng)).take(6).toList();
    final tiles = <_MatchTile>[];
    for (final k in sample) {
      tiles.add(_MatchTile(id: k.romaji, label: k.kana, pairId: k.romaji, isKana: true));
      tiles.add(_MatchTile(id: '${k.romaji}_r', label: k.bn, pairId: k.romaji, isKana: false));
    }
    tiles.shuffle(_rng);
    _tiles = tiles;
  }

  void _tap(String id) {
    final tile = _tiles.firstWhere((t) => t.id == id);
    if (_matched.contains(tile.pairId)) return;

    if (_selectedId == null) {
      setState(() => _selectedId = id);
      return;
    }

    if (_selectedId == id) {
      setState(() => _selectedId = null);
      return;
    }

    final prev = _tiles.firstWhere((t) => t.id == _selectedId);
    if (prev.pairId == tile.pairId) {
      HapticFeedback.lightImpact();
      setState(() {
        _matched.add(tile.pairId);
        _selectedId = null;
      });
      if (_matched.length == _tiles.length ~/ 2) {
        Future.delayed(const Duration(milliseconds: 400), _showResult);
      }
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _errors++;
        _selectedId = null;
      });
    }
  }

  void _showResult() {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.check_circle_rounded, color: _accent, size: 30),
              ),
              const SizedBox(height: 12),
              const Text('সব মিলিয়ে ফেললে!',
                  style: TextStyle(
                      color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text('ভুল: $_errors',
                  style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    setState(() {
                      _matched = {};
                      _selectedId = null;
                      _errors = 0;
                      _buildBoard();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('আবার খেলো', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'কানা ও উচ্চারণ মেলাও',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 14),
              ),
              Text('ভুল: $_errors',
                  style: TextStyle(
                      color: _errors > 0
                          ? AppColors.wrong
                          : AppColors.textMuted,
                      fontWeight: FontWeight.w800,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.1,
              children: [
                for (final tile in _tiles)
                  _MatchTileWidget(
                    tile: tile,
                    selected: _selectedId == tile.id,
                    matched: _matched.contains(tile.pairId),
                    onTap: () => _tap(tile.id),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchTile {
  const _MatchTile({
    required this.id,
    required this.label,
    required this.pairId,
    required this.isKana,
  });
  final String id;
  final String label;
  final String pairId;
  final bool isKana;
}

class _MatchTileWidget extends StatelessWidget {
  const _MatchTileWidget({
    required this.tile,
    required this.selected,
    required this.matched,
    required this.onTap,
  });

  final _MatchTile tile;
  final bool selected;
  final bool matched;
  final VoidCallback onTap;

  static const _accent = AppColors.tabActive;

  @override
  Widget build(BuildContext context) {
    final bg = matched
        ? _accent.withValues(alpha: 0.14)
        : selected
            ? AppColors.border
            : AppColors.bg;
    final border = matched
        ? _accent.withValues(alpha: 0.5)
        : selected
            ? AppColors.textMuted
            : AppColors.border;

    return GestureDetector(
      onTap: matched ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: selected ? 2 : 1.2),
        ),
        child: Center(
          child: Text(
            tile.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: matched ? _accent : AppColors.textPrimary,
              fontSize: tile.isKana ? 28 : 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
