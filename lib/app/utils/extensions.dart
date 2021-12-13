import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:mcap_orders_app/app/data/model/user_role_model.dart';

mixin ext_Extensions {}

extension RoleTypeEnumExtensions on RoleType {
  String getValue() {
    return toString().replaceAll(runtimeType.toString() + ".", '');
  }
}

extension XFileExtensions on XFile {
  File? get toFile {
    Uri? uri = Uri.tryParse(path);
    if (uri != null) {
      return File.fromUri(uri);
    }
  }
}
