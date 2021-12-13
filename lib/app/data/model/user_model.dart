import 'dart:convert';

import 'package:mcap_orders_app/app/data/model/user_role_model.dart';
import 'package:mcap_orders_app/app/utils/extensions.dart';

class UserModel {
  String? uid;
  String? name;
  String? phone;
  Role? role;

  UserModel({
    this.uid,
    required this.name,
    required this.phone,
    required this.role,
  });

  static UserModel? empty = UserModel(
    uid: null,
    name: "",
    phone: null,
    role: null,
  );

  UserModel copyWith({
    String? uid,
    String? name,
    String? phone,
    Role? role,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'phone': phone,
      'role': role!.type.getValue(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: Role.parse(map["role"].toString()),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.uid == uid &&
        other.name == name &&
        other.phone == phone &&
        other.role == role;
  }

  @override
  int get hashCode {
    return uid.hashCode ^ name.hashCode ^ phone.hashCode ^ role.hashCode;
  }
}
