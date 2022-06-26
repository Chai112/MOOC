import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/style/scholarly_colors.dart' as scholarly_color;
import 'dart:math' as maths;

class ScholarlyTextFieldController extends TextEditingController {
  String? errorText;
  void clearError() {
    errorText = null;
  }
}

class ScholarlyTextField extends StatelessWidget {
  // members of MyWidget
  final String label;
  final bool isPragmaticField;
  final bool isPasswordField;
  final ScholarlyTextFieldController? controller;
  FocusNode? focusNode;

  // constructor
  ScholarlyTextField(
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
              focusNode: focusNode,
              autofocus: true,
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
                  borderSide:
                      BorderSide(color: scholarly_color.greyLight, width: 1.0),
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

// myPage class which creates a state on call
class SwappableTextField extends StatefulWidget {
  final Widget textWidget;
  final ScholarlyTextField textFieldWidget;
  final Function onSubmit;
  const SwappableTextField(
      {Key? key,
      required this.textWidget,
      required this.textFieldWidget,
      required this.onSubmit})
      : super(key: key);

  @override
  _State createState() => _State();
}

// myPage state
class _State extends State<SwappableTextField> {
  bool editMode = false;
  FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focus.hasFocus) {
      widget.onSubmit();
      setState(() {
        editMode = false;
      });
    }
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    if (editMode) {
      return InkWell(child: widget.textFieldWidget);
    } else {
      return InkWell(
          onTap: () {
            setState(() {
              editMode = true;
              widget.textFieldWidget.focusNode = _focus;
            });
          },
          child: MouseRegion(
              cursor: SystemMouseCursors.text, child: widget.textWidget));
    }
    // ignore: unused_local_variable
  }
}
