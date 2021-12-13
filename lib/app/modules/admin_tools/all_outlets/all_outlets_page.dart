import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/data/model/outlet_model.dart';
import 'package:mcap_orders_app/app/data/model/region_model.dart';
import 'package:mcap_orders_app/app/data/provider/database.dart';
import 'package:mcap_orders_app/app/routes/app_routes.dart';
import 'package:mcap_orders_app/app/theme/app_theme.dart';
import 'package:mcap_orders_app/app/theme/color_theme.dart';
import 'package:mcap_orders_app/app/utils/connection_status.dart';

import 'all_outlets_controller.dart';

class AdminAllOutlets extends StatelessWidget {
  final bool isGeneral;

  const AdminAllOutlets({Key? key, this.isGeneral = true}) : super(key: key);

  Color get pageColor => Palette.adminBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme
          .copyWith(colorScheme: ColorScheme.light(primary: pageColor)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isGeneral ? "المنافذ الرئيسية" : " منافذ العملاء",
          ),
          foregroundColor: pageColor.inverted,
          backgroundColor: pageColor,
          actions: [
            IconButton(
                onPressed: () async {
                  await Get.toNamed(Routes.ADMIN_NEW_OUTLET)
                      ?.then((_) => Get.find<AllOutletsController>().update());
                },
                icon: const Icon(Icons.add_business_rounded))
          ],
        ),
        backgroundColor: Palette.cardBG,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: GetBuilder<AllOutletsController>(
              init: AllOutletsController(),
              builder: (controller) {
                return FutureBuilder<List<Outlet>?>(
                  future: isGeneral
                      ? Database.getGeneralOutlets()
                      : Database.getCustomersOutlets(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData &&
                          snapshot.data!.isNotEmpty) {
                        final headersMap = groupBy<Outlet, String>(
                            snapshot.data!,
                            (outlet) => isGeneral
                                ? outlet.region ?? ""
                                : outlet.customer ?? "");

                        final headers = headersMap.keys.toList();
                        headers.sort();

                        //! regions ////////////////////////////////////////////
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(50.0),
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: headers.length,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 32.0),
                              clipBehavior: Clip.antiAlias,
                              itemBuilder: (context, index) {
                                final header = headers[index];
                                final outlets = headersMap[header];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    isGeneral
                                        ? FutureBuilder<Region?>(
                                            future:
                                                Database.getRegionById(header),
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
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          snapshot.data!.name ??
                                                              "",
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 22.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Text(
                                                          snapshot.data!.id ??
                                                              "",
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14.0,
                                                            color:
                                                                Colors.black26,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
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
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              header,
                                              style: const TextStyle(
                                                fontSize: 22.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),

                                    //! outlets ////////////////////////////////////
                                    ListView.separated(
                                      clipBehavior: Clip.antiAlias,
                                      shrinkWrap: true,
                                      itemCount: outlets!.length,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return outletTile(
                                            controller, outlets[index]);
                                      },
                                      separatorBuilder: (context, index) {
                                        return const SizedBox(
                                          height: 4.0,
                                        );
                                      },
                                    ),
                                  ],
                                );
                              }),
                        );
                      } else {
                        return const Center(
                            child: Text(
                          'لا يوجد منافذ',
                          style: TextStyle(fontSize: 18.0),
                        ));
                      }
                    } else {
                      return Center(
                        child: Text('State: ${snapshot.connectionState}'),
                      );
                    }
                  },
                );
              }),
        ),
      ),
    );
  }

  Widget outletTile(AllOutletsController controller, Outlet outlet) {
    return ListTile(
      enabled: outlet.isEnabled,
      onLongPress: () => controller.hideOutlet(outlet),
      title: Text(outlet.name.toString()),
      visualDensity: VisualDensity.compact,
      tileColor: outlet.isEnabled ? Palette.white : Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
      trailing: outlet.isEnabled
          ? IconButton(
              onPressed: () async {
                if (!await ConnectionStatus.i.isConnected(false, true)) return;
                await Get.toNamed(
                  Routes.ADMIN_NEW_OUTLET,
                  arguments: {
                    "isEdit": true,
                    "outlet": outlet,
                  },
                );
                controller.update();
              },
              icon: const Icon(
                Icons.edit,
                color: Colors.black54,
              ),
              visualDensity: VisualDensity.compact,
              splashRadius: 24.0,
            )
          : IconButton(
              onPressed: () async {
                await Database.enableOutlet(outlet);
                controller.update();
              },
              icon: const Icon(
                Icons.remove_red_eye_rounded,
                color: Colors.black54,
              ),
              visualDensity: VisualDensity.compact,
              splashRadius: 24.0,
              highlightColor: Colors.black26.inverted,
            ),
    );
  }
}
