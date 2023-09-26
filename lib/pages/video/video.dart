import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' hide Colors;
import 'package:get/get.dart';
import 'package:graphic/graphic.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/dao/cam.dart';
import 'package:hospital_ai_client/components/charts.dart';
import 'package:hospital_ai_client/components/table.dart';
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
    return Stack(
      children: [
        const SizedBox(
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
        Align(
            alignment: AlignmentDirectional.bottomStart,
            child: Image.asset(
              'assets/images/frame_bottom.png',
              width: double.infinity,
              height: 37,
            )),
        const Row(
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
          margin: const EdgeInsets.only(top: 88),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 4,
                child: Obx(
                  () {
                    final keys =
                        videoModel.playerMap.keys.toList(growable: false)
                          ..sort((c1, c2) {
                            return c1.name.compareTo(c2.name);
                          });
                    final pages = (keys.length / 9).ceil();
                    // index.value = min(index.value, pages - 1);
                    final pageKeys = keys
                        .skip(index.value * 9)
                        .take(9)
                        .toList(growable: false);
                    final nineGridCams = List.generate(
                        9,
                        (index) =>
                            index < pageKeys.length ? pageKeys[index] : null);
                    return Column(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 16.0,
                              ),
                              Expanded(
                                child:
                                    NineGridLive(cams: nineGridCams.toList()),
                              ),
                              SizedBox(
                                width: 50,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Transform.rotate(
                                      angle: pi / 2,
                                      child: Button(
                                          child:
                                              const Icon(FluentIcons.page_left),
                                          onPressed: () {
                                            index.value =
                                                max(0, index.value - 1);
                                            // setState(() {});
                                          }),
                                    ),
                                    const SizedBox(
                                      height: 16.0,
                                    ),
                                    if (pages > 0)
                                      Obx(
                                        () => Text(
                                          '第${index.value + 1}/$pages页',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                    const SizedBox(
                                      height: 16.0,
                                    ),
                                    Transform.rotate(
                                      angle: pi / 2,
                                      child: Button(
                                          child: const Icon(
                                              FluentIcons.page_right),
                                          onPressed: () {
                                            index.value =
                                                min(pages - 1, index.value + 1);
                                            // setState(() {});
                                          }),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Expanded(flex: 1, child: const AlertStatCharts())
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(
                width: 16.0,
              ),
              const Expanded(
                flex: 1,
                child: AlertStatTables(),
              ),
              const SizedBox(
                width: 16.0,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AlertStatTables extends StatefulWidget {
  const AlertStatTables({super.key});

  @override
  State<AlertStatTables> createState() => _AlertStatTablesState();
}

class _AlertStatTablesState extends State<AlertStatTables> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 560,
      child: Column(
        children: [
          Expanded(child: _buildRtAlertTable()),
          const SizedBox(
            height: 20,
          ),
          Expanded(child: _buildHistoryAlertTable()),
          const SizedBox(
            height: 20,
          ),
          Expanded(child: _buildCamAlertTable()),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildRtAlertTable() {
    return const Frame(title: Text('实时报警'), content: Offstage(),);
  }

  Widget _buildHistoryAlertTable() {
    return const Frame(title: Text('实时报警'), content: Offstage(),);
  }

  Widget _buildCamAlertTable() {
    return const Frame(title: Text('实时报警'), content:  Offstage() ,);
  }
}

class AlertStatCharts extends StatefulWidget {
  const AlertStatCharts({super.key});

  @override
  State<AlertStatCharts> createState() => _AlertStatChartsState();
}

class _AlertStatChartsState extends State<AlertStatCharts> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
      height: 271,
      child: Row(
        children: [
          const SizedBox(
            width: 16.0,
          ),
          Expanded(flex: 1, child: _buildCamAlertTypeTable()),
          const SizedBox(
            width: 20,
          ),
          Expanded(flex: 2, child: _buildCamDataStatTable()),
        ],
      ),
    );
  }

  Widget _buildCamAlertTypeTable() {
    final li = kMockDataType.entries.toList();
    return Frame(title: Text('报警类型分布'), content: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform(transform: Matrix4.identity()..rotateZ(0.1)..rotateY(0.1),
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: KPieChart(
                    data: KPieChartData(kMockDataType, '例'),
                  ),
                ),
              ),
              SizedBox(width: 16,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: li.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Container(
                      width: 12,
                      height: 12,
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        border: Border.all(color: Defaults.colors10[li.indexOf(e)])
                      ),
                      child: ColoredBox(color: Defaults.colors10[li.indexOf(e)]),
                    ),
                    SizedBox(width: 6.0,),
                    Expanded(
                      child: Text('${e.key} ${e.value}例', style: TextStyle(
                        color: Color(0xFF415B73)
                      ), overflow: TextOverflow.clip,),
                    )
                                  ],),
                  )).toList(),),
              )
            ],
          ),);
  }

  Widget _buildCamDataStatTable() {
    return const Frame(title: Text('报警数据统计'), content: Offstage(),);
  }
}

class NineGridLive extends StatelessWidget {
  final List<Cam?> cams;
  const NineGridLive({super.key, required this.cams})
      : assert(cams.length == 9);

  @override
  Widget build(BuildContext context) {
    const hg = SizedBox(
      width: 20,
    );
    const vg = SizedBox(
      height: 20,
    );
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(flex: 1, child: VideoLiveMain(e: cams[0])),
              hg,
              Expanded(flex: 1, child: VideoLiveMain(e: cams[1])),
              hg,
              Expanded(flex: 1, child: VideoLiveMain(e: cams[2])),
            ],
          ),
        ),
        vg,
        Expanded(
          child: Row(
            children: [
              Expanded(flex: 1, child: VideoLiveMain(e: cams[3])),
              hg,
              Expanded(flex: 1, child: VideoLiveMain(e: cams[4])),
              hg,
              Expanded(flex: 1, child: VideoLiveMain(e: cams[5])),
            ],
          ),
        ),
        vg,
        Expanded(
          child: Row(
            children: [
              Expanded(flex: 1, child: VideoLiveMain(e: cams[6])),
              hg,
              Expanded(flex: 1, child: VideoLiveMain(e: cams[7])),
              hg,
              Expanded(flex: 1, child: VideoLiveMain(e: cams[8])),
            ],
          ),
        ),
      ],
    );
  }
}

class VideoLiveMain extends StatelessWidget {
  final Cam? e;
  const VideoLiveMain({super.key, required this.e});

  Widget _buildPlaceHolder() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0x00CAE5FF), Color(0xFFAADCFF)])),
          width: 40,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...kDefaultName.codeUnits.map((code) => Text(
                    String.fromCharCode(code),
                    style: const TextStyle(
                        fontSize: 16.0,
                        color: Color(0xFF5292CA),
                        fontWeight: FontWeight.w400),
                  ))
            ],
          ),
        ),
        Expanded(
          child: SizedBox(
            key: ValueKey(e),
            width: kThumbNailLiveWidth.toDouble(),
            height: double.infinity,
            child: Container(
              decoration: BoxDecoration(
                  color: kBgColor, border: Border.all(color: Colors.white)),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/no_content.png',
                      height: 75,
                      fit: BoxFit.fitHeight,
                    ),
                    Text(
                      '暂无画面',
                      style: TextStyle(color: Color(0xFF7395B3)),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var e = this.e;
    return e == null
        ? _buildPlaceHolder()
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0x00CAE5FF), Color(0xFFAADCFF)])),
                width: 40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...e.name.codeUnits.map((code) => Text(
                          String.fromCharCode(code),
                          style: const TextStyle(
                              fontSize: 16.0,
                              color: Color(0xFF5292CA),
                              fontWeight: FontWeight.w400),
                        ))
                  ],
                ),
              ),
              Expanded(
                child: SizedBox(
                  key: ValueKey(e),
                  width: kThumbNailLiveWidth.toDouble(),
                  height: double.infinity,
                  child: VideoLive(
                    cam: e,
                    width: kThumbNailLiveWidth.toDouble(),
                    height: kTextTabBarHeight.toDouble(),
                    type: LiveType.thumbnail,
                  ),
                ),
              ),
            ],
          );
  }
}
