import 'dart:async'; //For StreamController/Stream
import 'dart:io'; //InternetAddress utility

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/utils/show_snackbar.dart';

class ConnectionStatus extends GetxService {
  //This tracks the current connection status
  final _hasConnection = false.obs;
  bool get hasConnection => _hasConnection.value;
  set hasConnection(bool value) => _hasConnection.value = value;

  static ConnectionStatus get i => Get.find<ConnectionStatus>();

  //This is how we'll allow subscribing to connection changes
  final _connectionChangeController = StreamController.broadcast();

  //flutter_connectivity
  final _connectivity = Connectivity();

  Stream get connectionChange => _connectionChangeController.stream;

  @override
  void onInit() {
    //Hook into flutter_connectivity's Stream to listen for changes
    //And check the connection status out of the gate
    _connectivity.onConnectivityChanged.listen(_connectionChange);
    isConnected();
    super.onInit();
  }

  //A clean up method to close our StreamController
  //   Because this is meant to exist through the entire application life cycle this isn't
  //   really an issue
  @override
  void onClose() {
    _connectionChangeController.close();
  }

  //flutter_connectivity's listener
  void _connectionChange(ConnectivityResult result) {
    isConnected(true, true);
  }

  //The test to actually see if there is a connection
  Future<bool> isConnected(
      [bool notifyConnected = false, bool notifyNotConnected = false]) async {
    bool previousConnection = hasConnection;

    try {
      final result = await InternetAddress.lookup('google.com')
          .onError((error, stackTrace) {
        return [];
      });
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        hasConnection = true;

        if (notifyConnected) {
          const ShowSnackbar(
            message: "تم الاتصال بالانترنت",
            icon: Icons.wifi,
          ).success();
        }
      } else {
        hasConnection = false;

        if (notifyNotConnected) {
          const ShowSnackbar(
            message: "لا يوجد اتصال بالانترنت",
            icon: Icons.wifi_off,
          ).error();
        }
      }
    } on SocketException catch (_) {
      hasConnection = false;
    }

    //The connection status changed send out an update to all listeners
    if (previousConnection != hasConnection) {
      _connectionChangeController.add(hasConnection);
    }

    // print("*** connected: [$hasConnection] ***",);

    return hasConnection;
  }
}
