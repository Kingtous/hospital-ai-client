import 'dart:typed_data';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hospital_ai_client/base/models/dao/alerts.dart';
import 'package:hospital_ai_client/base/models/dao/cam.dart';

const kDbVersion = 2;
const kDefaultAdminName = 'admin';
const kDefaultAdminPassword = 'admin';
const kDbName = 'cam.db';
const kHeaderHeight = 35.0;
const kDefaultName = '监控平台';

const kBgColor = Color(0xFFEFF4FA);
const kRadius = 8.0;
const kHighlightColor = Color(0xFFE0EDFF);
const kBlueColor = Color(0xFF409EFF);
const kTableGreyColor = Color(0xFFF5F7FA);

/// UI
Widget get bgImage => SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        'assets/images/bg.png',
        fit: BoxFit.cover,
      ),
    );

warning(BuildContext context, String warnText) {
  displayInfoBar(context,
      alignment: Alignment.topCenter,
      builder: (context, close) => InfoBar(
            title: Text(warnText),
            severity: InfoBarSeverity.error,
          ));
}

info(BuildContext context, String infoText) {
  displayInfoBar(context,
      alignment: Alignment.topCenter,
      builder: (context, close) => InfoBar(
            title: Text(infoText),
            severity: InfoBarSeverity.info,
          ));
}

success(BuildContext context, String infoText) {
  displayInfoBar(context,
      alignment: Alignment.topCenter,
      builder: (context, close) => InfoBar(
            title: Text(infoText),
            severity: InfoBarSeverity.success,
          ));
}

const kMockDataType = <String, int>{"未穿防护服": 2, "未消毒": 1, "擅自离岗": 3, "未戴口罩": 4};

String getRtSpStreamUrl(Cam cam, {bool mainStream = true}) {
  return "rtsp://${cam.authUser}:${cam.password}@${cam.host}:${cam.port}/Streaming/Channels/${cam.channelId}${mainStream ? '01' : '02'}";
}

String getRtspBackTrackUrl(Cam cam, DateTime start, DateTime end) {
  return "rtsp://${cam.authUser}:${cam.password}@${cam.host}:${cam.port}/Streaming/Tracks/${cam.channelId}?starttime=${start.toIso8601String()}&endtime=${end.toIso8601String()}";
}

final kMockRealtimeAlert = <Alerts>[
  Alerts(1, DateTime.now().millisecondsSinceEpoch, Uint8List(0), 1, AlertType.whiteShirt.index, '测试摄像头', 1, '教学区'),
  Alerts(1, DateTime.now().millisecondsSinceEpoch, Uint8List(0), 1, AlertType.whiteShirt.index, '测试摄像头', 1, '教学区'),
  Alerts(1, DateTime.now().millisecondsSinceEpoch, Uint8List(0), 1, AlertType.whiteShirt.index, '测试摄像头', 1, '教学区'),
  Alerts(1, DateTime.now().millisecondsSinceEpoch, Uint8List(0), 1, AlertType.whiteShirt.index, '测试摄像头', 1, '教学区'),
  Alerts(1, DateTime.now().millisecondsSinceEpoch, Uint8List(0), 1, AlertType.whiteShirt.index, '测试摄像头', 1, '教学区'),
  Alerts(1, DateTime.now().millisecondsSinceEpoch, Uint8List(0), 1, AlertType.whiteShirt.index, '测试摄像头', 1, '教学区'),
  Alerts(1, DateTime.now().millisecondsSinceEpoch, Uint8List(0), 1, AlertType.whiteShirt.index, '测试摄像头', 1, '教学区')
];
