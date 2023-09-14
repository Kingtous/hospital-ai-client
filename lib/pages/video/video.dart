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
                      width: 180,
                      height: 320,
                      type: LiveType.thumbnail,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
