import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/data/model/outlet_model.dart';
import 'package:mcap_orders_app/app/data/model/rx_file_model.dart';
import 'package:mcap_orders_app/app/theme/app_theme.dart';
import 'package:mcap_orders_app/app/theme/color_theme.dart';
import 'package:mcap_orders_app/app/widgets/file_item/file_item.dart';
import 'package:mcap_orders_app/app/widgets/text_field.dart';

import 'add_report_controller.dart';

class AddReportPage extends StatelessWidget {
  final Outlet outlet;

  const AddReportPage(
    this.outlet, {
    Key? key,
  }) : super(key: key);

  Color get pageColor => Palette.myOutletsColor;

  @override
  Widget build(BuildContext context) {
    return GetX<AddReportController>(
      tag: outlet.id,
      builder: (controller) {
        return Theme(
          data: AppTheme.lightTheme
              .copyWith(colorScheme: ColorScheme.light(primary: pageColor)),
          child: Scaffold(
              backgroundColor: Palette.cardBG,
              // resizeToAvoidBottomInset: false,
              appBar: AppBar(
                foregroundColor: pageColor.inverted,
                backgroundColor: pageColor,
                title: Text("تقرير ${controller.outlet.name}"),
                actions: [
                  controller.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: pageColor.inverted,
                          ),
                        )
                      : IconButton(
                          onPressed: controller.sendReport,
                          icon: const Icon(Icons.send),
                        ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.only(
                  top: 16.0,
                  bottom: 90.0,
                  right: 16.0,
                  left: 16.0,
                ),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: CustomTextFormField(
                          controller: controller.messageController,
                          labelText: "تفاصيل التقرير",
                          maxLines: null,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "المرفقات:",
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (controller.files.isNotEmpty)
                            TextButton.icon(
                              onPressed: () {
                                controller.files.clear();
                              },
                              icon: const Icon(Icons.delete_forever),
                              label: const Text("مسح الكل"),
                              style: TextButton.styleFrom(
                                primary: Palette.black,
                              ),
                            )
                        ],
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      Expanded(
                        flex: controller.files.isEmpty ? 0 : 1,
                        child: controller.files.isEmpty
                            ? const Center(
                                child: Text("لم ترفق أي صور أو مقاطع فيديو"),
                              )
                            : GridView.builder(
                                itemCount: controller.files.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: 8.0,
                                ),
                                itemBuilder: (context, index) {
                                  RxFile rxFile = controller.files[index];

                                  return FileItem(
                                    controller: controller,
                                    rxFile: rxFile,
                                    onDelete: () {
                                      controller.files.removeAt(index);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        onPressed: controller.isLoading
                            ? null
                            : () => sourceSelector(controller: controller),
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.indigo.inverted,
                        child: const Icon(Icons.camera_alt_rounded),
                        heroTag: "fab_image_cam_tag",
                      ),
                      FloatingActionButton(
                        onPressed: controller.isLoading
                            ? null
                            : () => sourceSelector(
                                isImage: false, controller: controller),
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.teal.inverted,
                        child: const Icon(Icons.video_camera_back_rounded),
                        heroTag: "fab_video_cam_tag",
                      ),
                    ],
                  ),
                ],
              )),
        );
      },
    );
  }

  Future<void> sourceSelector(
      {bool isImage = true, required AddReportController controller}) async {
    return await Get.dialog(
      Center(
        child: Card(
          margin: const EdgeInsets.all(32.0),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("التقاط من الكاميرا"),
                onTap: () {
                  Get.back();
                  isImage ? controller.takeImage() : controller.takeVideo();
                },
              ),
              ListTile(
                title: const Text("اختيار من المعرض"),
                onTap: () {
                  Get.back();
                  isImage ? controller.pickImages() : controller.pickVideo();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
