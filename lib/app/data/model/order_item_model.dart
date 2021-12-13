import 'dart:convert';
import 'dart:ui';

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:mcap_orders_app/app/data/provider/storehouse.dart';
import 'package:mcap_orders_app/app/theme/color_theme.dart';

import 'item_model.dart';

class OrderItem {
  final Item? data;

  /* ************* */

  OrderItem({
    this.data,
  });
  factory OrderItem.empty() => OrderItem();

  /* ************* */

  final Rx<Color> _bgColor = Palette.white.obs;
  Color get bgColor => _bgColor.value;
  set bgColor(Color value) => _bgColor.value = value;

  /* ************* */

  final _count = 1.obs;
  int get count => _count.value;
  set count(int value) {
    if (value < 1) value = 1;
    _count.value = value;
  }

  /* ************* */

  final _selected = false.obs;
  bool get selected => _selected.value;
  set selected(bool value) => _selected.value = value;

  /* ************* */

  final _notes = "".obs;
  String get notes => _notes.value;
  set notes(String value) => _notes.value = value;

  /* ************* */

  String get id => data!.id;

  /* ************* */

  factory OrderItem.fromJson(String source) =>
      OrderItem.fromMap(json.decode(source));

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      data: map['data'] != null ? Item.fromMap(map['data']) : null,
    )
      ..count = map['count'] ?? 1
      ..notes = map['notes'] ?? "";
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return {
      'count': count,
      'data': data?.toMap(),
      'notes': notes,
    };
  }

  static Future<OrderItem?> fromId(String id) async {
    final items = await Storehouse.getListOfItems(cached: true);
    return items?.firstWhere((item) => item.id == id);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OrderItem && other.data == data && other.notes == notes;
  }

  @override
  String toString() => 'OrderItem(data: $data, notes: $notes)';

  @override
  int get hashCode => data.hashCode ^ notes.hashCode;
}
