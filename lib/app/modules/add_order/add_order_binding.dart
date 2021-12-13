import 'package:get/get.dart';

import 'add_order_controller.dart';

class AddOrderBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AddOrderController(), permanent: true);
  }
}
