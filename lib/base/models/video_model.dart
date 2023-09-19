import 'dart:async';

import 'package:get/get.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/camera_model.dart';
import 'package:hospital_ai_client/base/models/dao/area.dart';
import 'package:hospital_ai_client/base/models/dao/cam.dart';
import 'package:media_kit/media_kit.dart';

const kRTSPVideoModelJsonKey = 'rtsp_video_model';

class VideoModel {
  late final RxMap<Cam, PlayableDevice> _playerMap;
  RxMap<Cam, PlayableDevice> get playerMap => _playerMap;

  VideoModel() {
    _playerMap = RxMap();
  }

  Future<void> init() async {
    // rtsp
    final cams = await appDB.camDao.getAll();
    for (final cam in cams) {
      if (cam.camType == CamType.rtsp.index) {
        final rtspCam = RTSPCamera.fromDB(cam)?..init();
        if (rtspCam != null) {
          _playerMap[cam] = rtspCam;
        }
      }
    }
  }

  Future<void> remove(Cam cam) async {
    final dev = _playerMap.remove(cam);
    if (dev != null) {
      appDB.camDao.deleteCam(cam);
    }
  }

  Future<bool> addCamToArea(Cam cam, Area area) async {
    if (_playerMap[cam] != null) {
      return false;
    }
    final id = await appDB.camDao.addCam(cam, area);
    final cams = await appDB.camDao.getCamById(id);
    if (cams.isEmpty) {
      return false;
    }
    if (cam.camType == CamType.rtsp.index) {
      final rtspCam = RTSPCamera.fromDB(cams.first);
      if (rtspCam != null) {
        _playerMap[cams.first] = rtspCam;
        return true;
      } else {
        return false;
      }
    } else {
      throw UnimplementedError('Unimplemented');
    }
  }

  PlayableSource? get(Cam cam) {
    return _playerMap[cam];
  }

  Cam? getPlayableByName(String name) {
    if (name.isEmpty) {
      return null;
    }
    return _playerMap.entries
        .where((element) => element.key.name == name)
        .map((e) => e.key)
        .firstOrNull;
  }

  Player? getPlayablePlayer(Cam cam) {
    if (_playerMap.containsKey(cam)) {
      if (_playerMap[cam]! is CanPlayViaPlayer) {
        return (_playerMap[cam]! as CanPlayViaPlayer).player;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  String validate(Cam cam) {
    if (playerMap[cam] != null) {
      return "已有同名设备";
    }
    return "";
  }
}
