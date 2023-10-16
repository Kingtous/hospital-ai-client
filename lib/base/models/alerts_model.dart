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
    for (final dev in devices) {
      if (dev.value is RTSPCamera) {
        final rtsp = dev.value as RTSPCamera;
        // 如果还没有初始化，那么就初始化一下
        if (!rtsp.inited) {
          await rtsp.init();
        } else {
          var t = DateTime.now();
          final screenshot = await rtsp.screenshot();
          if (screenshot != null) {
            debugPrint("AI: post_alert_img from ${rtsp.id}");
            final arr = malloc.allocate<Uint8>(screenshot.length);
            arr.asTypedList(screenshot.length).setAll(0, screenshot);
            kNativeAlertApi.post_alert_img(
                arr.cast(), screenshot.length, dev.key.id!);
          }
          print(
              "${rtsp.id} cost: ${DateTime.now().millisecondsSinceEpoch - t.millisecondsSinceEpoch}ms");
        }
      } else {
        throw UnimplementedError('$dev 的报警还没实现');
      }
    }
  }
}
