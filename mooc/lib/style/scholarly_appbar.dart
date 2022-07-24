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
    return Container(
      height: 65,
      decoration: const BoxDecoration(
        color: scholarly_color.background,
        border: Border(
            bottom: BorderSide(color: scholarly_color.borderColor, width: 1)),
      ),
      child: Center(
          child: Container(
              height: 20,
              child: Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Image(
                    fit: BoxFit.fill, image: AssetImage('assets/logo.png')),
              ))),
    );
    /*
          */
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
  final Widget? tabPrefix, tabSuffix;
  // constructor
  const ScholarlyScaffold({
    Key? key,
    required this.hasAppbar,
    required this.body,
    required this.numberOfTabs,
    required this.tabNames,
    required this.tabs,
    this.tabPrefix,
    this.tabSuffix,
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
        body: Column(children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 48, vertical: 8),
                    child: tabPrefix ?? Container(),
                  )),
              Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 48, vertical: 8),
                    child: tabSuffix ?? Container(),
                  )),
              Column(
                children: [
                  hasAppbar ? ScholarlyAppbar() : Container(),
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
                                        fontSize: 15,
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
                ],
              ),
            ],
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
        color: scholarly_color.background,
        border: Border(
            top: BorderSide(color: scholarly_color.borderColor, width: 1)),
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
                  child: SingleChildScrollView(
                    child: ScholarlyHolder(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: sideBar!,
                    )),
                  ))
              : Container(),
          sideBar != null
              ? VerticalDivider(
                  width: 20, thickness: 1, color: scholarly_color.borderColor)
              : Container(),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScholarlyHolder(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: body,
                      ),
                    ),
                    SizedBox(width: sideBar != null ? 350 : 0),
                  ],
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
  final bool white;
  // constructor
  const ScholarlyLoading({Key? key, this.white = false}) : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
                color: white ? Colors.white : scholarly_color.scholarlyRed)));
  }
}

class ScholarlySideBarButton extends StatelessWidget {
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

  // main build function
  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          onPressed();
        },
        style: ButtonStyle(
            backgroundColor: selected
                ? MaterialStateProperty.all<Color>(
                    scholarly_color.scholarlyRedBackground)
                : null,
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ))),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Icon(icon,
                  color: selected
                      ? scholarly_color.scholarlyRed
                      : scholarly_color.grey),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ScholarlyTextH5(label, red: selected),
              ),
            ),
            Container(),
          ],
        ));
  }
}
