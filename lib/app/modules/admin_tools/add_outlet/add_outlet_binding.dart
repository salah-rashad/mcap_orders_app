import 'package:get/get.dart';

import 'add_outlet_controller.dart';

class NewOutletBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(NewOutletController());
  }
}
