import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mcap_orders_app/app/data/model/order_model.dart';
import 'package:mcap_orders_app/app/data/model/outlet_model.dart';
import 'package:mcap_orders_app/app/data/model/region_model.dart';
import 'package:mcap_orders_app/app/data/model/report_model.dart';
import 'package:mcap_orders_app/app/data/model/rx_file_model.dart';
import 'package:mcap_orders_app/app/data/model/user_model.dart';
import 'package:mcap_orders_app/app/data/provider/auth.dart';
import 'package:mcap_orders_app/app/data/provider/fcm.dart';
import 'package:mcap_orders_app/app/utils/connection_status.dart';
import 'package:mcap_orders_app/app/utils/show_snackbar.dart';

import 'storage.dart';

class Database {
  Database._();

  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  static final usersColl =
      firestore.collection("users").withConverter<UserModel>(
            fromFirestore: (snapshot, options) =>
                UserModel.fromMap(snapshot.data()!),
            toFirestore: (value, options) => value.toMap(),
          );

  static final regionsColl =
      firestore.collection("regions").withConverter<Region>(
            fromFirestore: (snapshot, options) => Region.fromSnapshot(snapshot),
            toFirestore: (value, options) => value.toMap(),
          );

  static final outletsColl =
      firestore.collection("outlets").withConverter<Outlet>(
            fromFirestore: (snapshot, options) => Outlet.fromSnapshot(snapshot),
            toFirestore: (value, options) => value.toMap(),
          );
  static final ordersColl = firestore.collection("orders").withConverter<Order>(
      fromFirestore: (snapshot, options) => Order.fromSnapshot(snapshot),
      toFirestore: (value, options) => value.toMap());

  static final reportsColl =
      firestore.collection("reports").withConverter<Report>(
            fromFirestore: (snapshot, options) => Report.fromSnapshot(snapshot),
            toFirestore: (value, options) => value.toMap(),
          );

  /* *************** */

  static Future<bool> addUser(UserModel user) async {
    if (!Auth.i.isManager) return false;
    if (!await ConnectionStatus.i.isConnected()) return false;
    try {
      await usersColl.doc(user.phone).set(user);
      print("User Added");
      return true;
    } catch (e) {
      print("Failed to add user: $e");
      return false;
    }
  }

  /* *************** */

  static Future<UserModel?> getUser(String phoneNumber) async {
    try {
      var user = await usersColl.doc(phoneNumber).get();
      return user.data();
    } catch (e) {
      print("Failed to get user: $e");
    }
  }

  /* *************** */

  static Future<List<Region>?> getRegions() async {
    try {
      var query = await regionsColl.orderBy("id").get();
      return query.docs.map((e) => e.data()).toList();
    } catch (e) {
      print(e);
    }
  }

  /* *************** */

  static Future<Region?> getRegionById(String regionId) async {
    try {
      var doc = await regionsColl.doc(regionId).get();
      return doc.data();
    } catch (e) {
      print("Failed to get outlet: $e");
    }
  }

  // /* *************** */

  // static Future<List<Outlet>?> getOutletsByRegionId(String regionId) async {
  //   try {
  //     var query = await outletsColl
  //         .where("region", isEqualTo: regionId)
  //         .orderBy("name")
  //         .get();
  //     return query.docs.map((e) => e.data()..id = e.id).toList()
  //       ..sort((a, b) {
  //         if (b.isEnabled) {
  //           return 1;
  //         } else {
  //           return -1;
  //         }
  //       });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  /* *************** */

  static Future<Outlet?> getOutletById(String outletId) async {
    try {
      var outlet = await outletsColl.doc(outletId).get();
      return outlet.data();
    } catch (e) {
      print("Failed to get outlet: $e");
    }
  }

  /* *************** */

  static Future<List<Outlet>?> getGeneralOutlets() async {
    try {
      var query = await outletsColl
          .where("isGeneral", isEqualTo: true)
          .orderBy('region')
          .orderBy("name")
          .get();

      var list = query.docs.map((e) => e.data()..id = e.id).toList()
        ..sort((a, b) {
          if (b.isEnabled) {
            return 1;
          } else {
            return -1;
          }
        });
      return list;
    } catch (e) {
      print(e);
    }
  }

  static Future<List<Outlet>?> getCustomersOutlets() async {
    try {
      var query = await outletsColl
          .where("isGeneral", isEqualTo: false)
          .orderBy('customer')
          .orderBy("name")
          .get();

      var list = query.docs.map((e) => e.data()..id = e.id).toList()
        ..sort((a, b) {
          if (b.isEnabled) {
            return 1;
          } else {
            return -1;
          }
        });

      return list;
    } catch (e) {
      print(e);
    }
  }

  /* *************** */

  static Future<List<Outlet>?> getMyOutlets() async {
    try {
      var query = await outletsColl
          .where(
            "moderators",
            arrayContains: Auth.i.user!.phoneNumber ?? "",
          )
          .orderBy('region')
          .orderBy("name")
          .get();

      var list = query.docs.map((e) => e.data()..id = e.id).toList()
        ..sort((a, b) {
          if (b.isEnabled) {
            return 1;
          } else {
            return -1;
          }
        });

      list.retainWhere((element) => element.isEnabled);

      return list;
    } catch (e) {
      print(e);
    }
  }

  /* *************** */

  static Future<DocumentReference?> addOutlet(Outlet outlet) async {
    if (!Auth.i.isManager) return null;
    if (!await ConnectionStatus.i.isConnected(false, true)) return null;
    try {
      return outletsColl.add(outlet);
    } catch (e) {
      print(e);
    }
  }

  /* *************** */

  static Future<void> updateOutlet(Outlet outlet) async {
    if (!Auth.i.isManager) return;
    if (!await ConnectionStatus.i.isConnected(false, true)) return;
    try {
      outletsColl.doc(outlet.id).update(outlet.toMap());
    } catch (e) {
      print(e);
    }
  }

  /* *************** */

  // static Future<void> deleteOutlet(Outlet outlet) async {
  //   try {
  //     return await regions
  //         .doc(outlet.region)
  //         .collection("outlets")
  //         .doc(outlet.id)
  //         .delete();
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  /* *************** */

  static Future<void> enableOutlet(Outlet outlet) async {
    if (!Auth.i.isManager) return;
    if (!await ConnectionStatus.i.isConnected(false, true)) return;
    final docRef = outletsColl.doc(outlet.id);
    docRef.update({
      "isEnabled": true,
    });
  }
  /* *************** */

  static Future<void> disableOutlet(Outlet outlet) async {
    if (!Auth.i.isManager) return;
    if (!await ConnectionStatus.i.isConnected(false, true)) return;
    final docRef = outletsColl.doc(outlet.id);
    docRef.update({"isEnabled": false});
  }

  /* *************** */

  static Future<void> removeAdmin(
      Outlet outlet, String adminPhoneNumber) async {
    if (!Auth.i.isManager) return;
    if (!await ConnectionStatus.i.isConnected(false, true)) return;
    final docRef = outletsColl.doc(outlet.id);
    docRef.update({
      "moderators": FieldValue.arrayRemove([adminPhoneNumber]),
    });
  }

  /* *************** */

  static Future<void> sendOrder(Order order, {Outlet? outlet}) async {
    if (!await ConnectionStatus.i.isConnected(false, true)) return;

    final docRef = await ordersColl.add(order);
    final doc = await docRef.get();

    if (doc.exists) {
      order.id = doc.id;
      const ShowSnackbar(
        message: "تم إرسال الطلبية بنجاح.",
      ).success();

      FCM.sendOrderNotification(
        title: "طلبية جديدة من " + (outlet!.name ?? ""),
        body: order.dateAndTimeFormatted,
        order: order,
      );
    } else {
      const ShowSnackbar(
        message: "لم يتم إرسال الطلبية ، حاول مرة أخرى في وقت لاحق.",
      ).error();
    }
  }

  /* *************** */

  static Future<bool?> sendReport(
    Report report, {
    required Outlet? outlet,
    required List<RxFile> files,
  }) async {
    if (!Auth.i.isSupervisor &&
        !outlet!.moderators!.contains(report.senderPhone)) return false;

    if (!await ConnectionStatus.i.isConnected(false, true)) return null;

    final docRef = await reportsColl.add(report);
    final doc = await docRef.get();

    if (doc.exists) {
      report.id = doc.id;

      var urls = <String>[];

      for (var i = 0; i < files.length; i++) {
        var rxFile = files[i];

        rxFile.uploadStatus = UploadStatus.ACTIVE;

        try {
          final task = await Storage.uploadReportAttachment(
            rxFile.file,
            doc.id,
            i,
          );

          if (task != null) {
            rxFile.uploadStatus = UploadStatus.DONE;
            urls.add(await task.ref.getDownloadURL());
          } else {
            rxFile.uploadStatus = UploadStatus.ERROR;
          }
        } catch (e) {
          rxFile.uploadStatus = UploadStatus.ERROR;
          print(e);
        }

        await doc.reference.update({
          "attachments": urls,
        });
      }

      final sender = await report.getSenderUser;

      FCM.sendReportNotification(
        title: "تقرير من " + sender!.name! + " (${outlet!.name})",
        body: report.dateAndTimeFormatted,
        report: report,
      );

      return true;
    } else {
      return false;
    }
  }

  /* *************** */

  static Future<List<Order>> getMyOrders() async {
    try {
      var query = await ordersColl
          .where("senderPhone", isEqualTo: Auth.i.userData!.phone)
          .orderBy('timeCreated', descending: true)
          .get();
      return query.docs.map((e) => e.data()).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  /* *************** */

  static Future<List<Order>> getAllOrders() async {
    try {
      var query =
          await ordersColl.orderBy('timeCreated', descending: true).get();
      return query.docs.map((e) => e.data()).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  /* *************** */

  static Future<List<Report>> getMyReports() async {
    try {
      var query = await reportsColl
          .where("senderPhone", isEqualTo: Auth.i.userData!.phone)
          .orderBy('timeCreated', descending: true)
          .get();
      return query.docs.map((e) => e.data()).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  /* *************** */

  static Future<List<Report>> getAllReports() async {
    try {
      var query =
          await reportsColl.orderBy('timeCreated', descending: true).get();
      return query.docs.map((e) => e.data()).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  /* *************** */

  // static Future<List<Order>?> getTodayOrders() async {
  //   try {
  //     var query = await ordersColl
  //         .where("isDone", isEqualTo: true)
  //         .orderBy('timeCreated')
  //         .get();
  //     return query.docs.map((e) => e.data()).toList();
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  /* *************** */

  static Future<void> setOrderDone(String orderId) async {
    if (!Auth.i.isManager) return;
    if (!await ConnectionStatus.i.isConnected(false, true)) return;

    try {
      await ordersColl.doc(orderId).update({
        "isDone": true,
      });
    } catch (e) {
      print(e);
    }
  }
}
