import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/data/model/order_item_model.dart';
import 'package:mcap_orders_app/app/theme/color_theme.dart';

import 'obs_order_item_tile_controller.dart';

class ObsOrderItemTile extends GetView<ObsOrderItemTileController> {
  final OrderItem _item;
  final int? index;
  final VoidCallback? onDelete;
  final Icon? icon;
  final bool isRemoved;

  const ObsOrderItemTile(
    this._item, {
    Key? key,
    this.index,
    this.onDelete,
    // this.data,
    this.icon,
    this.isRemoved = false,
  }) : super(key: key);

  factory ObsOrderItemTile.removed(OrderItem item) {
    return ObsOrderItemTile(
      item,
      icon: const Icon(
        Icons.delete_sweep_rounded,
        color: Palette.RED,
      ),
      isRemoved: true,
    );
  }

  final isRemovedTextStyle = const TextStyle(color: Palette.RED);
  TextStyle get defaultTextStyle =>
      TextStyle(color: controller.item.bgColor.inverted);

  @override
  String? get tag => _item.id;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ObsOrderItemTileController.ITEM_HEIGHT,
      child: Center(
        child: Obx(() {
          final item = controller.item.data!;
          return ListTile(
            dense: true,
            onTap: isRemoved ? null : editItem,
            horizontalTitleGap: 8.0,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            minLeadingWidth: 42.0,
            tileColor: controller.item.bgColor.withOpacity(0.8),
            leading: Text(
              controller.item.count.toString(),
              textAlign: TextAlign.center,
              style: isRemoved ? isRemovedTextStyle : defaultTextStyle,
            ),
            title: Text(
              controller.item.data!.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: isRemoved
                  ? isRemovedTextStyle
                  : defaultTextStyle.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Row(
              children: [
                Text(
                  item.unit,
                  style: isRemoved ? isRemovedTextStyle : defaultTextStyle,
                ),
                if (controller.item.notes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Chip(
                      label: const Text("ملاحظات"),
                      labelStyle: TextStyle(
                        fontSize: 12.0,
                        color: Palette.primaryColor,
                      ),
                      padding: EdgeInsets.zero,
                      backgroundColor: Palette.primaryColor100,
                      visualDensity: VisualDensity.compact,
                    ),
                  )
              ],
            ),
            trailing: IconButton(
              onPressed: isRemoved ? null : onDelete,
              icon: icon ??
                  Icon(
                    Icons.delete,
                    color: controller.item.bgColor.inverted,
                  ),
              visualDensity: VisualDensity.compact,
              splashRadius: 20.0,
            ),
          );
        }),
      ),
    );
  }

  Future<void> editItem() async {
    return await Get.dialog(
      Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(child: GestureDetector(
              onTap: () {
                Get.back();
              },
            )),
            Center(
              child: LayoutBuilder(builder: (context, constraints) {
                return Card(
                  clipBehavior: Clip.antiAlias,
                  color: Palette.cardBG,
                  margin: const EdgeInsets.all(32.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.item.data!.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 22.0),
                      ),
                      const Divider(thickness: 2.0),
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: GestureDetector(
                                      onLongPressStart: (details) {
                                        if (controller.timer != null) {
                                          controller.timer!.cancel();
                                        }
                                        controller.timer = Timer.periodic(
                                          100.milliseconds,
                                          (t) => controller.increaseCount(),
                                        );
                                      },
                                      onLongPressEnd: (details) {
                                        if (controller.timer != null) {
                                          controller.timer!.cancel();
                                        }
                                      },
                                      child: IconButton(
                                        onPressed: controller.increaseCount,
                                        icon: const Icon(Icons.add),
                                        highlightColor: Palette.GREEN,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: TextFormField(
                                      maxLines: 1,
                                      controller: controller.counterController,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 22.0),
                                      keyboardType: const TextInputType
                                          .numberWithOptions(),
                                      maxLength: 6,
                                      decoration: InputDecoration(
                                          counterText:
                                              controller.item.data!.unit),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp("[0-9]")),
                                        FilteringTextInputFormatter.deny(
                                            RegExp("^0"))
                                      ],
                                      onChanged: (value) {
                                        controller.item.count =
                                            int.tryParse(value) ?? 1;
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: GestureDetector(
                                      onLongPressStart: (details) {
                                        if (controller.timer != null) {
                                          controller.timer!.cancel();
                                        }
                                        controller.timer = Timer.periodic(
                                          100.milliseconds,
                                          (t) => controller.decreaseCount(),
                                        );
                                      },
                                      onLongPressEnd: (details) {
                                        if (controller.timer != null) {
                                          controller.timer!.cancel();
                                        }
                                      },
                                      child: IconButton(
                                        onPressed: controller.decreaseCount,
                                        icon: const Icon(Icons.remove),
                                        highlightColor: Palette.RED,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16.0),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  const Expanded(
                                    flex: 1,
                                    child: Text("كود الصنف"),
                                  ),
                                  const Text(" : "),
                                  Expanded(
                                    flex: 2,
                                    child: Text(controller.item.data!.id),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Expanded(
                                    flex: 1,
                                    child: Text("الفئة"),
                                  ),
                                  const Text(" : "),
                                  Expanded(
                                    flex: 2,
                                    child: Text(controller.item.data!.type),
                                  ),
                                ],
                              ),
                              const Divider(),
                              const SizedBox(
                                height: 16.0,
                              ),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: constraints.maxHeight / 2,
                                ),
                                child: IntrinsicHeight(
                                  child: TextFormField(
                                    controller: controller.notesController,
                                    maxLines: null,
                                    maxLength: 500,
                                    style: const TextStyle(height: 1.5),
                                    onChanged: (value) =>
                                        controller.item.notes = value.trim(),
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "ملاحظات",
                                      contentPadding: EdgeInsets.all(8.0),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // const Divider(thickness: 2.0),
                      ElevatedButton(
                        onPressed: Get.back,
                        child: const Text("تم"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(60.0),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    ).then((value) {
      if (controller.timer != null) controller.timer!.cancel();
    });
  }
}
