import 'dart:math';

import 'package:bruno/bruno.dart';
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
import 'package:hospital_ai_client/components/bar_chart.dart';

import '../../base/models/dao/alerts.dart';
import '../../components/local_chart_axis.dart';

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
                child: FutureBuilder(
                    future: videoModel.getAllowedCams(),
                    builder: (context, data) {
                      if (!data.hasData) {
                        return Center(
                          child: Text('加载中 ${data.hasError ? data.error : ''}'),
                        );
                      }
                      final allowedCams = data.data!;
                      return Obx(
                        () {
                          var keys =
                              videoModel.playerMap.keys.toList(growable: false)
                                ..sort((c1, c2) {
                                  return c1.name.compareTo(c2.name);
                                });
                          keys = keys
                              .where((element) => allowedCams.contains(element))
                              .toList();

                          final pages = (keys.length / 9).ceil();
                          // index.value = min(index.value, pages - 1);
                          final pageKeys = keys
                              .skip(index.value * 9)
                              .take(9)
                              .toList(growable: false);
                          final nineGridCams = List.generate(
                              9,
                              (index) => index < pageKeys.length
                                  ? pageKeys[index]
                                  : null);
                          return Column(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 16.0,
                                          ),
                                          Expanded(
                                            child: NineGridLive(
                                                cams: nineGridCams.toList()),
                                          ),
                                          SizedBox(
                                            width: 50,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Transform.rotate(
                                                  angle: pi / 2,
                                                  child: Button(
                                                      child: const Icon(
                                                          FluentIcons
                                                              .page_left),
                                                      onPressed: () {
                                                        index.value = max(
                                                            0, index.value - 1);
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
                                                      style: TextStyle(
                                                          color: Colors.blue),
                                                    ),
                                                  ),
                                                const SizedBox(
                                                  height: 16.0,
                                                ),
                                                Transform.rotate(
                                                  angle: pi / 2,
                                                  child: Button(
                                                      child: const Icon(
                                                          FluentIcons
                                                              .page_right),
                                                      onPressed: () {
                                                        index.value = min(
                                                            pages - 1,
                                                            index.value + 1);
                                                        // setState(() {});
                                                      }),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 400,
                                      child: AlertStatTables(),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(flex: 1, child: const AlertStatCharts())
                            ],
                          );
                        },
                      );
                    }),
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
        ],
      ),
    );
  }

  Widget _buildRtAlertTable() {
    return Frame(
      title: Text('实时报警'),
      content: Obx(
        () => ListView.builder(
          itemBuilder: ((context, index) {
            final item = alertsModel.rtAlertsRx[index];
            final dt = DateTime.fromMillisecondsSinceEpoch(item.createAt);
            return Container(
              height: 40,
              margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              padding: EdgeInsets.symmetric(horizontal: 6.0),
              decoration: BoxDecoration(color: Color(0x1F12ADFF)),
              child: Row(
                children: [
                  SizedBox(
                    width: 8.0,
                  ),
                  Image.asset(
                    'assets/images/alert.png',
                  ),
                  SizedBox(
                    width: 14.0,
                  ),
                  Text(
                    "${dt.toLocal().toString()}",
                    style: TextStyle(fontSize: 12),
                  ),
                  Expanded(
                      child: Text(
                    '${item.roomName}-${item.camName}',
                    style: TextStyle(color: Color(0xFF415B73)),
                  )),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      '查看',
                      style: TextStyle(color: Color(0xFFFF222F)),
                    ),
                  ),
                  SizedBox(
                    width: 13,
                  )
                ],
              ),
            );
          }),
          itemExtent: 40,
          itemCount: alertsModel.rtAlertsRx.length,
        ),
      ),
    );
  }

  Widget _buildHistoryAlertTable() {
    return const Frame(
      title: Text('历史列表'),
      content: HistoryAlertTable(),
    );
  }
}

class HistoryAlertTable extends StatefulWidget {
  const HistoryAlertTable({super.key});

  @override
  State<HistoryAlertTable> createState() => _HistoryAlertTableState();
}

class _HistoryAlertTableState extends State<HistoryAlertTable> {
  static const titleStyle = TextStyle(color: Color(0xFF415B73));
  static const bodyStyle = TextStyle(color: Color(0xFF415B73));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 40,
          color: Color(0x1F12ADFF),
          child: Row(
            children: [
              Expanded(
                  child: Text(
                '报警事件',
                textAlign: TextAlign.center,
                style: titleStyle,
              )),
              Expanded(
                  child: Text(
                '报警位置',
                textAlign: TextAlign.center,
                style: titleStyle,
              )),
              Expanded(
                  child: Text(
                '报警时间',
                textAlign: TextAlign.center,
                style: titleStyle,
              )),
            ],
          ),
        ),
        Expanded(
          child: Obx(
            () => ListView.builder(
              itemBuilder: (context, index) {
                var alert = alertsModel.historyAlertsRx[index];
                var ca = DateTime.fromMillisecondsSinceEpoch(alert.createAt);
                return Column(
                  children: [
                    Container(
                      height: 39,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              AlertType.values[alert.alertType].toHumanString(),
                              textAlign: TextAlign.center,
                              style: bodyStyle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${alert.roomName}',
                              textAlign: TextAlign.center,
                              style: bodyStyle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${ca.year}-${ca.month}-${ca.day}',
                              textAlign: TextAlign.center,
                              style: bodyStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.0),
                      height: 1,
                      color: Color(0xFF129BFF),
                    )
                  ],
                );
              },
              itemExtent: 40,
              itemCount: alertsModel.historyAlertsRx.length,
            ),
          ),
        )
      ],
    );
  }
}

class AlertStatCharts extends StatefulWidget {
  const AlertStatCharts({super.key});

  @override
  State<AlertStatCharts> createState() => _AlertStatChartsState();
}

class _AlertStatChartsState extends State<AlertStatCharts> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<int> dataTest = [5, 6, 5, 9, 5];
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
          const SizedBox(
            width: 20,
          ),
          SizedBox(width: 400, child: _buildCamAlertTable(dataTest))
        ],
      ),
    );
  }

  Widget _buildCamAlertTable(List<int> res) {
    ///左侧提示语句
    final li = kMockAlertsData.toList();

    ///y轴最大值，设置最小值是10，如果小于10，则等于10
    double yMax = _getMaxValueForDemo1(res) * 1.1;
    yMax = yMax < 10 ? 10 : yMax;

    ///y轴刻度
    List<LocalAxisItem> items = _getYAxisItem(res);

    ///将传进来的数据进行转换
    List<LocalBrnProgressBarItem> barItems = [];
    for (int i = 0; i < res.length; i++) {
      barItems.add(LocalBrnProgressBarItem(
          text: res[i].toString(), value: res[i].toDouble()));
    }

    return Frame(
      title: Text('科室报警统计'),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: li
                  .map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              padding: EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Defaults.colors10[li.indexOf(e)])),
                              child: ColoredBox(
                                  color: Defaults.colors10[li.indexOf(e)]),
                            ),
                            SizedBox(
                              width: 6.0,
                            ),
                            Expanded(
                              child: Text(
                                '${e}',
                                style: TextStyle(
                                    color: Color(0xFF415B73), fontSize: 12),
                                overflow: TextOverflow.clip,
                              ),
                            )
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          //定制化组件
          BarChart(
            barChartStyle: LocalBarChartStyle.vertical,
            xAxis: LocalChartAxisX(axisItemList: [
              LocalAxisItem(showText: '画面一'),
              LocalAxisItem(showText: '画面二'),
              LocalAxisItem(showText: '画面三'),
              LocalAxisItem(showText: '画面四'),
              LocalAxisItem(showText: '画面五'),
            ]),
            barBundleList: [
              LocalBrnProgressBarBundle(barList: barItems),
            ],
            yAxis: LocalChartAxisY(

                ///Y轴坐标刻度
                axisItemList: items),
            singleBarWidth: 8,
            barGroupSpace: 32,
            barMaxValue: yMax,
            onBarItemClickInterceptor:
                (barBundleIndex, barBundle, barGroupIndex, barItem) {
              return true;
            },
          ),
          //官网组件
          // BrnProgressBarChart(
          //   barChartStyle: BarChartStyle.vertical,
          //   xAxis: ChartAxis(axisItemList: [
          //     AxisItem(showText: '示例1'),
          //     AxisItem(showText: '示例2'),
          //     AxisItem(showText: '示例3'),
          //     AxisItem(showText: '示例4'),
          //     AxisItem(showText: '示例5'),
          //     AxisItem(showText: '示例6'),
          //     AxisItem(showText: '示例7'),
          //     AxisItem(showText: '示例8'),
          //     AxisItem(showText: '示例9'),
          //     AxisItem(showText: '示例10'),
          //   ]),
          //   barBundleList: [
          //     BrnProgressBarBundle(barList: [
          //       BrnProgressBarItem(
          //           text: '示例11', value: 5, hintValue: 15, showBarValueText: "1122334"),
          //       BrnProgressBarItem(text: '示例12', value: 20, selectedHintText: '示例12:20'),
          //       BrnProgressBarItem(
          //           text: '示例13',
          //           value: 30,
          //           selectedHintText: '示例13:30\n示例13:30\n示例13:30\n示例13:30\n示例13:30\n示例13:30'),
          //       BrnProgressBarItem(text: '示例14', value: 25),
          //       BrnProgressBarItem(text: '示例15', value: 21),
          //       BrnProgressBarItem(text: '示例16', value: 28),
          //       BrnProgressBarItem(text: '示例17', value: 15),
          //       BrnProgressBarItem(text: '示例18', value: 11),
          //       BrnProgressBarItem(text: '示例19', value: 30),
          //       BrnProgressBarItem(text: '示例110', value: 24),
          //     ], colors: [
          //       Color(0xff1545FD),
          //       Color(0xff0984F9)
          //     ]),
          //     BrnProgressBarBundle(barList: [
          //       BrnProgressBarItem(text: '示例21', value: 20, hintValue: 15),
          //       BrnProgressBarItem(text: '示例22', value: 15, selectedHintText: '示例12:20'),
          //       BrnProgressBarItem(
          //           text: '示例23',
          //           value: 30,
          //           selectedHintText: '示例13:30\n示例13:30\n示例13:30\n示例13:30\n示例13:30\n示例13:30'),
          //       BrnProgressBarItem(text: '示例24', value: 20),
          //       BrnProgressBarItem(text: '示例25', value: 28),
          //       BrnProgressBarItem(text: '示例26', value: 25),
          //       BrnProgressBarItem(text: '示例27', value: 17),
          //       BrnProgressBarItem(text: '示例28', value: 14),
          //       BrnProgressBarItem(text: '示例29', value: 36),
          //       BrnProgressBarItem(text: '示例210', value: 29),
          //     ], colors: [
          //       Color(0xff01D57D),
          //       Color(0xff01D57D)
          //     ]),
          //   ],
          //   yAxis: ChartAxis(axisItemList: [
          //     AxisItem(showText: '10'),
          //     AxisItem(showText: '20'),
          //     AxisItem(showText: '30')
          //   ]),
          //   singleBarWidth: 30,
          //   barGroupSpace: 30,
          //   barMaxValue: 60,
          //   onBarItemClickInterceptor: (barBundleIndex, barBundle, barGroupIndex, barItem) {
          //     return true;
          //   },
          // )
        ],
      ),
    );
  }

  Widget _buildCamAlertTypeTable() {
    final li = kMockDataType.entries.toList();
    return Frame(
      title: Text('报警类型分布'),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: KPieChart(
              data: KPieChartData(
                  kMockDataType.map(
                      (key, value) => MapEntry(key.toHumanString(), value)),
                  '例'),
            ),
          ),
          SizedBox(
            width: 8,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: li
                  .map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              padding: EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Defaults.colors10[li.indexOf(e)])),
                              child: ColoredBox(
                                  color: Defaults.colors10[li.indexOf(e)]),
                            ),
                            SizedBox(
                              width: 6.0,
                            ),
                            Expanded(
                              child: Text(
                                '${e.key.toHumanString()} ${e.value}例',
                                style: TextStyle(color: Color(0xFF415B73)),
                                overflow: TextOverflow.clip,
                              ),
                            )
                          ],
                        ),
                      ))
                  .toList(),
            ),
          )
        ],
      ),
    );
  }

  _buildCamDataStatTable() {
    return Obx(
      () {
        final alerts = alertsModel.rtAlertsRx;
        List<int> alertsData = getRtLines(alerts);
        return Frame(
            title: Text("报警数据统计"),
            content: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 0,
                    ),
                    Expanded(
                      child: BrnBrokenLine(
                        showPointDashLine: true,
                        yHintLineOffset: 30,
                        isTipWindowAutoDismiss: false,
                        lines: [
                          BrnPointsLine(
                            isShowPointText: false,
                            lineWidth: 3,
                            pointRadius: 4,
                            isShowPoint: true,
                            isCurve: true,
                            points: _linePointsForDemo1(alertsData),
                            shaderColors: [
                              Colors.green.withOpacity(0.3),
                              Colors.green.withOpacity(0.01)
                            ],
                            lineColor: Colors.green,
                          )
                        ],
                        size: Size(
                          MediaQuery.of(context).size.width / 3 + 100,
                          MediaQuery.of(context).size.height / 5 - 50,
                        ),
                        isShowXHintLine: true,
                        //X 轴刻度数据
                        xDialValues: _getXDialValuesForDemo1(alertsData),
                        //X 轴展示范围最小值
                        xDialMin: 0,
                        //X 轴展示范围最大值
                        xDialMax: _getXDialValuesForDemo1(alertsData)
                            .length
                            .toDouble(),
                        //Y 轴刻度数据
                        yDialValues: _getYDialValuesForDemo1(alertsData),
                        //Y 轴展示范围最小值
                        yDialMin: 0,
                        //Y 轴展示范围最大值,断言>0
                        yDialMax: _getMaxValueForDemo1(alertsData) <= 10
                            ? 10
                            : _getMaxValueForDemo1(alertsData),
                        isHintLineSolid: false,
                        isShowYDialText: true,
                        isShowXDialText: true,
                      ),
                    )
                  ],
                ))
              ],
            ));
      },
    );
  }

  List<BrnPointData> _linePointsForDemo1(List<int> brokenData) {
    List<int> hours = List<int>.generate(12, (index) => index);
    return hours.map((hour) {
      int dataIndex = hour; // 获取对应的brokenData索引
      int value = brokenData[hour];
      if (hour == 12) {
        //24点和0点值一样
        value = brokenData[0];
      }
      return BrnPointData(
        pointText: value.toString(),
        x: dataIndex.toDouble(),
        y: double.parse(value.toString()),
        lineTouchData: BrnLineTouchData(
          tipWindowSize: Size(60, 40),
          onTouch: () {
            return value.toString();
          },
        ),
      );
    }).toList();
  }

  List<LocalAxisItem> _getYAxisItem(List<int> axisData) {
    double max = _getMaxValueForDemo1(axisData) * 1.1;
    int step = ((max - 0) / 5).ceil();
    List<LocalAxisItem> yAxisData = [];

    if (max <= 10) {
      max = 10;
      step = 2;
      for (int index = 0; index <= 5; index++) {
        yAxisData.add(LocalAxisItem(
          showText: (0 + index * step).ceilToDouble().toInt().toString(),
        ));
      }
    } else {
      for (int index = 0; index <= 5; index++) {
        yAxisData.add(LocalAxisItem(
          showText: (0 + index * step).ceilToDouble().toInt().toString(),
        ));
      }
    }

    ///把0去掉
    yAxisData.removeAt(0);
    return yAxisData;
  }

  List<BrnDialItem> _getYDialValuesForDemo1(List<int> brokenData) {
    // double min = _getMinValueForDemo1(brokenData);
    double max = _getMaxValueForDemo1(brokenData) * 1.1;
    int step = ((max - 0) / 5).ceil();
    List<BrnDialItem> _yDialValue = [];
    //如果没有预警或者预警过低会报错或导致折线图超出预期大小
    if (max <= 10) {
      max = 10;
      step = 2;
      for (int index = 0; index <= 5; index++) {
        _yDialValue.add(BrnDialItem(
          dialText: '${(0 + index * step).ceil()}',
          dialTextStyle: TextStyle(fontSize: 12.0, color: Color(0xFF999999)),
          value: (0 + index * step).ceilToDouble(),
        ));
      }
    }
    // double dValue = (max - min) / 10;
    else {
      for (int index = 0; index <= 5; index++) {
        _yDialValue.add(BrnDialItem(
          dialText: '${(0 + index * step).ceil()}',
          dialTextStyle: TextStyle(fontSize: 12.0, color: Color(0xFF999999)),
          value: (0 + index * step).ceilToDouble(),
        ));
      }
    }

    return _yDialValue;
  }

  double _getMinValueForDemo1(List<int> brokenData) {
    double minValue = double.tryParse(brokenData[0].toString()) ?? 0;
    for (int point in brokenData) {
      minValue = min(double.tryParse(point.toString()) ?? 0, minValue);
    }
    return minValue;
  }

  double _getMaxValueForDemo1(List<int> brokenData) {
    double maxValue = double.tryParse(brokenData[0].toString()) ?? 0;
    for (int point in brokenData) {
      maxValue = max(double.tryParse(point.toString()) ?? 0, maxValue);
    }
    return maxValue;
  }

  List<BrnDialItem> _getXDialValuesForDemo1(List<int> brokenData) {
    List<BrnDialItem> _xDialValue = [];
    for (int index = 0; index < brokenData.length; index++) {
      // int hour = brokenData[index] % 24;
      //返回"xx:00"的形式
      String dialText = '${(index * 2).toString().padLeft(2, '0')}:00';

      _xDialValue.add(BrnDialItem(
        dialText: dialText,
        dialTextStyle:
            TextStyle(fontSize: 12.0, color: Color(0xFF999999), height: 1.0),
        value: index.toDouble(),
      ));
    }
    return _xDialValue;
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
                    height: kThumbNailLiveHeight.toDouble(),
                    type: LiveType.thumbnail,
                  ),
                ),
              ),
            ],
          );
  }
}
