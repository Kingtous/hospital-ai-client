import 'dart:convert';

import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/camera_model.dart';

const kRTSPVideoModelJsonKey = 'rtsp_video_model';

class VideoModel {
  late final Map<String, PlayableDevice> _playerMap;
  Map<String, PlayableDevice> get playerMap => _playerMap;

  VideoModel() {
    _playerMap = <String, PlayableDevice>{};
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

  PlayableDevice? get(String id) {
    return _playerMap[id];
  }
}
