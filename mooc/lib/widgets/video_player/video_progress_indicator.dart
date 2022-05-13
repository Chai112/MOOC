import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart'; // Flutter

class MyVideoProgressIndicator extends StatefulWidget {
  final VideoPlayerController controller;
  const MyVideoProgressIndicator({Key? key, required this.controller})
      : super(key: key);

  @override
  _MyVideoProgressIndicatorState createState() =>
      _MyVideoProgressIndicatorState();
}

class _MyVideoProgressIndicatorState extends State<MyVideoProgressIndicator> {
  double _sliderSize = 0;
  double _sliderPositionValue = 0;
  double _sliderBufferedValue = 0;
  int _videoDuration = 1;
  bool _isBeingDragged = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(updateSeeker);
  }

  @override
  void dispose() {
    widget.controller.removeListener(updateSeeker);
    super.dispose();
  }

  Future<void> updateSeeker() async {
    if (!widget.controller.value.isInitialized) return;
    _videoDuration = widget.controller.value.duration.inSeconds;
    setState(() {
      int videoPosition = widget.controller.value.position.inSeconds;
      _sliderPositionValue = videoPosition / _videoDuration;
      List<DurationRange> bufferedSections = widget.controller.value.buffered;
      for (DurationRange i in bufferedSections) {
        // if the track is current being played at the moment
        if (videoPosition > i.start.inSeconds &&
            videoPosition < i.end.inSeconds) {
          _sliderBufferedValue = i.end.inSeconds / _videoDuration;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 200),
        tween: Tween<double>(begin: 0, end: _sliderSize),
        curve: Curves.ease,
        builder: (BuildContext _, double animMouseHover, Widget? __) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(maxHeight: 50),
              child: MouseRegion(
                onEnter: (PointerEnterEvent _) {
                  setState(() {
                    _sliderSize = 1;
                  });
                },
                onExit: (PointerExitEvent _) {
                  setState(() {
                    if (!_isBeingDragged) {
                      _sliderSize = 0;
                    }
                  });
                },
                child: Stack(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                          thumbColor: Colors.white,
                          activeTrackColor: const Color(0x88FFFFFF),
                          trackHeight: animMouseHover * 5 + 3,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 0)),
                      child: Slider(
                        value: _sliderBufferedValue,
                        onChanged: (double value) {},
                      ),
                    ),
                    SliderTheme(
                      data: SliderThemeData(
                          inactiveTrackColor: Colors.transparent,
                          thumbColor: Colors.blue,
                          trackHeight: animMouseHover * 5 + 3,
                          thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius: animMouseHover * 10)),
                      child: Slider(
                        value: _sliderPositionValue,
                        onChanged: (double value) {
                          setState(() {
                            _sliderPositionValue = value;
                          });
                        },
                        onChangeStart: (double _) {
                          _isBeingDragged = true;
                          setState(() {
                            _sliderSize = 1;
                          });
                        },
                        onChangeEnd: (double _) {
                          _isBeingDragged = false;
                          setState(() {
                            _sliderSize = 0;
                          });
                          setState(() {
                            if (!widget.controller.value.isInitialized) {
                              return;
                            }
                            widget.controller.seekTo(Duration(
                                seconds: (_sliderPositionValue * _videoDuration)
                                    .round()));
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
