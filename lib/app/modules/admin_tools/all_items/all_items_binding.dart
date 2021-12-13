import 'package:get/get.dart';
import 'package:mcap_orders_app/app/modules/admin_tools/all_items/all_items_controller.dart';

class AllItemsBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<AllItemsController>(AllItemsController());
  }
}
