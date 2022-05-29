import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/style/colors.dart' as scholarly_color;

class ScholarlyButton extends StatelessWidget {
  // members of MyWidget
  final String text;
  final Function() onPressed;
  final bool invertedColor;

  // constructor
  const ScholarlyButton(this.text,
      {Key? key, required this.onPressed, this.invertedColor = false})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
              child: Text(
                text,
                style: TextStyle(
                    fontSize: 16,
                    color: !invertedColor
                        ? scholarly_color.scholarlyRed
                        : Colors.white),
              ))),
    );
  }
}
