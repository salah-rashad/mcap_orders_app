// import 'package:get/get.dart';
// import 'package:mcap_orders_app/app/consts/consts.dart';
// import 'package:mcap_orders_app/app/data/provider/auth.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';

// class OneSignalManager {
//   static final _authCtrl = Get.find<Auth>();

//   static Future<void> init() async {
//     //Remove this method to stop OneSignal Debugging
//     await OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

//     await OneSignal.shared.setAppId(Consts.ONE_SIGNAL_APP_ID);

//     // The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
//     await OneSignal.shared
//         .promptUserForPushNotificationPermission()
//         .then((accepted) {
//       print("Accepted permission: $accepted");
//     });

//     await OneSignal.shared.setLanguage("ar");

//     await OneSignal.shared.setExternalUserId(Auth.auth.currentUser!.uid);

//     if (_authCtrl.isAdmin) {
//       await OneSignal.shared.sendTag("isAdmin", "true");
//       await OneSignal.shared.addTrigger("isSignedIn", true);
//     }

//     await OneSignal.shared.postNotification(
//       OSCreateNotification(
//         playerIds: ["cd49a71c-4e5c-11ec-bf17-eaffddb39efd"],
//         content: "Hello guys",
//         androidSmallIcon: "icon",
//         buttons: [
//           OSActionButton(id: "open", text: "Open", icon: "icon"),
//         ],
//       ),
//     );
//   }
// }
