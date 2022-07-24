import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:mooc/pages/course/editor_page.dart';
import 'package:mooc/style/scholarly_appbar.dart';
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

class _Video {
  int duration;
  String videoDataId;
  bool isInitialized, isUploading;
  String videoData;
  _Video(
      {required this.duration,
      required this.videoDataId,
      required this.isInitialized,
      required this.isUploading,
      required this.videoData});
}

class _Literature {
  String literatureData;
  _Literature({required this.literatureData});
}

class _Form {
  String formData;
  _Form({required this.formData});
}

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
  final _courseElementNameController = ScholarlyTextFieldController();

  @override
  void initState() {
    super.initState();
    _courseElementNameController.text =
        Uri.decodeComponent(widget.controller.courseElementName);
  }

  @override
  void dispose() {
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
    widget.controller.courseElementName = _courseElementNameController.text;
    widget.callback();
    setState(() {});
  }

  _Video? _video;
  Future<bool> loadData() async {
    String token = auth_service.globalUser.token!.token;
    Map<String, dynamic> response =
        await networking_service.serverGet("getVideo", {
      "token": token,
      "courseElementId": widget.controller.courseElementId.toString(),
    });
    _video = _Video(
      duration: response["data"]["duration"],
      videoDataId: response["data"]["videoDataId"],
      isInitialized: response["data"]["isInitialized"]["data"][0] == 1,
      isUploading: response["data"]["isUploading"]["data"][0] == 1,
      videoData: response["data"]["videoData"],
    );
    print(response["data"]);
    return true;
  }

  double sliderValue = 0;
  double sliderSize = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadData(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 70),
                  _video!.isInitialized
                      ? _ScholarlyVideoPlayer(videoDataId: _video!.videoDataId)
                      : _ScholarlyVideoUploader(
                          videoDataId: _video!.videoDataId,
                          callback: () {
                            setState(() {});
                          },
                        ),
                  SizedBox(height: 30),
                  /*
              ScholarlyButton(
              ),
              */
                  SizedBox(height: 30),
                  SwappableTextField(
                    textWidget:
                        ScholarlyTextH2(_courseElementNameController.text),
                    textFieldWidget: ScholarlyTextField(
                        label: "course name",
                        controller: _courseElementNameController),
                    onSubmit: changeCourseElementName,
                  ),
                  SizedBox(height: 30),
                  ScholarlyTextP(
                      "In this course you're gonna be learning how to like become a functioning human. Cause I have experience. I've been a human for over 36 months and have many qualifications. By 8 weeks I even mastered how to breathe. By 4 months I amassed a wealth of 3.5 billion dollars, according to Forbes. Come see how I climb through the ranks of society and bought my first lamborghini with my friend Jeffrey Bezos."),
                  SizedBox(height: 30),
                  ScholarlyBox(
                      text:
                          "Learning Objectives:\n*How to life\n*How to run\n*How to like speak"),
                  SizedBox(height: 300),
                ],
              ),
            );
          } else {
            return Expanded(child: Center(child: const ScholarlyLoading()));
          }
        });
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

// myPage class which creates a state on call
class _ScholarlyVideoPlayer extends StatefulWidget {
  final String videoDataId;
  const _ScholarlyVideoPlayer({Key? key, required this.videoDataId})
      : super(key: key);

  @override
  _ScholarlyVideoPlayerState createState() => _ScholarlyVideoPlayerState();
}

// myPage state
class _ScholarlyVideoPlayerState extends State<_ScholarlyVideoPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      /*"${networking_service.getApiUrl()}?action=downloadVideo&videoDataId=${widget.videoDataId}",*/
      'https://sicherthai.com/test/nocturne.mp4', // should not use actual server for testing!
      closedCaptionFile: _loadCaptions(),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<ClosedCaptionFile> _loadCaptions() async {
    final String fileContents = await DefaultAssetBundle.of(context)
        .loadString('assets/bumble_bee_captions.vtt');
    return WebVTTCaptionFile(
        fileContents); // For vtt files, use WebVTTCaptionFile
  }

  // main build function
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 720, maxWidth: 720, maxHeight: 540),
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
    );
  }
}

// myPage class which creates a state on call
class _ScholarlyVideoUploader extends StatefulWidget {
  final String videoDataId;
  final Function() callback;
  const _ScholarlyVideoUploader(
      {Key? key, required this.videoDataId, required this.callback})
      : super(key: key);

  @override
  _ScholarlyVideoUploaderState createState() => _ScholarlyVideoUploaderState();
}

// myPage state
class _ScholarlyVideoUploaderState extends State<_ScholarlyVideoUploader> {
  FilePickerResult? _result;
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
    return Container(
        decoration: BoxDecoration(
            color: scholarly_color.backgroundDim,
            border: Border.all(color: scholarly_color.borderColor),
            borderRadius: BorderRadius.circular(8.0)),
        child: Container(
          height: 540,
          width: 720,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              Icon(Icons.file_upload_outlined,
                  size: 100, color: scholarly_color.grey),
              SizedBox(height: 10),
              _result == null
                  ? ScholarlyTextH2B("Upload your Video")
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.file_copy_rounded,
                            color: scholarly_color.grey),
                        SizedBox(width: 5),
                        ScholarlyTextH2B(_result!.names.first!),
                      ],
                    ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _result != null
                      ? ScholarlyButton("Upload", invertedColor: true,
                          onPressed: () async {
                          await networking_service.serverUploadVideo(
                              widget.videoDataId, _result!.files.single.bytes!);
                          print("done uploadign");
                          widget.callback();
                        })
                      : Container(),
                  ScholarlyButton(
                    _result == null ? "Select Files" : "Reselect Files",
                    darkenBackground: true,
                    onPressed: () async {
                      _result = await FilePicker.platform.pickFiles();

                      if (_result != null) {
                        setState(() {});
                        //print(result.files.single.bytes);
                        //networking_service.serverUploadVideo(
                        //123, result.files.single.bytes!);
                      } else {
                        // User canceled the picker
                      }
                    },
                    padding: false,
                  )
                ],
              ),
            ],
          ),
        ));
  }
}
