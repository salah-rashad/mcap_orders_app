import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/data/model/outlet_model.dart';
import 'package:mcap_orders_app/app/data/model/user_model.dart';
import 'package:mcap_orders_app/app/data/provider/database.dart';
import 'package:mcap_orders_app/app/theme/color_theme.dart';

class AllOutletsController extends GetxController {
  Future<void> editOutlet(Outlet outlet) async {
    final mods = outlet.moderators;
    return await Get.dialog(
      Center(
        child: Card(
          color: Palette.cardBG,
          margin: const EdgeInsets.symmetric(
            horizontal: 32.0,
            vertical: 16.0,
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            constraints: BoxConstraints(
              maxHeight: Get.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  outlet.name!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22.0,
                  ),
                ),
                Flexible(
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "المشرفين:",
                            style: TextStyle(fontSize: 16.0),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.person_add_alt_1_rounded,
                              color: Colors.black54,
                            ),
                            visualDensity: VisualDensity.compact,
                            splashRadius: 18.0,
                          )
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: mods != null && mods.isNotEmpty
                            ? SizedBox(
                                height: Get.height * 0.5,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    itemCount: mods.length,
                                    itemBuilder: (ctx, i) {
                                      return FutureBuilder<UserModel?>(
                                        future: Database.getUser(mods[i]),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          } else if (snapshot.connectionState ==
                                              ConnectionState.done) {
                                            if (snapshot.hasError) {
                                              return const Text('Error');
                                            } else if (snapshot.hasData) {
                                              final user = snapshot.data!;
                                              return ListTile(
                                                title: Text(user.name!),
                                                subtitle: Text(user.phone!),
                                                dense: true,
                                                visualDensity:
                                                    VisualDensity.compact,
                                                trailing: IconButton(
                                                  onPressed: () async {
                                                    await Database.removeAdmin(
                                                        outlet, user.name!);
                                                    update();
                                                  },
                                                  icon: const Icon(Icons
                                                      .delete_forever_rounded),
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  splashRadius: 24.0,
                                                ),
                                              );
                                            } else {
                                              return const Text(
                                                "المنفذ لا يحتوي على مشرفين.",
                                              );
                                            }
                                          } else {
                                            return Text(
                                                'State: ${snapshot.connectionState}');
                                          }
                                        },
                                      );
                                    }),
                              )
                            : const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("المنفذ لا يحتوي على مشرفين."),
                              ),
                      ),
                    ],
                  ),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text("إلغاء"),
                      style: TextButton.styleFrom(
                        primary: Colors.black87,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        update();
                        Get.back();
                      },
                      icon: const Icon(Icons.done_rounded),
                      label: const Text("حفظ"),
                      style: TextButton.styleFrom(
                        primary: Palette.white,
                        backgroundColor: Palette.adminBackgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      useSafeArea: true,
    );
  }

  Future<void> hideOutlet(Outlet outlet) async {
    final message = """
سيتم إخفاء منفذ ${outlet.name} ،
لن يظهر هذا المنفذ للمشرفين.
(يمكنك إظهار المنفذ مرة أخرى)""";

    return await Get.defaultDialog(
      title: "تحذير",
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      backgroundColor: Palette.cardBG,
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text("إلغاء"),
          style: TextButton.styleFrom(
            primary: Colors.black87,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            await Database.disableOutlet(outlet);
            update();
            Get.back();
          },
          icon: const Icon(Icons.remove_circle_rounded),
          label: const Text("إخفاء"),
          style: TextButton.styleFrom(
            primary: Palette.white,
            backgroundColor: Palette.RED,
          ),
        )
      ],
    );
  }
}
