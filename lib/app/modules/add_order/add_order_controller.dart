import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/data/model/order_item_model.dart';
import 'package:mcap_orders_app/app/data/model/order_model.dart';
import 'package:mcap_orders_app/app/data/model/outlet_model.dart';
import 'package:mcap_orders_app/app/data/model/sort_model.dart';
import 'package:mcap_orders_app/app/data/provider/auth.dart';
import 'package:mcap_orders_app/app/data/provider/database.dart';
import 'package:mcap_orders_app/app/theme/color_theme.dart';
import 'package:mcap_orders_app/app/utils/random_color.dart';
import 'package:mcap_orders_app/app/widgets/obs_order_item_tile/obs_order_item_tile.dart';
import 'package:mcap_orders_app/app/widgets/obs_order_item_tile/obs_order_item_tile_controller.dart';

class AddOrderController extends GetxController {
  final _items = <OrderItem>[].obs;
  List<OrderItem> get items => _items;
  set items(List<OrderItem> items) => _items.value = items;

  final _unSortedList = <OrderItem>[];

  /* ************ */

  final nameController = TextEditingController();
  String get name => nameController.text;
  set name(String value) => nameController.text = value;

  /* ************ */

  final _topContainerHeight = 50.0.obs;
  double get topContainerHeight => _topContainerHeight.value;
  set topContainerHeight(double value) => _topContainerHeight.value = value;

  /* ************ */

  final Rx<Outlet> _selectedOutlet = Outlet.empty.obs;
  Outlet get selectedOutlet => _selectedOutlet.value;
  set selectedOutlet(Outlet value) => _selectedOutlet.value = value;

  /* ************ */

  final listKey = GlobalKey<AnimatedListState>();
  final scrollController = ScrollController();

  double get maxScrollExtent => scrollController.position.maxScrollExtent;
  double get itemHeight => ObsOrderItemTileController.ITEM_HEIGHT;

  /* ************ */

  final _currentSort = 0.obs;
  int get currentSort => _currentSort.value;
  set currentSort(int value) => _currentSort.value = value;

  bool get isSorted => currentSort != 0;

  List<Sort> get sortChoices => [
        Sort(
          id: 0,
          icon: const Icon(Icons.sort_rounded),
          text: "- إلغاء الترتيب -",
          action: resetSort,
        ),
        Sort(
          id: 1,
          icon: const Icon(
            Icons.format_list_numbered_rtl_rounded,
            color: Colors.amber,
          ),
          text: "العدد (تصاعدياً ⬆️)",
          action: () => sortByCount(asc: true),
        ),
        Sort(
          id: 2,
          icon: const Icon(
            Icons.format_list_numbered_rtl_rounded,
            color: Colors.amber,
          ),
          text: "العدد (تنازلياً ⬇️)",
          action: sortByCount,
        ),
        Sort(
          id: 3,
          icon: const Icon(
            Icons.sort_by_alpha_rounded,
            color: Colors.cyan,
          ),
          text: "الفئة (تصاعدياً ⬆️)",
          action: () => sortByType(asc: true),
        ),
        Sort(
          id: 4,
          icon: const Icon(
            Icons.sort_by_alpha_rounded,
            color: Colors.cyan,
          ),
          text: "الفئة (تنازلياً ⬇️)",
          action: sortByType,
        ),
      ];

  /* ************************************************************************ */

  @override
  void onInit() {
    scrollController.addListener(_scrollListener);
    super.onInit();
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  //! ******************************* */

  Future<void> animateToLastItem([int newItemsLength = 1]) async {
    try {
      double x = maxScrollExtent * itemHeight;

      if (x != 0) {
        await scrollController.animateTo(
          maxScrollExtent + (itemHeight * newItemsLength),
          duration: 1.seconds,
          curve: Curves.easeInOutCirc,
        );
      }
    } catch (e) {
      print(e);
    }
  }

  //! ******************************* */

  Future<void> _addItem(OrderItem item) async {
    if (items.any((element) => element.id == item.id)) return;

    final index = items.length;
    items.add(item);

    listKey.currentState!.insertItem(
      index,
      duration: 800.milliseconds,
    );

    _unSortedList.add(item);
  }

  //! ******************************* */

  Future<void> addAllItems(List<OrderItem> items) async {
    if (items.isEmpty) return;
    currentSort = 0;
    resetSort(keepOrder: true);
    animateToLastItem(items.length);

    for (var item in items) {
      _addItem(item);
    }

    await 0.8.delay();

    await animateToLastItem();
  }

  //! ******************************* */

  void removeItem(OrderItem item) {
    if (!items.any((element) => element.id == item.id)) return;

    item.bgColor = Colors.white;
    listKey.currentState!.removeItem(
      items.indexOf(item),
      (ctx, anim) {
        return FadeTransition(
          opacity: anim,
          child: SizeTransition(
            sizeFactor: anim.drive(CurveTween(curve: Curves.easeInOutExpo)),
            axisAlignment: 1.0,
            child: ObsOrderItemTile.removed(item),
          ),
        );
      },
      duration: 800.milliseconds,
    );

    items.remove(item);
    _unSortedList.remove(item);
  }

  //! ******************************* */

  Future<void> removeAllItems({bool forced = false}) async {
    void onConfirm() {
      for (var item in items) {
        item.bgColor = Colors.white;
        listKey.currentState!.removeItem(
          0,
          (ctx, anim) {
            return FadeTransition(
              opacity: anim.drive(CurveTween(curve: Curves.easeOut)),
              child: ObsOrderItemTile.removed(item),
            );
          },
          duration: 800.milliseconds,
        );

        item.bgColor = Palette.white;
      }
      items.clear();
      _unSortedList.clear();
      currentSort = 0;
    }

    if (forced) return onConfirm();

    return await Get.defaultDialog(
      title: "تأكيد",
      middleText: "سيتم إزالة جميع المنتجات في القائمة.",
      textConfirm: "تأكيد",
      textCancel: "إلغاء",
      onConfirm: () {
        onConfirm();
        Get.back();
      },
      buttonColor: Palette.RED,
      backgroundColor: Palette.cardBG,
      confirmTextColor: Palette.white,
      cancelTextColor: Palette.black,
    );
  }

  //! ******************************* */

  void _scrollListener() {
    if (scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (topContainerHeight != 0) {
        topContainerHeight = 0;
      }
    }
    if (scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (topContainerHeight == 0) {
        topContainerHeight = 50;
      }
    }
  }

  //! ******************************* */

  void sortByCount({bool asc = false}) {
    resetSort();
    try {
      if (asc) {
        items.sort((a, b) => a.count.compareTo(b.count));
      } else {
        items.sort((a, b) => b.count.compareTo(a.count));
      }

      // ignore: unused_local_variable
      for (var item in items) {
        item.bgColor = Colors.white;
        listKey.currentState!.removeItem(
          0,
          (ctx, anim) {
            return const SizedBox();
          },
          duration: 0.milliseconds,
        );
      }

      // ignore: unused_local_variable
      for (int i = 0; i < items.length; i++) {
        listKey.currentState!.insertItem(
          i,
          duration: 100.milliseconds,
        );
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  //! ******************************* */

  void sortByType({bool asc = false}) {
    resetSort();
    try {
      if (asc) {
        items.sort((a, b) => a.data!.type.compareTo(b.data!.type));
      } else {
        items.sort((a, b) => b.data!.type.compareTo(a.data!.type));
      }

      // ignore: unused_local_variable
      for (var item in items) {
        item.bgColor = Colors.white;
        listKey.currentState!.removeItem(
          0,
          (ctx, anim) {
            return const SizedBox();
          },
          duration: 0.milliseconds,
        );
      }

      // ignore: unused_local_variable
      for (int i = 0; i < items.length; i++) {
        final current = items[i];
        final after = items[min(i + 1, items.length - 1)];

        if (isSorted) {
          if (i == 0) current.bgColor = randomColor();
          if (current.data!.type == after.data!.type) {
            after.bgColor = current.bgColor;
          } else {
            after.bgColor = randomColor(not: current.bgColor);
          }
        } else {
          current.bgColor = Colors.transparent;
        }

        listKey.currentState!.insertItem(
          i,
          duration: 100.milliseconds,
        );
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  //! ******************************* */

  void resetSort({keepOrder = false}) {
    currentSort == 0;
    try {
      items = List.from(_unSortedList);

      if (!keepOrder) {
        // ignore: unused_local_variable
        for (var item in items) {
          item.bgColor = Colors.white;
          listKey.currentState!.removeItem(
            0,
            (ctx, anim) {
              return const SizedBox();
            },
            duration: 0.milliseconds,
          );
        }
      }

      // ignore: unused_local_variable
      for (var item in items) {
        item.bgColor = Colors.white;

        if (!keepOrder) listKey.currentState!.insertItem(0);
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  //! ******************************* */

  Future<void> sendOrder() async {
    return await Get.bottomSheet(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              color: Palette.cardBG,
              child: const Text(
                "إرسال الطلبية",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FutureBuilder<List<Outlet>?>(
              future: Database.getMyOutlets(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    final outlets = snapshot.data!;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  "اختر المنفذ",
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ),
                              ListView.separated(
                                shrinkWrap: true,
                                itemCount: outlets.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  var outlet = outlets[index];
                                  return Obx(
                                    () => RadioListTile<Outlet>(
                                      value: outlet,
                                      activeColor: Palette.primaryColor,
                                      groupValue: selectedOutlet,
                                      selected: selectedOutlet == outlet,
                                      selectedTileColor:
                                          Palette.primaryColor100,
                                      onChanged: (value) =>
                                          selectedOutlet = value!,
                                      title: Text("${outlet.name}"),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return const Divider(height: 0.0);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return const Text('لا يوجد منافذ');
                  }
                } else {
                  return Text('State: ${snapshot.connectionState}');
                }
              },
            ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text("إلغاء"),
                  style: TextButton.styleFrom(primary: Palette.black),
                ),
                Obx(
                  () => ElevatedButton.icon(
                    onPressed: selectedOutlet == Outlet.empty
                        ? null
                        : () {
                            final Order order = Order(
                              items: items,
                              outletId: selectedOutlet.id!,
                              timeCreated: Timestamp.fromDate(DateTime.now()),
                              senderPhone: Auth.i.user?.phoneNumber ?? "",
                            );
                            Database.sendOrder(order, outlet: selectedOutlet);
                            Get.back();
                          },
                    icon: const Icon(Icons.send_rounded),
                    label: const Text("إرسال"),
                  ),
                ),
              ],
            ),
          ],
        ),
        isScrollControlled: true,
        clipBehavior: Clip.antiAlias,
        backgroundColor: Palette.cardBG,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16.0),
          ),
        )
        // onConfirm: () async {
        //   final Order order = Order(
        //     items: items,
        //     outletId: selectedOutlet.id!,
        //     timeCreated: DateTime.now().toString(),
        //     senderPhone: Auth.i.user?.phoneNumber ?? "",
        //   );
        //   Database.sendOrder(order);
        //   Get.back();
        // },
        // buttonColor: Palette.RED,

        // confirmTextColor: Palette.white,
        // cancelTextColor: Palette.black,
        );
  }
}
