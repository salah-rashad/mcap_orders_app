import 'dart:ui';

import 'package:flutter/material.dart';

class Palette {
  Palette._();

  static Color get primaryColor100 => Colors.deepPurple.shade100;
  static Color get primaryColor200 => Colors.deepPurple.shade200;
  static Color get primaryColor300 => Colors.deepPurple.shade300;
  static Color get primaryColor400 => Colors.deepPurple.shade400;
  static Color get primaryColor => Colors.deepPurple;

  static Color get accentColor => Colors.blueGrey;
  static Color get myOutletsColor => Colors.blueAccent.shade700;
  static Color get historyColor => Colors.grey.shade900;
  static Color get adminBackgroundColor => Colors.indigo;
  static Color get adminNewUserColor => Colors.teal;
  static Color get adminNewOutletColor => Colors.blueAccent;
  static Color get settingsColor => Colors.white;
  static Color get reportsColor => Colors.pink.shade700;

  static const Color black = Colors.black;
  static const Color white = Colors.white;
  static const Color RED = Colors.redAccent;
  static const Color BLUE = Colors.blueAccent;
  static const Color GREEN = Colors.green;

  static Color cardBG = Colors.blueGrey.shade100;
}

extension ColorExtension on Color {
  Color get inverted => computeLuminance() > 0.5 ? Colors.black : Colors.white;
}
