import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/data/model/order_item_model.dart';
import 'package:mcap_orders_app/app/modules/admin_tools/all_items/all_items_controller.dart';
import 'package:mcap_orders_app/app/theme/app_theme.dart';
import 'package:mcap_orders_app/app/theme/color_theme.dart';

class AdminAllItems extends GetView<AllItemsController> {
  const AdminAllItems({Key? key}) : super(key: key);

  Color get pageColor =>
      controller.isNewOrder ? Palette.BLUE : Palette.adminBackgroundColor;

  Color get _backgroundColor => Palette.adminBackgroundColor;
  Color get _barBackgroundColor => Palette.white.withOpacity(0.1);
  Color get _barColorTouched => Palette.BLUE;
  Color get _barColor => Palette.white;
  Color get _tooltipBgColor => Palette.black.withOpacity(0.7);
  Color get _tooltipTextColor => _barColorTouched;
  final double _barWidth = 24.0;

  double get getMaxX {
    var list =
        List<List<OrderItem>>.from(controller.getActrualTabs.values.toList());
    list.sortByCompare<int>(
        (element) => element.length, (a, b) => a.compareTo(b));

    return list.last.length.toDouble();
  }

  double get getMaxY {
    var list =
        List<List<OrderItem>>.from(controller.getActrualTabs.values.toList());
    list.sortByCompare<int>(
        (element) => element.length, (a, b) => a.compareTo(b));

    return list.last.length.toDouble();
  }

  Duration get animDuration => const Duration(milliseconds: 200);

  final int touchedBarAddition = 3;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme.copyWith(
        colorScheme: ColorScheme.light(primary: pageColor),
      ),
      child: Material(
        child: FutureBuilder<List<OrderItem>?>(
          future: controller.getItemsList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              } else if (snapshot.hasData) {
                final items = snapshot.data;
                return DefaultTabController(
                  length: controller.tabs.length,
                  child: Scaffold(
                    appBar: AppBar(
                      title: const Text("المخزن"),
                      foregroundColor: pageColor.inverted,
                      backgroundColor: pageColor,
                      actions: [
                        if (controller.isNewOrder)
                          Obx(
                            () => Center(
                              child: Text(
                                "(${controller.selectedItems.length})",
                                style: const TextStyle(fontSize: 22.0),
                              ),
                            ),
                          ),
                      ],
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(kToolbarHeight),
                        child: TabBar(
                          isScrollable: true,
                          unselectedLabelColor: Colors.white.withOpacity(0.5),
                          indicatorColor: Colors.white,
                          tabs: controller.tabs.keys.map(
                            (type) {
                              if (type == controller.dashboardText) {
                                return const Tab(
                                  icon: Icon(
                                    Icons.insert_chart_outlined_rounded,
                                    color: Palette.white,
                                  ),
                                );
                              }
                              return Tab(text: type);
                            },
                          ).toList(),
                        ),
                      ),
                    ),
                    body: TabBarView(
                        children:
                            controller.tabs.keys.mapIndexed<Widget>((i, type) {
                      final tabItems = items!
                          .where((element) => element.data!.type == type)
                          .toList();

                      if (i == 0 && !controller.isNewOrder) {
                        return dashboard();
                      }

                      return ListView.separated(
                        itemCount: tabItems.length,
                        padding: EdgeInsets.only(
                            bottom: controller.isNewOrder ? 100.0 : 0.0),
                        itemBuilder: (context, index) {
                          final orderItem = tabItems[index];
                          if (!controller.isNewOrder) {
                            return ListTile(
                              dense: true,
                              title: Text(
                                orderItem.data!.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text("الكود: " + orderItem.id),
                              trailing: Text(orderItem.data!.unit),
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                            );
                          } else {
                            return Obx(
                              () => CheckboxListTile(
                                value: orderItem.selected,
                                selected: orderItem.selected,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                dense: true,

                                onChanged: (value) {
                                  if (orderItem.selected) {
                                    controller.selectedItems.remove(orderItem);
                                    orderItem.selected = false;
                                  } else {
                                    controller.selectedItems.add(orderItem);
                                    orderItem.selected = true;
                                  }
                                },
                                selectedTileColor:
                                    Palette.BLUE.withOpacity(0.2),
                                title: Text(
                                  orderItem.data!.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text("الكود: " + orderItem.id),
                                secondary: Text(orderItem.data!.unit),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                // minLeadingWidth: 42.0,
                              ),
                            );
                          }
                        },
                        separatorBuilder: (context, index) {
                          return Divider(
                            indent: controller.isNewOrder ? 56.0 : 0.0,
                            thickness: 1.0,
                            height: 0.0,
                          );
                        },
                      );
                    }).toList()),
                  ),
                );
              } else {
                return const Center(child: Text('Empty data'));
              }
            } else {
              return Center(child: Text('State: ${snapshot.connectionState}'));
            }
          },
        ),
      ),
    );
  }

  Widget dashboard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      clipBehavior: Clip.none,
      color: _backgroundColor,
      child: SingleChildScrollView(
        clipBehavior: Clip.none,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              'عدد الأصناف في كل فئة',
              style: TextStyle(
                color: Palette.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'إجمالي عدد الأصناف:  ' + controller.items!.length.toString(),
              style: TextStyle(
                  color: Palette.white.withOpacity(0.7),
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              'إجمالي عدد الفئات:  ' +
                  controller.getActrualTabs.length.toString(),
              style: TextStyle(
                  color: Palette.white.withOpacity(0.7),
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold),
            ),
            SingleChildScrollView(
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: SizedBox.fromSize(
                size: Size(
                  controller.getActrualTabs.length * _barWidth + Get.width,
                  getMaxY * 3.5,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Obx(
                    () => BarChart(
                      mainBarData(),
                      swapAnimationDuration: animDuration,
                      swapAnimationCurve: Curves.easeOut,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32.0),
            // const ListTile(
            //   title: Text("Hi"),
            // ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color? barColor,
    double? width,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: isTouched ? y + touchedBarAddition : y,
          colors: isTouched ? [_barColorTouched] : [barColor ?? _barColor],
          width: _barWidth,
          borderSide: isTouched
              ? BorderSide(
                  color: _barColorTouched, width: touchedBarAddition.toDouble())
              : BorderSide(color: _barColor, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            y: getMaxY + 10,
            colors: [_barBackgroundColor],
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() {
    return controller.getActrualTabs.values.mapIndexed((i, element) {
      return makeGroupData(
        i,
        element.length.toDouble(),
        isTouched: i == controller.touchedIndex,
        width: 16.0,
      );
    }).toList();
  }

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: _tooltipBgColor,
            direction: TooltipDirection.auto,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String weekDay;

              weekDay = controller.getActrualTabs.entries
                  .toList()[groupIndex.toInt()]
                  .key;

              return BarTooltipItem(
                weekDay + '\n',
                TextStyle(
                  color: _tooltipTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: (rod.y - touchedBarAddition).toInt().toString(),
                    style: TextStyle(
                      color: _tooltipTextColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          if (!event.isInterestedForInteractions ||
              barTouchResponse == null ||
              barTouchResponse.spot == null) {
            controller.touchedIndex = -1;
            return;
          }
          controller.touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        leftTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
        rightTitles: SideTitles(
          showTitles: true,
          margin: 16.0,
          reservedSize: 50.0,
          getTextStyles: (context, value) => const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14.0,
          ),
          getTitles: (value) => value.toInt().toString(),
        ),
        bottomTitles: SideTitles(
          showTitles: true,
          getTextStyles: (context, value) => const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14.0,
          ),
          rotateAngle: 45,
          margin: 16,
          textDirection: TextDirection.rtl,
          getTitles: (double value) {
            final title =
                controller.getActrualTabs.entries.toList()[value.toInt()].key;
            return title;
          },
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minY: 0,
      maxY: getMaxY + 10,
      barGroups: showingGroups(),
      gridData: FlGridData(show: false),
    );
  }
}
