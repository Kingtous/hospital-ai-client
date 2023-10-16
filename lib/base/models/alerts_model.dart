import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'dart:isolate';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/camera_model.dart';
import 'package:hospital_ai_client/base/models/dao/alerts.dart';
import 'package:hospital_ai_client/base/models/dao/cam.dart';
import 'package:hospital_ai_client/constants.dart';
import 'package:hospital_ai_client/generated_bindings.dart';

class AlertsModel {
  AlertsModel() {}

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
      p.ref.img.cast<Uint8>().asTypedList(p.ref.img_size);
      p = kNativeAlertApi.get_latest_alert_msg();
      // todo
    }
  }
}
