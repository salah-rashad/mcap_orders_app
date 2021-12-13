import 'package:get/get.dart';

import 'reports_history_controller.dart';

class ReportsHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(ReportsHistoryController());
  }
}
