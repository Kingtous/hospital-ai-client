import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'dart:isolate';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/camera_model.dart';
import 'package:hospital_ai_client/base/models/dao/alerts.dart';
import 'package:hospital_ai_client/base/models/dao/cam.dart';
import 'package:hospital_ai_client/constants.dart';
import 'package:hospital_ai_client/generated_bindings.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as image;
import 'package:path/path.dart';

class AlertsModel {
  RxList<Alerts> rtAlertsRx = RxList<Alerts>();
  RxList<Alerts> historyAlertsRx = RxList<Alerts>();
  Timer? _timer;
  Timer? _timerDel;
  AlertsModel() {
    _timer = Timer.periodic(
        const Duration(seconds: kDebugMode ? 5 : kKeepDays), refreshAlerts);
    _timerDel = Timer.periodic(const Duration(hours: 12), (timer) async {
      final now = DateTime.now();
      final before = DateTime.fromMillisecondsSinceEpoch(
          now.millisecondsSinceEpoch - 1000 * 60 * 60 * 24 * kKeepDays);
      // 删除老的alerts
      await appDB.alertDao.deleteAlertsBefore(before.millisecondsSinceEpoch);
    });
  }

  Future<void> refreshAlerts(Timer timer) async {
    final now = DateTime.now();
    final before = DateTime.fromMillisecondsSinceEpoch(
        now.millisecondsSinceEpoch - 1000 * 60 * 60 * 24 * kKeepDays);
    final today = DateTime.fromMillisecondsSinceEpoch(
        now.millisecondsSinceEpoch - 1000 * 60 * 60 * 24);
    // 历史7天
    final lists =
        await appDB.alertDao.getAlertsFromNoImg(before.millisecondsSinceEpoch);
    rtAlertsRx.value =
        await appDB.alertDao.getAlertsFromNoImg(today.millisecondsSinceEpoch);
    historyAlertsRx.value = lists;
    if (kDebugMode) {
      print("updated alerts: " + historyAlertsRx.length.toString());
    }
  }

  Future<void> close() async {
    _timer?.cancel();
    _timerDel?.cancel();
  }

  Future<List<Alerts>> getAlertsFromTo(int st, int ed) async {
    if (userModel.isAdmin) {
      return appDB.alertDao.getAlertsFromTo(st, ed);
    } else {
      final cams = await videoModel.getAllowedCams();
      if (cams.isEmpty) {
        return [];
      } else {
        return appDB.alertDao
            .getAlertsInCamsFrom(cams.map((e) => e.id!).toList(), st, ed);
      }
    }
  }

  Future<Alerts?> getFullAlerts(int id) async {
    return appDB.alertDao.getFullAlertsById(id);
  }

  Future<Alerts?> trigger(
      Iterable<MapEntry<Cam, PlayableDevice>> devices) async {
    if (kNativeAlertApi.is_alert_ready() <= 0) {
      // 没有准备好
      return null;
    }
    for (final dev in devices) {
      if (dev.value is RTSPCamera) {
        final rtsp = dev.value as RTSPCamera;
        // 如果还没有初始化，那么就初始化一下
        if (!rtsp.inited) {
          await rtsp.init();
        } else {
          // var t = DateTime.now();
          await rtsp.postImgToAlert();
          // print(
          //     "${rtsp.id} cost: ${DateTime.now().millisecondsSinceEpoch - t.millisecondsSinceEpoch}ms");
        }
      } else {
        throw UnimplementedError('$dev 的报警还没实现');
      }
    }
    // check alerts
    var p = kNativeAlertApi.get_latest_alert_msg();
    while (p.address != 0) {
      final cams = await appDB.camDao.getCamById(p.ref.cam_id);
      await Future.microtask(() async {
        try {
          final pixels = image.Image(
            width: p.ref.width,
            height: p.ref.height,
            numChannels: 4,
          );
          final c = p.ref.img.cast<Uint8>();
          for (final pixel in pixels) {
            final x = pixel.x;
            final y = pixel.y;
            final i = (y * p.ref.stride) + (x * 4);
            pixel.b = c[i];
            pixel.g = c[i + 1];
            pixel.r = c[i + 2];
            pixel.a = c[i + 3];
          }
          final jpg = image.encodeJpg(
              image.copyResize(pixels, width: kAlertWidth),
              quality: 60);
          if (cams.isNotEmpty) {
            final cam = cams.first;
            final rooms = await appDB.roomDao.getRoomById(cam.roomId);
            if (rooms.isNotEmpty) {
              final room = rooms.first;
              Alerts newAlerts = Alerts(
                  null,
                  DateTime.now().millisecondsSinceEpoch,
                  jpg.buffer.asUint8List(),
                  p.ref.cam_id,
                  p.ref.alert_type,
                  cam.name,
                  room.id!,
                  room.roomName);
              await appDB.alertDao.insertAlert(newAlerts);
            }
          }
        } catch (e) {
          print(e);
        }
      });
      kNativeAlertApi.free_alert(p);
      p = kNativeAlertApi.get_latest_alert_msg();
    }
    return null;
  }
}
