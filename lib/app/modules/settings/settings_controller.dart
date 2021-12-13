import 'package:get/get.dart';
import 'package:mcap_orders_app/app/data/provider/auth.dart';
import 'package:mcap_orders_app/app/theme/color_theme.dart';

class SettingsController extends GetxController {
  Future<void> signOut() async {
    return Get.defaultDialog(
        title: "تسجيل الخروج",
        middleText: "هل انت متأكد من تسجيل الخروج؟",
        textConfirm: "نعم",
        textCancel: "إلغاء",
        onConfirm: () => Auth.i.signOut(forced: true),
        confirmTextColor: Palette.white,
        cancelTextColor: Palette.black,
        buttonColor: Palette.RED);
  }
}
