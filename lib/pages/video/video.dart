import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/components/video_widget.dart';

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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '监控主页',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(
            height: 8.0,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Obx(
                () {
                  final keys =
                      videoModel.playerMap.keys.toList(growable: false);
                  return Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          children: [
                            ...keys.map((e) => SizedBox(
                                  width: kThumbNailLiveWidth.toDouble(),
                                  height: kThumbNailLiveHeight.toDouble(),
                                  child: VideoLive(
                                    key: ValueKey(e),
                                    id: e,
                                    width: kThumbNailLiveWidth.toDouble(),
                                    height: kTextTabBarHeight.toDouble(),
                                    type: LiveType.thumbnail,
                                  ),
                                ))
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
