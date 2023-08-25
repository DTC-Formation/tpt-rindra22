// ignore_for_file: must_be_immutable

import 'package:memories_frontend_flutter/helpers/colors.dart';
import 'package:flutter/cupertino.dart';

class SimpleButton extends StatelessWidget {
    double height, width, borderRadius, textFontSize;
    double? borderWidth;
    Color backgroundColor, textColor;
    Color? borderColor;
    String buttonText;
    final VoidCallback? onButtonPressed;

    SimpleButton({
        Key? key,
        required this.height,
        required this.width,
        required this.backgroundColor,
        required this.borderRadius,
        required this.buttonText,
        required this.textColor,
        required this.textFontSize,
        this.borderWidth,
        this.borderColor,
        this.onButtonPressed,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return CupertinoButton(
            onPressed: onButtonPressed,
            child: Container(
                height: height,
                width: width,
                decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border.all(
                        color: borderColor ?? primary, width: borderWidth ?? 0),
                    borderRadius: BorderRadius.circular(borderRadius)),
                child: Center(
                    child: Text(
                        buttonText,
                        style: TextStyle(
                            color: textColor,
                            fontSize: textFontSize,
                            decoration: TextDecoration.none),
                        textAlign: TextAlign.center,
                    ),
                ),
            ),
        );
    }
}

class SimpleImageButton extends StatelessWidget {
    double height, width, borderRadius, textFontSize;
    double? borderWidth;
    Color backgroundColor, textColor;
    Color? borderColor;
    String buttonText, image;

    final VoidCallback? onButtonPressed;

    SimpleImageButton(
      {Key? key,
      required this.height,
      required this.width,
      required this.backgroundColor,
      required this.borderRadius,
      required this.buttonText,
      required this.textColor,
      required this.textFontSize,
      required this.image,
      this.borderWidth,
      this.borderColor,
      this.onButtonPressed})
      : super(key: key);

    @override
    Widget build(BuildContext context) {
        return CupertinoButton(
            onPressed: onButtonPressed,
            child: Container(
                height: height,
                width: width,
                decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border.all(
                        color: borderColor ?? primary, width: borderWidth ?? 0
                    ),
                    borderRadius: BorderRadius.circular(borderRadius)
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Image.asset(
                            image,
                            width: 25,
                            height: 25,
                        ),
                        const SizedBox(
                            width: 14,
                        ),
                        Text(
                            buttonText,
                            style: TextStyle(
                                color: textColor,
                                fontSize: textFontSize,
                                decoration: TextDecoration.none
                            ),
                            textAlign: TextAlign.center,
                        ),
                    ],
                ),
            ),
        );
    }
}
