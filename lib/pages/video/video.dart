import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/components/video_control.dart';
import 'package:hospital_ai_client/components/video_widget.dart';
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
    return Column(
      children: [
        Text(
          '监控主页',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(
          height: 8.0,
        ),
        Expanded(
          child: Obx(
            () {
              final keys = videoModel.playerMap.keys.toList(growable: false);
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  childAspectRatio: 16 / 9,
                  crossAxisSpacing: 4,
                ),
                itemCount: videoModel.playerMap.length,
                itemBuilder: (context, idx) {
                  final e = keys[idx];
                  return VideoLive(
                    key: ValueKey(e),
                    id: e,
                    type: LiveType.thumbnail,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
