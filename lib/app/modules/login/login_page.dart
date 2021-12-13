import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mcap_orders_app/app/data/provider/auth.dart';
import 'package:mcap_orders_app/app/theme/color_theme.dart';
import 'package:mcap_orders_app/app/widgets/text_field.dart';
import 'package:sms_autofill/sms_autofill.dart';

import 'login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(
            () => !controller.codeSent ? phoneForm() : verificationForm(),
          ),
        ),
      ),
    );
  }

  Widget phoneForm() {
    return Form(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "المصرية للإنتاج الحيواني",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 27.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 64),
              const Text(
                "أدخل رقم موبايلك",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22.0),
              ),
              const SizedBox(height: 32),
              Form(
                key: controller.formKey,
                child: CustomTextFormField.phoneNumber(
                  enabled: !controller.isLoading,
                  controller: controller.phoneController,
                  onSubmitted: (_) => controller.login(),
                ),
              ),
              const SizedBox(height: 16.0),
              Obx(() => !controller.isLoading
                  ? ElevatedButton(
                      onPressed: controller.login,
                      child: const Text("المتابعة"),
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(60.0)),
                    )
                  : !controller.codeSent && controller.timer.isActive
                      ? Obx(
                          () => Text(
                            controller.countdown.seconds
                                .toString()
                                .split(".")[0],
                            textAlign: TextAlign.center,
                          ),
                        )
                      : const Center(child: CircularProgressIndicator())),
            ],
          ),
        ),
      ),
    );
  }

  Widget verificationForm() {
    return Form(
      child: Center(
        child: SingleChildScrollView(
          child: Obx(
            () => !controller.isLoading
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          "تم إرسال كود التأكيد على الرقم\n+20${controller.phoneController.text}",
                          style: const TextStyle(fontSize: 22.0),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Auth.i.signOut(forced: true);
                        },
                        label: const Text("تعديل الرقم"),
                        icon: const Icon(Icons.edit),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(120, 40),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        "يرجى إدخال الكود المكون من 6 أرقام",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22.0),
                      ),
                      const SizedBox(height: 32),
                      PinFieldAutoFill(
                        controller: controller.otpController,
                        autoFocus: true,
                        cursor: Cursor(
                          enabled: true,
                          color: Colors.black,
                          width: 2.0,
                          height: 20.0,
                          radius: const Radius.circular(30.0),
                        ),
                        onCodeSubmitted: (code) {
                          print("submitted");
                        },
                        onCodeChanged: (code) {
                          if (code != null) {
                            if (code.length == 6) {
                              controller.verify();
                            }
                          }
                        },
                        codeLength: 6,
                      ),
                      const SizedBox(height: 64.0),
                      Obx(
                        () {
                          return controller.countdown > 0
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    const Flexible(
                                      child: Text(
                                        "يمكنك إعادة إرسال الكود بعد إنتهاء الوقت",
                                      ),
                                    ),
                                    Obx(
                                      () => Text(
                                        controller.countdown.seconds
                                            .toString()
                                            .split(".")[0],
                                      ),
                                    ),
                                  ],
                                )
                              : ElevatedButton.icon(
                                  onPressed: controller.login,
                                  label: const Text("إعادة إرسال الكود"),
                                  icon: const Icon(Icons.refresh_rounded),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(60.0),
                                  ),
                                );
                        },
                      ),
                    ],
                  )
                : const CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
