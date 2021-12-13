import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/data/model/outlet_model.dart';
import 'package:mcap_orders_app/app/data/model/region_model.dart';
import 'package:mcap_orders_app/app/data/model/user_model.dart';
import 'package:mcap_orders_app/app/data/provider/auth.dart';
import 'package:mcap_orders_app/app/data/provider/database.dart';
import 'package:mcap_orders_app/app/utils/show_snackbar.dart';

class NewOutletController extends GetxController {
  /* ************************************************* */
  final RxBool _isEdit = false.obs;
  bool get isEdit => _isEdit.value;
  set isEdit(bool value) => _isEdit.value = value;
  /* ***** */
  final Rx<Outlet?> _outlet = Outlet.empty.obs;
  Outlet? get outlet => _outlet.value;
  set outlet(Outlet? value) => _outlet.value = value;
  /* ************************************************* */

  final outletNameController = TextEditingController();
  String get outletName => outletNameController.text;
  set outletName(String value) => outletNameController.text = value;

  /* ************ */

  final addressController = TextEditingController();
  String get location => addressController.text;
  set location(String value) => addressController.text = value;

  /* ************ */

  final modController = TextEditingController();
  String get modText => modController.text;
  set modText(String value) => modController.text = value;

  /* ************ */

  final customerNameController = TextEditingController();
  String get customerName => customerNameController.text;
  set customerName(String value) => customerNameController.text = value;

  /* ************ */

  final Rx<Region?> _selectedRegion = Region.empty.obs;
  Region? get selectedRegion => _selectedRegion.value;
  set selectedRegion(Region? value) => _selectedRegion.value = value;

  /* ************ */

  final RxList<Region?>? _regions = <Region?>[].obs;
  List<Region?>? get regions => _regions;
  set regions(List<Region?>? value) => _regions!.assignAll(value!);

  /* ************ */

  final RxBool _isGeneral = true.obs;
  bool get isGeneral => _isGeneral.value;
  set isGeneral(bool value) => _isGeneral.value = value;

  /* ************ */

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) => _isLoading.value = value;

  /* ************ */

  final RxList _mods = [].obs;
  List get mods => _mods;
  set mods(List value) => _mods.assignAll(value);

  /* ************ */

  final formKey = GlobalKey<FormState>();

  /* ************************************************************************ */

  @override
  Future<void> onReady() async {
    Map<String, dynamic>? args = Get.arguments;

    _mods.listen((p0) async {
      if (p0.isEmpty) return;
      var value = p0.last;
      if (value is String) {
        try {
          final user = await Database.getUser(value);
          if (user != null) {
            var index = mods.indexWhere((element) => element == value);
            mods[index] = user;
          }
        } catch (e) {
          print(e);
        }
      }
    });

    try {
      regions = await Database.getRegions();
      selectedRegion = regions!.first;
    } catch (e) {
      print(e);
    }

    if (args != null) {
      isEdit = args["isEdit"] ?? false;
      outlet = args["outlet"];

      if (outlet != null) {
        isGeneral = outlet!.isGeneral!;
        outletName = outlet!.name ?? "";
        if (isGeneral) {
          selectedRegion = (regions ?? [])
              .singleWhere((region) => region!.id.toString() == outlet!.region);
        }
        customerName = outlet!.customer ?? "";
        location = outlet!.location ?? "";
        for (var mod in outlet!.moderators!) {
          mods.add(mod);
        }
      }
    }
    super.onReady();
  }

  /* ************ */

  void insertModerator() {
    final value = "+20" + modText;
    if (value.length == 13) {
      if (mods.contains(value) ||
          mods.any((element) {
            if (element is UserModel) {
              UserModel user = element;
              return user.phone == value;
            } else {
              return false;
            }
          })) {
        const ShowSnackbar(
          message: "الرقم موجود بالفعل",
        ).warning();
      } else {
        mods.addNonNull(value);
        modController.clear();
      }
    } else {
      const ShowSnackbar(message: "الرقم غير صحيح").error();
    }
  }

  /* ************ */

  Future<void> addOutlet() async {
    try {
      if (!formKey.currentState!.validate()) return;
      isLoading = true;
      await Database.addOutlet(
        isGeneral
            ? Outlet(
                name: outletName.trim(),
                region: selectedRegion!.id,
                location: location,
                moderators: mods.map<String>((e) {
                  if (e is UserModel) {
                    return e.phone!;
                  } else {
                    return e;
                  }
                }).toList(),
              )
            : Outlet.customer(
                name: outletName.trim(),
                customer: customerName,
                location: location,
                moderators: [
                  Auth.i.user!.phoneNumber!,
                ],
              ),
      );
      Get.back();
    } catch (e) {
      print(e);
    }

    if (isGeneral) {
      ShowSnackbar(
        message: "تم إضافة منفذ [ $outletName ] - ${selectedRegion?.name}",
      ).success();
    } else {
      ShowSnackbar(
        message: "تم إضافة منفذ [ $outletName ] - $customerName",
      ).success();
    }

    isLoading = false;
  }

  /* ************ */

  /* ************ */

  Future<void> updateOutlet() async {
    try {
      if (!formKey.currentState!.validate()) return;
      isLoading = true;
      await Database.updateOutlet(
        isGeneral
            ? Outlet(
                id: outlet!.id,
                name: outletName.trim(),
                region: selectedRegion!.id,
                location: location,
                moderators: mods.map<String>((e) {
                  if (e is UserModel) {
                    return e.phone!;
                  } else {
                    return e;
                  }
                }).toList(),
              )
            : Outlet.customer(
                id: outlet!.id,
                name: outletName.trim(),
                customer: customerName,
                location: location,
                moderators: mods.map<String>((e) {
                  if (e is UserModel) {
                    return e.phone!;
                  } else {
                    return e;
                  }
                }).toList(),
              ),
      );
      Get.back();
    } catch (e) {
      print(e);
    }

    const ShowSnackbar(
      message: "تم تعديل المنفذ",
    ).success();

    isLoading = false;
  }

  /* ************ */
}
