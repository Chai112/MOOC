import 'dart:html';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart'; // Flutter
import 'package:mooc/style/scholarly_colors.dart' as scholarly_color;
import 'package:mooc/style/widgets/scholarly_elements.dart';
import 'package:mooc/style/widgets/scholarly_text.dart';

class ScholarlyAppbar extends StatelessWidget {
  // constructor
  const ScholarlyAppbar({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
              bottom: BorderSide(color: scholarly_color.greyLight, width: 1)),
          //boxShadow: [scholarly_color.shadow],
        ),
      ),
      title: Container(
          height: 20,
          child: Image(fit: BoxFit.fill, image: AssetImage('assets/logo.png'))),
    );
  }
}

class ScholarlyTabHeaders {
  final String tabName;
  final IconData tabIcon;
  const ScholarlyTabHeaders({required this.tabName, required this.tabIcon});
}

class ScholarlyScaffold extends StatelessWidget {
  final bool hasAppbar;
  final int numberOfTabs;
  final List<ScholarlyTabHeaders> tabNames;
  final List<Widget> body;
  final List<Widget> tabs;
  final List<Widget>? sideBar;
  // constructor
  const ScholarlyScaffold({
    Key? key,
    required this.hasAppbar,
    required this.body,
    required this.numberOfTabs,
    required this.tabNames,
    required this.tabs,
    this.sideBar,
  }) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    // this is to make sure it fills the entire column
    body.add(Container());

    return DefaultTabController(
      length: numberOfTabs,
      child: Scaffold(
        appBar: hasAppbar
            ? AppBar(
                elevation: 0,
                flexibleSpace: ScholarlyAppbar(),
              )
            : null,
        body: Column(children: [
          ScholarlyHolder(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: body,
                ),
                TabBar(
                  isScrollable: true,
                  tabs: List.generate(tabNames.length, (int i) {
                    return Tab(
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 1.0),
                            child: Icon(tabNames[i].tabIcon,
                                color: scholarly_color.grey),
                          ),
                          const SizedBox(width: 10),
                          Text(tabNames[i].tabName,
                              style: const TextStyle(
                                fontSize: 16,
                                color: scholarly_color.grey,
                              )),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          Expanded(
              child: TabBarView(
            children: tabs,
          ))
        ]),
      ),
    );
  }
}

class ScholarlyTabPage extends StatelessWidget {
  final List<Widget> body;
  final List<Widget>? sideBar;
  // constructor
  const ScholarlyTabPage({Key? key, required this.body, this.sideBar})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    body.add(Container());
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border:
            Border(top: BorderSide(color: scholarly_color.greyLight, width: 1)),
        //boxShadow: [scholarly_color.shadow],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sideBar != null
              ? Container(
                  width: 350,
                  constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height),
                  child: ScholarlyHolder(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sideBar!,
                  )))
              : Container(),
          sideBar != null
              ? VerticalDivider(
                  width: 20, thickness: 1, color: scholarly_color.greyLight)
              : Container(),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ScholarlyHolder(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: body,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScholarlyLoading extends StatelessWidget {
  // constructor
  const ScholarlyLoading({Key? key}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return const Center(
        child: SizedBox(
            height: 30, width: 30, child: CircularProgressIndicator()));
  }
}

class ScholarlySideBarButton extends StatefulWidget {
  // members of MyWidget
  final String label;
  final IconData icon;
  final bool selected;
  final Function onPressed;

  // constructor
  const ScholarlySideBarButton(
      {Key? key,
      required this.label,
      required this.icon,
      required this.onPressed,
      this.selected = false})
      : super(key: key);

  @override
  _ScholarlySideBarButtonState createState() => _ScholarlySideBarButtonState();
}

class _ScholarlySideBarButtonState extends State<ScholarlySideBarButton> {
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (PointerEnterEvent _) {
        setState(() {
          _isHovering = true;
        });
      },
      onExit: (PointerExitEvent _) {
        setState(() {
          _isHovering = false;
        });
      },
      child: TextButton(
          onPressed: () {
            widget.onPressed();
          },
          style: ButtonStyle(
              backgroundColor: widget.selected
                  ? MaterialStateProperty.all<Color>(
                      scholarly_color.scholarlyRedBackground)
                  : null,
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ))),
          child: Row(
            children: [
              Icon(widget.icon,
                  color: widget.selected
                      ? scholarly_color.scholarlyRed
                      : scholarly_color.grey),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ScholarlyTextH5(widget.label, red: widget.selected),
              ),
              Expanded(child: Container()),
              _isHovering
                  ? IconButton(
                      hoverColor: Colors.transparent,
                      icon: Icon(Icons.post_add_rounded,
                          color: widget.selected
                              ? scholarly_color.scholarlyRedLight
                              : scholarly_color.greyLight),
                      onPressed: () {},
                    )
                  : Container(),
            ],
          )),
    );
  }
}
