import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/style/scholarly_colors.dart' as scholarly_color;

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
          color: scholarly_color.grey,
        ));
  }
}

class ScholarlyTextH3 extends StatelessWidget {
  // members of MyWidget
  final String text;
  final String? bracketText;

  // constructor
  const ScholarlyTextH3(this.text, {Key? key, this.bracketText})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text,
            style: const TextStyle(
              fontSize: 18,
              color: scholarly_color.scholarlyRed,
              fontWeight: FontWeight.bold,
            )),
        const SizedBox(width: 10),
        Text(bracketText ?? "",
            style: const TextStyle(
              fontSize: 15,
              color: scholarly_color.scholarlyRed,
            )),
      ],
    );
  }
}

class ScholarlyTextH4 extends StatelessWidget {
  // members of MyWidget
  final String text;

  // constructor
  const ScholarlyTextH4(this.text, {Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
          fontSize: 25,
        ));
  }
}

class ScholarlyTextH5 extends StatelessWidget {
  // members of MyWidget
  final String text;
  final bool red;

  // constructor
  const ScholarlyTextH5(this.text, {Key? key, this.red = false})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
          fontSize: 18,
          color: red ? scholarly_color.scholarlyRed : scholarly_color.grey,
        ));
  }
}

class ScholarlyTextP extends StatelessWidget {
  // members of MyWidget
  final String text;
  final TextAlign? textAlign;

  // constructor
  const ScholarlyTextP(this.text, {Key? key, this.textAlign}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Text(text,
        textAlign: textAlign,
        style: const TextStyle(
          fontSize: 15,
        ));
  }
}
