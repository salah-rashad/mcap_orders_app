import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mcap_orders_app/app/consts/consts.dart';
import 'package:mcap_orders_app/app/data/model/order_model.dart';
import 'package:mcap_orders_app/app/data/model/report_model.dart';
import 'package:mcap_orders_app/app/data/provider/auth.dart';
import 'package:mcap_orders_app/app/routes/app_routes.dart';
import 'package:mcap_orders_app/app/theme/color_theme.dart';

class FCM {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static const ordersChannel = AndroidNotificationChannel(
    'order_notification', // id
    'إشعارات الطلبيات الجديدة', // title
    description: 'هذه القناة تستخدم لإستقبال إشعارات الطلبيات الجديدة.',
    importance: Importance.max,
    enableVibration: true,
    playSound: true,
    showBadge: true,
  );

  static const reportsChannel = AndroidNotificationChannel(
    'report_notification', // id
    'إشعارات التقارير الجديدة', // title
    description: 'هذه القناة تستخدم لإستقبال إشعارات التقارير الجديدة.',
    importance: Importance.max,
    enableVibration: true,
    playSound: true,
    showBadge: true,
  );

  /* ************************************** */

  static Future<void> init() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings("icon"),
      ),
      onSelectNotification: _onSelectNotification,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(ordersChannel);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(reportsChannel);

    //! ********************** ON MESSAGE ************************** */

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      print("object");

      // If `onMessage` is triggered with a notification, construct our own
      // local notification to show to users using the created channel.
      if (notification != null && android != null) {
        if (Auth.i.isManager) {
          if (message.data.containsKey("order")) {
            flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  ordersChannel.id,
                  ordersChannel.name,
                  channelDescription: ordersChannel.description,
                  icon: android.smallIcon,
                  enableVibration: true,
                  importance: Importance.max,
                  playSound: true,
                  color: Palette.primaryColor,
                  showWhen: true,
                  when: int.tryParse(message.data['when']),
                ),
              ),
              payload: json.encode(
                {
                  "isOrder": true,
                  "data": message.data['order'],
                },
              ),
            );
          } else if (message.data.containsKey("report")) {
            flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  reportsChannel.id,
                  reportsChannel.name,
                  channelDescription: reportsChannel.description,
                  icon: android.smallIcon,
                  enableVibration: true,
                  importance: Importance.max,
                  playSound: true,
                  color: Palette.primaryColor,
                  showWhen: true,
                  when: int.tryParse(message.data['when']),
                ),
              ),
              payload: json.encode(
                {
                  "isReport": true,
                  "data": message.data['report'],
                },
              ),
            );
          }
        }
      }
    });

    //! ******************** ON MESSAGE [OPENED APP] ************************** */

    /* FirebaseMessaging.onMessageOpenedApp.listen((message) {
      RemoteNotification? notification = message.notification;
      
      Order order = Order.fromJson(message.data['order']);

      final newOrders = Get.find<HomeController>().newOrders;

      Get.generalDialog(
        pageBuilder: (context, animation, secondaryAnimation) {
          return Dialog(
            backgroundColor: Colors.white,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/images/mailbox.png"),
                Text(
                  notification?.title ?? "لديك طلبية جديدة",
                  style: TextStyle(
                    fontSize: 22.0,
                  ),
                ),
                Text(notification!.body!),
                ButtonBar(
                  children: [
                    ElevatedButton(
                      onPressed: () => Get.toNamed(Routes.TODAY_ORDERS,
                          parameters: {
                            "init_tab": newOrders
                                .indexWhere((o) => o.id == order.id)
                                .toString()
                          }),
                      child: const Text("فتح الطلبية"),
                    )
                  ],
                )
              ],
            ),
          );
        },
      );
    }); */

    if (Auth.i.isManager) {
      await messaging.subscribeToTopic(Consts.ORDERS_NOTIFICATIONS_TOPIC_ID);
      await messaging.subscribeToTopic(Consts.REPORTS_NOTIFICATIONS_TOPIC_ID);
    }
  }

  //! ********************** SEND NOTIFICATION ************************** */

  static Future<bool> sendOrderNotification({
    required String title,
    required String body,
    required Order order,
  }) async {
    String toParams = "/topics/" + Consts.ORDERS_NOTIFICATIONS_TOPIC_ID;

    final data = {
      "notification": {
        "title": title,
        "body": body,
      },
      "priority": "high",
      // // "badge": ,
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "sound": 'default',
        "screen": Routes.NEW_ORDERS,
        "when": order.timeCreated!.millisecondsSinceEpoch,
        "order": order.toJson(),
      },
      "to": toParams
    };

    return await _postNotification(data);
  }

  static Future<bool> sendReportNotification({
    required String title,
    required String body,
    required Report report,
  }) async {
    String toParams = "/topics/" + Consts.REPORTS_NOTIFICATIONS_TOPIC_ID;

    final data = {
      "notification": {
        "title": title,
        "body": body,
      },
      "priority": "high",
      // // "badge": ,
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "sound": 'default',
        "screen": Routes.NEW_REPORTS,
        "when": report.timeCreated!.millisecondsSinceEpoch,
        "report": report.toJson(),
      },
      "to": toParams
    };

    return await _postNotification(data);
  }

  static Future<bool> _postNotification(Map<String, Object> data) async {
    const postUrl = 'https://fcm.googleapis.com/fcm/send';

    final headers = {
      'content-type': 'application/json; charset=UTF-8',
      'Authorization': 'key=' + Consts.FCM_TOKEN,
    };

    try {
      final response = await http.post(
        Uri.parse(postUrl),
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // on success do
        print("notification sent");
        return true;
      } else {
        // on failure do
        print("notification failed: [${response.statusCode.toString()}]: " +
            response.reasonPhrase!);
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future _onSelectNotification(String? payload) async {
    if (payload == null) return;

    var data = json.decode(payload);

    print(data['data']);

    if (data["isOrder"]) {
      Order order = Order.fromJson(data['data']);

      // WidgetsFlutterBinding.ensureInitialized();
      _showOrderDialog(order);
    } else if (data["isReport"]) {
      Report report = Report.fromJson(data['data']);

      // WidgetsFlutterBinding.ensureInitialized();
      _showReportDialog(report);
    }
  }

  static Future<void> _showOrderDialog(Order order) async {
    return Get.generalDialog(
      pageBuilder: (context, animation, secondaryAnimation) {
        return Dialog(
          backgroundColor: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/images/mailbox.png"),
              const Text(
                "طلبية جديدة",
                style: TextStyle(
                  fontSize: 22.0,
                ),
              ),
              Text(order.dateAndTimeFormatted),
              const SizedBox(
                height: 16.0,
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back(closeOverlays: true);
                  Get.toNamed(
                    Routes.NEW_ORDERS,
                    parameters: {
                      "init_order_id": order.id ?? "",
                    },
                  );
                },
                child: const Text(
                  "فتح الطلبية",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60.0),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _showReportDialog(Report report) async {
    return Get.generalDialog(
      pageBuilder: (context, animation, secondaryAnimation) {
        return Dialog(
          backgroundColor: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/images/notify.png"),
              const Text(
                "تقرير جديد",
                style: TextStyle(
                  fontSize: 22.0,
                ),
              ),
              Text(report.dateAndTimeFormatted),
              const SizedBox(
                height: 16.0,
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back(closeOverlays: true);
                  Get.toNamed(
                    Routes.NEW_REPORTS,
                    parameters: {
                      "init_order_id": report.id!,
                    },
                  );
                },
                child: const Text(
                  "فتح التقرير",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60.0),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
