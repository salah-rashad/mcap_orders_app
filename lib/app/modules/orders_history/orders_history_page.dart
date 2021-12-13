import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/data/model/order_model.dart';
import 'package:mcap_orders_app/app/data/model/outlet_model.dart';
import 'package:mcap_orders_app/app/data/provider/auth.dart';
import 'package:mcap_orders_app/app/data/provider/database.dart';
import 'package:mcap_orders_app/app/theme/app_theme.dart';
import 'package:mcap_orders_app/app/theme/color_theme.dart';
import 'package:mcap_orders_app/app/widgets/order_item_tile.dart';

import 'orders_history_controller.dart';

class OrdersHistoryPage extends GetView<OrdersHistoryController> {
  const OrdersHistoryPage({Key? key}) : super(key: key);

  Color get pageColor => Palette.historyColor;
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Theme(
          data: AppTheme.lightTheme
              .copyWith(colorScheme: ColorScheme.light(primary: pageColor)),
          child: FutureBuilder<List<Order>?>(
            future: Auth.i.isManager
                ? Database.getAllOrders()
                : Database.getMyOrders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return const Text('Error');
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  var orders = snapshot.data!;
                  return DefaultTabController(
                    length: orders.length,
                    child: Scaffold(
                      appBar: AppBar(
                        title: const Text("سجلّ الطلبيات"),
                        foregroundColor: pageColor.inverted,
                        backgroundColor: pageColor,
                        bottom: orders.isEmpty
                            ? null
                            : PreferredSize(
                                preferredSize:
                                    const Size.fromHeight(kToolbarHeight),
                                child: TabBar(
                                  indicatorColor: pageColor.inverted,
                                  unselectedLabelColor:
                                      Palette.white.withOpacity(0.3),
                                  isScrollable: true,
                                  tabs: orders
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
                      body: orders.isEmpty
                          ? const Center(
                              child: Text("لا يوجد طلبيات"),
                            )
                          : TabBarView(
                              children: orders.map((order) {
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          FutureBuilder<Outlet?>(
                                            future: order.getSenderOutlet,
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return const CircularProgressIndicator();
                                              } else if (snapshot
                                                      .connectionState ==
                                                  ConnectionState.done) {
                                                if (snapshot.hasError) {
                                                  return const Text('Error');
                                                } else if (snapshot.hasData) {
                                                  return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "العميل:  " +
                                                            snapshot
                                                                .data!.name!,
                                                        style: const TextStyle(
                                                          fontSize: 16.0,
                                                        ),
                                                      ),
                                                      Text(
                                                        "العنوان:  " +
                                                            snapshot.data!
                                                                .location!,
                                                        style: const TextStyle(
                                                          fontSize: 16.0,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                } else {
                                                  return const Text(
                                                      'Empty data');
                                                }
                                              } else {
                                                return Text(
                                                    'State: ${snapshot.connectionState}');
                                              }
                                            },
                                          ),
                                          ButtonBar(
                                            alignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              TextButton.icon(
                                                onPressed: () {},
                                                icon: const Icon(
                                                  Icons.print_rounded,
                                                ),
                                                label:
                                                    const Text("طباعة فاتورة"),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    ListView.separated(
                                      itemCount: items.length,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
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
                } else {
                  return const Center(child: Text('لا يوجد أي طلبيات'));
                }
              } else {
                return Text('State: ${snapshot.connectionState}');
              }
            },
          )),
    );
  }
}
