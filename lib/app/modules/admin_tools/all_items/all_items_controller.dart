import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/data/model/order_item_model.dart';
import 'package:mcap_orders_app/app/data/provider/storehouse.dart';
import 'package:mcap_orders_app/app/modules/add_order/add_order_controller.dart';

class AllItemsController extends GetxController {
  var tabs = <String, List<OrderItem>>{};
  List<OrderItem>? items = <OrderItem>[];

  Map<String, List<OrderItem>> get getActrualTabs {
    var map = LinkedHashMap.fromEntries(tabs.entries.toList().reversed);
    map.remove(dashboardText);

    return map;
  }

  AddOrderController get ctrl => Get.find<AddOrderController>();

  final dashboardText = "بيانات";

  final _isNewOrder = false.obs;
  bool get isNewOrder => _isNewOrder.value;
  set isNewOrder(bool value) => _isNewOrder.value = value;

  final RxInt _touchedIndex = (-1).obs;
  int get touchedIndex => _touchedIndex.value;
  set touchedIndex(int value) => _touchedIndex.value = value;

  final _selectedItems = <OrderItem>[].obs;
  List<OrderItem> get selectedItems => _selectedItems;
  set selectedItems(List<OrderItem> items) => _selectedItems.assignAll(items);

  Future<List<OrderItem>?> getItemsList() async {
    items = await Storehouse.getListOfItems();

    if (items != null) {
      final orderCtrl = Get.find<AddOrderController>();

      for (var item in items!) {
        for (var orderItem in orderCtrl.items) {
          if (orderItem.id == item.id) {
            item.selected = true;
          }
        }
      }

      tabs.clear();

      var groups = groupBy<OrderItem, String>(items!, (e) => e.data!.type);
      tabs.clear();

      if (isNewOrder) {
        tabs = groups;
      } else {
        tabs.addAll({dashboardText: [], ...groups});
      }
    }

    return items;
  }

  @override
  void onInit() {
    isNewOrder = Get.arguments ?? false;

    if (isNewOrder) {
      selectedItems.assignAll(ctrl.items);
    }

    super.onInit();
  }

  @override
  void onClose() {
    if (isNewOrder) {
      var newItems =
          selectedItems.where((item) => !ctrl.items.contains(item)).toList();

      ctrl.addAllItems(newItems);

      if (selectedItems.isNotEmpty) {
        var removedItems = List.of(ctrl.items);

        var selected =
            selectedItems.where((element) => element.selected).toList();

        removedItems.retainWhere((a) => selected.any((b) => a == b));
      }
    }

    super.onClose();
  }
}
