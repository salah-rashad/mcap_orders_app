import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/data/model/order_item_model.dart';
import 'package:mcap_orders_app/app/data/model/sort_model.dart';
import 'package:mcap_orders_app/app/routes/app_routes.dart';
import 'package:mcap_orders_app/app/theme/color_theme.dart';
import 'package:mcap_orders_app/app/widgets/obs_order_item_tile/obs_order_item_tile.dart';
import 'package:mcap_orders_app/app/widgets/obs_order_item_tile/obs_order_item_tile_controller.dart';

import 'add_order_controller.dart';

class AddOrderPage extends GetView<AddOrderController> {
  Color get pageColor => Palette.primaryColor;

  const AddOrderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<AddOrderController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: Palette.white,
          appBar: AppBar(
            title: Obx(() => Text("طلبية جديدة (${controller.items.length})")),
            foregroundColor: pageColor.inverted,
            backgroundColor: pageColor,
            actions: [
              IconButton(
                onPressed:
                    controller.items.isNotEmpty ? controller.sendOrder : null,
                icon: const Icon(Icons.done_rounded),
                tooltip: "إرسال الطلبية",
              ),
            ],
            automaticallyImplyLeading: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Row(
                children: [
                  Expanded(
                    child: ButtonBar(
                      alignment: MainAxisAlignment.start,
                      children: [
                        PopupMenuButton<Sort>(
                          enabled: controller.items.isNotEmpty,
                          icon: Obx(() => controller
                              .sortChoices[controller.currentSort].icon),
                          tooltip: "ترتيب القائمة",
                          onSelected: (choice) {
                            if (controller.items.isEmpty) return;
                            controller.currentSort = choice.id;
                            choice.action();
                            controller.scrollController.animateTo(
                              controller.scrollController.offset + 1,
                              duration: 1.seconds,
                              curve: Curves.easeOut,
                            );
                          },
                          itemBuilder: (BuildContext context) {
                            return controller.sortChoices.map((choice) {
                              return PopupMenuItem<Sort>(
                                value: choice,
                                child: Text(choice.text),
                              );
                            }).toList();
                          },
                        ),
                        Obx(() {
                          if (controller.isSorted) {
                            return Text(
                              "ترتيب حسب " +
                                  controller
                                      .sortChoices[controller.currentSort].text,
                              style: const TextStyle(color: Palette.white),
                            );
                          } else {
                            return const SizedBox();
                          }
                        })
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: controller.items.isEmpty
                        ? null
                        : controller.removeAllItems,
                    icon: Icon(
                      Icons.delete_forever_rounded,
                      color:
                          controller.items.isEmpty ? Colors.grey : Palette.RED,
                    ),
                    label: const Text("مسح الكل"),
                    style: TextButton.styleFrom(
                      primary: Palette.white,
                      onSurface: Palette.white,
                    ),
                  )
                ],
              ),
            ),
          ),
          body: Stack(
            children: [
              Obx(
                () => controller.items.isEmpty
                    ? Center(
                        child: SizedBox(
                          width: Get.width * 0.7,
                          child: Opacity(
                            opacity: 0.3,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_shopping_cart_rounded,
                                  color: Palette.primaryColor,
                                  size: 72.0,
                                ),
                                Text(
                                  "اضغط الزر في الأسفل لإضافة المنتجات",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22.0,
                                    color: Palette.primaryColor,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              AnimatedList(
                key: controller.listKey,
                controller: controller.scrollController,
                padding: const EdgeInsets.only(bottom: 80.0),
                itemBuilder: (context, i, anim) {
                  var currentItem = controller.items[i];
                  var beforeItem = controller
                      .items[min(max(i - 1, 0), controller.items.length - 1)];
                  bool hasHeader =
                      currentItem.data!.type != beforeItem.data!.type || i == 0;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Obx(() {
                        if (controller.currentSort > 2 && hasHeader) {
                          return Container(
                            margin: const EdgeInsets.only(top: 8.0),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 8.0),
                            width: double.infinity,
                            color: currentItem.bgColor,
                            child: Text(
                              currentItem.data!.type,
                              style: TextStyle(
                                color: currentItem.bgColor.inverted,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                      _buildItem(currentItem, i, anim),
                    ],
                  );
                },
                initialItemCount: controller.items.length,
              ),
            ],
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () =>
                Get.toNamed(Routes.ADMIN_ALL_ITEMS, arguments: true),
            backgroundColor: pageColor,
            foregroundColor: Palette.white,
            label: const Text("إضافة منتجات"),
            icon: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildItem(OrderItem item, int index, Animation<double> anim) {
    Get.put(ObsOrderItemTileController(item), tag: item.id);

    return FadeTransition(
      opacity: anim,
      child: SizeTransition(
        sizeFactor: anim.drive(CurveTween(curve: Curves.easeOutExpo)),
        axisAlignment: 1.0,
        child: ObsOrderItemTile(
          item,
          onDelete: () => controller.removeItem(item),
        ),
      ),
    );
  }
}
