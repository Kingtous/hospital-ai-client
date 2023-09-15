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
    debugPrint("rebuild video screen...");
    final height = kThumbNailLiveHeight * 3 + 50 + 8 + 40;
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Image.asset(
            'assets/images/bg.jpeg',
            fit: BoxFit.cover,
          ),
        ),
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 8.0,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(100),
                          borderRadius: BorderRadius.circular(24.0)),
                      padding: const EdgeInsets.all(4.0),
                      width: kThumbNailLiveWidth * 3 + 8,
                      height: height.toDouble(),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Text(
                                  '总览',
                                  style: TextStyle(
                                      fontSize: 20.0, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Obx(
                              () {
                                final keys = videoModel.playerMap.keys
                                    .toList(growable: false)
                                  ..sort();
                                final pages = (keys.length / 9).ceil();
                                // index.value = min(index.value, pages - 1);
                                final pageKeys = keys
                                    .skip(index.value * 9)
                                    .take(9)
                                    .toList(growable: false);
                                return Column(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Wrap(
                                              alignment: WrapAlignment.start,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.start,
                                              // maxCrossAxisExtent: kThumbNailLiveWidth.toDouble(),
                                              // childAspectRatio: 16 / 9,
                                              children: [
                                                ...pageKeys.map((e) => SizedBox(
                                                      key: ValueKey(e),
                                                      width: kThumbNailLiveWidth
                                                          .toDouble(),
                                                      height:
                                                          kThumbNailLiveHeight
                                                              .toDouble(),
                                                      child: VideoLive(
                                                        id: e,
                                                        width:
                                                            kThumbNailLiveWidth
                                                                .toDouble(),
                                                        height:
                                                            kTextTabBarHeight
                                                                .toDouble(),
                                                        type:
                                                            LiveType.thumbnail,
                                                      ),
                                                    ))
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 50,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Button(
                                              child: const Icon(
                                                  FluentIcons.page_left),
                                              onPressed: () {
                                                index.value =
                                                    max(0, index.value - 1);
                                                // setState(() {});
                                              }),
                                          const SizedBox(
                                            width: 4.0,
                                          ),
                                          Obx(
                                            () => Text(
                                              '第${index.value + 1}/$pages页',
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 4.0,
                                          ),
                                          Button(
                                              child: const Icon(
                                                  FluentIcons.page_right),
                                              onPressed: () {
                                                index.value = min(
                                                    pages - 1, index.value + 1);
                                                // setState(() {});
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
                ),
                const SizedBox(
                  width: 16.0,
                ),
                Expanded(
                  child: Container(
                    height: height.toDouble(),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(100),
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(
                                '报警信息',
                                style: TextStyle(color: Colors.white, fontSize: 20),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
