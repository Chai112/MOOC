import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/style/scholarly_appbar.dart';
import 'package:mooc/style/scholarly_colors.dart' as scholarly_color;

class ScholarlyButton extends StatelessWidget {
  // members of MyWidget
  final String text;
  final Function() onPressed;
  final bool invertedColor, darkenBackground;
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
    return Padding(
      padding: padding
          ? EdgeInsets.symmetric(
              vertical: 8.0, horizontal: (verticalOnlyPadding ? 0.0 : 8.0))
          : EdgeInsets.zero,
      child: TextButton(
          onPressed: onPressed,
          style: ButtonStyle(
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              backgroundColor: !invertedColor
                  ? (!darkenBackground
                      ? MaterialStateProperty.all<Color>(
                          scholarly_color.scholarlyRedBackground)
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
              loading ? ScholarlyLoading(white: invertedColor) : Container(),
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
                          fontSize: 16,
                          color: textColor,
                        )),
                  ),
                ],
              ),
            ],
          )),
    );
  }
}

/*
class ScholarlyButton extends StatelessWidget {
  // members of MyWidget
  final String text;
  final Function() onPressed;
  final bool invertedColor;
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
    return Padding(
      padding: padding
          ? EdgeInsets.symmetric(
              vertical: 8.0, horizontal: (verticalOnlyPadding ? 0.0 : 8.0))
          : EdgeInsets.zero,
      child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor:
                !invertedColor ? Colors.white : scholarly_color.scholarlyRed,
            primary:
                !invertedColor ? scholarly_color.scholarlyRed : Colors.white,
            elevation: 0,
          ),
          child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  loading
                      ? ScholarlyLoading(white: invertedColor)
                      : Container(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      icon != null
                          ? Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(
                                icon,
                                color: textColor,
                              ),
                            )
                          : Container(),
                      Text(text,
                          style: TextStyle(
                            fontSize: 16,
                            color: textColor,
                          )),
                    ],
                  ),
                ],
              ))),
    );
  }
}

*/