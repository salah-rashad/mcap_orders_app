import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mcap_orders_app/app/utils/extensions.dart';

class Storage {
  static final storage = FirebaseStorage.instance;

  static Reference get attachments =>
      storage.ref().child("reports_attachments/");

  static Future<TaskSnapshot?> uploadReportAttachment(
      XFile xFile, String reportId, int index) async {
    try {
      var file = xFile.toFile;
      if (file != null) {
        final ref = attachments.child("$reportId/$reportId-$index");
        return await ref.putFile(
          file,
        );
      }
    } catch (e) {
      print(e);
    }
  }
}
