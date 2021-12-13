import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/data/model/outlet_model.dart';
import 'package:mcap_orders_app/app/data/provider/auth.dart';
import 'package:mcap_orders_app/app/data/provider/database.dart';
import 'package:mcap_orders_app/app/modules/new_orders/new_orders_controller.dart';
import 'package:mcap_orders_app/app/theme/app_theme.dart';
import 'package:mcap_orders_app/app/theme/color_theme.dart';
import 'package:mcap_orders_app/app/widgets/order_item_tile.dart';

class NewOrdersPage extends GetView<NewOrdersController> {
  const NewOrdersPage({Key? key}) : super(key: key);

  Color get pageColor => Palette.primaryColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Theme(
        data: AppTheme.lightTheme
            .copyWith(colorScheme: ColorScheme.light(primary: pageColor)),
        child: GetX<NewOrdersController>(
          builder: (controller) {
            int? initOrderIndex = Auth.i.newOrders
                .indexWhere((o) => o.id == Get.parameters["init_order_id"]);

            int initIndex = initOrderIndex == -1 ? 0 : initOrderIndex;

            return DefaultTabController(
              length: Auth.i.newOrders.length,
              initialIndex: initIndex,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text("الطلبيات الجديدة"),
                  foregroundColor: pageColor.inverted,
                  backgroundColor: pageColor,
                  bottom: Auth.i.newOrders.isEmpty
                      ? null
                      : PreferredSize(
                          preferredSize: const Size.fromHeight(kToolbarHeight),
                          child: TabBar(
                            indicatorColor: pageColor.inverted,
                            unselectedLabelColor:
                                Palette.white.withOpacity(0.3),
                            isScrollable: true,
                            tabs: Auth.i.newOrders
                                .map((e) => Tab(
                                      child: Text(
                                        e.dateFormatted +
                                            "\n" +
                                            e.timeFormatted,
                                        style: const TextStyle(
                                          height: 1.3,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                ),
                body: Auth.i.newOrders.isEmpty
                    ? const Center(
                        child: Text("لا يوجد طلبيات"),
                      )
                    : TabBarView(
                        children: Auth.i.newOrders.map((order) {
                        final items = order.items!;
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(
                                    right: 16.0, left: 16.0, top: 16.0),
                                color: pageColor.withOpacity(0.3),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FutureBuilder<Outlet?>(
                                      future: order.getSenderOutlet,
                                      builder: (context, snapshot) {
                                        print(snapshot.connectionState);
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.connectionState ==
                                            ConnectionState.done) {
                                          if (snapshot.hasError) {
                                            return const Text('Error');
                                          } else if (snapshot.hasData) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "العميل:  " +
                                                      snapshot.data!.name!,
                                                  style: const TextStyle(
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                                Text(
                                                  "العنوان:  " +
                                                      snapshot.data!.location!,
                                                  style: const TextStyle(
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                              ],
                                            );
                                          } else {
                                            return const Text('Empty data');
                                          }
                                        } else {
                                          return Text(
                                              'State: ${snapshot.connectionState}');
                                        }
                                      },
                                    ),
                                    ButtonBar(
                                      alignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () {},
                                          icon: const Icon(
                                            Icons.print_rounded,
                                          ),
                                          label: const Text("طباعة فاتورة"),
                                        ),
                                        TextButton.icon(
                                          onPressed: () {
                                            Database.setOrderDone(order.id!);
                                            controller.update();
                                          },
                                          icon: const Icon(
                                            Icons.done_outline_rounded,
                                          ),
                                          label: const Text("تم"),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              ListView.separated(
                                itemCount: items.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  var item = items[index];
                                  return OrderItemTile(
                                    item,
                                    color: pageColor,
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return const Divider();
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList()),
              ),
            );
          },
        ),
      ),
    );
  }
}
