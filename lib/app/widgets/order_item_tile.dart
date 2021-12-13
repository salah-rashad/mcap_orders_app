import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/data/model/order_item_model.dart';
import 'package:mcap_orders_app/app/theme/color_theme.dart';

class OrderItemTile extends StatelessWidget {
  final OrderItem item;
  final Color color;
  const OrderItemTile(
    this.item, {
    Key? key,
    this.color = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      horizontalTitleGap: 8.0,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      minLeadingWidth: 42.0,
      leading: Text(
        item.count.toString(),
        textAlign: TextAlign.center,
      ),
      title: Text(
        item.data!.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Row(
        children: [
          Text(
            item.data!.unit,
          ),
          if (item.notes.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Chip(
                label: const Text("ملاحظات"),
                labelStyle: TextStyle(
                  fontSize: 12.0,
                  color: color,
                ),
                padding: EdgeInsets.zero,
                backgroundColor: color.withOpacity(0.2),
                visualDensity: VisualDensity.compact,
              ),
            )
        ],
      ),
      trailing: Text(
        item.data!.type,
      ),
      onTap: item.notes.isNotEmpty ? showNotes : null,
    );
  }

  void showNotes() {
    Get.defaultDialog(
      title: "ملاحظات\n" + item.data!.name,
      middleText: item.notes,
      textConfirm: "حسناً",
      confirmTextColor: color.inverted,
      buttonColor: color,
      onConfirm: Get.back,
    );
  }
}
