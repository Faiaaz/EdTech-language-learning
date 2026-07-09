import 'package:ez_trainz/view/calendly_booking_screen.dart';
import 'package:ez_trainz/view/for_you_screen.dart';
import 'package:ez_trainz/view/games_screen.dart';
import 'package:ez_trainz/view/jlc_home_screen.dart';
import 'package:ez_trainz/view/library_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class JapaneseDashboardController extends GetxController {

  RxInt selectedIndex = 0.obs;
  int index;
  JapaneseDashboardController({required this.index});




  RxList<Widget> pages = [
    const JlcHomeScreen(),
    const GamesScreen(),
    const ForYouScreen(),
    const CalendlyBookingScreen(),
    const LibraryScreen(),
  ].obs;

}