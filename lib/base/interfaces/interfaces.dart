import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:hospital_ai_client/base/models/alerts_model.dart';
import 'package:hospital_ai_client/base/models/app_model.dart';
import 'package:hospital_ai_client/base/models/dao/cam.dart';
import 'package:hospital_ai_client/base/models/record_model.dart';
import 'package:hospital_ai_client/base/models/role_model.dart';
import 'package:hospital_ai_client/base/models/dao/db.dart';
import 'package:hospital_ai_client/base/models/room_model.dart';
import 'package:hospital_ai_client/base/models/user_model.dart';
import 'package:hospital_ai_client/base/models/video_model.dart';
import 'package:hospital_ai_client/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

final it = GetIt.instance;

Future<void> setupDependencies() async {
  if (!kIsWeb) {
    await windowManager.ensureInitialized();
    windowManager.setMinimumSize(const Size(1000, 720));
    windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  }
}

Future<void> setupDependenciesInApp() async {
  // fs
  final d = await path_provider.getApplicationDocumentsDirectory();
  final dir = Directory.fromUri(
      Uri.file('${d.path}\\hospital-client-pc\\', windows: true));
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  final sp = await SharedPreferences.getInstance();
  final db = await $FloorAppDB
      .databaseBuilder(kDbName)
      .addMigrations(kMigrations)
      .build();

  it.registerSingleton<AppDB>(db);
  it.registerSingleton<SharedPreferences>(sp);
  final u = UserModel();
  await u.init();
  it.registerSingleton<UserModel>(u);
  it.registerSingleton<AppModel>(AppModel());
  it.registerSingleton<VideoModel>(VideoModel(), dispose: (m) {
    m.dispose();
  });
  it.registerSingleton<AlertsModel>(AlertsModel(), dispose: (m) {
    return m.close();
  });
  final r = RoleModel();
  await r.init();
  it.registerSingleton<RoleModel>(r);
  it.registerSingleton<RoomModel>(RoomModel());
  it.registerSingleton<CamRecorder>(FFmpegCamRecorder());
  it.registerSingleton<BaseFilePicker>(FilePickerImpl());
  it.registerSingleton<RecordModel>(RecordModel());
  // init
  if (kAlertSupported) {
    kNativeAlertApi.alert_init();
  }
  await videoModel.init();
  unawaited(recordModel.refresh());
}

VideoModel get videoModel => it.get();
AppModel get appModel => it.get();
SharedPreferences get perf => it.get();
AppDB get appDB => it.get();
UserModel get userModel => it.get();
RoleModel get roleModel => it.get();
RoomModel get roomModel => it.get();
AlertsModel get alertsModel => it.get();
CamRecorder get recorder => it.get();
BaseFilePicker get filePicker => it.get();
RecordModel get recordModel => it.get();

const kThumbNailLiveHeight = 207;
const kThumbNailLiveWidth = 368;

const kAlertWidth = 640;
const kAlertHeight = 1088;
