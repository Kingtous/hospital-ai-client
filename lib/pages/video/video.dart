import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' hide Colors;
import 'package:get/get.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/components/video_widget.dart';
import 'package:hospital_ai_client/constants.dart';

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
    const height = kThumbNailLiveHeight * 3 + 50 + 8 + 40;
    return Stack(
      children: [
        SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: ColoredBox(color: Color(0xFFE7F3FF))),
        Image.asset(
          'assets/images/frame.png',
          fit: BoxFit.cover,
        ),
        Image.asset(
          'assets/images/frame_header.png',
          height: 88,
          width: double.infinity,
          fit: BoxFit.fill,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '大数据监控平台',
                  style: TextStyle(
                      color: Color(0xFF409EFF),
                      fontSize: 30,
                      fontWeight: FontWeight.w400),
                ),
                Text('Hospital big data monitoring platform',
                    style: TextStyle(
                        color: Color(0xFF409EFF),
                        fontSize: 18,
                        fontWeight: FontWeight.w400))
              ],
            ),
            
          ],
        ),
        Container(
          margin: EdgeInsets.only(top: 88),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 8.0,
                  ),
                  SizedBox(
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
                                  horizontal: 16.0, vertical: 8.0),
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
                                ..sort((c1, c2) {
                                  return c1.name.compareTo(c2.name);
                                });
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
                                                    height: kThumbNailLiveHeight
                                                        .toDouble(),
                                                    child: VideoLive(
                                                      cam: e,
                                                      width: kThumbNailLiveWidth
                                                          .toDouble(),
                                                      height: kTextTabBarHeight
                                                          .toDouble(),
                                                      type: LiveType.thumbnail,
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ...List.generate(
                                  10,
                                  (index) => Row(
                                        children: [
                                          Expanded(
                                            child: InfoBar(
                                              title: Text('摄像头$index'),
                                              isLong: false,
                                              content: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text('白大褂报警'),
                                                  Button(
                                                    child: Icon(
                                                        FluentIcons.page_right),
                                                    onPressed: () {},
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
