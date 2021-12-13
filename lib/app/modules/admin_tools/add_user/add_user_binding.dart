import 'package:get/get.dart';

import 'add_user_controller.dart';

class NewUserBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(NewUserController());
  }
}
