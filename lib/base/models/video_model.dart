import 'dart:async';

import 'package:get/get.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/camera_model.dart';
import 'package:hospital_ai_client/base/models/dao/cam.dart';
import 'package:hospital_ai_client/base/models/dao/room.dart';
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

  Future<List<Cam>> getAllCams() async {
    return appDB.camDao.getAll();
  }

  Future<void> remove(Cam cam) async {
    final dev = _playerMap.remove(cam);
    if (dev != null) {
      appDB.camDao.deleteCam(cam);
    }
  }

  Future<Room> addRoom(Room room) async {
    final id = await appDB.roomDao.insertRoom(room);
    return room..id = id;
  }

  Future<bool> addCamToRoom(Cam cam, Room room) async {
    if (_playerMap[cam] != null) {
      return false;
    }
    final id = await appDB.camDao.addCam(cam, room);
    cam.id = id;
    if (cam.camType == CamType.rtsp.index) {
      final rtspCam = RTSPCamera(cam.name, rtspUrl: cam.url);
      await rtspCam.init();
      _playerMap[cam] = rtspCam;
      return true;
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

  Future<List<Room>> getRooms() {
    return appDB.roomDao.getRooms();
  }

  Future<void> deleteRoom(Room e) {
    return appDB.roomDao.deleteRoom(e);
  }

  Future<void> updateCam(Cam cam) {
    return appDB.camDao.updateCam(cam);
  }

  Future<void> deleteCam(Cam cam) {
    return appDB.camDao.deleteCam(cam);
  }
}
