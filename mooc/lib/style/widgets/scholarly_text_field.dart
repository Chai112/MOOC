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
      padding: const EdgeInsets.all(20.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 50,
          child: TextFormField(
            decoration: const InputDecoration(
              focusColor: scholarly_color.scholarlyBlue,
              labelText: "username",
              border: OutlineInputBorder(
                borderSide: BorderSide(color: scholarly_color.grey, width: 1.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
