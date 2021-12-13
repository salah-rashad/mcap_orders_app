import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShowSnackbar {
  final String? message;
  final IconData? icon;
  final Widget? mainButton;
  final Duration? duration;

  const ShowSnackbar({this.message, this.icon, this.mainButton, this.duration});

  void success() async {
    Get.rawSnackbar(
      icon: Icon(
        icon ?? Icons.done_rounded,
        color: Colors.green,
      ),
      duration: duration ?? 7.seconds,
      mainButton: mainButton,
      messageText: Text(
        message ?? "",
        style: const TextStyle(
          color: Colors.green,
        ),
      ),
      dismissDirection: SnackDismissDirection.HORIZONTAL,
    );
  }

  void error() async {
    Get.rawSnackbar(
      icon: Icon(
        icon ?? Icons.error,
        color: Colors.red,
      ),
      duration: duration ?? 7.seconds,
      mainButton: mainButton,
      messageText: Text(
        message ?? "",
        style: const TextStyle(
          color: Colors.red,
        ),
      ),
      dismissDirection: SnackDismissDirection.HORIZONTAL,
    );
  }

  void warning() async {
    Get.rawSnackbar(
      icon: Icon(
        icon ?? Icons.warning,
        color: Colors.amber,
      ),
      duration: duration ?? 7.seconds,
      mainButton: mainButton,
      messageText: Text(
        message ?? "",
        style: const TextStyle(
          color: Colors.amber,
        ),
      ),
      dismissDirection: SnackDismissDirection.HORIZONTAL,
    );
  }

  void info() async {
    Get.rawSnackbar(
      icon: Icon(
        icon ?? Icons.info,
        color: Colors.blue,
      ),
      duration: duration ?? 7.seconds,
      mainButton: mainButton,
      messageText: Text(
        message ?? "",
        style: const TextStyle(
          color: Colors.blue,
        ),
      ),
      dismissDirection: SnackDismissDirection.HORIZONTAL,
    );
  }
}
