import 'dart:convert';

import 'package:get/get.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/camera_model.dart';
import 'package:media_kit/media_kit.dart';

const kRTSPVideoModelJsonKey = 'rtsp_video_model';

class VideoModel {
  late final RxMap<String, PlayableDevice> _playerMap;
  RxMap<String, PlayableDevice> get playerMap => _playerMap;

  VideoModel() {
    _playerMap = RxMap();
    init();
  }

  void init() {
    final list = perf.getStringList(kRTSPVideoModelJsonKey) ?? [];
    for (final item in list) {
      final map = jsonDecode(item);
      if (map != null) {
        add(RTSPCamera.fromJson(map));
      }
    }
  }

  Future<void> remove(String id) async {
    _playerMap.remove(id);
    await perf.setStringList(kRTSPVideoModelJsonKey, _playerMap.keys.toList());
  }

  Future<void> store() async {
    await perf.setStringList(
        kRTSPVideoModelJsonKey,
        _playerMap.values
            .whereType<RTSPCamera>()
            .map((e) => jsonEncode(e.toJson()))
            .toList());
  }

  Future<void> add(PlayableDevice device) async {
    if (_playerMap[device.id] != null) {
      _playerMap[device.id]!.dispose();
      _playerMap.remove(device.id);
    }
    _playerMap[device.id] = device;
    await store();
  }

  PlayableSource? get(String id) {
    return _playerMap[id];
  }

  Player? getPlayablePlayer(String id) {
    if (_playerMap.containsKey(id)) {
      if (_playerMap[id]! is CanPlayViaPlayer) {
        return (_playerMap[id]! as CanPlayViaPlayer).player;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  String validate(String id) {
    if (playerMap[id] != null) {
      return "已有同名设备";
    }
    return "";
  }
}
