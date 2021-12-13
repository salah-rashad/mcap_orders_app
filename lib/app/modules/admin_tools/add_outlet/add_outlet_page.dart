import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/data/model/region_model.dart';
import 'package:mcap_orders_app/app/data/model/user_model.dart';
import 'package:mcap_orders_app/app/theme/app_theme.dart';
import 'package:mcap_orders_app/app/theme/color_theme.dart';
import 'package:mcap_orders_app/app/widgets/text_field.dart';
import 'package:mcap_orders_app/app/widgets/user_chip.dart';

import 'add_outlet_controller.dart';

class NewOutletPage extends GetView<NewOutletController> {
  Color get pageColor =>
      controller.isEdit ? Palette.black : Palette.adminNewOutletColor;

  const NewOutletPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<NewOutletController>(
      init: NewOutletController(),
      initState: (_) {},
      builder: (controller) {
        return Theme(
          data: AppTheme.lightTheme
              .copyWith(colorScheme: ColorScheme.light(primary: pageColor)),
          child: Scaffold(
            appBar: AppBar(
              title:
                  Text(controller.isEdit ? "تعديل المنفذ" : "إضافة منفذ جديد"),
              foregroundColor: pageColor.inverted,
              backgroundColor: pageColor,
              actions: [
                controller.isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: pageColor.inverted,
                        ),
                      )
                    : IconButton(
                        onPressed: controller.isEdit
                            ? controller.updateOutlet
                            : controller.addOutlet,
                        icon: const Icon(Icons.done_rounded),
                      ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              clipBehavior: Clip.none,
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextFormField(
                      controller: controller.outletNameController,
                      labelText: "اسم المنفذ",
                      keyboardType: TextInputType.name,
                      textAlign: TextAlign.start,
                      validator: (value) {
                        if (value != null) {
                          if (value.isEmpty) {
                            return "يجب إدخال اسم المنفذ";
                          }
                        }
                      },
                    ),
                    FormField(
                      enabled: !controller.isEdit,
                      builder: (state) {
                        return Obx(
                          () => CheckboxListTile(
                            value: !controller.isGeneral,
                            title: const Text("منفذ لعميل"),
                            onChanged: (value) {
                              controller.isGeneral = !value!;
                              state.didChange(value);
                            },
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        );
                      },
                    ),
                    controller.isGeneral
                        ? regionDropdownFormField()
                        : CustomTextFormField(
                            controller: controller.customerNameController,
                            labelText: "اسم العميل",
                            keyboardType: TextInputType.name,
                            textAlign: TextAlign.start,
                            validator: (value) {
                              if (value != null) {
                                if (value.trim().isEmpty) {
                                  return "يجب إدخال اسم العميل";
                                }
                              }
                            },
                          ),
                    CustomTextFormField(
                      controller: controller.addressController,
                      labelText: "العنوان",
                      keyboardType: TextInputType.streetAddress,
                      textAlign: TextAlign.start,
                      validator: (value) {
                        if (value != null) {
                          if (value.isEmpty) {
                            return "يجب إدخال العنوان";
                          }
                        }
                      },
                    ),
                    const Divider(
                      height: 32.0,
                      thickness: 1.5,
                    ),
                    const Text(
                      "المشرفين:",
                      style: TextStyle(fontSize: 18.0),
                    ),
                    CustomTextFormField.phoneNumber(
                      controller: controller.modController,
                      textAlign: TextAlign.start,
                      counter: const SizedBox.shrink(),
                      onSubmitted: (p0) => controller.insertModerator(),
                      // suffix: IconButton(
                      //   onPressed: controller.insertModerator,
                      //   icon: const Icon(Icons.add_circle),
                      // ),
                      validator: (value) {},
                    ),
                    Wrap(
                      runSpacing: -8.0,
                      spacing: 8.0,
                      children: controller.mods.map((e) {
                        if (e is String) {
                          return UserChip(
                            labelText: e,
                            onDelete: () => controller.mods.remove(e),
                          );
                        } else if (e is UserModel) {
                          Color? color = e.role?.color;

                          return UserChip.isTooltipped(
                            labelText: e.name!,
                            toolTipText: "${e.phone}\n${e.role?.title}",
                            onDelete: () => controller.mods.remove(e),
                            color: color,
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }).toList(),
                    ),
                    const SizedBox(height: 32.0),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget regionDropdownFormField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FormField<Region?>(
        builder: (state) {
          return Obx(() {
            return InputDecorator(
              isEmpty: controller.selectedRegion == Region.empty ||
                  controller.selectedRegion == null,
              decoration: InputDecoration(
                labelText: "المنطقة",
                labelStyle: const TextStyle(fontSize: 18.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Region?>(
                  value: controller.selectedRegion,
                  itemHeight: 65.0,
                  onChanged: (Region? newValue) {
                    controller.selectedRegion = newValue;
                    state.didChange(newValue);
                  },
                  items: controller.regions!.map((element) {
                    return DropdownMenuItem<Region?>(
                      value: element,
                      child: Text(element!.name!),
                    );
                  }).toList(),
                ),
              ),
            );
          });
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (controller.selectedRegion == null ||
              controller.selectedRegion == Region.empty) {
            return "يجب اختيار المنطقة";
          }
        },
      ),
    );
  }
}
