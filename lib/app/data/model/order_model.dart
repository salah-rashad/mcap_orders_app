import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart' as intl;
import 'package:mcap_orders_app/app/data/model/outlet_model.dart';
import 'package:mcap_orders_app/app/data/model/user_model.dart';
import 'package:mcap_orders_app/app/data/provider/database.dart';

import 'order_item_model.dart';

class Order extends Comparable<Order> {
  String? id;
  final List<OrderItem>? items;
  final Timestamp? timeCreated;
  final String? senderPhone;
  final String? outletId;
  final bool? isDone;

  Order({
    this.id,
    this.items,
    required this.timeCreated,
    required this.senderPhone,
    required this.outletId,
    this.isDone = false,
  });

  Future<UserModel?> get getSenderUser async =>
      await Database.getUser(senderPhone!);

  Future<Outlet?> get getSenderOutlet async =>
      await Database.getOutletById(outletId!);

  String get dateFormatted => intl.DateFormat.yMMMEd("ar_EG")
      .format(DateTime.parse(timeCreated!.toDate().toString()));
  String get timeFormatted => intl.DateFormat("hh:mm a", "ar_EG")
      .format(DateTime.parse(timeCreated!.toDate().toString()));

  String get dateAndTimeFormatted => dateFormatted + " |  " + timeFormatted;

  Map<String, dynamic> toMap({bool withId = false}) {
    return {
      if (withId) "id": id,
      'items': json.encode(items!.map((x) => x.toJson()).toList()),
      'timeCreated': timeCreated!.millisecondsSinceEpoch,
      'senderPhone': senderPhone,
      'outletId': outletId,
      'isDone': isDone,
    };
  }

  factory Order.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();

    return Order(
      id: snapshot.id,
      items: List<OrderItem>.from(
          json.decode(data!['items'])?.map((x) => OrderItem.fromJson(x)) ??
              const []),
      timeCreated: Timestamp.fromMillisecondsSinceEpoch(data['timeCreated']),
      senderPhone: data['senderPhone'] ?? '',
      outletId: data['outletId'] ?? '',
      isDone: data['isDone'] ?? false,
    );
  }

  @override
  String toString() {
    return 'Order(id: $id, items: $items, timeCreated: $timeCreated, senderPhone: $senderPhone, outletId: $outletId, isDone: $isDone)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Order &&
        other.id == id &&
        listEquals(other.items, items) &&
        other.timeCreated == timeCreated &&
        other.senderPhone == senderPhone &&
        other.outletId == outletId &&
        other.isDone == isDone;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        items.hashCode ^
        timeCreated.hashCode ^
        senderPhone.hashCode ^
        outletId.hashCode ^
        isDone.hashCode;
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      items: map['items'] != null
          ? List<OrderItem>.from(
              json.decode(map['items'])?.map((x) => OrderItem.fromJson(x)))
          : null,
      timeCreated: Timestamp.fromMillisecondsSinceEpoch(map['timeCreated']),
      senderPhone: map['senderPhone'] ?? '',
      outletId: map['outletId'] ?? '',
      isDone: map['isDone'] ?? false,
    );
  }

  String toJson() => json.encode(toMap(withId: true));

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source));

  @override
  int compareTo(Order other) {
    return timeCreated!.compareTo(other.timeCreated!);
  }
}
