import 'dart:convert';

import 'package:excel/excel.dart';

class Item {
  final String id;
  final String type;
  final String name;
  final String unit;

  Item({
    required this.id,
    required this.type,
    required this.name,
    required this.unit,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'category': unit,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] ?? '',
      type: map['type'] ?? '',
      name: map['name'] ?? '',
      unit: map['category'] ?? '',
    );
  }

  factory Item.fromExcelRow(List<Data?> data) {
    List row = data.map((e) {
      return e?.value.toString();
    }).toList();

    return Item(
      id: row[0] ?? "-",
      type: row[1] ?? "*",
      name: row[2] ?? "-",
      unit: row[3] ?? "-",
    );
  }

  String toJson() => json.encode(toMap());

  factory Item.fromJson(String source) => Item.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Item(id: $id, type: $type, name: $name, category: $unit)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Item &&
        other.id == id &&
        other.type == type &&
        other.name == name &&
        other.unit == unit;
  }

  @override
  int get hashCode {
    return id.hashCode ^ type.hashCode ^ name.hashCode ^ unit.hashCode;
  }

  Item copyWith({
    String? id,
    String? type,
    String? name,
    String? unit,
  }) {
    return Item(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      unit: unit ?? this.unit,
    );
  }
}
