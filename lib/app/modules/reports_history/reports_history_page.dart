import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/data/model/outlet_model.dart';
import 'package:mcap_orders_app/app/data/model/report_model.dart';
import 'package:mcap_orders_app/app/data/provider/auth.dart';
import 'package:mcap_orders_app/app/data/provider/database.dart';
import 'package:mcap_orders_app/app/theme/app_theme.dart';
import 'package:mcap_orders_app/app/theme/color_theme.dart';
import 'package:mcap_orders_app/app/widgets/file_item/file_item.dart';

import 'reports_history_controller.dart';

class ReportsHistoryPage extends GetView<ReportsHistoryController> {
  const ReportsHistoryPage({Key? key}) : super(key: key);

  Color get pageColor => Palette.historyColor;
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Theme(
          data: AppTheme.lightTheme
              .copyWith(colorScheme: ColorScheme.light(primary: pageColor)),
          child: FutureBuilder<List<Report>?>(
            future: Auth.i.isManager
                ? Database.getAllReports()
                : Database.getMyReports(),
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
                        title: const Text("سجلّ التقريرات"),
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
                              child: Text("لا يوجد تقريرات"),
                            )
                          : TabBarView(
                              children: orders.map((report) {
                              final attachments = report.attachments!;
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
                                            future: report.getSenderOutlet,
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
                                                    const Text("طباعة التقرير"),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    Text(
                                      report.message ?? "",
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Divider(
                                      thickness: 2.0,
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        "المرفقات:",
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    attachments.isEmpty
                                        ? const Center(
                                            child: Text(
                                                "لم ترفق أي صور أو مقاطع فيديو"),
                                          )
                                        : GridView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: attachments.length,
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              crossAxisSpacing: 8.0,
                                              mainAxisSpacing: 8.0,
                                            ),
                                            padding: const EdgeInsets.all(8.0),
                                            itemBuilder: (context, index) {
                                              return FileItem.download(
                                                url: attachments[index],
                                              );
                                            },
                                          ),
                                  ],
                                ),
                              );
                            }).toList()),
                    ),
                  );
                } else {
                  return const Center(child: Text('لا يوجد أي تقريرات'));
                }
              } else {
                return Text('State: ${snapshot.connectionState}');
              }
            },
          )),
    );
  }
}
