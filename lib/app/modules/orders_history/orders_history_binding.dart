import 'package:get/get.dart';

import 'orders_history_controller.dart';

class OrdersHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(OrdersHistoryController());
  }
}
