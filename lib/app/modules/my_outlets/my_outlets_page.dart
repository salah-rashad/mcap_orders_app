import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/data/model/outlet_model.dart';
import 'package:mcap_orders_app/app/data/model/region_model.dart';
import 'package:mcap_orders_app/app/data/provider/auth.dart';
import 'package:mcap_orders_app/app/data/provider/database.dart';
import 'package:mcap_orders_app/app/modules/add_report/add_report_controller.dart';
import 'package:mcap_orders_app/app/modules/add_report/add_report_page.dart';
import 'package:mcap_orders_app/app/theme/app_theme.dart';
import 'package:mcap_orders_app/app/theme/color_theme.dart';

import 'my_outlets_controller.dart';

class MyOutletsPage extends GetView<MyOutletsController> {
  Color get pageColor => Palette.myOutletsColor;

  const MyOutletsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme
          .copyWith(colorScheme: ColorScheme.light(primary: pageColor)),
      child: Scaffold(
        backgroundColor: Palette.cardBG,
        appBar: AppBar(
          foregroundColor: pageColor.inverted,
          backgroundColor: pageColor,
          title: const Text(
            "المنافذ",
          ),
        ),
        body: FutureBuilder<List<Outlet>?>(
          future: Database.getMyOutlets(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return const Text('Error');
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                var items = snapshot.data!;
                return ListView.builder(
                  itemCount: items.length,
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemBuilder: (context, index) {
                    var outlet = items[index];

                    if (Auth.i.isSupervisor) {
                      Get.put<AddReportController>(
                        AddReportController(outlet),
                        tag: outlet.id,
                        permanent: true,
                      );
                    }
                    return Card(
                      elevation: 0.0,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Obx(() => Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      outlet.name!,
                                      style: const TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (Auth.i.isSupervisor)
                                      IconButton(
                                        onPressed: () {
                                          Get.to(
                                            () => AddReportPage(outlet),
                                            // arguments: {"outlet": outlet},
                                          );
                                        },
                                        icon: const Icon(Icons.report),
                                      )
                                  ],
                                )),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Expanded(
                                  flex: 1,
                                  child: Text(
                                    "العنوان",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Text(" : "),
                                Expanded(
                                  flex: 3,
                                  child: Text(outlet.location!),
                                ),
                              ],
                            ),
                            if (outlet.isGeneral!)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Divider(
                                    thickness: 1.5,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Expanded(
                                        flex: 1,
                                        child: Text(
                                          "المنطقة",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Text(" : "),
                                      Expanded(
                                        flex: 3,
                                        child: FutureBuilder<Region?>(
                                          future: Database.getRegionById(
                                              outlet.region!),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            } else if (snapshot
                                                    .connectionState ==
                                                ConnectionState.done) {
                                              if (snapshot.hasError) {
                                                return const Text('Error');
                                              } else if (snapshot.hasData) {
                                                return Text(
                                                    snapshot.data!.name!);
                                              } else {
                                                return const Text('Empty data');
                                              }
                                            } else {
                                              return Text(
                                                'State: ${snapshot.connectionState}',
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );

                    /* ListTile(
                      title: Text(outlet.name!),
                      subtitle: ,
                      leading: ,
                    ); */
                  },
                );
              } else {
                return const Center(child: Text('لا يوجد منافذ'));
              }
            } else {
              return Text('State: ${snapshot.connectionState}');
            }
          },
        ),
      ),
    );
  }
}
