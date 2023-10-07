import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/dao/cam.dart';
import 'package:hospital_ai_client/base/models/dao/room.dart';
import 'package:hospital_ai_client/constants.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
part 'camera_model.g.dart';

abstract interface class PlayableSource {
  // playable id
  String get id;

  Future<void> init();

  Future<void> startPlay();
  // 重试
  Future<void> reload();

  Future<void> pause();

  Future<void> stop();

  Future<void> dispose();
}

abstract class PlayableDevice extends PlayableSource {
  static Future<void> addNewDevice(BuildContext context, Room room) async {}
}

mixin GUIConfigurable on PlayableDevice {
  Widget buildForm(BuildContext context, {VoidCallback? onComplete});
}

mixin CanPlayViaPlayer on PlayableDevice {
  Player get player;

  VideoController get thumbNailController;
}

mixin CamStorable on PlayableDevice {
  Cam toCam();
}

@JsonSerializable()
class RTSPCamera extends PlayableDevice
    with GUIConfigurable
    implements PlayableSource, CanPlayViaPlayer {
  late String rtspUrl;
  @override
  late String id;
  @override
  @JsonKey(includeFromJson: false)
  late final Player player;
  @JsonKey(includeFromJson: false)
  var isPlaying = false;
  @JsonKey(includeFromJson: false)
  Timer? timer;
  @JsonKey(includeFromJson: false)
  StreamSubscription<String>? onError;
  @JsonKey(includeFromJson: false)
  StreamSubscription<bool>? onPlaying;
  @override
  @JsonKey(includeFromJson: false)
  late VideoController thumbNailController;

  RTSPCamera(this.id, {required this.rtspUrl}) {
    assert(rtspUrl.startsWith('rtsp://'));
    player = Player();
    // no sound needed.
    player.setVolume(0.0);
    player.setPlaylistMode(PlaylistMode.loop);
    onError = player.stream.error.listen(_onStatus);
    onPlaying = player.stream.playing.listen((playing) {});
  }

  @override
  Future<void> init() async {
    print('初始化縮略圖 for $rtspUrl');
    thumbNailController = VideoController(player,
        configuration: const VideoControllerConfiguration(
          width: kThumbNailLiveWidth,
          height: kThumbNailLiveHeight,
        ));
    await player.open(Playlist([Media(rtspUrl)]), play: true);
  }

  void _onStatus(String evt) {
    print("RTSP Player Error: $evt. retrying after 2 secs...");
    onError?.cancel();
    timer?.cancel();
    final ws = WeakReference(this);
    timer = Timer(const Duration(seconds: 3), () async {
      final self = ws.target;
      if (self != null) {
        self.onError = player.stream.error.listen(_onStatus);
        await self.reload();
        print("🔧reload ${self.id} on Error: $evt. retrying");
        await self.startPlay();
      }
    });
  }

  @override
  Future<void> dispose() {
    timer?.cancel();
    onError?.cancel();
    onPlaying?.cancel();
    return player.dispose();
  }

  @override
  Future<void> pause() async {
    debugPrint('pause rtsp from $rtspUrl');
    await player.pause();
  }

  @override
  Future<void> reload() async {
    debugPrint('reload rtsp from $rtspUrl');
    await player.stop();
    await player.open(Media(rtspUrl), play: true);
  }

  @override
  Future<void> startPlay() async {
    if (player.state.playing) {
      debugPrint('player $id is already playing, ignore [startPlay] requests');
      debugPrintStack();
      return;
    }
    debugPrint(
        'start play rtsp from $rtspUrl, play queue: ${player.state.playlist.medias.length}');
    await player.play();
  }

  /// Connect the generated [_$PersonFromJson] function to the `fromJson`
  /// factory.
  factory RTSPCamera.fromJson(Map<String, dynamic> json) =>
      _$RTSPCameraFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$RTSPCameraToJson(this);

  @override
  Future<void> stop() async {
    debugPrint('player $id is stopping');
    await player.stop();
  }

  void save() async {}

  @override
  Widget buildForm(BuildContext context, {VoidCallback? onComplete}) {
    var newUrl = rtspUrl;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TextBox(
          prefix: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('设备RTSP地址'),
          ),
          controller: TextEditingController(text: rtspUrl),
          onChanged: (s) {
            newUrl = s;
          },
        ),
        const SizedBox(
          height: 8.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FilledButton(
                child: const Text('保存'),
                onPressed: () {
                  if (!newUrl.startsWith('rtsp://')) {
                    showDialog(
                        context: context,
                        builder: (context) => ContentDialog(
                              title: const Text('数据有误'),
                              content: const Text('地址不合法，应该以rtsp://开头'),
                              actions: [
                                Button(
                                    child: const Text('确定'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    })
                              ],
                            ));
                  } else {
                    (videoModel.playerMap[id]! as RTSPCamera).rtspUrl = newUrl;
                    videoModel.playerMap.refresh();
                    onComplete?.call();
                  }
                }),
            const SizedBox(
              width: 4.0,
            ),
            Button(
                child: const Text('取消'),
                onPressed: () {
                  onComplete?.call();
                }),
          ],
        )
      ],
    );
  }

  static Future<void> addNewDevice(BuildContext context, Room room) async {
    var rtspUrl = "";
    var id = "";
    var msg = "";
    var channelId = -1;
    var userName = "";
    var password = "";
    var port = 554;
    var host = "172.0.0.1";
    await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return ContentDialog(
              title: const Text('新增RTSP设备'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InfoBar(
                          title: const Text('新增设备说明'),
                          content: Text(msg.isNotEmpty
                              ? msg
                              : '设备名保证唯一，视频流地址应以rtsp://开头'),
                          severity: msg.isNotEmpty
                              ? InfoBarSeverity.warning
                              : InfoBarSeverity.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 4.0,
                  ),
                  TextBox(
                    prefix: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('设备名称'),
                    ),
                    maxLength: 50,
                    onChanged: (s) {
                      id = s;
                    },
                  ),
                  TextBox(
                    prefix: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('设备串流地址'),
                    ),
                    autofillHints: ['rtsp://'],
                    onChanged: (s) {
                      rtspUrl = s;
                    },
                  ),
                  ComboBox(items: [
                    ...List.generate(512, (idx) {
                      return ComboBoxItem(
                        child: Text('通道$idx'),
                        value: idx,
                      );
                    }),
                  ])
                ],
              ),
              actions: [
                FilledButton(
                    child: const Text('确定'),
                    onPressed: () async {
                      final rtspUri = Uri.tryParse(rtspUrl);
                      if (rtspUri == null) {
                        msg = "不是一个有效的URL地址";
                        setState(() {});
                        return;
                      }
                      print(rtspUri.scheme);
                      if (rtspUri.scheme != "rtsp") {
                        setState(() {});
                        msg = "设备地址格式有误，请与rtsp://开头";
                        return;
                      }
                      if (rtspUri.host.isEmpty) {
                        msg = "地址内域名/IP地址填写错误";
                        setState(() {});
                        return;
                      }
                      if (rtspUri.path.isEmpty) {
                        msg = "地址内没有path路径";
                        setState(() {});
                        return;
                      }
                      bool res = await videoModel.addCamToRoom(
                          Cam(null, id, room.id!, channelId, CamType.rtsp.index,
                              false, userName, password, port, host),
                          room);
                      if (res) {
                        success(context, '添加成功');
                      } else {
                        warning(context, '添加失败');
                      }
                      Navigator.of(context).pop();
                    }),
                FilledButton(
                    child: const Text('取消'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ],
            );
          });
        });
  }

  static RTSPCamera? fromDB(Cam cam) {
    return RTSPCamera(cam.name,
        rtspUrl: getRtSpStreamUrl(cam, mainStream: false));
  }
}
