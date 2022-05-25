import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/style/colors.dart' as scholarly_color;

class ScholarlyTile extends StatelessWidget {
  // members of MyWidget
  final double height, width;

  // constructor
  const ScholarlyTile({Key? key, required this.height, required this.width})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: scholarly_color.grey, width: 1),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: const [scholarly_color.shadow],
        ),
      ),
    );
  }
}
