import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/style/colors.dart' as scholarly_color;

class ScholarlyTextH2 extends StatelessWidget {
  // members of MyWidget
  final String text;

  // constructor
  const ScholarlyTextH2(this.text, {Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
          fontSize: 35,
          color: scholarly_color.h2Grey,
        ));
  }
}
