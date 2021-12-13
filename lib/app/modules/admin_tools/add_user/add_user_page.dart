import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/data/model/user_role_model.dart';
import 'package:mcap_orders_app/app/theme/app_theme.dart';
import 'package:mcap_orders_app/app/theme/color_theme.dart';
import 'package:mcap_orders_app/app/widgets/text_field.dart';

import 'add_user_controller.dart';

class NewUserPage extends GetView<NewUserController> {
  Color get pageColor => Palette.adminNewUserColor;

  const NewUserPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme
          .copyWith(colorScheme: ColorScheme.light(primary: pageColor)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("إضافة حساب جديد"),
          foregroundColor: pageColor.inverted,
          backgroundColor: pageColor,
          actions: [
            Obx(
              () => controller.isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: pageColor.inverted,
                      ),
                    )
                  : IconButton(
                      onPressed: controller.addUser,
                      icon: const Icon(Icons.done_rounded),
                    ),
            )
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextFormField(
                    controller: controller.nameController,
                    labelText: "الإسم",
                    keyboardType: TextInputType.name,
                    textAlign: TextAlign.start,
                    validator: (value) {
                      if (value != null) {
                        if (value.trim().isEmpty) {
                          return "يجب إدخال اسم الحساب";
                        }
                      }
                    },
                  ),
                  CustomTextFormField.phoneNumber(
                    controller: controller.phoneNumberController,
                    counter: const SizedBox.shrink(),
                  ),
                  userRoleDropdown(),
                ],
              )),
        ),
      ),
    );
  }

  Widget userRoleDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FormField<RoleType>(
        builder: (state) {
          return Obx(() => InputDecorator(
                decoration: InputDecoration(
                  labelText: "حساب لـ",
                  labelStyle: const TextStyle(fontSize: 18.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<RoleType>(
                    value: controller.selectedRole,
                    itemHeight: 65.0,
                    onChanged: (RoleType? newValue) {
                      controller.selectedRole = newValue;
                    },
                    items: RoleType.values.map((roleType) {
                      final role = Role.fromType(roleType);
                      return DropdownMenuItem<RoleType>(
                        value: roleType,
                        child: Text(
                          role?.title ?? "",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: role!.color),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ));
        },
      ),
    );
  }
}
