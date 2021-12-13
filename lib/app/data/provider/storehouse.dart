import 'dart:io';

import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/data/model/item_model.dart';
import 'package:mcap_orders_app/app/data/model/order_item_model.dart';
import 'package:mcap_orders_app/app/modules/add_order/add_order_controller.dart';
import 'package:mcap_orders_app/app/utils/show_snackbar.dart';
import 'package:path_provider/path_provider.dart';

import '../../utils/connection_status.dart';

class Storehouse {
  static final storage = FirebaseStorage.instance;

  static Reference get itemsFileRef => storage.ref("/items.xlsx");

  static Future<File?> _getItems([bool cached = false]) async {
    File localFile;
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      localFile = File('${appDocDir.path}/items.xlsx');

      if (await localFile.exists()) {
        return localFile;
      }

      // if (localFile.existsSync()) await localFile.delete();

      if (ConnectionStatus.i.hasConnection) {
        var metaData = await itemsFileRef.getMetadata();

        if (await localFile.exists()) {
          DateTime lastUpdated = await localFile.lastModified();
          if (metaData.updated!.isAfter(lastUpdated)) {
            print(">>>>>>>> ITEMS: updating... <<<<<<<<");
            await _downloadFile(localFile);
          } else {
            print(">>>>>>>> ITEMS: up to date <<<<<<<<");
            const ShowSnackbar(
              message: "لديك اخر تحديث",
              icon: Icons.download_done_sharp,
            ).success();
          }
          return localFile;
        } else {
          await _downloadFile(localFile);
          return localFile;
        }
      } else {
        ConnectionStatus.i.isConnected();
        return localFile;
      }
    } on Exception catch (e) {
      print(e);
      return null;
    }
  }

  static Future<TaskSnapshot?> _downloadFile(File file) async {
    print(">>>>>>>> Creating & Downloading ITEMS file... <<<<<<<<");
    const ShowSnackbar(
      message: "يتم تحديث المخزن...",
      icon: Icons.download,
    ).info();

    try {
      return await itemsFileRef.writeToFile(file);
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  static Future<List<OrderItem>?> getListOfItems({bool cached = false}) async {
    var list = <OrderItem>[];

    try {
      final excelFile = await Storehouse._getItems(cached);

      if (excelFile == null || !await excelFile.exists()) return null;

      var bytes = excelFile.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      final orderCtrl = Get.find<AddOrderController>();

      for (var row in excel.tables.values.first.rows) {
        if (row.first != null && row.first!.value == "id") continue;
        var item = OrderItem(data: Item.fromExcelRow(row));
        for (var orderItem in orderCtrl.items) {
          if (orderItem.id == item.id) {
            item.selected = true;
          }
        }

        list.add(item);
      }
    } catch (e) {
      print(e);
    }

    return list;
  }
}
