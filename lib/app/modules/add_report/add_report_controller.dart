import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mcap_orders_app/app/data/model/outlet_model.dart';
import 'package:mcap_orders_app/app/data/model/report_model.dart';
import 'package:mcap_orders_app/app/data/model/rx_file_model.dart';
import 'package:mcap_orders_app/app/data/provider/auth.dart';
import 'package:mcap_orders_app/app/data/provider/database.dart';
import 'package:mcap_orders_app/app/utils/show_snackbar.dart';

class AddReportController extends GetxController {
  final Outlet outlet;
  AddReportController(this.outlet);
  // final _outlet = Outlet.empty.obs;
  // Outlet get outlet => _outlet.value;
  // set outlet(Outlet value) => _outlet.value = value;

  /* ************ */

  final messageController = TextEditingController();
  String get message => messageController.text;
  set message(String value) => messageController.text = value;

  /* ************ */

  final _files = <RxFile>[].obs;
  List<RxFile> get files => _files;
  set files(List<RxFile> value) => _files.assignAll(value);

  /* ************ */

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) => _isLoading.value = value;

  /* ************ */

  final formKey = GlobalKey<FormState>();
  final galleryViewKey = GlobalKey();

  /* ************ */

  final ImagePicker _picker = ImagePicker();

  /* ************************************************************************ */

  @override
  Future<void> onReady() async {
    // outlet = Get.arguments?["outlet"];

    var response = await _picker.retrieveLostData();
    if (response.files != null) {
      files = response.files!.map((e) => RxFile(e)).toList();
    }

    super.onReady();
  }

  Future<void> sendReport() async {
    try {
      if (!formKey.currentState!.validate()) return;

      isLoading = true;
      final Report report = Report(
        outletId: outlet.id!,
        timeCreated: Timestamp.fromDate(DateTime.now()),
        senderPhone: Auth.i.user?.phoneNumber ?? "",
        message: message,
        attachments: [],
      );

      final result =
          await Database.sendReport(report, outlet: outlet, files: files);

      if (result == true) {
        Get.back(closeOverlays: true);
        const ShowSnackbar(
          message: "تم إرسال التقرير بنجاح.",
        ).success();
      } else if (result == false) {
        const ShowSnackbar(
          message: "لم يتم إرسال التقرير ، حاول مرة أخرى في وقت لاحق.",
        ).error();
      }
    } catch (e) {
      print(e);
    }

    isLoading = false;
  }

  Future<void> takeImage() async {
    try {
      var file = await _picker.pickImage(source: ImageSource.camera);
      if (file != null) {
        files.addNonNull(RxFile(file));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> takeVideo() async {
    try {
      var file = await _picker.pickVideo(source: ImageSource.camera);
      if (file != null) {
        files.addNonNull(RxFile(file));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> pickImages() async {
    try {
      var list = await _picker.pickMultiImage();
      if (list != null) {
        files.addAll(list.map((file) {
          return RxFile(file);
        }).toList());
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> pickVideo() async {
    try {
      var file = await _picker.pickVideo(source: ImageSource.gallery);
      if (file != null) {
        files.addNonNull(RxFile(file));
      }
    } catch (e) {
      print(e);
    }
  }
}
