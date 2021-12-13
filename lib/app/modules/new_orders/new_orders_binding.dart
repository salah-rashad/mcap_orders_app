import 'package:get/get.dart';

import 'new_orders_controller.dart';

class NewOrdersBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(NewOrdersController());
  }
}
