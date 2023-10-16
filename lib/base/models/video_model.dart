import 'dart:async';

import 'package:flutter/widgets.dart';
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
  Timer? timer;

  VideoModel() {
    _playerMap = RxMap();
  }

  Future<void> init() async {
    // rtsp
    final cams = await appDB.camDao.getAll();
    for (final cam in cams) {
      if (cam.camType == CamType.rtsp.index) {
        final rtspCam = RTSPCamera.fromDB(cam);
        if (rtspCam != null) {
          _playerMap[cam] = rtspCam;
          if (cam.enableAlert) {
            debugPrint("init ${cam.name}");
            rtspCam.init();
          }
        }
      }
    }
    timer = Timer(const Duration(milliseconds: 200), _onAlertTick);
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
      final url =
          "rtsp://${cam.authUser}:${cam.password}@${cam.host}:${cam.port}/Streaming/Channels/${cam.channelId}02";
      final rtspCam = RTSPCamera(cam.name, rtspUrl: url);
      await rtspCam.init();
      _playerMap[cam] = rtspCam;
      return true;
    } else {
      throw UnimplementedError('Unimplemented');
    }
  }

  Future<List<Cam>> getAllowedCams() async {
    if (userModel.isAdmin) {
      return appDB.camDao.getAll();
    } else {
      final roles =
          await appDB.areaUserDao.findAllAreasByUser(userModel.user!.id!);
      final camsAllowed = roles.isNotEmpty
          ? await appDB.areaUserDao
              .findAllCamUsersByRoles(roles.map((e) => e.id!).toList())
          : <Cam>[];
      return camsAllowed;
    }
  }

  Future<Map<Room, List<Cam>>> getCamTree() async {
    Map<Room, List<Cam>> camTree = Map<Room, List<Cam>>();
    final rooms = await appDB.roomDao.getRooms();
    final roles =
        await appDB.areaUserDao.findAllAreasByUser(userModel.user!.id!);
    final camsAllowed = roles.isNotEmpty
        ? await appDB.areaUserDao
            .findAllCamUsersByRoles(roles.map((e) => e.id!).toList())
        : [];
    for (final room in rooms) {
      var cams = await appDB.roomDao.getCamsByRoom(room.id!);
      if (!userModel.isAdmin) {
        cams = cams.where((element) => camsAllowed.contains(element)).toList();
      }
      if (cams.isNotEmpty || userModel.isAdmin) {
        camTree[room] = cams;
      }
    }
    return camTree;
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

  Future<void> updateCam(Cam cam) async {
    await appDB.camDao.updateCam(cam);
    if (_playerMap.containsKey(cam)) {
      final src = _playerMap[cam]!;
      _playerMap.remove(cam);
      _playerMap[cam] = src;
    }
  }

  Future<void> deleteCam(Cam cam) {
    if (_playerMap[cam] != null) {
      _playerMap[cam]!.dispose();
    }
    _playerMap.remove(cam);
    return appDB.camDao.deleteCam(cam);
  }

  void dispose() {
    timer?.cancel();
    for (final entry in _playerMap.entries) {
      entry.value.dispose();
    }
  }

  void _onAlertTick() async {
    debugPrint("onAlertTick, check alerts in ${DateTime.now()}");
    await alertsModel
        .trigger(_playerMap.entries.where((entry) => entry.key.enableAlert));
    timer = Timer(const Duration(milliseconds: 200), _onAlertTick);
  }
}
