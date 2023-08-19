// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:memories_frontend_flutter/helpers/colors.dart';

class AppTextField extends StatelessWidget {

    final TextEditingController controller;
    String hintText;
    IconData prefixIcon;
    IconData? suffixIcon;
    Function? suffixIconCallBack;
    VoidCallback? textFieldCallBack;
    bool? isPasswordField, isEnabled, autoFocus;
    FocusNode focusNode;
    TextInputType? keyboardType;
    Function(String)? onChanged;


    AppTextField({
        Key? key,
        required this.hintText,
        required this.prefixIcon,
        required this.suffixIcon,
        this.suffixIconCallBack,
        required this.focusNode,
        required this.controller,
        this.isPasswordField,
        this.textFieldCallBack,
        this.keyboardType,
        this.isEnabled,
        this.autoFocus,
        this.onChanged,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Container(
            margin: const EdgeInsetsDirectional.only(bottom: 20),
            child: TextField(
                enabled: isEnabled ?? true,
                autofocus: autoFocus ?? false,
                controller: controller,
                style: const TextStyle(fontSize: 14),
                onTap: textFieldCallBack,
                onChanged: onChanged,
                obscureText: isPasswordField ?? false,
                focusNode: focusNode,
                keyboardType: keyboardType ?? TextInputType.text,
                decoration: InputDecoration(
                    hintText: hintText,
                    focusedBorder: focusedOutlineInputBorder(),
                    enabledBorder: enabledOutlineInputBorder(),
                    disabledBorder: enabledOutlineInputBorder(),
                    prefixIcon: Icon(prefixIcon,
                        color: focusNode.hasFocus
                            ? primary
                            : textColorLight,
                        size: 25),
                    suffixIcon: IconButton(
                    onPressed: () {
                        if (suffixIcon != null) {
                            suffixIconCallBack!();
                        }
                    },
                    icon: Icon(suffixIcon,
                        color: focusNode.hasFocus
                            ? primary
                            : textColorLight,
                        size: 25),
                    ),
                    filled: true,
                    fillColor: focusNode.hasFocus
                        ? primaryLightColor
                        : grey,
                )
            ),
        );
    }
}

class AppTextFieldWithSuffixIcon extends StatelessWidget {
  final TextEditingController? controller;
  String hintText;
  IconData prefixIcon;
  IconData postfixIcon;
  VoidCallback? textFieldCallBack, postfixIconCallBack;
  bool? isPasswordField, isEnabled, autoFocus;
  FocusNode focusNode;
  TextInputType? keyboardType;

  AppTextFieldWithSuffixIcon({
    Key? key,
    required this.hintText,
    required this.prefixIcon,
    required this.focusNode,
    required this.postfixIcon,
    this.controller,
    this.isPasswordField,
    this.postfixIconCallBack,
    this.textFieldCallBack,
    this.keyboardType,
    this.isEnabled,
    this.autoFocus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(bottom: 20),
      child: TextField(
          enabled: isEnabled ?? true,
          autofocus: autoFocus ?? false,
          controller: controller,
          style: const TextStyle(fontSize: 14),
          onTap: textFieldCallBack,
          obscureText: isPasswordField ?? false,
          focusNode: focusNode,
          keyboardType: keyboardType ?? TextInputType.text,
          decoration: InputDecoration(
            hintText: hintText,
            focusedBorder: focusedOutlineInputBorder(),
            enabledBorder: enabledOutlineInputBorder(),
            disabledBorder: enabledOutlineInputBorder(),
            prefixIcon: Icon(prefixIcon,
                color: focusNode.hasFocus
                    ? primary
                    :white,
                size: 25),
            suffixIcon: IconButton(
                splashRadius: 1,
                onPressed: postfixIconCallBack,
                icon: Icon(postfixIcon,
                    color: focusNode.hasFocus
                        ? primary
                        : white)),
            filled: true,
            fillColor: focusNode.hasFocus
                ? primary
                : white,
          )),
    );
  }
}

focusedOutlineInputBorder() {
  return OutlineInputBorder(
    borderSide: const BorderSide(color: primary),
    borderRadius: BorderRadius.circular(15),
  );
}

enabledOutlineInputBorder() {
  return OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.transparent),
    borderRadius: BorderRadius.circular(15),
  );
}
