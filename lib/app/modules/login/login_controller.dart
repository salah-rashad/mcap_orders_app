import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/data/provider/auth.dart';

int maxTimerSeconds = 60;

class LoginController extends GetxController {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  String? verificationId;

  final Rx<Timer> _timer = Timer(0.seconds, () {}).obs;
  Timer get timer => _timer.value;
  set timer(Timer value) => _timer.value = value;

  final RxInt _countdown = maxTimerSeconds.obs;
  int get countdown => _countdown.value;
  set countdown(int value) => _countdown.value = value;

  /* *********** */

  // int get minutes => countdown.minute;
  // int get seconds => countdown.second;

  /* *********** */

  final RxBool _codeSent = false.obs;
  bool get codeSent => _codeSent.value;
  set codeSent(bool value) => _codeSent.value = value;

  /* *********** */

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) => _isLoading.value = value;

  /* *********** */

  bool get resendEnabled => countdown <= 0;

  /* ************ */

  final formKey = GlobalKey<FormState>();

  /* ************************************************************************ */

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;
    await Auth.i.phoneSignIn(phoneNumber: phoneController.text);
  }

  ////////////////////////////////////////

  Future<void> verify() async {
    final code = otpController.text;
    otpController.clear();

    isLoading = true;

    var credential = PhoneAuthProvider.credential(
      verificationId: verificationId!,
      smsCode: code,
    );

    await Auth.i.loginWithPhone(credential);
    isLoading = false;
  }

  ////////////////////////////////////////

  void startTimer() {
    countdown = maxTimerSeconds;
    timer = Timer.periodic(
      1.seconds,
      (Timer timer) {
        if (countdown == 0) {
          timer.cancel();
          isLoading = false;
        } else {
          if (!codeSent) {
            isLoading = true;
          }
          countdown--;
        }
      },
    );
  }
}
