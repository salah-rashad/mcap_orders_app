import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/routes/app_routes.dart';
import 'package:mcap_orders_app/app/theme/app_theme.dart';
import 'package:mcap_orders_app/app/theme/color_theme.dart';
import 'package:mcap_orders_app/app/widgets/home_button.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  Color get pageColor => Palette.adminBackgroundColor;

  List<Widget?> get buttons1 => [
        HomeButton(
          onPressed: () => Get.toNamed(Routes.ADMIN_ALL_ITEMS),
          title: "المخزن",
          icon: Icons.chrome_reader_mode_rounded,
          primaryColor: pageColor,
        ),
        HomeButton(
          onPressed: () => Get.toNamed(Routes.ADMIN_GENERAL_OUTLETS),
          title: "منافذي",
          icon: Icons.storefront_outlined,
          primaryColor: pageColor,
        ),
        HomeButton(
          onPressed: () => Get.toNamed(Routes.ADMIN_CUSTOMER_OUTLETS),
          title: "العملاء",
          icon: Icons.supervisor_account_rounded,
          primaryColor: pageColor,
        ),
      ];

  List<Widget?> get buttons2 => [
        HomeButton(
          onPressed: () => Get.toNamed(Routes.ADMIN_NEW_OUTLET),
          title: "إضافة منفذ جديد",
          icon: Icons.add_business_rounded,
          primaryColor: Palette.adminNewOutletColor,
        ),
        HomeButton(
          onPressed: () => Get.toNamed(Routes.ADMIN_NEW_USER),
          title: "إضافة حساب جديد",
          icon: Icons.person_add,
          primaryColor: Palette.adminNewUserColor,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme
          .copyWith(colorScheme: ColorScheme.light(primary: pageColor)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("لوحة التحكم"),
          backgroundColor: pageColor,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 12 / 9,
                ),
                padding: const EdgeInsets.all(16.0),
                itemCount: buttons1.length,
                itemBuilder: (context, index) {
                  final item = buttons1[index];

                  if (item == null) return Container();
                  return item;
                },
              ),
              const Divider(
                height: 0,
                thickness: 2.0,
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 12 / 9,
                ),
                padding: const EdgeInsets.all(16.0),
                itemCount: buttons2.length,
                itemBuilder: (context, index) {
                  final item = buttons2[index];

                  if (item == null) return Container();
                  return item;
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
