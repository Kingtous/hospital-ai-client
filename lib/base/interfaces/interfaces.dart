import 'package:get_it/get_it.dart';
import 'package:hospital_ai_client/base/models/app_model.dart';
import 'package:hospital_ai_client/base/models/camera_model.dart';
import 'package:hospital_ai_client/base/models/video_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final it = GetIt.instance;

Future<void> setupDependencies() async {
  it.registerSingleton<AppModel>(AppModel());
  it.registerSingleton<VideoModel>(VideoModel());
  final sp = await SharedPreferences.getInstance();
  it.registerSingleton<SharedPreferences>(sp);
  videoModel.add(RTSPCamera('监控室', rtspUrl: ''));
}

VideoModel get videoModel => it.get();
AppModel get appModel => it.get();
SharedPreferences get perf => it.get();
