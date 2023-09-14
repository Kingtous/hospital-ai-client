import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
part 'camera_model.g.dart';

abstract interface class Playable {
  // playable id
  String get id;

  Future<void> startPlay();
  // 重试
  Future<void> reload();

  Future<void> pause();

  Future<void> stop();

  Future<void> dispose();
}

abstract class PlayableDevice extends Playable {
  static Future<void> addNewDevice(BuildContext context) async {}
}

mixin GUIConfigurable on PlayableDevice {
  Widget buildForm(BuildContext context, {VoidCallback? onComplete});
}

mixin CanPlayViaPlayer on PlayableDevice {
  Player get player;
}

@JsonSerializable()
class RTSPCamera extends PlayableDevice
    with GUIConfigurable
    implements Playable, CanPlayViaPlayer {
  late String rtspUrl;
  late String id;
  @JsonKey(includeFromJson: false)
  late final Player player;
  @JsonKey(includeFromJson: false)
  var isPlaying = false;

  RTSPCamera(this.id, {required this.rtspUrl}) {
    assert(rtspUrl.startsWith('rtsp://'));
    player = Player();
    player.add(Media(rtspUrl));
    player.open(Playlist([Media(rtspUrl)]), play: false);
    // no sound needed.
    player.setVolume(0.0);
    player.setPlaylistMode(PlaylistMode.loop);
  }

  @override
  Future<void> dispose() {
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
    await player.next();
  }

  @override
  Future<void> startPlay() async {
    debugPrint('start play rtsp from $rtspUrl');
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
          prefix: Padding(
            padding: const EdgeInsets.all(8.0),
            child: const Text('设备RTSP地址'),
          ),
          controller: TextEditingController(text: rtspUrl),
          onChanged: (s) {
            newUrl = s;
          },
        ),
        SizedBox(
          height: 8.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FilledButton(
                child: Text('保存'),
                onPressed: () {
                  if (!newUrl.startsWith('rtsp://')) {
                    showDialog(
                        context: context,
                        builder: (context) => ContentDialog(
                              title: Text('数据有误'),
                              content: Text('地址不合法，应该以rtsp://开头'),
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
                    videoModel.store();
                    videoModel.playerMap.refresh();
                    onComplete?.call();
                  }
                }),
            SizedBox(
              width: 4.0,
            ),
            Button(
                child: Text('取消'),
                onPressed: () {
                  onComplete?.call();
                }),
          ],
        )
      ],
    );
  }

  static Future<void> addNewDevice(BuildContext context) async {
    var rtspUrl = "";
    var id = "";
    var msg = "";
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
                  SizedBox(
                    height: 4.0,
                  ),
                  TextBox(
                    prefix: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text('设备名称'),
                    ),
                    maxLength: 50,
                    onChanged: (s) {
                      id = s;
                    },
                  ),
                  TextBox(
                    prefix: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text('设备串流地址'),
                    ),
                    onChanged: (s) {
                      rtspUrl = s;
                    },
                  )
                ],
              ),
              actions: [
                FilledButton(
                    child: const Text('确定'),
                    onPressed: () {
                      msg = videoModel.validate(id);
                      if (msg.isNotEmpty) {
                        setState(() {});
                        return;
                      }
                      if (!rtspUrl.startsWith("rtsp://")) {
                        setState(() {});
                        msg = "设备地址格式有误，请与rtsp://开头";
                      }
                      videoModel.add(RTSPCamera(id, rtspUrl: rtspUrl));
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
}
