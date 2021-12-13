import 'package:flutter/material.dart';
import 'package:mcap_orders_app/app/utils/extensions.dart';

enum RoleType {
  MANAGER,
  SUPERVISOR,
  OUTLET_MANAGER,
  CUSTOMER,
}

class Role {
  final String title;
  final Color color;
  final RoleType type;

  const Role({
    required this.title,
    required this.color,
    required this.type,
  });

  static Role? parse(String type) {
    return roles[type];
  }

  static Role? fromType(RoleType type) {
    return roles[type.getValue()];
  }

  static const Map<String, Role?> roles = {
    "MANAGER": Role(
      title: "إدارة عليا",
      color: Colors.indigo,
      type: RoleType.MANAGER,
    ),
    "SUPERVISOR": Role(
      title: "مشرف منافذ",
      color: Colors.orange,
      type: RoleType.SUPERVISOR,
    ),
    "OUTLET_MANAGER": Role(
      title: "مدير منفذ",
      color: Colors.pink,
      type: RoleType.OUTLET_MANAGER,
    ),
    "CUSTOMER": Role(
      title: "عميل",
      color: Colors.teal,
      type: RoleType.CUSTOMER,
    ),
  };

  @override
  String toString() => 'UserRole(title: $title, color: $color, role: $type)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Role &&
        other.title == title &&
        other.color == color &&
        other.type == type;
  }

  @override
  int get hashCode => title.hashCode ^ color.hashCode ^ type.hashCode;
}
