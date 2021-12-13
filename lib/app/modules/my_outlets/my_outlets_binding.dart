import 'package:get/get.dart';

import 'my_outlets_controller.dart';

class MyOutletsBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(MyOutletsController());
  }
}
