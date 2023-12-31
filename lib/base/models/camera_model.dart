import 'dart:async';
import 'dart:ffi' hide Size;
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/alerts_model.dart';
import 'package:hospital_ai_client/base/models/dao/cam.dart';
import 'package:hospital_ai_client/base/models/dao/room.dart';
import 'package:hospital_ai_client/components/table.dart';
import 'package:hospital_ai_client/constants.dart';
import 'package:hospital_ai_client/generated_bindings.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit/generated/libmpv/bindings.dart' as generated;
import 'package:media_kit/src/player/native/core/native_library.dart'
    as MediaKitNative;
import 'package:image/image.dart' as image;
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
part 'camera_model.g.dart';

const uuid = Uuid();

Future<String> getYoloModelPicsPath() async {
  try {
    var dir = Directory("D:\\");
    if (!await dir.exists()) {
      dir = await getRecorderHistoryFolder();
    }
    var storeDir = Directory(join(dir.path, "yolo\\"));
    if (!await storeDir.exists()) {
      await storeDir.create(recursive: true);
    }
    final p = join(storeDir.path, "${uuid.v4()}.png");
    return p;
  } catch (e) {
    kLogger.e(e);
    return "";
  }
}

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

  Future<AlertResult?> postImgToAlert();
}

abstract class PlayableDevice extends PlayableSource {
  static Future<void> addNewDevice(BuildContext context, Room room) async {}
}

mixin GUIConfigurable on PlayableDevice {
  Widget buildForm(BuildContext context, {VoidCallback? onComplete});
}

mixin CanPlayViaPlayer on PlayableDevice {
  Player get player;

  // VideoController get thumbNailController;
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
  bool inited = false;
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
  // @override
  // @JsonKey(includeFromJson: false)
  // late VideoController thumbNailController;
  int dbId;

  RTSPCamera(this.id, {required this.rtspUrl, required this.dbId}) {
    assert(rtspUrl.startsWith('rtsp://'));
    player = Player(
        configuration: const PlayerConfiguration(
            bufferSize: 32 * 1024 * 1024, muted: true));
    // no sound needed.
    player.setVolume(0.0);
    player.setPlaylistMode(PlaylistMode.loop);
    onError = player.stream.error.listen(_onStatus);
    onPlaying = player.stream.playing.listen((playing) {});
    // thumbNailController = VideoController(player,
    //     configuration: const VideoControllerConfiguration(
    //       width: kThumbNailLiveWidth,
    //       height: kThumbNailLiveHeight,
    //       enableHardwareAcceleration: true,
    //     ));
  }

  @override
  Future<void> init() async {
    if (inited) return;
    debugPrint('初始化縮略圖 for $rtspUrl');
    await player.open(Playlist([Media(rtspUrl)]), play: true);
    inited = true;
  }

  void _onStatus(String evt) {
    // no sound事件不需要响应
    if (evt.contains('no sound')) {
      return;
    }
    print("RTSP Player Error: $evt. retrying after 2 secs...");
    onError?.cancel();
    timer?.cancel();
    final ws = WeakReference(this);
    timer = Timer(const Duration(seconds: 3), () async {
      final self = ws.target;
      if (self != null) {
        self.onError = player.stream.error.listen(_onStatus);
        await self.reload();
        // print("🔧reload ${self.id} on Error: $evt. retrying");
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
    // debugPrint('pause rtsp from $rtspUrl');
    await player.pause();
  }

  @override
  Future<void> reload() async {
    // debugPrint('reload rtsp from $rtspUrl');
    await player.stop();
    await player.open(Media(rtspUrl), play: true);
  }

  @override
  Future<void> startPlay() async {
    if (player.state.playing) {
      // kLogger.w('player $id is already playing, ignore [startPlay] requests');
      // debugPrintStack();
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
    var id = "";
    var msg = "";
    var channelId = 1;
    var userName = "admin";
    var password = "";
    var port = 554;
    var host = "172.0.0.2";
    await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return ContentDialog(
              style: kContentDialogStyle,
              // title: Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     const Text('新增摄像头设备', style: TextStyle(
              //       fontSize: 20.0,
              //     ),),
              //   ],
              // ),
              constraints: BoxConstraints.loose(Size(500, 500)),
              content: Frame(
                title: const Text(
                  '新增摄像头设备',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
                content: Container(
                  margin: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: InfoBar(
                              title: const Text('新增设备说明'),
                              content: Text(msg.isNotEmpty ? msg : '设备名保证唯一'),
                              severity: msg.isNotEmpty
                                  ? InfoBarSeverity.warning
                                  : InfoBarSeverity.info,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      TextBox(
                        prefix: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('NVR IP'),
                        ),
                        autofillHints: ['172.0.0.2'],
                        onChanged: (s) {
                          host = s;
                        },
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      TextBox(
                        prefix: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('NVR 端口'),
                        ),
                        controller: TextEditingController(text: '554'),
                        autofillHints: ['554'],
                        onChanged: (s) {
                          int? tmpPort = int.tryParse(s);
                          port = tmpPort ?? 554;
                        },
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      TextBox(
                        prefix: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('NVR 用户名'),
                        ),
                        autofillHints: const ['admin'],
                        controller: TextEditingController(text: 'admin'),
                        onChanged: (s) {
                          userName = s;
                        },
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      TextBox(
                        prefix: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('NVR 密码'),
                        ),
                        onChanged: (p) {
                          password = p;
                        },
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      TextBox(
                        prefix: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('摄像头名称'),
                        ),
                        maxLength: 50,
                        onChanged: (s) {
                          id = s;
                        },
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ComboBox(
                                value: channelId,
                                onChanged: (newChannelId) {
                                  setState(() {
                                    if (newChannelId == null) {
                                      return;
                                    }
                                    channelId = newChannelId;
                                  });
                                },
                                items: [
                                  ...List.generate(512, (idx) {
                                    return ComboBoxItem(
                                      child: Text('摄像头通道号 ${idx + 1}'),
                                      value: idx + 1,
                                    );
                                  }),
                                ]),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: FilledButton(
                                child: const Text('确定'),
                                onPressed: () async {
                                  if (userName.isEmpty || password.isEmpty) {
                                    msg = "用户名或密码不能为空";
                                    setState(() {});
                                    return;
                                  }
                                  if (host.isEmpty) {
                                    msg = "地址内域名/IP地址不能为空";
                                    setState(() {});
                                    return;
                                  }
                                  bool res = await videoModel.checkCamName(id);
                                  if (!res) {
                                    msg = "摄像头名称已存在，请重新输入";
                                    setState(() {});
                                    return;
                                  }
                                  res = await videoModel.addCamToRoom(
                                      Cam(
                                          null,
                                          id,
                                          room.id!,
                                          channelId,
                                          CamType.rtsp.index,
                                          false,
                                          userName,
                                          password,
                                          port,
                                          host),
                                      room);
                                  if (res) {
                                    success(context, '添加成功');
                                  } else {
                                    warning(context, '添加失败');
                                  }
                                  Navigator.of(context).pop();
                                }),
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                          Expanded(
                            child: Button(
                                child: const Text('取消'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  static Future<void> updateDevice(BuildContext context, Cam cam) async {
    var id = cam.name;
    var msg = "";
    var channelId = cam.channelId;
    var userName = cam.authUser;
    var password = cam.password;
    var port = cam.port;
    var host = cam.host;
    await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return ContentDialog(
              style: kContentDialogStyle,
              constraints: BoxConstraints.loose(Size(500, 500)),
              content: Frame(
                title: const Text(
                  '更新摄像头设备',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
                content: Container(
                  margin: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: InfoBar(
                              title: const Text('更新设备说明'),
                              content: Text(msg.isNotEmpty ? msg : '设备名保证唯一'),
                              severity: msg.isNotEmpty
                                  ? InfoBarSeverity.warning
                                  : InfoBarSeverity.info,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8.0,
                      ),
                      TextBox(
                        prefix: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('NVR IP'),
                        ),
                        controller: TextEditingController(text: host),
                        autofillHints: ['172.0.0.2'],
                        onChanged: (s) {
                          cam.host = s;
                        },
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      TextBox(
                        prefix: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('NVR 端口'),
                        ),
                        controller:
                            TextEditingController(text: port.toString()),
                        autofillHints: ['554'],
                        onChanged: (s) {
                          int? tmpPort = int.tryParse(s);
                          cam.port = tmpPort ?? 554;
                        },
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      TextBox(
                        prefix: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('NVR 用户名'),
                        ),
                        autofillHints: const ['admin'],
                        controller: TextEditingController(text: userName),
                        onChanged: (s) {
                          cam.authUser = s;
                        },
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      TextBox(
                        prefix: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('NVR 密码'),
                        ),
                        controller: TextEditingController(text: password),
                        onChanged: (p) {
                          cam.password = p;
                        },
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      TextBox(
                        prefix: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('摄像头名称'),
                        ),
                        maxLength: 50,
                        controller: TextEditingController(text: id),
                        onChanged: (s) {
                          cam.name = s;
                        },
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ComboBox(
                                value: cam.channelId,
                                onChanged: (newChannelId) {
                                  setState(() {
                                    if (newChannelId == null) {
                                      return;
                                    }
                                    cam.channelId = newChannelId;
                                  });
                                },
                                items: [
                                  ...List.generate(512, (idx) {
                                    return ComboBoxItem(
                                      child: Text('摄像头通道号 ${idx + 1}'),
                                      value: idx + 1,
                                    );
                                  }),
                                ]),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: FilledButton(
                                child: const Text('确定'),
                                onPressed: () async {
                                  if (userName.isEmpty || password.isEmpty) {
                                    msg = "用户名或密码不能为空";
                                    setState(() {});
                                    return;
                                  }
                                  if (host.isEmpty) {
                                    msg = "地址内域名/IP地址不能为空";
                                    setState(() {});
                                    return;
                                  }
                                  bool res;

                                  ///首先判断摄像头名称是否更新
                                  if (cam.name != id) {
                                    res =
                                        await videoModel.checkCamName(cam.name);
                                    if (!res) {
                                      msg = "摄像头名称已存在，请重新输入";
                                      setState(() {});
                                      return;
                                    }
                                  }
                                  res = await videoModel.updateCamInRoom(cam);
                                  if (res) {
                                    success(context, '更新成功');
                                  } else {
                                    warning(context, '更新失败');
                                  }
                                  Navigator.of(context).pop();
                                }),
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                          Expanded(
                            child: Button(
                                child: const Text('取消'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  static RTSPCamera? fromDB(Cam cam) {
    return RTSPCamera(cam.name,
        rtspUrl: getRtSpStreamUrl(cam, mainStream: false), dbId: cam.id!);
  }

  @override
  Future<AlertResult?> postImgToAlert() async {
    final pp = (player.platform as NativePlayer);
    final path = await getYoloModelPicsPath();
    kLogger.d('postImgToAlert temp path: $path');
    return await compute(
        (msg) => _screenshot(msg),
        _ScreenshotData(pp.ctx.address, MediaKitNative.NativeLibrary.path, null,
            dbId, path));
  }
}

Future<AlertResult?> _screenshot(_ScreenshotData data) async {
  Pointer<PredictBean> bean =
      calloc.allocate<PredictBean>(sizeOf<PredictBean>());
  // ---------
  final mpv = generated.MPV(DynamicLibrary.open(data.lib));
  final ctx = Pointer<generated.mpv_handle>.fromAddress(data.ctx);
  // https://mpv.io/manual/stable/#command-interface-screenshot-raw
  final args = [
    'screenshot-raw',
    'video',
  ];
  final result = calloc<generated.mpv_node>();
  final pointers = args.map<Pointer<Utf8>>((e) {
    return e.toNativeUtf8();
  }).toList();
  final Pointer<Pointer<Utf8>> arr = calloc.allocate(args.join().length);
  for (int i = 0; i < args.length; i++) {
    arr[i] = pointers[i];
  }
  mpv.mpv_command_ret(
    ctx,
    arr.cast(),
    result.cast(),
  );
  final alertResult = AlertResult()..type = 0;
  if (result.ref.format == generated.mpv_format.MPV_FORMAT_NODE_MAP) {
    int? w, h, stride;
    Pointer<Void>? bytes;
    int? sz;

    final map = result.ref.u.list;
    for (int i = 0; i < map.ref.num; i++) {
      final key = map.ref.keys[i].cast<Utf8>().toDartString();
      final value = map.ref.values[i];
      switch (value.format) {
        case generated.mpv_format.MPV_FORMAT_INT64:
          switch (key) {
            case 'w':
              w = value.u.int64;
              break;
            case 'h':
              h = value.u.int64;
              break;
            case 'stride':
              stride = value.u.int64;
              break;
          }
          break;
        case generated.mpv_format.MPV_FORMAT_BYTE_ARRAY:
          switch (key) {
            case 'data':
              sz = value.u.ba.ref.size;
              bytes = value.u.ba.ref.data;
              break;
          }
          break;
      }
    }
    if (w != null &&
        h != null &&
        stride != null &&
        bytes != null &&
        sz != null) {
      // 随机生成一个uuid
      final uuidStr = data.uuidPath;
      final uuidPtr = uuidStr.toNativeUtf8();
      bean.ref.cam_id = data.camId;
      bean.ref.height = h;
      bean.ref.width = w;
      bean.ref.len = sz;
      bean.ref.stride = stride;
      bean.ref.bgra_data = bytes.cast();
      bean.ref.uuid = uuidPtr.cast();
      int ret = kNativeAlertApi.post_alert_img(bean);
      alertResult.type = ret;
      calloc.free(uuidPtr);
      if (ret > 0) {
        // 编码成jpg
        final pixels = image.Image(
          width: w,
          height: h,
          numChannels: 4,
        );
        final c = bytes.cast<Uint8>();
        for (final pixel in pixels) {
          final x = pixel.x;
          final y = pixel.y;
          final i = (y * stride) + (x * 4);
          pixel.b = c[i];
          pixel.g = c[i + 1];
          pixel.r = c[i + 2];
          pixel.a = c[i + 3];
        }
        final jpg = image.encodeJpg(
            image.copyResize(pixels, width: kAlertWidth),
            quality: 60);
        alertResult.jpg = jpg;
      }
      calloc.free(bean);
      // print(
      //     "check ${data.camId}: 模型预测返回：$ret, 耗时：${DateTime.now().difference(t1).inMilliseconds}ms");
    }
  }

  pointers.forEach(calloc.free);
  mpv.mpv_free_node_contents(result.cast());

  calloc.free(arr);
  calloc.free(result.cast());
  return alertResult;
}

class _ScreenshotData {
  final int ctx;
  final String lib;
  final String? format;
  final int camId;
  final String uuidPath;

  _ScreenshotData(
    this.ctx,
    this.lib,
    this.format,
    this.camId,
    this.uuidPath,
  );
}
