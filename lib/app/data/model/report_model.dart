import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart' as intl;

import 'package:mcap_orders_app/app/data/model/user_model.dart';
import 'package:mcap_orders_app/app/data/provider/database.dart';

import 'outlet_model.dart';

class Report with Comparable<Report> {
  String? id;
  final String? senderPhone;
  final String? outletId;
  final Timestamp? timeCreated;
  final String? message;
  final List<String>? attachments;
  final bool? isRead;

  Report({
    this.id,
    required this.senderPhone,
    required this.outletId,
    required this.timeCreated,
    required this.message,
    required this.attachments,
    this.isRead = false,
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
      'senderPhone': senderPhone,
      'outletId': outletId,
      'timeCreated': timeCreated?.millisecondsSinceEpoch,
      'message': message,
      'attachments': attachments,
      'isRead': isRead,
    };
  }

  factory Report.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();

    return Report(
      id: snapshot.id,
      timeCreated:
          Timestamp.fromMillisecondsSinceEpoch(data!['timeCreated'] ?? 0),
      message: data['message'] ?? '',
      attachments: List<String>.from(data['attachments'] ?? const []),
      senderPhone: data['senderPhone'] ?? '',
      outletId: data['outletId'] ?? '',
      isRead: data['isRead'] ?? false,
    );
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'],
      timeCreated: Timestamp.fromMillisecondsSinceEpoch(map['timeCreated']),
      message: map['message'] ?? '',
      attachments: List<String>.from(map['attachments'] ?? const []),
      senderPhone: map['senderPhone'] ?? '',
      outletId: map['outletId'] ?? '',
      isRead: map['isRead'] ?? false,
    );
  }

  @override
  String toString() {
    return 'Report(id: $id, senderPhone: $senderPhone, outletId: $outletId, timeCreated: $timeCreated, message: $message, attachments: $attachments, isRead: $isRead)';
  }

  String toJson() => json.encode(toMap(withId: true));

  factory Report.fromJson(String source) => Report.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Report &&
        other.id == id &&
        other.senderPhone == senderPhone &&
        other.outletId == outletId &&
        other.timeCreated == timeCreated &&
        other.message == message &&
        listEquals(other.attachments, attachments) &&
        other.isRead == isRead;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        senderPhone.hashCode ^
        outletId.hashCode ^
        timeCreated.hashCode ^
        message.hashCode ^
        attachments.hashCode ^
        isRead.hashCode;
  }

  @override
  int compareTo(Report other) {
    return timeCreated!.compareTo(other.timeCreated!);
  }
}
