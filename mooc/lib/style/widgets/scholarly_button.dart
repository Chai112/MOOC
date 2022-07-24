import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/style/scholarly_appbar.dart';
import 'package:mooc/style/scholarly_colors.dart' as scholarly_color;

class ScholarlyButton extends StatelessWidget {
  // members of MyWidget
  final String text;
  final Function() onPressed;
  final bool invertedColor, darkenBackground, lightenBackground;
  final bool verticalOnlyPadding;
  final bool padding;
  final bool loading;
  final IconData? icon;

  // constructor
  const ScholarlyButton(
    this.text, {
    Key? key,
    required this.onPressed,
    this.invertedColor = false,
    this.darkenBackground = false,
    this.lightenBackground = false,
    this.verticalOnlyPadding = false,
    this.padding = true,
    this.loading = false,
    this.icon,
  }) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    Color textColor = !invertedColor
        ? (!loading ? scholarly_color.scholarlyRed : Colors.white)
        : (!loading ? Colors.white : scholarly_color.scholarlyRed);
    return Row(
      children: [
        Padding(
          padding: padding
              ? EdgeInsets.symmetric(
                  vertical: 8.0, horizontal: (verticalOnlyPadding ? 0.0 : 8.0))
              : EdgeInsets.zero,
          child: TextButton(
              onPressed: onPressed,
              style: ButtonStyle(
                  side: lightenBackground
                      ? MaterialStateProperty.all<BorderSide>(BorderSide(
                          color: scholarly_color.borderColor,
                          width: 1,
                          style: BorderStyle.solid))
                      : null,
                  foregroundColor: MaterialStateProperty.all<Color>(
                      scholarly_color.background),
                  backgroundColor: !invertedColor
                      ? (!darkenBackground
                          ? (!lightenBackground
                              ? MaterialStateProperty.all<Color>(
                                  scholarly_color.scholarlyRedBackground)
                              : MaterialStateProperty.all<Color>(
                                  scholarly_color.background))
                          : MaterialStateProperty.all<Color>(
                              scholarly_color.scholarlyRedLight))
                      : MaterialStateProperty.all<Color>(
                          scholarly_color.scholarlyRed),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ))),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      icon != null
                          ? Padding(
                              padding: const EdgeInsets.only(left: 8, right: 0),
                              child: Icon(
                                icon,
                                color: textColor,
                              ),
                            )
                          : Container(),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: icon == null ? 14 : 8, vertical: 12),
                        child: Text(text,
                            style: TextStyle(
                              fontSize: 15,
                              color: textColor,
                            )),
                      ),
                    ],
                  ),
                  loading
                      ? ScholarlyLoading(white: invertedColor)
                      : Container(),
                ],
              )),
        ),
      ],
    );
  }
}
