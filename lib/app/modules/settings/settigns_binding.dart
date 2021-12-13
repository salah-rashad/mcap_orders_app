import 'package:get/get.dart';
import 'package:mcap_orders_app/app/modules/settings/settings_controller.dart';

class SettingsBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(SettingsController());
  }
}
