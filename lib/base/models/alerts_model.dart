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

class AlertResult {
  Uint8List? jpg;
  late int type;
  String? debugLabel;

  String toString() {
    return type == 0 ? "no alert found" : "alert_type: $type, $debugLabel";
  }
}

class AlertsModel {
  RxList<Alerts> rtAlertsRx = RxList<Alerts>();
  RxList<Alerts> historyAlertsRx = RxList<Alerts>();
  Timer? _timer;
  Timer? _timerDel;
  DateTime? _refreshedDateTime;

  AlertsModel() {
    _timer = Timer.periodic(
        const Duration(seconds: kDebugMode ? 5 : kKeepDays), refreshAlerts);
    _timerDel = Timer.periodic(const Duration(hours: 1), (timer) async {
      final now = DateTime.now();
      final before = DateTime.fromMillisecondsSinceEpoch(
          now.millisecondsSinceEpoch - 1000 * 60 * 60 * 24 * kKeepDays);
      // 删除老的alerts
      await appDB.alertDao.deleteAlertsBefore(before.millisecondsSinceEpoch);
    });
  }

  Future<void> refreshAlerts(Timer timer) async {
    final now = DateTime.now();
    final before = _refreshedDateTime ??
        DateTime.fromMillisecondsSinceEpoch(
            now.millisecondsSinceEpoch - 1000 * 60 * 60 * 24 * kKeepDays);
    final today = DateTime.fromMillisecondsSinceEpoch(
        now.millisecondsSinceEpoch - 1000 * 60 * 60 * 24);
    // 历史7天
    // var dt = DateTime.now();
    final lists =
        await appDB.alertDao.getAlertsFromNoImg(before.millisecondsSinceEpoch);
    // print("query cost history: ${DateTime.now().difference(dt)}");
    // kLogger.d("query cost history: ${DateTime.now().difference(dt)}");
    // dt = DateTime.now();
    rtAlertsRx.value =
        await appDB.alertDao.getAlertsFromNoImg(today.millisecondsSinceEpoch);
    if (_refreshedDateTime == null) {
      historyAlertsRx.value = lists;
    } else {
      historyAlertsRx.addAll(lists);
    }
    // if (kDebugMode) {
    //   print("updated alerts: ${historyAlertsRx.length}");
    // }
    _refreshedDateTime = DateTime.now();
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
      kLogger.i('alert: AI模型正在初始化');
      return null;
    }
    final dt = DateTime.now();
    var cnt = 0;
    var scanCnt = 0;
    for (final dev in devices) {
      if (dev.value is RTSPCamera) {
        final rtsp = dev.value as RTSPCamera;
        // 如果还没有初始化，那么就初始化一下
        if (!rtsp.inited) {
          kLogger.i("init rtsp: ${rtsp.rtspUrl}");
          await rtsp.init();
        } else {
          final result = await rtsp.postImgToAlert();
          // if (kDebugMode) {
          //   kLogger.i('检测 ${dev.key.name}, $result');
          // }
          // print(
          //     "${rtsp.id} cost: ${DateTime.now().millisecondsSinceEpoch - t.millisecondsSinceEpoch}ms, ${result.toString()}");
          scanCnt++;
          if (result?.type != 0) {
            final rooms = await appDB.roomDao.getRoomById(dev.key.roomId);
            if (rooms.isNotEmpty) {
              final room = rooms.first;
              Alerts newAlerts = Alerts(
                  null,
                  DateTime.now().millisecondsSinceEpoch,
                  result!.jpg,
                  dev.key.id!,
                  result.type,
                  dev.key.name,
                  room.id!,
                  room.roomName);
              await appDB.alertDao.insertAlert(newAlerts);
              cnt += 1;
            }
          }
        }
      } else {
        throw UnimplementedError('$dev 的报警还没实现');
      }
    }
    kLogger.i(
        "${dt.toIso8601String()} - scaned, found ${cnt}/${scanCnt} alerts, cost: ${DateTime.now().difference(dt).inMilliseconds}ms");
    // check alerts
    // var p = kNativeAlertApi.get_latest_alert_msg();
    // while (p.address != 0) {
    //   final cams = await appDB.camDao.getCamById(p.ref.cam_id);
    //   await Future.microtask(() async {
    //     try {
    //       final pixels = image.Image(
    //         width: p.ref.width,
    //         height: p.ref.height,
    //         numChannels: 4,
    //       );
    //       final c = p.ref.img.cast<Uint8>();
    //       for (final pixel in pixels) {
    //         final x = pixel.x;
    //         final y = pixel.y;
    //         final i = (y * p.ref.stride) + (x * 4);
    //         pixel.b = c[i];
    //         pixel.g = c[i + 1];
    //         pixel.r = c[i + 2];
    //         pixel.a = c[i + 3];
    //       }
    //       final jpg = image.encodeJpg(
    //           image.copyResize(pixels, width: kAlertWidth),
    //           quality: 60);
    //       if (cams.isNotEmpty) {
    //         final cam = cams.first;
    //         final rooms = await appDB.roomDao.getRoomById(cam.roomId);
    //         if (rooms.isNotEmpty) {
    //           final room = rooms.first;
    //           Alerts newAlerts = Alerts(
    //               null,
    //               DateTime.now().millisecondsSinceEpoch,
    //               jpg.buffer.asUint8List(),
    //               p.ref.cam_id,
    //               p.ref.alert_type,
    //               cam.name,
    //               room.id!,
    //               room.roomName);
    //           await appDB.alertDao.insertAlert(newAlerts);
    //         }
    //       }
    //     } catch (e) {
    //       debugPrintStack();
    //       print(e);
    //     }
    //   });
    //   kNativeAlertApi.free_alert(p);
    //   p = kNativeAlertApi.get_latest_alert_msg();
    // }
    // return null;
  }
}
