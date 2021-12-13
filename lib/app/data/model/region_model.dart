import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Region {
  String? id;
  final String? name;

  Region([
    this.id,
    this.name,
  ]);

  static Region get empty => Region();

  Region copyWith({
    String? id,
    String? name,
  }) {
    return Region(
      id ?? this.id,
      name ?? this.name,
    );
  }

  factory Region.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> data) {
    return Region.fromMap(data.data()!);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Region.fromMap(Map<String, dynamic> map) {
    return Region(
      map['id'],
      map['name'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Region.fromJson(String source) => Region.fromMap(json.decode(source));

  @override
  String toString() => 'Region(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Region && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
