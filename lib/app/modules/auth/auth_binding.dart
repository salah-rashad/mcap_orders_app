import 'package:get/get.dart';
import 'package:mcap_orders_app/app/data/provider/auth.dart';
import 'package:mcap_orders_app/app/modules/login/login_controller.dart';
import 'package:mcap_orders_app/app/utils/connection_status.dart';

class AuthBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(Auth(), permanent: true);
    Get.put(ConnectionStatus(), permanent: true);
    Get.put(LoginController(), permanent: true);
  }
}
