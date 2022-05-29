import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/style/colors.dart' as scholarly_color;
import 'dart:math' as maths;

class ScholarlyTextFieldController extends TextEditingController {
  String? errorText;
}

class ScholarlyTextField extends StatelessWidget {
  // members of MyWidget
  final String label;
  final bool isPragmaticField;
  final bool isPasswordField;
  final ScholarlyTextFieldController? controller;

  // constructor
  const ScholarlyTextField(
      {Key? key,
      required this.label,
      this.isPragmaticField = false,
      this.isPasswordField = false,
      this.controller})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: SizedBox(
        height: 70,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: controller,
              autocorrect: !isPragmaticField,
              enableSuggestions: !isPragmaticField,
              obscureText: isPasswordField,
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
                prefixIcon: controller?.errorText == null
                    ? null // if errorText is null, then no icon is needed
                    : const Icon(Icons.warning_rounded,
                        color: scholarly_color.scholarlyRed),
              ),
            ),
            TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                tween: Tween<double>(
                    begin: 0, end: controller?.errorText == null ? 0 : 10.0),
                curve: Curves.ease,
                builder: (BuildContext _, double anim, Widget? __) {
                  return Padding(
                    padding: EdgeInsets.only(
                        left: 10.0 + 20 * (maths.sin(anim) * (1 / (anim + 1))),
                        top: 2),
                    child: Text(controller?.errorText ?? "",
                        style: const TextStyle(
                          color: scholarly_color.scholarlyRed,
                          fontSize: 14,
                        )),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
