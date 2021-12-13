import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/modules/settings/settings_controller.dart';
import 'package:mcap_orders_app/app/theme/app_theme.dart';
import 'package:mcap_orders_app/app/theme/color_theme.dart';

class SettingsPage extends GetView<SettingsController> {
  Color get pageColor => Palette.settingsColor;

  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme
          .copyWith(colorScheme: ColorScheme.light(primary: pageColor)),
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: pageColor.inverted,
          backgroundColor: pageColor,
          title: const Text("الإعدادات"),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(),
              ),
            ),
            ListTile(
              title: const Text("تسجيل الخروج"),
              leading: const Icon(Icons.logout_rounded),
              onTap: () => controller.signOut(),
            ),
          ],
        ),
      ),
    );
  }
}
