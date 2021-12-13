import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/data/model/order_model.dart';
import 'package:mcap_orders_app/app/data/model/user_model.dart';
import 'package:mcap_orders_app/app/data/provider/auth.dart';
import 'package:mcap_orders_app/app/data/provider/database.dart';
import 'package:mcap_orders_app/app/data/provider/fcm.dart';
import 'package:mcap_orders_app/app/modules/add_order/add_order_controller.dart';
import 'package:mcap_orders_app/app/routes/app_routes.dart';
import 'package:mcap_orders_app/app/theme/color_theme.dart';
import 'package:mcap_orders_app/app/widgets/home_button.dart';

class HomeController extends GetxController {
  Timer? popTimer;

  final RxBool _blinking = true.obs;
  bool get blinking => _blinking.value;
  set blinking(bool value) => _blinking.value = value;

  late Timer blinkingTimer;

  final orderCtrl = Get.put(AddOrderController());

  List<Order> get todayOrders => Auth.i.newOrders
      .where((p0) => p0.timeCreated!.toDate().day == DateTime.now().day)
      .toList();

  // HomeButton get _settingsButton => HomeButton(
  //       onPressed: () => Get.toNamed(Routes.SETTINGS),
  //       title: "الإعدادات",
  //       icon: Icons.settings,
  //       primaryColor: Palette.settingsColor,
  //     );

  HomeButton get _logoutButton => HomeButton(
        onPressed: Auth.i.signOut,
        title: "تسجيل الخروج",
        icon: Icons.logout,
        primaryColor: Palette.RED,
        noBackground: true,
      );

  List<HomeButton?> get mainButtons => [
        HomeButton(
          onPressed: () => Get.toNamed(
            Routes.ADD_ORDER,
            preventDuplicates: true,
          ),
          title: "طلبية جديدة",
          icon: Icons.add_box_rounded,
          primaryColor: Palette.primaryColor,
          onPrimaryColor: Colors.amber,
          elevation: 7.0,
          badge: orderCtrl.items.isEmpty
              ? null
              : orderCtrl.items.length.toString(),
        ),
        HomeButton(
          onPressed: () => Get.toNamed(Routes.MY_OUTLETS),
          title: "منافذي",
          icon: Icons.store_mall_directory_rounded,
          primaryColor: Palette.myOutletsColor,
        ),
        HomeButton(
          onPressed: () => Get.toNamed(Routes.ORDERS_HISTORY),
          title: "سجلّ الطلبيات",
          icon: Icons.history_rounded,
          primaryColor: Palette.historyColor,
        ),
        HomeButton(
          onPressed: () => Get.toNamed(Routes.REPORTS_HISTORY),
          title: "سجلّ التقريرات",
          icon: Icons.pending_actions_rounded,
          primaryColor: Palette.historyColor,
        ),
        _logoutButton,
      ];

  List<HomeButton?> get managerButtons => [
        HomeButton(
          onPressed: () => Get.toNamed(Routes.NEW_ORDERS),
          title: "الطلبيات الجديدة",
          icon: Icons.today_rounded,
          primaryColor: Palette.primaryColor,
          elevation: 7.0,
          badge: Auth.i.newOrders.isEmpty
              ? null
              : Auth.i.newOrders.length.toString(),
        ),
        HomeButton(
          onPressed: () => Get.toNamed(Routes.NEW_REPORTS),
          title: "التقارير الجديدة",
          icon: Icons.article_rounded,
          primaryColor: Palette.reportsColor,
          onPrimaryColor: Colors.green,
          elevation: 7.0,
          badge: Auth.i.newOrders.isEmpty
              ? null
              : Auth.i.newOrders.length.toString(),
        ),
        HomeButton(
          onPressed: () => Get.toNamed(Routes.ORDERS_HISTORY),
          title: "سجلّ الطلبيات",
          icon: Icons.history_rounded,
          primaryColor: Palette.historyColor,
        ),
        HomeButton(
          onPressed: () => Get.toNamed(Routes.ADMIN_HOME),
          title: "لوحة التحكم",
          icon: Icons.admin_panel_settings_rounded,
          primaryColor: Palette.adminBackgroundColor,
        ),
        _logoutButton,
        // HomeButton(
        //   onPressed: () => Get.toNamed(
        //     Routes.ADD_ORDER,
        //     preventDuplicates: true,
        //   ),
        //   title: "طلبية جديدة",
        //   icon: Icons.add_box_rounded,
        //   primaryColor: Palette.primaryColor,
        //   onPrimaryColor: Colors.amber,
        //   elevation: 7.0,
        //   badge: orderCtrl.items.isEmpty
        //       ? null
        //       : orderCtrl.items.length.toString(),
        // ),
      ];

  @override
  Future<void> onReady() async {
    try {
      var data = await Database.getUser(Auth.i.user!.phoneNumber!);
      Auth.i.userData = data ?? UserModel.empty;

      if (Auth.i.isManager) FCM.init();

      blinkingTimer =
          Timer.periodic(1.seconds, (timer) => blinking = !blinking);
    } catch (e) {
      print(e);
    }
  }
}
