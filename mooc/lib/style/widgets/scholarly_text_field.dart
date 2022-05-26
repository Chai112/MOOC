import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/style/colors.dart' as scholarly_color;

class ScholarlyTextField extends StatelessWidget {
  // members of MyWidget
  final String label;

  // constructor
  const ScholarlyTextField({Key? key, required this.label}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: SizedBox(
        height: 50,
        child: TextFormField(
          decoration: InputDecoration(
            focusColor: scholarly_color.scholarlyBlue,
            labelText: label,
            focusedBorder: const OutlineInputBorder(
              // width: 0.0 produces a thin "hairline" border
              borderSide:
                  BorderSide(color: scholarly_color.scholarlyBlue, width: 2.0),
            ),
            enabledBorder: const OutlineInputBorder(
              // width: 0.0 produces a thin "hairline" border
              borderSide:
                  BorderSide(color: scholarly_color.highlightGrey, width: 1.0),
            ),
          ),
        ),
      ),
    );
  }
}
