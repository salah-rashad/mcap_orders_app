import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/data/model/user_model.dart';
import 'package:mcap_orders_app/app/data/model/user_role_model.dart';
import 'package:mcap_orders_app/app/data/provider/database.dart';
import 'package:mcap_orders_app/app/utils/show_snackbar.dart';

class NewUserController extends GetxController {
  final nameController = TextEditingController();
  String get name => nameController.text;
  set name(String value) => nameController.text = value;

  /* ************ */

  final phoneNumberController = TextEditingController();
  String get phoneNumber => phoneNumberController.text;
  set phoneNumber(String value) => phoneNumberController.text = value;

  /* ************ */

  final Rx<RoleType?> _selectedRole = RoleType.CUSTOMER.obs;
  RoleType? get selectedRole => _selectedRole.value;
  set selectedRole(RoleType? value) => _selectedRole.value = value;

  /* ************ */

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) => _isLoading.value = value;

  /* ************ */

  final formKey = GlobalKey<FormState>();

  /* ************************************************************************ */

  Future<void> addUser() async {
    bool result = false;
    try {
      if (!formKey.currentState!.validate()) return;

      isLoading = true;
      result = await Database.addUser(
        UserModel(
          name: name.trim(),
          phone: "+20" + phoneNumber,
          role: Role.fromType(selectedRole!),
        ),
      );
    } catch (e) {
      print(e);
    }

    if (result) {
      Get.back(closeOverlays: true);
      ShowSnackbar(
        message: "تم إضافة الحساب - [ $name ] - [ +20$phoneNumber ]",
      ).success();
    }

    isLoading = false;
  }
}
