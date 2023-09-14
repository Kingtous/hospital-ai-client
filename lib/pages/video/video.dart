import 'package:flutter/material.dart';
import 'package:hospital_ai_client/components/video_control.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoHomePage extends StatefulWidget {
  const VideoHomePage({super.key});

  @override
  State<VideoHomePage> createState() => _VideoHomePageState();
}

class _VideoHomePageState extends State<VideoHomePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: AspectRatio(
        aspectRatio: 16 / 9,
      ),
    );
  }
}
