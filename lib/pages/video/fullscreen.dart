import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:bruno/bruno.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/dao/cam.dart';
import 'package:hospital_ai_client/components/header.dart';
import 'package:hospital_ai_client/components/video_control.dart';
import 'package:hospital_ai_client/components/video_widget.dart';
import 'package:hospital_ai_client/constants.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path_provider/path_provider.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:convert';


// 录像机是0区，我们是东八
const int kUtcTimeMsOffset = 1000 * 60 * 60 * 8;

class FullScreenLive extends StatefulWidget {
  final Cam cam;
  const FullScreenLive({super.key, required this.cam});

  @override
  State<FullScreenLive> createState() => _FullScreenLiveState();
}

class _FullScreenLiveState extends State<FullScreenLive> {
  VideoController? controller;
  // is Live
  RxBool isLive = true.obs;
  Rx<DateTime> currentPlayingTim = Rx(DateTime.now());
  int seconds = 60 * 60 * 24;
  RxInt pastSecondsFromStart = 0.obs;
  RxBool isRecording = false.obs;
  late Timer timer;
  late final Player player;
  late final Rx<Cam> cam;

  @override
  void initState() {
    super.initState();
    cam = widget.cam.obs;
    cam.listen((c) {
      _loadVideoOrPlayback();
    });
    timer = Timer.periodic(Duration(seconds: 1), _onTimeTick);
    final now = DateTime.now();
    currentPlayingTim.value = DateTime(now.year, now.month, now.day, 0, 0, 0);
    pastSecondsFromStart.value = (now.millisecondsSinceEpoch -
            currentPlayingTim.value.millisecondsSinceEpoch) ~/
        1000;
    player = Player(
        configuration: const PlayerConfiguration(
            title: '全屏播放器', bufferSize: 32 * 1024 * 1024));
    controller = VideoController(player,
        configuration: const VideoControllerConfiguration());
    _loadVideoOrPlayback();
  }

  @override
  void dispose() {
    timer.cancel();
    player.dispose();
    // check recorder
    recorder.stopRecording();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    return Column(
      children: [
        const Row(
          children: [
            Expanded(
              child: AppHeader(),
            )
          ],
        ),
        Expanded(
          child: NavigationView(
            content: Container(
              decoration: BoxDecoration(color: kBgColor),
              child: Row(
                children: [
                  Container(
                    color: kBgColor,
                    // padding: EdgeInsets.all(4.0),
                    width: 350,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                            Color(0x1F12ADFF),
                            Color(0x0012ADFF)
                          ])),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 8.0,
                              ),
                              Image.asset('assets/images/list_icon.png'),
                              Text(
                                '时间查询',
                                style: TextStyle(color: Color(0xFF415B73)),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        BrnCalendarView(
                          selectMode: SelectMode.single,
                          dateChange: (dt) {
                            currentPlayingTim.value = dt;
                            pastSecondsFromStart.value = 0;
                            isLive.value = false;
                            _loadVideoOrPlayback();
                          },
                          minDate: DateTime(2000),
                          maxDate: DateTime.now(),
                          rangeDateChange: (_) => DateTimeRange(
                              start: DateTime(2023), end: DateTime.now()),
                        ),
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                            Color(0x1F12ADFF),
                            Color(0x0012ADFF)
                          ])),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 8.0,
                              ),
                              Image.asset('assets/images/video_icon.png'),
                              Text(
                                '摄像头列表',
                                style: TextStyle(color: Color(0xFF415B73)),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Expanded(child: CamTreeView(selectedCam: cam)),
                        Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FilledButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('退出直播回放页'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: controller == null
                              ? const Center(
                                  child: Text('未找到源，请重试'),
                                )
                              : Video(
                                  controller: controller,
                                  controls: (state) => Obx(() => VideoControl2(
                                        state: state,
                                        cam: cam.value,
                                        type: LiveType.fullscreen,
                                        onRecordToggled: _onRecordToggled,
                                        isRecording: isRecording,
                                      )),
                                ),
                        ),
                        Container(
                          decoration: BoxDecoration(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 50,
                                child: Obx(
                                  () => Container(
                                    color: isLive.value
                                        ? Colors.red
                                        : Colors.grey.withOpacity(0.5),
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      isLive.value ? "直播" : '回放',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 16.0,
                              ),
                              Obx(
                                () => Text(
                                  '${cam.value.name}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(
                                width: 16.0,
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: Obx(() => _buildIndicator(context)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Obx(
                                  () => Text(
                                    '${pastSecondsFromStart.value ~/ 3600}:${(pastSecondsFromStart.value % 3600) ~/ 60}:${pastSecondsFromStart.value % 60}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator(BuildContext context) {
    // print(pastSecondsFromStart.value);
    // print(seconds);
    return Slider(
        value: pastSecondsFromStart.value.toDouble(),
        min: 0.0,
        max: seconds.toDouble(),
        style: SliderThemeData(labelBackgroundColor: Colors.grey),
        label:
            '${pastSecondsFromStart.value ~/ 3600}:${(pastSecondsFromStart.value % 3600) ~/ 60}:${pastSecondsFromStart.value % 60}',
        onChanged: (s) {
          pastSecondsFromStart.value = s.floor();
        },
        onChangeStart: (s) {
          timer.cancel();
        },
        onChangeEnd: (s) {
          // print("changed: $s");
          pastSecondsFromStart.value = s.floor();
          // 判断是否超过了今天
          final n = DateTime.now();
          if (n.millisecondsSinceEpoch -
                  (pastSecondsFromStart.value * 1000 +
                      currentPlayingTim.value.millisecondsSinceEpoch) <=
              0) {
            pastSecondsFromStart.value = (n.millisecondsSinceEpoch -
                    currentPlayingTim.value.millisecondsSinceEpoch) ~/
                1000;
            if (!isLive.value) {
              isLive.value = true;
              _loadVideoOrPlayback();
            }
          } else {
            if (isLive.value) {
              isLive.value = false;
            }
            _loadVideoOrPlayback();
          }
          timer = Timer.periodic(const Duration(seconds: 1), _onTimeTick);
        });
  }

  void _onTimeTick(Timer timer) {
    pastSecondsFromStart.value = min(seconds, pastSecondsFromStart.value + 1);
    // debugPrint(pastSecondsFromStart.toString());
    // debugPrint("${player.state.playlist}");
  }

  void _loadVideoOrPlayback() async {
    // print('loading video ${cam.value}');
    var url = "";
    if (isLive.value) {
      url = getRtSpStreamUrl(cam.value, mainStream: false);
    } else {
      final st = DateTime.fromMillisecondsSinceEpoch(
          currentPlayingTim.value.millisecondsSinceEpoch +
              pastSecondsFromStart.value * 1000 -
              kUtcTimeMsOffset);
      final ed = DateTime.fromMillisecondsSinceEpoch(
          (currentPlayingTim.value.millisecondsSinceEpoch + seconds * 1000) -
              kUtcTimeMsOffset);
      url = getRtspBackTrackUrl(cam.value, st, ed);
    }
    // print("playing: $url");
    player.setVolume(0);
    await player.open(Media(url), play: true);
    // print(player.state.playing);
  }

  void _onRecordToggled() async {
    final wc = WeakReference(context);
    final videoFolder = await getRecorderHistoryFolder();
    if (!await videoFolder.exists()) {
      await videoFolder.create(recursive: true);
    }
    if (isRecording.value) {
      if (wc.target != null) {
        BrnToast.show("视频已保存至${videoFolder.path}", wc.target!);
        recordModel.refresh();
      }
      await recorder.stopRecording();
      // launchUrl(dir.uri);
      isRecording.value = false;
    } else {
      if (!await videoFolder.exists()) {
        await videoFolder.create(recursive: true);
      }
      if (isLive.value) {
        final vPath =
            "${videoFolder.path}/${cam.value.id!}-${base64.encode(DateTime.now().toIso8601String().codeUnits)}.mp4";
        await recorder.recordRealtime(cam.value, vPath);
        isRecording.value = true;
      } else {
        final from = DateTime.fromMillisecondsSinceEpoch(
            currentPlayingTim.value.millisecondsSinceEpoch +
                pastSecondsFromStart.value * 1000);
        final vPath =
            "${videoFolder.path}/${cam.value.id!}-${base64.encode(from.toIso8601String().codeUnits)}.mp4";
        await recorder.recordFrom(cam.value, from, vPath);
        isRecording.value = true;
      }
    }
  }
}

class CamTreeView extends StatelessWidget {
  final Rx<Cam> selectedCam;
  const CamTreeView({super.key, required this.selectedCam});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: videoModel.getCamTree(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            final m = snapshot.data!;
            return Obx(
              () => TreeView(
                  selectionMode: TreeViewSelectionMode.single,
                  items: m.entries
                      .map((e) => TreeViewItem(
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${e.key.roomName}',
                                style: kTextStyle,
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                margin: EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                    color: kBlueColor,
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ],
                          ),
                          children: e.value
                              .map((e) => TreeViewItem(
                                  selected: selectedCam.value == e,
                                  onInvoked: (item, reason) async {
                                    selectedCam.value = e;
                                  },
                                  content: Row(
                                    children: [
                                      Image.asset('assets/images/cam_icon.png'),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        "${e.name}",
                                        style: kTextStyle,
                                      ),
                                    ],
                                  )))
                              .toList()))
                      .toList()),
            );
          } else {
            return Offstage();
          }
        }));
  }
}
