import 'package:flutter/material.dart';
import 'package:mcap_orders_app/app/theme/color_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
        primaryColor: Palette.primaryColor,
        platform: TargetPlatform.iOS,
        fontFamily: "Cairo",
        colorScheme: ColorScheme.light(
          primary: Palette.primaryColor,
          onPrimary: Palette.white,
          secondary: Palette.accentColor,
        ),
      );
}
