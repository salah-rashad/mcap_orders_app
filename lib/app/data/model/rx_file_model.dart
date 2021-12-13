import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

enum UploadStatus {
  NONE,
  ACTIVE,
  DONE,
  ERROR,
}

class RxFile {
  final XFile file;
  RxFile(this.file);

  // static TaskSnapshot? snap = const AsyncSnapshot<TaskSnapshot>.nothing().data;

  // final _taskSnapshot = snap.obs;
  // TaskSnapshot? get taskSnapshot => _taskSnapshot.value;
  // set taskSnapshot(TaskSnapshot? value) => _taskSnapshot.value = value;

  final _uploadStatus = UploadStatus.NONE.obs;
  UploadStatus get uploadStatus => _uploadStatus.value;
  set uploadStatus(UploadStatus value) => _uploadStatus.value = value;
}
