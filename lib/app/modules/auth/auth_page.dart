import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/data/provider/auth.dart';
import 'package:mcap_orders_app/app/modules/home/home_page.dart';
import 'package:mcap_orders_app/app/modules/login/login_page.dart';

class AuthPage extends GetView<Auth> {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
        () => controller.isSignedIn ? const HomePage() : const LoginPage());
  }
}
