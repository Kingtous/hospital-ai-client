import 'package:get_it/get_it.dart';
import 'package:hospital_ai_client/base/models/app_model.dart';
import 'package:hospital_ai_client/base/models/video_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final it = GetIt.instance;

Future<void> setupDependencies() async {
  final sp = await SharedPreferences.getInstance();
  it.registerSingleton<SharedPreferences>(sp);
  it.registerSingleton<AppModel>(AppModel());
  it.registerSingleton<VideoModel>(VideoModel());
  // init
  await videoModel.init();
}

VideoModel get videoModel => it.get();
AppModel get appModel => it.get();
SharedPreferences get perf => it.get();

const kThumbNailLiveHeight = 180;
const kThumbNailLiveWidth = 320;
