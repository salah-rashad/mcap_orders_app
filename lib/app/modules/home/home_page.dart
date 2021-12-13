import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/data/provider/auth.dart';
import 'package:mcap_orders_app/app/routes/app_routes.dart';

import 'home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<HomeController>(
        init: HomeController(),
        builder: (controller) {
          return WillPopScope(
            onWillPop: () {
              if (controller.popTimer != null &&
                  controller.popTimer!.isActive) {
                return Future.value(true);
              } else {
                Fluttertoast.showToast(
                  msg: "اضغط زر الرجوع مرة أخرى لإغلاق التطبيق.",
                  gravity: ToastGravity.BOTTOM,
                  toastLength: Toast.LENGTH_LONG,
                );

                controller.popTimer = Timer(3.seconds, () {});
                return Future.value(false);
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: const Text("المصرية"),
              ),
              body: SingleChildScrollView(
                child: Column(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Auth.i.user!.phoneNumber!,
                            style: const TextStyle(fontSize: 16.0),
                            textDirection: TextDirection.ltr,
                          ),
                          Text(
                            Auth.i.userData!.name!,
                            style: const TextStyle(fontSize: 22.0),
                          ),
                        ],
                      ),
                    ),
                    if (Auth.i.isManager && Auth.i.newOrders.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 16.0,
                          right: 16.0,
                          left: 16.0,
                        ),
                        child: Center(
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            tileColor: Colors.amber,
                            onTap: () => Get.toNamed(Routes.NEW_ORDERS),
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            title: Obx(() => Text(
                                  "لديك (${Auth.i.newOrders.length}) طلبية جديدة",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18.0,
                                    color: Colors.blueGrey.shade800,
                                  ),
                                )),
                            leading: Obx(
                              () => AnimatedOpacity(
                                duration: 800.milliseconds,
                                curve: Curves.easeInOutCirc,
                                opacity: controller.blinking ? 1.0 : 0.4,
                                child: Icon(
                                  Icons.new_releases_rounded,
                                  color: Colors.blueGrey.shade800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Obx(() {
                      if (Auth.i.userRole == null) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (Auth.i.isManager) {
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 16 / 12,
                          ),
                          padding: const EdgeInsets.only(
                            right: 16.0,
                            left: 16.0,
                            bottom: 32.0,
                          ),
                          itemCount: controller.managerButtons.length,
                          itemBuilder: (context, index) {
                            final item = controller.managerButtons[index];

                            if (item == null) return Container();
                            return item;
                          },
                        );
                      } else {
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 16 / 12,
                          ),
                          padding: const EdgeInsets.only(
                            right: 16.0,
                            left: 16.0,
                            bottom: 32.0,
                          ),
                          itemCount: controller.mainButtons.length,
                          itemBuilder: (context, index) {
                            final item = controller.mainButtons[index];

                            if (item == null) return Container();
                            return item;
                          },
                        );
                      }
                    }),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
