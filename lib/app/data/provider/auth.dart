import 'dart:async';
import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/consts/consts.dart';
import 'package:mcap_orders_app/app/data/model/order_model.dart';
import 'package:mcap_orders_app/app/data/model/report_model.dart';
import 'package:mcap_orders_app/app/data/model/user_model.dart';
import 'package:mcap_orders_app/app/data/model/user_role_model.dart';
import 'package:mcap_orders_app/app/data/provider/fcm.dart';
import 'package:mcap_orders_app/app/modules/login/login_controller.dart';
import 'package:mcap_orders_app/app/routes/app_routes.dart';
import 'package:mcap_orders_app/app/theme/color_theme.dart';
import 'package:mcap_orders_app/app/utils/connection_status.dart';
import 'package:mcap_orders_app/app/utils/show_snackbar.dart';
import 'package:sms_autofill/sms_autofill.dart';

import 'database.dart';

class Auth extends GetxService {
  static FirebaseAuth auth = FirebaseAuth.instance;

  LoginController get _loginCtrl => Get.find<LoginController>();
  static Auth get i => Get.find<Auth>();

  final _isSignedIn = false.obs;
  bool get isSignedIn => _isSignedIn.value;
  set isSignedIn(bool value) => _isSignedIn.value = value;

  /* ************** */

  RoleType? get userRole => userData?.role?.type;

  bool get isManager => userData?.role?.type == RoleType.MANAGER;
  bool get isSupervisor => userData?.role?.type == RoleType.SUPERVISOR;
  bool get isOutletManager => userData?.role?.type == RoleType.OUTLET_MANAGER;
  bool get isCustomer => userData?.role?.type == RoleType.CUSTOMER;

  /* ************** */

  final _userData = UserModel.empty.obs;
  UserModel? get userData => _userData.value;
  set userData(UserModel? value) => _userData.value = value;

  User? get user => auth.currentUser;

  /* ************** */

  late StreamSubscription<QuerySnapshot<Order>> newOrdersStream;
  late StreamSubscription<QuerySnapshot<Report>> newReportsStream;

  /* ************** */

  final _newOrders = <Order>[].obs;
  List<Order> get newOrders => _newOrders;
  set newOrders(List<Order> value) => _newOrders.assignAll(value);

  /* ************** */

  final _newReports = <Report>[].obs;
  List<Report> get newReports => _newReports;
  set newReports(List<Report> value) => _newReports.assignAll(value);

  /* ************************************************************************ */

  @override
  void onInit() {
    auth.authStateChanges().listen((User? user) {
      isSignedIn = user != null;

      print("*** Singed In: [$isSignedIn] ***");

      if (!isSignedIn) {
        try {
          newOrdersStream.cancel();
          newReportsStream.cancel();
        } catch (e) {
          print(e);
        }
      }

      if (isSignedIn && isManager) {
        try {
          final ordersStream = Database.ordersColl
              .where("isDone", isEqualTo: false)
              .orderBy("timeCreated", descending: true)
              .snapshots()
              .asBroadcastStream();
          final reportsStream = Database.reportsColl
              .where("isRead", isEqualTo: false)
              .orderBy("timeCreated", descending: true)
              .snapshots()
              .asBroadcastStream();

          Auth.i.newOrdersStream = ordersStream.listen(
            (event) {
              newOrders = event.docs.map((e) => e.data()).toList();
            },
          );
          Auth.i.newReportsStream = reportsStream.listen(
            (event) {
              newReports = event.docs.map((e) => e.data()).toList();
            },
          );
        } catch (e) {
          print(e);
        }
      }
    });

    super.onInit();
  }

  ////////////////////////////////////////

  Future<void> loginWithPhone(PhoneAuthCredential credential) async {
    try {
      await Auth.auth.signInWithCredential(credential).then((value) async {
        final user = value.user;

        if (user != null) {
          Auth.i.userData = await Database.getUser(user.phoneNumber!);

          await Database.usersColl.doc(user.phoneNumber).update({
            "uid": user.uid,
          });
        }
      });
    } on FirebaseAuthException catch (exception) {
      String? message = "";
      if (exception.code == 'invalid-verification-code') {
        message = "الكود الذي أدخلته غير صحيح!";
      } else if (exception.message!.contains('network')) {
        message = "لا يوجد إتصال بالانترنت";
      } else {
        if (exception.message!.contains('expired')) {
          message = "انتهت صلاحية العملية، يجب إعادة إرسال الكود.";
        } else {
          message = exception.message;
        }
      }

      ShowSnackbar(message: message).error();
    } catch (e) {
      Get.printError(info: e.toString());
    }
  }

  ////////////////////////////////////////

  Future<void> phoneSignIn({required String phoneNumber}) async {
    _loginCtrl.isLoading = true;

    if (await ConnectionStatus.i.isConnected()) {
      final fullPhoneNumber = "+20$phoneNumber";

      if (!await isUserExists(fullPhoneNumber)) {
        const ShowSnackbar(
          message: "هذا الرقم غير مسجل، تأكد من الرقم.",
        ).error();
        _loginCtrl.isLoading = false;
        return;
      } else {
        await auth.verifyPhoneNumber(
          phoneNumber: fullPhoneNumber,
          verificationCompleted: _onVerificationCompleted,
          verificationFailed: _onVerificationFailed,
          codeSent: _onCodeSent,
          codeAutoRetrievalTimeout: _onCodeTimeout,
          timeout: maxTimerSeconds.seconds,
        );
        return;
      }
    }

    _loginCtrl.isLoading = false;
  }

  ////////////////////////////////////////

  _onVerificationCompleted(PhoneAuthCredential credential) async {
    print("verification completed ${credential.smsCode}");

    var smsCode = credential.smsCode;

    if (smsCode != null) {
      _loginCtrl.otpController.text = smsCode;
      print("************************************");

      await loginWithPhone(credential);
      _loginCtrl.isLoading = false;
    }
  }

  ////////////////////////////////////////

  _onVerificationFailed(FirebaseAuthException exception) {
    String? message = "";
    if (exception.code == 'invalid-phone-number') {
      message = "الرقم الذي أدخلته غير صحيح!";
    } else if (exception.message!.contains('network')) {
      message = "لا يوجد إتصال بالانترنت";
    } else {
      message = exception.message;
    }

    ShowSnackbar(message: message).error();
    _loginCtrl.isLoading = false;
  }

  ////////////////////////////////////////

  _onCodeSent(String verificationId, int? forceResendingToken) async {
    _loginCtrl.isLoading = false;
    _loginCtrl.codeSent = true;
    _loginCtrl.verificationId = verificationId;

    _loginCtrl.startTimer();

    print("**** code sent");

    SmsAutoFill().listenForCode();
  }

  ////////////////////////////////////////

  _onCodeTimeout(String timeout) {
    _loginCtrl.codeSent = false;
    _loginCtrl.isLoading = false;
    _loginCtrl.timer.cancel();
  }

  ////////////////////////////////////////

  Future<bool> isUserExists(String phoneNumber) async {
    try {
      return await Database.usersColl.doc(phoneNumber).get().then((value) {
        print("User Exists: [${value.exists}]");
        return value.exists;
      });
    } catch (e) {
      print(e);
      _loginCtrl.isLoading = false;
      return false;
    }
  }

  ////////////////////////////////////////

  Future<void> signOut({bool forced = false}) async {
    if (!forced) {
      return Get.defaultDialog(
        title: "تسجيل الخروج",
        middleText: "هل انت متأكد من تسجيل الخروج؟",
        textConfirm: "نعم",
        textCancel: "إلغاء",
        onConfirm: () => signOut(forced: true),
        confirmTextColor: Palette.white,
        cancelTextColor: Palette.black,
        buttonColor: Palette.RED,
      );
    }

    try {
      await auth.signOut();
      _loginCtrl.codeSent = false;
      _loginCtrl.verificationId = null;
      userData = UserModel.empty;

      FCM.messaging.unsubscribeFromTopic(Consts.ORDERS_NOTIFICATIONS_TOPIC_ID);
      FCM.messaging.unsubscribeFromTopic(Consts.REPORTS_NOTIFICATIONS_TOPIC_ID);

      try {
        newOrdersStream.cancel();
        newReportsStream.cancel();
      } catch (e) {
        print(e);
      }

      Get.until((route) => Get.currentRoute == Routes.HOME_or_AUTH);
      Get.forceAppUpdate();
    } catch (e) {
      print(e);
    }
    Get.back(closeOverlays: true);
  }

  ////////////////////////////////////////

}
