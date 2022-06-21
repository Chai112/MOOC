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
              bottom:
                  BorderSide(color: scholarly_color.highlightGrey, width: 1)),
          //boxShadow: [scholarly_color.shadow],
        ),
      ),
      title: Container(
          height: 20,
          child: Image(fit: BoxFit.fill, image: AssetImage('assets/logo.png'))),
    );
  }
}

class ScholarlyScaffold extends StatelessWidget {
  final bool hasAppbar;
  final List<Widget> body;
  final List<Widget>? bottom;
  final List<Widget>? sideBar;
  // constructor
  const ScholarlyScaffold(
      {Key? key,
      required this.hasAppbar,
      required this.body,
      this.bottom,
      this.sideBar})
      : super(key: key);

  // main build function
  @override
  Widget build(BuildContext context) {
    // this is to make sure it fills the entire column
    body.add(Container());
    if (bottom != null) {
      bottom!.add(Container());
    }

    return Scaffold(
        appBar: hasAppbar
            ? AppBar(
                elevation: 0,
                flexibleSpace: ScholarlyAppbar(),
              )
            : null,
        body: SingleChildScrollView(
          child: Column(
            children: [
              ScholarlyHolder(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: body,
                ),
              ),
              bottom != null
                  ? Container(
                      constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            top: BorderSide(
                                color: scholarly_color.highlightGrey,
                                width: 1)),
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
                                      minHeight:
                                          MediaQuery.of(context).size.height),
                                  child: ScholarlyHolder(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: sideBar!,
                                  )))
                              : Container(),
                          Expanded(
                            child: Container(
                              decoration: sideBar != null
                                  ? const BoxDecoration(
                                      color: Colors.white,
                                      border: Border(
                                          left: BorderSide(
                                              color:
                                                  scholarly_color.highlightGrey,
                                              width: 1)),
                                      //boxShadow: [scholarly_color.shadow],
                                    )
                                  : null,
                              child: Center(
                                child: ScholarlyHolder(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: bottom!,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(),
            ],
          ),
        ));
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
