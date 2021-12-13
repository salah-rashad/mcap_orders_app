import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/foundation.dart";

class Outlet {
  String? id;
  String? name;
  String? region;
  String? customer;
  String? location;
  List<String>? moderators;
  bool? isGeneral;
  bool isEnabled;

  Outlet({
    this.id,
    required this.name,
    required this.region,
    required this.location,
    required this.moderators,
    this.isEnabled = true,
  }) : isGeneral = true;

  Outlet.customer({
    this.id,
    required this.name,
    required this.customer,
    required this.location,
    required this.moderators,
    this.isEnabled = true,
  }) : isGeneral = false;

  static Outlet empty = Outlet(
    name: "name",
    region: "region",
    location: "location",
    moderators: [],
  );

  factory Outlet.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> data) {
    return Outlet.fromMap(data.data()!)..id = data.id;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'region': region,
      'customer': customer,
      'location': location,
      'moderators': moderators,
      'isGeneral': isGeneral,
      'isEnabled': isEnabled,
    };
  }

  factory Outlet.fromMap(Map<String, dynamic> map) {
    final isGeneral = map['isGeneral'] ?? false;

    if (isGeneral) {
      return Outlet(
        id: map['id'],
        name: map['name'],
        region: map['region'],
        location: map['location'],
        moderators: map['moderators'] != null
            ? List<String>.from(map['moderators'])
            : null,
        isEnabled: map['isEnabled'] ?? false,
      );
    } else {
      return Outlet.customer(
        id: map['id'],
        name: map['name'],
        customer: map['customer'],
        location: map['location'],
        moderators: map['moderators'] != null
            ? List<String>.from(map['moderators'])
            : null,
        isEnabled: map['isEnabled'] ?? false,
      );
    }
  }

  String toJson() => json.encode(toMap());

  factory Outlet.fromJson(String source) => Outlet.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Outlet(id: $id, name: $name, region: $region, location: $location, moderators: $moderators, isGeneral: $isGeneral, isEnabled: $isEnabled)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Outlet &&
        other.id == id &&
        other.name == name &&
        other.region == region &&
        other.location == location &&
        listEquals(other.moderators, moderators) &&
        other.isGeneral == isGeneral &&
        other.isEnabled == isEnabled;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        region.hashCode ^
        location.hashCode ^
        moderators.hashCode ^
        isGeneral.hashCode ^
        isEnabled.hashCode;
  }
}
