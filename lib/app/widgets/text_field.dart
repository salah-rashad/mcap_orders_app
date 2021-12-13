import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CustomTextFormField extends StatelessWidget {
  final bool? enabled;
  final TextEditingController? controller;
  final TextAlign textAlign;
  final TextInputType? keyboardType;
  final TextDirection textDirection;
  final String? labelText;
  final Widget? prefix;
  final Widget? suffix;
  final int? maxLength;
  final int? maxLines;
  final Widget? counter;

  final FormFieldValidator<String?>? validator;
  final Function(String)? onSubmitted;
  final Iterable<String>? autoFillHints;

  final bool _isPhoneNumber;

  const CustomTextFormField({
    Key? key,
    this.enabled,
    this.controller,
    this.labelText,
    this.textAlign = TextAlign.start,
    this.keyboardType,
    this.textDirection = TextDirection.rtl,
    this.prefix,
    this.suffix,
    this.maxLength,
    this.maxLines,
    this.counter,
    this.validator,
    this.onSubmitted,
    this.autoFillHints,
  })  : _isPhoneNumber = false,
        super(key: key);

  const CustomTextFormField.phoneNumber({
    Key? key,
    this.enabled,
    this.controller,
    this.labelText = "رقم الموبايل",
    this.textAlign = TextAlign.left,
    this.keyboardType = TextInputType.phone,
    this.textDirection = TextDirection.ltr,
    this.prefix = const Text(
      "🇪🇬  +20",
      style: TextStyle(fontSize: 16.0),
    ),
    this.suffix,
    this.maxLength = 10,
    this.maxLines,
    this.counter,
    this.validator,
    this.onSubmitted,
    this.autoFillHints,
  })  : _isPhoneNumber = true,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Directionality(
        textDirection: textDirection,
        child: TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          enabled: enabled,
          autofillHints: autoFillHints,
          controller: controller,
          textAlign: textAlign,
          keyboardType: keyboardType,
          onFieldSubmitted: onSubmitted,
          textDirection: textDirection,
          enableSuggestions: true,
          textAlignVertical: TextAlignVertical.top,
          inputFormatters: [
            if (_isPhoneNumber)
              FilteringTextInputFormatter.allow(RegExp("[0-9]")),
            if (_isPhoneNumber) FilteringTextInputFormatter.deny(RegExp("^0")),
          ],
          decoration: InputDecoration(
            labelText: labelText,
            alignLabelWithHint: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            isDense: true,
            prefixIcon: prefix != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: prefix,
                  )
                : null,
            suffixIcon: suffix != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: suffix,
                  )
                : _isPhoneNumber
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: IconButton(
                          onPressed: chooseContact,
                          icon: const Icon(Icons.contacts_rounded),
                        ),
                      )
                    : null,
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            counter: counter,
          ),
          maxLength: maxLength,
          expands: true,
          maxLines: maxLines,
          validator: validator ??
              (_isPhoneNumber
                  ? (value) {
                      final phone = "+20" + value!;
                      if (phone.length != 13) {
                        return "الرقم غير صحيح";
                      }
                    }
                  : null),
        ),
      ),
    );
  }

  Future chooseContact() async {
    try {
      final PhoneContact contact =
          await FlutterContactPicker.pickPhoneContact();

      var text = contact.phoneNumber!.number!
          .replaceAll(RegExp(r"(\s)|(\+20)|(\-)|(^0)"), "");

      if (text.length == 10) {
        controller!.text = text;
      } else {
        Fluttertoast.showToast(msg: "هذا الرقم لا يمكن استخدامه");
      }
    } catch (e) {
      print(e);
    }
  }
}
