import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/components/video_control.dart';
import 'package:hospital_ai_client/components/video_widget.dart';
import 'package:media_kit_video/media_kit_video.dart';

class FullScreenLive extends StatefulWidget {
  final String id;
  const FullScreenLive({super.key, required this.id});

  @override
  State<FullScreenLive> createState() => _FullScreenLiveState();
}

class _FullScreenLiveState extends State<FullScreenLive> {
  VideoController? controller;

  @override
  void initState() {
    super.initState();
    final player = videoModel.getPlayablePlayer(widget.id);
    if (player != null) {
      controller = VideoController(player);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    return NavigationView(
      appBar: NavigationAppBar(
        title: Text('设备详情 ${widget.id}')
      ),
      content: Row(
        children: [
          Flexible(
            child: Column(
              children: [
                Expanded(
                  child: controller == null
                      ? Center(
                          child: Text('未找到源，请重试'),
                        )
                      : Video(
                          controller: controller,
                          controls: (state) => VideoControl2(state: state, deviceId: widget.id, type: LiveType.fullscreen),
                        ),
                ),
              ],
            ),
            flex: 3,
          ),
          Flexible(
              child: Column(
            children: [Text('meta')],
          ))
        ],
      )
    );
  }
}
