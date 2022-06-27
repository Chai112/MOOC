import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/style/scholarly_colors.dart' as scholarly_color;

class ScholarlyTile extends StatelessWidget {
  // members of MyWidget
  final double? width;
  final Widget child;
  final bool hasShadows;

  // constructor
  const ScholarlyTile(
      {Key? key, this.width, required this.child, this.hasShadows = false})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 1000000, // if no width given, then expand fully
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: scholarly_color.greyLight, width: 1),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: hasShadows ? const [scholarly_color.shadow] : const [],
        ),
        child: child,
      ),
    );
  }
}

class ScholarlyHolder extends StatelessWidget {
  // members of MyWidget
  final Widget child;

  // constructor
  const ScholarlyHolder({Key? key, required this.child}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900),
        child: child,
      ),
    );
  }
}

class ScholarlyPadding extends StatelessWidget {
  // members of MyWidget
  final Widget child;
  final bool thick;
  final bool verticalOnly;

  // constructor
  const ScholarlyPadding(
      {Key? key,
      required this.child,
      this.thick = false,
      this.verticalOnly = false})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    double paddingThickness = thick ? 30 : 20;
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: verticalOnly ? 0 : paddingThickness,
          vertical: verticalOnly ? paddingThickness / 2 : paddingThickness),
      child: child,
    );
  }
}

// myPage class which creates a state on call
class ScholarlyHoverButton extends StatefulWidget {
  final Widget child;
  const ScholarlyHoverButton({Key? key, required this.child}) : super(key: key);

  @override
  _ScholarlyHoverButtonState createState() => _ScholarlyHoverButtonState();
}

// myPage state
class _ScholarlyHoverButtonState extends State<ScholarlyHoverButton> {
  bool _isHovering = false;

  // main build function
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovering = false;
        });
      },
      child: Stack(
        children: [
          widget.child,
          _isHovering
              ? Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.settings, color: Colors.black12),
                    onPressed: () {},
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
