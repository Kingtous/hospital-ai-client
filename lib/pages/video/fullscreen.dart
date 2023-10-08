import 'dart:async';
import 'dart:math';

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
  late Timer timer;
  late final Player player;

  @override
  void initState() {
    super.initState();
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
                    padding: EdgeInsets.all(4.0),
                    width: 400,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Button(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('返回'),
                        )
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
                                ),
                        ),
                        Container(
                          decoration: BoxDecoration(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              Obx(
                                () => Offstage(
                                  offstage: !isLive.value,
                                  child: SizedBox(
                                    width: 50,
                                    child: Container(
                                      color: Colors.red,
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        "LIVE",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
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
        label:
            '${pastSecondsFromStart.value ~/ 3600}:${(pastSecondsFromStart.value % 3600) ~/ 60}:${pastSecondsFromStart.value % 60}',
        onChanged: (s) {
          pastSecondsFromStart.value = s.floor();
        },
        onChangeStart: (s) {
          timer.cancel();
        },
        onChangeEnd: (s) {
          print("changed: $s");
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
              _loadVideoOrPlayback();
            }
          }
          timer = Timer.periodic(const Duration(seconds: 1), _onTimeTick);
        });
  }

  void _onTimeTick(Timer timer) {
    pastSecondsFromStart.value = min(seconds, pastSecondsFromStart.value + 1);
    // debugPrint(pastSecondsFromStart.toString());
    debugPrint("${player.state.playlist}");
  }

  void _loadVideoOrPlayback() async {
    var url = "";
    if (isLive.value) {
      url = getRtSpStreamUrl(widget.cam, mainStream: false);
    } else {
      final st = DateTime.fromMillisecondsSinceEpoch(
          currentPlayingTim.value.millisecondsSinceEpoch +
              pastSecondsFromStart.value * 1000 -
              kUtcTimeMsOffset);
      final ed = DateTime.fromMillisecondsSinceEpoch(
          (currentPlayingTim.value.millisecondsSinceEpoch + seconds * 1000) -
              kUtcTimeMsOffset);
      url = getRtspBackTrackUrl(widget.cam, st, ed);
    }
    // print("playing: $url");
    await player.open(Media(url), play: true);
    print(player.state.playing);
  }
}
