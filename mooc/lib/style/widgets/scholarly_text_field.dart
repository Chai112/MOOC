import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/style/colors.dart' as scholarly_color;

class ScholarlyTextField extends StatelessWidget {
  // members of MyWidget
  final String label;
  final String? errorText;

  // constructor
  const ScholarlyTextField({Key? key, required this.label, this.errorText})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: SizedBox(
        height: 70,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(
                focusColor: scholarly_color.scholarlyRed,
                labelText: label,
                focusedBorder: const OutlineInputBorder(
                  // width: 0.0 produces a thin "hairline" border
                  borderSide: BorderSide(
                      color: scholarly_color.scholarlyRed, width: 2.0),
                ),
                enabledBorder: const OutlineInputBorder(
                  // width: 0.0 produces a thin "hairline" border
                  borderSide: BorderSide(
                      color: scholarly_color.highlightGrey, width: 1.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 5),
              child: AnimatedOpacity(
                opacity: errorText != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 100),
                child: Text(errorText ?? "",
                    style: const TextStyle(
                      color: scholarly_color.scholarlyRed,
                      fontSize: 14,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
