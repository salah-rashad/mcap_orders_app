import 'package:get/get.dart';

import 'all_outlets_controller.dart';

class AllOutletsBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<AllOutletsController>(AllOutletsController());
  }
}
