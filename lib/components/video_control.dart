import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoControl extends StatelessWidget {
  final VideoState state;
  final String deviceId;
  const VideoControl({super.key, required this.state, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Button(
              child: const Text('刷新'),
              onPressed: () async {
                videoModel.get(deviceId)?.reload();
              }),
        ],
      ),
    );
  }
}
