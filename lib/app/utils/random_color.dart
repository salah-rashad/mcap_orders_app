import 'dart:math';

import 'package:flutter/material.dart';

Color randomColor({Color? not}) {
  var result = Colors.primaries[Random().nextInt(Colors.primaries.length)];
  if (not != null) {
    if (result == not) return randomColor(not: result);
  }

  return result;
}
