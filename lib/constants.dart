import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hospital_ai_client/base/models/dao/alerts.dart';
import 'package:hospital_ai_client/base/models/dao/cam.dart';
import 'package:hospital_ai_client/generated_bindings.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

const kDbVersion = 3;
const kDefaultAdminName = 'admin';
const kDefaultAdminPassword = 'admin';
const kDbName = 'cam.db';
const kHeaderHeight = 35.0;
const kDefaultName = '监控平台';
const kKeepDays = 15;
// Debug模式10s，Release模式1分钟
const kAlertIntervalMs = kDebugMode ? 10000 : 1000 * 60 * 1;
// 记得改db.g.dart
var kdbPath = "";
bool get kAlertSupported => Platform.isWindows;

const kBgColor = Color(0xFFEFF4FA);
const kRadius = 8.0;
const kHighlightColor = Color(0xFFE0EDFF);
const kBlueColor = Color(0xFF409EFF);
const kTableGreyColor = Color(0xFFF5F7FA);
const kTextColor = Color(0xFF415B73);
const kTextStyle = TextStyle(color: kTextColor);
const kContentDialogStyle = ContentDialogThemeData(
    bodyPadding: EdgeInsets.zero,
    decoration: BoxDecoration(color: Colors.transparent));
final kNativeAlertApi = NativeLibrary(DynamicLibrary.process());
final kLogger = Logger();

void kSentryLogger(
  SentryLevel level,
  String message, {
  String? logger,
  Object? exception,
  StackTrace? stackTrace,
}) {
  if (kDebugMode) {
    switch (level) {
      case SentryLevel.debug:
        kLogger.d(message);
        break;
      case SentryLevel.info:
        kLogger.i(message);
        break;
      case SentryLevel.fatal:
        kLogger.f(message);
        break;
      case SentryLevel.warning:
        kLogger.w(message);
        break;
      default:
        kLogger.i(message);
    }
  }
}

final kIsFullScreen = false.obs;

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

const kMockDataType = <AlertType, int>{
  AlertType.whiteShirt: 2,
  AlertType.other: 1
};
const kMockAlertsData = {"画面一", "画面二", "画面三", "画面四", "画面五"};

String getRtSpStreamUrl(Cam cam, {bool mainStream = true}) {
  return "rtsp://${cam.authUser}:${cam.password}@${cam.host}:${cam.port}/Streaming/Channels/${cam.channelId}${mainStream ? '01' : '02'}";
}

String paddingNum(int z) {
  if (z <= 10) {
    return "0$z";
  } else {
    return "$z";
  }
}

String toPlaybackDate(DateTime dt) {
  return "${dt.year}${paddingNum(dt.month)}${paddingNum(dt.day)}T${paddingNum(dt.hour)}${paddingNum(dt.minute)}${paddingNum(dt.second)}Z";
}

String getRtspBackTrackUrl(Cam cam, DateTime start, DateTime end) {
  return "rtsp://${cam.authUser}:${cam.password}@${cam.host}:${cam.port}/Streaming/Tracks/${cam.channelId}01?starttime=${toPlaybackDate(start)}&endtime=${toPlaybackDate(end)}";
}

final kMockRealtimeAlert = <Alerts>[
  Alerts(1, DateTime.now().millisecondsSinceEpoch, Uint8List(0), 1,
      AlertType.whiteShirt.index, '测试摄像头', 1, '教学区'),
  Alerts(1, DateTime.now().millisecondsSinceEpoch, Uint8List(0), 1,
      AlertType.whiteShirt.index, '测试摄像头', 1, '教学区'),
  Alerts(1, DateTime.now().millisecondsSinceEpoch, Uint8List(0), 1,
      AlertType.whiteShirt.index, '测试摄像头', 1, '教学区'),
  Alerts(1, DateTime.now().millisecondsSinceEpoch, Uint8List(0), 1,
      AlertType.whiteShirt.index, '测试摄像头', 1, '教学区'),
  Alerts(1, DateTime.now().millisecondsSinceEpoch, Uint8List(0), 1,
      AlertType.whiteShirt.index, '测试摄像头', 1, '教学区'),
  Alerts(1, DateTime.now().millisecondsSinceEpoch, Uint8List(0), 1,
      AlertType.whiteShirt.index, '测试摄像头', 1, '教学区'),
  Alerts(1, DateTime.now().millisecondsSinceEpoch, Uint8List(0), 1,
      AlertType.whiteShirt.index, '测试摄像头', 1, '教学区')
];

Future<Directory> getRecorderHistoryFolder() async {
  final dir = Directory.fromUri(Uri.file(
      "${(await getApplicationDocumentsDirectory()).path}/AI-RECORDER"));
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  return dir;
}

List<int> getRtLines(List<Alerts> alerts) {
  // print("getRtLines");
  List<int> lines = List.generate(12, (index) => 0);
  final now = DateTime.now();
  for (final alert in alerts) {
    final dt = DateTime.fromMillisecondsSinceEpoch(alert.createAt);
    if (now.day != dt.day) {
      continue;
    }
    // if (dt.hour == 13) {
    //   print(dt.hour);
    // }
    final hour = dt.hour ~/ 2;
    lines[hour]++;
  }
  // print(hours);
  return lines;
}
