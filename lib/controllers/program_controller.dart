import 'package:get/get.dart';

import 'package:ez_trainz/models/program.dart';

/// Holds the currently selected language program (JLC, KLC, ELC, GLC).
/// Set when user taps a program card on the home hub; cleared when leaving the flow.
class ProgramController extends GetxController {
  static ProgramController get to => Get.find();

  final _current = Rxn<Program>();
  Program? get current => _current.value;
  bool get hasProgram => _current.value != null;

  void setProgram(Program program) {
    _current.value = program;
  }

  void clearProgram() {
    _current.value = null;
  }
}
