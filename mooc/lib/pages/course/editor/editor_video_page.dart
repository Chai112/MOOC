import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:mooc/pages/course/editor_page.dart';
import 'package:mooc/style/widgets/scholarly_button.dart';
import 'package:mooc/style/widgets/scholarly_elements.dart';
import 'package:mooc/style/widgets/scholarly_text.dart';
import 'package:mooc/style/widgets/scholarly_text_field.dart';
import 'package:video_player/video_player.dart';
import 'package:mooc/style/scholarly_colors.dart' as scholarly_color;
import 'package:mooc/style/widgets/video_player/video_progress_indicator.dart';

import 'package:mooc/services/networking_service.dart' as networking_service;
import 'package:mooc/services/auth_service.dart' as auth_service;

import 'package:flutter/material.dart';

class CourseEditorVideoPage extends StatefulWidget {
  final CourseHierarchyController controller;
  final Function() callback;

  const CourseEditorVideoPage(
      {Key? key, required this.controller, required this.callback})
      : super(key: key);
  @override
  _CourseEditorVideoPageState createState() => _CourseEditorVideoPageState();
}

class _CourseEditorVideoPageState extends State<CourseEditorVideoPage> {
  late VideoPlayerController _controller;
  final _courseElementNameController = ScholarlyTextFieldController();

  Future<ClosedCaptionFile> _loadCaptions() async {
    final String fileContents = await DefaultAssetBundle.of(context)
        .loadString('assets/bumble_bee_captions.vtt');
    return WebVTTCaptionFile(
        fileContents); // For vtt files, use WebVTTCaptionFile
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      'https://sicherthai.com/test/nocturne.mp4', // should not use actual server for testing!
      closedCaptionFile: _loadCaptions(),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize();
    _courseElementNameController.text =
        Uri.decodeComponent(widget.controller.courseElementName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void changeCourseElementName() async {
    String token = auth_service.globalUser.token!.token;

    await networking_service.serverGet("changeCourseElement", {
      "token": token,
      "courseElementId": widget.controller.courseElementId.toString(),
      "courseElementName": _courseElementNameController.text,
      "courseElementDescription": "",
    });
    widget.callback();
    setState(() {});
  }

  double sliderValue = 0;
  double sliderSize = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 70),
          Container(
            constraints:
                BoxConstraints(minWidth: 720, maxWidth: 720, maxHeight: 540),
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    VideoPlayer(_controller),
                    ClosedCaption(text: _controller.value.caption.text),
                    _ControlsOverlay(controller: _controller),
                    MyVideoProgressIndicator(controller: _controller),
                  ],
                ),
              ),
            ),
          ),
          Container(width: 800),
          SizedBox(height: 30),
          /*
          ScholarlyButton(
            "Upload",
            icon: Icons.upload_file_rounded,
            invertedColor: true,
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles();

              if (result != null) {
                //print(result.files.single.bytes);
                networking_service.serverUploadVideo(
                    123, result.files.single.bytes!);
              } else {
                // User canceled the picker
              }
            },
            padding: false,
          ),
          */
          SizedBox(height: 30),
          SwappableTextField(
            textWidget: ScholarlyTextH2(_courseElementNameController.text),
            textFieldWidget: ScholarlyTextField(
                label: "course name", controller: _courseElementNameController),
            onSubmit: changeCourseElementName,
          ),
          SizedBox(height: 30),
          ScholarlyBox(text: "ah"),
          SizedBox(height: 30),
          SizedBox(height: 300),
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  const _ControlsOverlay({Key? key, required this.controller})
      : super(key: key);

  static const List<double> _examplePlaybackRates = <double>[
    0.25,
    0.5,
    1.0,
    1.5,
    2.0,
    3.0,
    5.0,
    10.0,
  ];

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 50),
          reverseDuration: const Duration(milliseconds: 200),
          child: controller.value.isPlaying
              ? const SizedBox.shrink()
              : Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 100.0,
                      semanticLabel: 'Play',
                    ),
                  ),
                ),
        ),
        GestureDetector(
          onTap: () {
            controller.value.isPlaying ? controller.pause() : controller.play();
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: PopupMenuButton<double>(
            initialValue: controller.value.playbackSpeed,
            tooltip: 'Playback speed',
            onSelected: (double speed) {
              controller.setPlaybackSpeed(speed);
            },
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem<double>>[
                for (final double speed in _examplePlaybackRates)
                  PopupMenuItem<double>(
                    value: speed,
                    child: Text('${speed}x'),
                  )
              ];
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                // Using less vertical padding as the text is also longer
                // horizontally, so it feels like it would need more spacing
                // horizontally (matching the aspect ratio of the video).
                vertical: 12,
                horizontal: 16,
              ),
              child: Text('${controller.value.playbackSpeed}x'),
            ),
          ),
        ),
      ],
    );
  }
}
