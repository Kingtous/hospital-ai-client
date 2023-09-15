import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' hide Colors;
import 'package:get/get.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/components/video_widget.dart';

class VideoHomePage extends StatefulWidget {
  const VideoHomePage({super.key});

  @override
  State<VideoHomePage> createState() => _VideoHomePageState();
}

class _VideoHomePageState extends State<VideoHomePage> {
  var index = 0.obs;

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
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          child: Image.asset(
            'assets/images/bg.jpeg',
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '监控主页',
                    style: Theme.of(context).textTheme.titleLarge!
                      ..copyWith(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(
                height: 8.0,
              ),
              SizedBox(
                width: kThumbNailLiveWidth * 3,
                height: kThumbNailLiveHeight * 3 + 50,
                child: Obx(
                  () {
                    final keys = videoModel.playerMap.keys
                        .toList(growable: false)
                      ..sort();
                    final pages = (keys.length / 9).ceil();
                    index.value = min(index.value, pages - 1);
                    final pageKeys = keys
                        .skip(index.value * 9)
                        .take(9)
                        .toList(growable: false);
                    return Column(
                      children: [
                        Expanded(
                          child: Wrap(
                            // maxCrossAxisExtent: kThumbNailLiveWidth.toDouble(),
                            // childAspectRatio: 16 / 9,
                            children: [
                              ...pageKeys.map((e) => SizedBox(
                                    key: ValueKey(e),
                                    width: kThumbNailLiveWidth.toDouble(),
                                    height: kThumbNailLiveHeight.toDouble(),
                                    child: VideoLive(
                                      id: e,
                                      width: kThumbNailLiveWidth.toDouble(),
                                      height: kTextTabBarHeight.toDouble(),
                                      type: LiveType.thumbnail,
                                    ),
                                  ))
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Button(
                                  child: const Icon(FluentIcons.page_left),
                                  onPressed: () {
                                    index.value = max(0, index.value - 1);
                                  }),
                              const SizedBox(
                                width: 4.0,
                              ),
                              Text(
                                '第${index + 1}/$pages页',
                                style: TextStyle(color: Colors.white),
                              ),
                              const SizedBox(
                                width: 4.0,
                              ),
                              Button(
                                  child: const Icon(FluentIcons.page_right),
                                  onPressed: () {
                                    index.value =
                                        min(pages - 1, index.value + 1);
                                  }),
                            ],
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
