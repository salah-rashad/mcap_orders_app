import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:mcap_orders_app/app/data/model/order_item_model.dart';

class ObsOrderItemTileController extends GetxController {
  static const ITEM_HEIGHT = 65.0;
  final OrderItem initialItem;

  final counterController = TextEditingController();
  final notesController = TextEditingController();
  Timer? timer;

  ObsOrderItemTileController(this.initialItem);

  final Rx<OrderItem> _item = OrderItem.empty().obs;
  OrderItem get item => _item.value;
  set item(OrderItem value) => _item.value = value;

  void decreaseCount() {
    if (item.count > 1) {
      item.count--;
    } else {
      item.count = 1;
    }

    counterController.text = item.count.toString();
  }

  void increaseCount() {
    if (item.count >= 1 && item.count < 999999) {
      item.count++;
    } else {
      item.count = 1;
    }

    counterController.text = item.count.toString();
  }

  @override
  void onInit() {
    item = initialItem;
    counterController.text = item.count.toString();
    notesController.text = item.notes.trim();
    super.onInit();
  }
}
